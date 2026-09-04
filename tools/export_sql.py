#!/usr/bin/env python3
"""ترحيل data/*.json لـSQL بذر (seed) لقاعدة Supabase.

الفكرة المركزية: مفاتيح الحلول بتنفصل عن الأسئلة. items ما فيه عمود answer —
الحلول بتروح لـitem_answers، وهاد الجدول مقفول على العميل بالكامل.

    python3 tools/export_sql.py data supabase/seed/b1.sql --level b1

الناتج يعاد تشغيله بأمان (idempotent): كل insert عليه on conflict do update،
والمفاتيح الطبيعية هي (level, slug) للامتحان و(test, section_id) للقسم وهكذا.
"""
import json, sys, argparse
from pathlib import Path

# الحقول يلي بتنحفظ بـsections.config بدل أعمدة لحالها
CONFIG_KEYS = ('bank', 'bankTitle', 'bankImage', 'passages', 'note', 'brief',
               'hints', 'criteria', 'grades', 'factor', 'maxPoints',
               'availablePoints', 'missing', 'pointsPerItem')


def q(v):
    """قيمة نصّية كـliteral آمن."""
    if v is None:
        return 'null'
    return "'" + str(v).replace("'", "''") + "'"


def qj(v):
    """قيمة jsonb."""
    if v is None:
        return 'null::jsonb'
    return q(json.dumps(v, ensure_ascii=False)) + '::jsonb'


def qn(v, default='1'):
    """رقم."""
    return default if v is None else str(v)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('src', help='مجلد data')
    ap.add_argument('out', help='ملف SQL الناتج')
    ap.add_argument('--level', default='b1')
    ap.add_argument('--level-title', default='telc Deutsch B1')
    a = ap.parse_args()

    src = Path(a.src)
    index = json.loads((src / 'index.json').read_text())
    L = a.level

    o = []
    w = o.append
    w(f"-- مولّد من {a.src} بـtools/export_sql.py — لا تعدّله بالإيد")
    w("begin;")
    w("")
    w("insert into levels (id, title, sort, published) values "
      f"({q(L)}, {q(a.level_title)}, 0, true)")
    w("on conflict (id) do update set title = excluded.title;")

    n_tests = n_sections = n_items = n_answers = 0

    for meta in index['modelle']:
        d = json.loads((src / meta['file']).read_text())
        slug = d['id']
        n_tests += 1

        w("")
        w(f"-- ================= {slug} · {d.get('title','')} =================")
        w("insert into tests (level_id, slug, title, subtitle, blocks, aufgaben,"
          " published, sort)")
        w(f"values ({q(L)}, {q(slug)}, {q(d.get('title'))}, {q(d.get('subtitle'))},")
        w(f"        {qj(d.get('blocks', []))}, {meta.get('aufgaben', 0)}, true, {n_tests})")
        w("on conflict (level_id, slug) do update set"
          " title = excluded.title, subtitle = excluded.subtitle,"
          " blocks = excluded.blocks, aufgaben = excluded.aufgaben,"
          " sort = excluded.sort;")

        # ---- الأقسام ----
        rows = []
        for i, s in enumerate(d['sections']):
            cfg = {k: s[k] for k in CONFIG_KEYS if k in s}
            rows.append(
                f"    ({q(s['id'])}, {q(s.get('group'))}, {q(s.get('title'))}, "
                f"{qn(s.get('minutes'), 'null')}, {q(s.get('instruction'))}, "
                f"{q(s['format'])}, {qj(cfg)}, {i})")
            n_sections += 1
        w("")
        w('insert into sections (test_id, section_id, "group", title, minutes,'
          ' instruction, format, config, sort)')
        w("select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction,"
          " v.format, v.config, v.sort")
        w("from (values")
        w(",\n".join(rows))
        w(") as v(section_id, grp, title, minutes, instruction, format, config, sort)")
        w(f"join tests t on t.level_id = {q(L)} and t.slug = {q(slug)}")
        w("on conflict (test_id, section_id) do update set"
          ' "group" = excluded."group", title = excluded.title,'
          " minutes = excluded.minutes, instruction = excluded.instruction,"
          " format = excluded.format, config = excluded.config,"
          " sort = excluded.sort;")

        # ---- الأسئلة (بدون حلول) ----
        irows, arows = [], []
        for s in d['sections']:
            ppi = s.get('pointsPerItem')
            for j, it in enumerate(s.get('items', [])):
                # writing: points هي قائمة نقاط مطلوبة مو علامة رقمية
                extra = {k: it[k] for k in ('minWords', 'points')
                         if k in it and s['format'] == 'writing'}
                pts = qn(ppi) if s['format'] != 'writing' else '0'
                irows.append(
                    f"    ({q(s['id'])}, {q(it['id'])}, {q(it.get('text'))}, "
                    f"{qj(it.get('options'))}, {pts}, "
                    f"{qj(extra or None)}, {j})")
                n_items += 1
                if 'answer' in it:
                    arows.append(
                        f"    ({q(s['id'])}, {q(it['id'])}, {q(it['answer'])}, "
                        f"{q(it.get('explain'))})")
                    n_answers += 1

        w("")
        w("insert into items (section_id, item_id, text, options, points, meta, sort)")
        w("select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort")
        w("from (values")
        w(",\n".join(irows))
        w(") as v(section_id, item_id, text, options, points, meta, sort)")
        w(f"join tests t on t.level_id = {q(L)} and t.slug = {q(slug)}")
        w("join sections s on s.test_id = t.id and s.section_id = v.section_id")
        w("on conflict (section_id, item_id) do update set"
          " text = excluded.text, options = excluded.options,"
          " points = excluded.points, meta = excluded.meta, sort = excluded.sort;")

        # ---- الحلول (الجدول المقفول) ----
        w("")
        w("insert into item_answers (item_id, answer, explanation)")
        w("select i.id, v.answer, v.explanation")
        w("from (values")
        w(",\n".join(arows))
        w(") as v(section_id, item_id, answer, explanation)")
        w(f"join tests t on t.level_id = {q(L)} and t.slug = {q(slug)}")
        w("join sections s on s.test_id = t.id and s.section_id = v.section_id")
        w("join items i on i.section_id = s.id and i.item_id = v.item_id")
        w("on conflict (item_id) do update set"
          " answer = excluded.answer, explanation = excluded.explanation;")

    w("")
    w("commit;")

    out = Path(a.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text("\n".join(o) + "\n")

    print(f"✓ {out}")
    print(f"  {n_tests} امتحان · {n_sections} قسم · {n_items} سؤال · {n_answers} حل")
    print(f"  {n_items - n_answers} سؤال بلا حل (تعبير كتابي — متوقّع)")


if __name__ == '__main__':
    main()
