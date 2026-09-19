#!/usr/bin/env python3
"""بيقارن حلول telc B1 المخزّنة بمفتاح الحلول المطبوع بالكتاب.

    python3 tools/check_keys.py                      # الكتاب اللي بالمستودع
    python3 tools/check_keys.py --feed <مجلّد>       # ومعه ملفّات النماذج المفردة
    python3 tools/check_keys.py --show               # كل المطابقات، مو بس الفروق

★ المفتاح مرجع، مو حَكَم. الكتاب من إعداد مجموعة تدريس مو من telc، وفيه
  أغلاط مثبتة (حلّ «trotz» بمطرح ما بيصحّ فيه إلا «trotzdem»، حلّ «langer»
  بدل «lange»…). فكل فرق مقصود مكتوب بـDoku/loesungen-abweichungen.json
  ومعه سببه من النصّ. الفرق يلي مو مكتوب هونيك بيفشّل الفحص — يعني إمّا
  حدا غيّر حلّ بلا سبب، أو المحتوى انبنى من جديد وانزاح.

الحدّ: بيغطّي telc B1 بس (هو الوحيد اللي إله كتاب بالمستودع).
"""
import sys, os, re, json, glob, argparse

RANGES = [('lv1',1,5), ('lv2',6,10), ('lv3',11,20), ('sb1',21,30), ('sb2',31,40),
          ('hv1',41,45), ('hv2',46,55), ('hv3',56,60)]
BOOK = 'Doku/B1 Telc.pdf'
ALLOW = 'Doku/loesungen-abweichungen.json'


def parse_key(txt):
    """«21 c» · «41 +» · «35 D GEEIGNET» → {21:'c', 41:'r', 35:'D'} مع الكلمات"""
    out, words = {}, {}
    for m in re.finditer(r'(?<![\d])(\d{1,2})\s*[\.\)]?\s*([A-Za-zÄÖÜ]\b|[+\-–—])', txt):
        n, v = int(m.group(1)), m.group(2)
        if not 1 <= n <= 60 or n in out: continue
        out[n] = 'r' if v == '+' else 'f' if v in '-–—' else v
    for m in re.finditer(r'(?<![\d])(\d{1,2})\s*[\.\)]?\s*([A-Za-zÄÖÜ])\b[ \t]*\n?[ \t]*'
                         r'([A-Za-zÄÖÜäöüß][\wÄÖÜäöüß]{2,}(?:\s+[A-ZÄÖÜ]{3,})?)', txt):
        n = int(m.group(1))
        if 1 <= n <= 60 and n not in words: words[n] = m.group(3).strip()
    return out, words


def resolve(key_letter, key_word, options):
    """الكلمة هي الحكم لما تكون موجودة — ترتيب الحروف بالكتاب ممكن يختلف."""
    if key_word:
        w = key_word.strip()
        for pred in (lambda t: t == w,
                     lambda t: t.lower() == w.lower(),
                     lambda t: t.lower().startswith(w.lower()) and len(w) >= 5):
            hit = [k for k, t in options.items() if pred((t or '').strip())]
            if len(hit) == 1: return hit[0]
            if len(hit) > 1: break
    return key_letter


