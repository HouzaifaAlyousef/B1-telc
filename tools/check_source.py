#!/usr/bin/env python3
"""بيقارن المحتوى المستخرَج بالكتاب الأصلي، وبيميّز بين نوعين من التكرار.

    python3 tools/check_source.py "Doku/B1 Telc.pdf" data
    python3 tools/check_source.py "<كتاب.pdf>" content/oesd/a1
    python3 tools/check_source.py "<كتاب.pdf>" data --show      # الجدول كامل

★ السؤال اللي بتجاوب عليه:
  تكرار نصّ بين نموذجين — هل هو من الكتاب، ولا من استخراج غلط؟

  الكتاب مرتّب: كل نموذج بياخد شريط صفحات متتالية (١٠ صفحات تقريباً)،
  وأقسامه بتيجي بالترتيب lv1 → lv2 → … → hv3. من هون بيطلع المعيار:

    · القسم وقع **جوّا** شريط نموذجه  →  هيدي صفحته. لو نموذج تاني كمان
      وقع جوّا شريطه هو وطلع النصّ نفسه — **الكتاب معيد النصّ.** طبيعي.

    · القسم وقع **برّا** شريط نموذجه، وجوّا شريط نموذج تاني  →  الاستخراج
      أخد صفحة الغلط. **عطب**، والصفحة الصحيحة لسا بالكتاب.

  يعني الفرق مو بالنصّ — بمطرحه.

الحدّ: بده الكتاب الأصلي PDF فيه نصّ (مو صور مسحوبة scan بلا OCR).
"""
import sys, os, re, json, glob, statistics, argparse, collections

SPAN = 8          # نصف عرض شريط النموذج بالصفحات
HIT  = 0.35       # أدنى تطابق تا نقول «هالقسم من هالصفحة»


def norm(s):
    s = (s or '').lower()
    s = re.sub(r'[^\wäöüß]+', ' ', s, flags=re.U)
    return re.sub(r'\s+', ' ', s).strip()


def grams(text):
    w = text.split()
    return set(zip(w, w[1:]))


def section_text(sec):
    """نصّ القسم: الفقرات والبنك والأسئلة وخياراتها."""
    parts = []
    for pa in sec.get('passages') or []:
        for p in pa.get('paragraphs') or []:
            parts.append(norm(p.get('t')))
    for o in sec.get('bank') or []:
        parts.append(norm(o.get('text')))
    for it in sec.get('items') or []:
        parts.append(norm(it.get('text')))
        for o in it.get('options') or []:
            parts.append(norm(o.get('text')))
    return ' '.join(x for x in parts if x)


