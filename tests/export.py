#!/usr/bin/env python3
"""اختبار المصدّر: هل SQL المولّد بيعكس الـJSON بأمانة؟

الفكرة: بدل ما نصدّق العدّادات يلي بيطبعها المصدّر، منحمّل الناتج
بـPostgres حقيقي ومنقارن كل صف بمصدره.
"""
import json, glob, subprocess, sys, tempfile, os
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PORT = os.environ.get('PGPORT', '5433')
R = []


def check(label, cond):
    R.append((label, bool(cond)))
    print(f"  {'✓' if cond else '✗'} {label}")


def psql(q, db='telc'):
    p = subprocess.run(
        ['psql', '-h', '/tmp', '-p', PORT, '-U', 'postgres', '-d', db,
         '-tAq', '-v', 'ON_ERROR_STOP=1', '-c', q],
        capture_output=True, text=True)
    if p.returncode:
        raise RuntimeError(p.stderr.strip()[:400])
    lines = [l.strip() for l in p.stdout.strip().split('\n') if l.strip()]
    return lines[-1] if lines else ''


print('\n=== المصدّر: JSON ← SQL ← قاعدة بيانات ===')

# ---- ١) التوليد ----
out = Path(tempfile.mkdtemp()) / 'b1.sql'
p = subprocess.run([sys.executable, str(ROOT / 'tools/export_sql.py'),
                    str(ROOT / 'data'), str(out), '--level', 'b1'],
                   capture_output=True, text=True)
check(f'التوليد نجح ({p.returncode})', p.returncode == 0 and out.exists())

# ---- ٢) المصدر ----
src = {}
for f in sorted(glob.glob(str(ROOT / 'data/modell-*.json'))):
    d = json.load(open(f))
    src[d['id']] = d
n_sec = sum(len(d['sections']) for d in src.values())
n_it = sum(len(s.get('items', [])) for d in src.values() for s in d['sections'])
n_ans = sum(1 for d in src.values() for s in d['sections']
            for i in s.get('items', []) if 'answer' in i)

# ---- ٣) العدّ الفعلي بقاعدة البيانات ----
# العدّ محصور بالمستوى يلي صدّرناه. اختبارات تانية بتضيف امتحانات
# لمستويات تانية، وعدّ الكل بيقارن أشياء مو متقابلة.
B1 = "join sections s on s.id = i.section_id join tests t on t.id = s.test_id" \
     " where t.level_id = 'b1'"
db = {
    'tests': int(psql("select count(*) from tests where level_id = 'b1';")),
    'sections': int(psql("select count(*) from sections s join tests t"
                         " on t.id = s.test_id where t.level_id = 'b1';")),
    'items': int(psql(f"select count(*) from items i {B1};")),
    'item_answers': int(psql("select count(*) from item_answers ia"
                             " join items i on i.id = ia.item_id"
                             f" {B1};")),
}
check(f'الامتحانات: {len(src)} ← {db["tests"]}', db['tests'] == len(src))
check(f'الأقسام: {n_sec} ← {db["sections"]}', db['sections'] == n_sec)
check(f'الأسئلة: {n_it} ← {db["items"]}', db['items'] == n_it)
check(f'الحلول: {n_ans} ← {db["item_answers"]}', db['item_answers'] == n_ans)

# ---- ٤) ★ ولا حل تسرّب لجدول الأسئلة ----
leaked = int(psql("""select count(*) from items
  where options::text ilike '%"answer"%' or text ilike '%"answer":%';"""))
check('★ ولا حل بجدول الأسئلة', leaked == 0)
check('★ جدول الأسئلة ما فيه عمود answer',
      psql("""select count(*) from information_schema.columns
              where table_name='items' and column_name='answer';""") == '0')

# ---- ٥) مقارنة صف بصف على عيّنة ----
mismatch = []
for slug in ('modell-01', 'modell-08', 'modell-16'):
    d = src[slug]
    for s in d['sections']:
        got = psql(f"""select coalesce(jsonb_agg(jsonb_build_object(
                   'id', i.item_id, 'text', i.text, 'a', ia.answer)
                   order by i.sort), '[]'::jsonb)
                 from items i
                 left join item_answers ia on ia.item_id = i.id
                 join sections sec on sec.id = i.section_id
                 join tests t on t.id = sec.test_id
                where t.slug = '{slug}' and sec.section_id = '{s['id']}';""")
        rows = json.loads(got)
        if len(rows) != len(s.get('items', [])):
            mismatch.append(f"{slug}/{s['id']}: عدد {len(s['items'])} ← {len(rows)}")
            continue
        for a, b in zip(s.get('items', []), rows):
            if str(a['id']) != str(b['id']):
                mismatch.append(f"{slug}/{s['id']}: رقم {a['id']} ← {b['id']}")
            if (a.get('text') or '') != (b.get('text') or ''):
                mismatch.append(f"{slug}/{s['id']}/{a['id']}: النص اختلف")
            if a.get('answer') != b.get('a'):
                mismatch.append(f"{slug}/{s['id']}/{a['id']}: الحل {a.get('answer')} ← {b.get('a')}")
for m in mismatch[:5]:
    print(f'      {m}')
check(f'٣ امتحانات: كل سؤال وحله مطابق ({len(mismatch)} فرق)', not mismatch)

# ---- ٦) إعادة التحميل ما بتكرّر ----
before = db['items']
subprocess.run(['psql', '-h', '/tmp', '-p', PORT, '-U', 'postgres', '-d', 'telc',
                '-q', '-v', 'ON_ERROR_STOP=1', '-f', str(out)],
               capture_output=True, text=True)
after = int(psql(f"select count(*) from items i {B1};"))
check(f'إعادة التحميل ما كرّرت ({before} ← {after})', before == after)

# ---- ٧) العدّ المخزّن يطابق الحقيقي ----
bad = psql("""select count(*) from tests t
  where t.level_id = 'b1' and t.aufgaben <>
  (select count(*) from items i join sections s on s.id = i.section_id
    where s.test_id = t.id);""")
check(f'عمود aufgaben مطابق للعدّ الحقيقي ({bad} مخالف)', bad == '0')

fails = [x for x in R if not x[1]]
print(f"\n{'✗ ' + str(len(fails)) + ' فشل من ' + str(len(R)) if fails else '✓ كل الـ' + str(len(R)) + ' اختبارات نجحت'}")
sys.exit(1 if fails else 0)