def load_app():
    app = {}
    for f in sorted(glob.glob('data/modell-*.json')):
        m = os.path.basename(f)[:-5].replace('modell-', '')
        d = json.load(open(f, encoding='utf-8'))
        secs, ans = {s['id']: s for s in d['sections']}, {}
        for sid, a, b in RANGES:
            s = secs.get(sid)
            if not s: continue
            for it, n in zip(s['items'], range(a, b + 1)):
                opts = {o['key']: o['text'] for o in (it.get('options') or [])} or \
                       {o['key']: o['text'] for o in (s.get('bank') or [])}
                ans[n] = (sid, it.get('answer'), opts)
        app[m] = ans
    return app


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--feed', default=None, help='مجلّد ملفّات النماذج المفردة')
    ap.add_argument('--show', action='store_true')
    a = ap.parse_args()
    # ★ pymupdf بيقرا صفحة المفتاح بترتيب أقرب للمطبوع، فربط «الرقم ←
    #   الكلمة» بيطلع صح. pypdf بيخلط الترتيب وبيضيّع الربط. منفضّل الأول
    #   ومنرجع للتاني لو مو مثبّت — ومنقول أيّهما اشتغل.
    reader = None
    try:
        import pymupdf
        reader = lambda f: [pg.get_text() or '' for pg in pymupdf.open(f)]
        engine = 'pymupdf'
    except ImportError:
        try:
            import pypdf
            reader = lambda f: [pg.extract_text() or '' for pg in pypdf.PdfReader(f).pages]
            engine = 'pypdf (ربط الكلمات أضعف)'
        except ImportError:
            sys.exit('✗ لازم pymupdf أو pypdf')
    if not os.path.exists(BOOK): sys.exit(f'✗ ما في {BOOK}')

    app = load_app()
    pdfs = [BOOK] + ([os.path.join(a.feed, f) for f in sorted(os.listdir(a.feed))
                      if f.lower().endswith('.pdf')] if a.feed else [])
    # أفضل مفتاح لكل نموذج = يلي أعلى تطابق
    best = {}
    for path in pdfs:
        try: pages = reader(path)
        except Exception: continue
        for i, t in enumerate(pages):
            if 'ösungen' not in t and 'osungen' not in t: continue
            k, w = parse_key(t)
            if len(k) < 40: continue
            for m, ans in app.items():
                both = [n for n in k if n in ans and ans[n][1]]
                if len(both) < 30: continue
                hit = sum(1 for n in both
                          if str(ans[n][1]).lower() ==
                             str(resolve(k[n], w.get(n), ans[n][2])).lower())
                sc = hit / len(both)
                # ★ حدّ أدنى للثقة. بلاه، نموذج ما إله مفتاح بهالكتاب بيتلزق
                #   بمفتاح نموذج تاني وبيطلع ٦٠ «فرق» كذب. المفتاح الصح
                #   بيطابق ٩٠٪ وفوق؛ أي شي تحت ٨٥٪ مو مفتاحه.
                if sc >= 0.85 and (m not in best or sc > best[m][0]):
                    best[m] = (sc, k, w, f'{os.path.basename(path)} ص{i+1}')

    allow = {(x['m'], x['teil'], x['nr']) for x in
             json.load(open(ALLOW, encoding='utf-8'))['abweichungen']} \
            if os.path.exists(ALLOW) else set()

    diffs, known = [], 0
    for m in sorted(best):
        sc, k, w, origin = best[m]
        for n, (sid, cur, opts) in sorted(app[m].items()):
            if n not in k or not cur: continue
            truth = resolve(k[n], w.get(n), opts)
            truth = truth.lower() if sid.startswith('hv') else truth
            if str(cur).lower() == str(truth).lower():
                if a.show: print(f'  ✓ {m} {sid} {n}: {cur}')
                continue
            if (m, sid, n) in allow: known += 1; continue
            diffs.append((m, sid, n, cur, opts.get(cur, '')[:30],
                          truth, opts.get(truth, '')[:30], origin))

    missing = sorted(set(app) - set(best))
    print(f'محرّك القراءة: {engine}')
    print(f'مغطّى {len(best)} نموذج من {len(app)} · {known} مخالفة موثّقة')
    if missing:
        print(f'· بلا مفتاح بهالكتاب: {", ".join(missing)} — ما انفحصوا')
    if diffs:
        print('\n✗ فروق مو مكتوبة بـDoku/loesungen-abweichungen.json:')
        for m, sid, n, cur, ct, tr, tt, org in diffs:
            print(f'   نموذج {m} · {sid} · سؤال {n}:  المخزّن {cur} {ct}   ≠   الكتاب {tr} {tt}   [{org}]')
        return 1
    print('✓ كل حلّ إمّا مطابق للكتاب أو مخالفته موثّقة بسببها.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