def load_models(src):
    """data/*.json أو content/<مؤسسة>/<درجة>/modell-*/text.txt"""
    out = {}
    if os.path.isdir(src) and glob.glob(os.path.join(src, 'modell-*.json')):
        for f in sorted(glob.glob(os.path.join(src, 'modell-*.json'))):
            d = json.load(open(f, encoding='utf-8'))
            out[os.path.basename(f)[:-5].replace('modell-', '')] = d.get('sections') or []
        return out
    import subprocess
    node = ('const fs=require("fs"),M=require("./admin/parse.js");const o={};'
            'for (const m of fs.readdirSync(process.argv[1]).filter(d=>d.startsWith("modell-"))){'
            ' const f=`${process.argv[1]}/${m}/text.txt`; if(!fs.existsSync(f)) continue;'
            ' o[m.replace("modell-","")]=M.parse(fs.readFileSync(f,"utf8")).test.sections;}'
            'process.stdout.write(JSON.stringify(o));')
    r = subprocess.run(['node', '-e', node, src], capture_output=True, text=True)
    if r.returncode:
        sys.exit(f'✗ ما قدرت أقرا {src}:\n{r.stderr[:300]}')
    return json.loads(r.stdout)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('pdf'); ap.add_argument('src')
    ap.add_argument('--show', action='store_true', help='اعرض الجدول كامل')
    a = ap.parse_args()

    try:
        import pypdf
    except ImportError:
        sys.exit('✗ لازم pypdf:  pip install pypdf')
    if not os.path.exists(a.pdf):
        sys.exit(f'✗ ما في {a.pdf}')

    pages = []
    for p in pypdf.PdfReader(a.pdf).pages:
        pages.append(grams(norm(p.extract_text() or '')))
    if sum(1 for p in pages if p) < len(pages) / 4:
        sys.exit('✗ الكتاب صور بلا نصّ — الأداة بدها PDF فيه نصّ قابل للنسخ.')

    models = load_models(a.src)
    order, best = [], {}
    for m, secs in models.items():
        for s in secs:
            if s.get('format') == 'writing':
                continue
            if s['id'] not in order:
                order.append(s['id'])
            g = grams(section_text(s))
            if len(g) < 25:            # قسم بلا نصّ (صورة/صوت) — ما بينقارن
                continue
            pg, cov = max(((i + 1, len(g & q) / len(g)) for i, q in enumerate(pages) if q),
                          key=lambda x: x[1], default=(0, 0.0))
            if cov >= HIT:
                best[(m, s['id'])] = pg

    # ★ شريط كل نموذج.
    #   الوسيط لحاله ما بيكفي: لو نصّ أقسام النموذج أخدوا صفحات غلط،
    #   الوسيط بينجرّ معهن ويصير الشريط نفسه غلط — وقتها الأداة بتبرّئ
    #   الأقسام المغلوطة وبتتّهم السليمة. منستعمل ترتيب الكتاب كمرساة:
    #   جوّا النموذج، الأقسام بتيجي lv1 → lv2 → … → hv3 وصفحاتها بتزيد.
    #   الشريط الصح هو يلي بيجمع أكبر عدد أقسام **بترتيبها الصحيح**.
    rank = {s: i for i, s in enumerate(order)}

    def score(m, anchor):
        got = sorted(((best[(m, s)], rank[s]) for s in order
                      if (m, s) in best and abs(best[(m, s)] - anchor) <= SPAN))
        if not got:
            return (0, 0)
        asc = sum(1 for i in range(1, len(got)) if got[i][1] > got[i - 1][1])
        return (len(got), asc)          # عدد الأقسام، وكم منهن بالترتيب

    home = {}
    for m in models:
        ps = sorted({p for (mm, _), p in best.items() if mm == m})
        if len(ps) < 4:
            continue
        home[m] = max(ps, key=lambda a: score(m, a))

    if a.show:
        print(f"{'نموذج':7} " + ' '.join(f'{s:>6}' for s in order) + '   شريطه')
        print('─' * (9 + 7 * len(order) + 12))
        for m in sorted(models):
            row = ' '.join(f"{best.get((m, s), '—'):>6}" for s in order)
            h = f"{int(home[m])-SPAN}–{int(home[m])+SPAN}" if m in home else '؟'
            print(f'{m:7} {row}   {h}')
        print()

    strays, natural = [], []
    for (m, s), p in sorted(best.items()):
        if m not in home:
            continue
        if abs(p - home[m]) <= SPAN:
            continue
        owner = sorted(x for x in home if abs(p - home[x]) <= SPAN and x != m)
        strays.append((m, s, p, owner))

    # ★ وقسم جوّا الشريط بس مو بترتيبه مشبوه كمان: بالكتاب lv3 ما بتيجي
    #   قبل lv1. غالباً أخد صفحة الجزء نفسه من نموذج الجار.
    for m in sorted(home):
        got = [(best[(m, s)], s) for s in order if (m, s) in best
               and abs(best[(m, s)] - home[m]) <= SPAN]
        got.sort(key=lambda x: rank[x[1]])
        for i in range(1, len(got)):
            if got[i][0] < got[i - 1][0]:
                strays.append((m, got[i][1], got[i][0], ['؟ الترتيب']))

    # تكرار طبيعي: نموذجين كل واحد بشريطه، ونصّ صفحتيهن متشابه
    inside = collections.defaultdict(list)
    for (m, s), p in best.items():
        if m in home and abs(p - home[m]) <= SPAN:
            inside[s].append((m, p))
    for s, lst in inside.items():
        for i in range(len(lst)):
            for j in range(i + 1, len(lst)):
                (m1, p1), (m2, p2) = lst[i], lst[j]
                if p1 == p2:
                    continue
                g1, g2 = pages[p1 - 1], pages[p2 - 1]
                if g1 and g2 and len(g1 & g2) / len(g1 | g2) >= 0.55:
                    natural.append((s, m1, p1, m2, p2))

    if natural:
        print('✓ تكرار من الكتاب نفسه — كل نموذج أخد صفحته، والكتاب معيد النصّ:')
        for s, m1, p1, m2, p2 in sorted(natural):
            print(f'   {s}: نموذج {m1} (ص {p1})  ≡  نموذج {m2} (ص {p2})')
        print()

    if strays:
        print('✗ استخراج غلط — القسم أخد صفحة نموذج تاني:')
        for m, s, p, owner in strays:
            who = ('صفحة نموذج ' + '/'.join(owner)) if owner else 'صفحة برّا كل الشرائط'
            lo, hi = int(home[m]) - SPAN, int(home[m]) + SPAN
            print(f'   نموذج {m} · {s:4} ← ص {p}  ({who})   شريطه {lo}–{hi}')
        print(f'\n{len(strays)} قسم لازم ينعاد استخراجه من شريط نموذجه.')
        return 1

    print('✓ ولا قسم أخد صفحة نموذج تاني.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
