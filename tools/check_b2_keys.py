#!/usr/bin/env python3
"""بيقارن حلول telc B2 المخزّنة بالحلول المطبوعة بملفّ المصدر.

    python3 tools/check_b2_keys.py                 # المصدر من تاريخ المستودع
    python3 tools/check_b2_keys.py --pdf <ملف>     # ملف مصدر تاني
    python3 tools/check_b2_keys.py --show          # كل المطابقات، مو بس الفروق

★ مصدر B2 مو متل كتاب B1: ما فيه صفحة مفتاح بالآخر. الحلول مدسوسة جوّا
  التمرين نفسه — «10. Gabi - d» بـLesen Teil 3، و«46 (e- sicher)» بـ
  Sprachbausteine. يعني المفتاح موجود لأربع أقسام بس:

      lv1 · lv3 · sb1 · sb2      ← فيها حلول مطبوعة، منفحصها هون
      lv2 · lv4 · lvs1           ← ما فيها ولا حلّ مطبوع بالمصدر كلّه

  أقسام الـ«ما فيها» انفحصت بالقراءة، وما بينفحصوا آلياً. الأداة بتقول
  كم سؤال غطّت وكم ضلّ برّا، حتى ما حدا يقرا «✓» ويفكّر إنّه فحص الكل.

★ الأرقام والحروف بالمصدر مكتوبة بخليط لاتيني-كيريلي (الـ«с» بـ«3. Anka
  с» كيريلية مو لاتينية). بلا توحيدهن بيطلع فرق كذب بكل سؤال حرفه بيشبه
  حرف روسي.
"""
import sys, os, re, json, glob, subprocess, argparse

# الافتراضي: المصدر مشال من الشجرة (كبير)، فمنجيبه من التاريخ عند الحاجة
SRC_IN_GIT = 'Doku/feed pdf/Alle Informati B2 от 27.04.2026.pdf'
CONTENT    = 'content/telc/b2'
ALLOW      = 'Doku/b2-abweichungen.json'

# كيريلي ← لاتيني لكل الحروف يلي شكلها واحد
CYR = str.maketrans('асеорхуАСЕОРХУВКМНТ', 'aceopxyACEOPXYBKMHT')


def clean(s):
    return re.sub(r'\s+', ' ', (s or '').translate(CYR)).strip()


def read_pages(path):
    try:
        import pymupdf
    except ImportError:
        sys.exit('✗ لازم pymupdf')
    # ★ رقم الصفحة مطبوع بأوّل كل صفحة. لو ضلّ، «10 Lesen Teil 1 … d»
    #   بينقرا كأنّه السؤال ١٠ وبيبلع جواب السؤال ١.
    return [re.sub(r'^\s*\d{1,3}\s+', '', clean(p.get_text()))
            for p in pymupdf.open(path)]


# ---------- قراءة الحلول من المصدر ----------

# ★ رقم السؤال لازم يجي بعده نقطة، ومو مسبوق بـ«№». بلا هالشرطين
#   العنوان «(вариант №3) - 100% 1. Lamia … b» بينقرا كأنّه السؤال ٣
#   وحلّه b، فبياخد محلّ السؤال ٣ الحقيقي وبيطلع فرق كذب.
#   والنقطة نفسها مو مضمونة: في صفحات كاتبة «1 Junis» بلا نقطة. فمنقبل
#   بلاها بس نشترط إنّ بعدها حرف كبير — يعني اسم، مو رقم جوّا جملة.
ITEM = r'(?<![\d№])(\d{1,2})\s*\.?\s*(?=[A-ZÄÖÜ])'


def key_matching(txt):
    """Lesen Teil 1: «1. Moutasem fragt sich … e» — الحلّ آخر السطر، وبعده
    السؤال التالي أو بداية قايمة الإعلانات."""
    out = {}
    for m in re.finditer(ITEM + r'(.{3,140}?)\s*[-–—]?\s*'
                         r'\b([a-jx])\b\s*(?:\(\s*100\s*%\s*\))?'
                         r'(?=\s+(?:' + ITEM + r'|[a-j]\s*\)|$))', txt, re.I):
        n = int(m.group(1))
        if 1 <= n <= 20: out.setdefault(n, m.group(3).lower())
    return out


def key_forum(txt):
    """Lesen Teil 3: «10. Gabi - d Ich hatte gerade Urlaub …» — الحلّ جوّا
    السطر بين الاسم والمشاركة، مو بآخره. فشكله تاني عن Teil 1."""
    out = {}
    for m in re.finditer(ITEM + r'([A-ZÄÖÜ][\wÄÖÜäöüß]{1,20})\s*[-–—]\s*'
                         r'([a-jxA-JX])\b', txt):
        n = int(m.group(1))
        if 1 <= n <= 20: out.setdefault(n, m.group(3).lower())
    return out


def key_bausteine(txt):
    """Sprachbausteine: «46 (e- sicher)» جوّا النصّ، و«e) SICHER - 46» بالقايمة"""
    out, words = {}, {}
    for m in re.finditer(r'(?<!\d)(\d{2})\s*\(\s*([a-j])\s*[-–—]\s*([^)]{1,40}?)\s*\)', txt):
        n = int(m.group(1))
        if 46 <= n <= 57: out.setdefault(n, m.group(2)); words.setdefault(n, m.group(3).strip())
    for m in re.finditer(r'\b([a-j])\s*\)\s*([A-ZÄÖÜa-zäöüß][\wÄÖÜäöüß]{1,25})\s*[-–—]\s*(\d{2})\b', txt):
        n = int(m.group(3))
        if 46 <= n <= 57: out.setdefault(n, m.group(1)); words.setdefault(n, m.group(2).strip())
    return out, words


# ---------- قراءة المخزّن ----------

def load_app():
    """بيرجّع {نموذج: {قسم: [(رقم, حلّ, {مفتاح: نصّ}, نصّ السؤال)]}}"""
    app = {}
    for d in sorted(glob.glob(os.path.join(CONTENT, 'modell-*'))):
        m = os.path.basename(d).replace('modell-', '')
        f = os.path.join(d, 'text.txt')
        if not os.path.exists(f): continue
        t = json.loads(subprocess.run(
            ['node', '-e',
             "const fs=require('fs'),M=require('./admin/parse.js');"
             "console.log(JSON.stringify(M.parse(fs.readFileSync(process.argv[1],'utf8')).test));",
             f], capture_output=True, text=True).stdout)
        def ptext(sec):
            out = []
            for pas in (sec.get('passages') or []):
                for par in (pas.get('paragraphs') or []):
                    out.append(par.get('t') or '')
            return clean(' '.join(out))

        secs, texts = {}, {}
        for s in t['sections']:
            if s.get('format') == 'writing': continue
            texts[s['id']] = ptext(s)
            opts_sec = {o['key']: o.get('text', '') for o in (s.get('bank') or [])}
            rows = []
            for it in s.get('items') or []:
                opts = {o['key']: o.get('text', '') for o in (it.get('options') or [])} or opts_sec
                rows.append((it['id'], it.get('answer'), opts,
                             clean(it.get('text') or ''), ''))
            secs[s['id']] = rows
        app[m] = (secs, texts)
    return app


def overlap(a, b):
    wa = set(w for w in re.findall(r'\w{4,}', a.lower()))
    wb = set(w for w in re.findall(r'\w{4,}', b.lower()))
    return len(wa & wb) / max(len(wa), 1)


KEYED   = {'lv1': key_matching, 'lv3': key_forum,
           'sb1': key_bausteine, 'sb2': key_bausteine}
UNKEYED = ('lv2', 'lv4', 'lvs1')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--pdf', default=None)
    ap.add_argument('--show', action='store_true')
    a = ap.parse_args()

    path = a.pdf
    if not path:
        if os.path.exists(SRC_IN_GIT): path = SRC_IN_GIT
        else: sys.exit(f'✗ ما لقيت المصدر. جيبيه من التاريخ أو مرّري --pdf\n'
                       f'   المسار بالتاريخ: {SRC_IN_GIT}')
    pages = read_pages(path)
    app = load_app()
    allow = {(x['m'], x['teil'], str(x['nr'])) for x in
             json.load(open(ALLOW, encoding='utf-8'))['abweichungen']} \
            if os.path.exists(ALLOW) else set()

    diffs, checked, known, matched_secs = [], 0, 0, 0
    skipped, unmatched, total_keyed = [], [], [0]
    for m in sorted(app):
        secs, texts = app[m]
        for sid, rows in sorted(secs.items()):
            if sid not in KEYED:
                if sid in UNKEYED: skipped.append((m, sid, len(rows)))
                continue
            total_keyed[0] += sum(1 for r in rows if r[1])
            blob = (texts.get(sid, '') + ' ' + ' '.join(r[3] for r in rows)
                    + ' ' + ' '.join(t for r in rows for t in r[2].values()))
            # أحسن صفحة = أعلى تشابه كلمات
            best, bestsc = None, 0
            for i, t in enumerate(pages):
                sc = overlap(blob, t)
                if sc > bestsc: best, bestsc = i, sc
            if best is None or bestsc < 0.35:
                unmatched.append((m, sid, len(rows), 'ما لقيت صفحته بالمصدر'))
                continue
            fn = KEYED[sid]
            res = fn(pages[best])
            key, words = res if isinstance(res, tuple) else (res, {})
            if not key:
                unmatched.append((m, sid, len(rows), f'صفحته ص{best+1} بلا حلول مطبوعة'))
                continue
            matched_secs += 1
            for nr, cur, opts, qtext, _ in rows:
                n = int(re.sub(r'\D', '', str(nr)) or 0)
                if n not in key or not cur: continue
                checked += 1
                truth = key[n]
                # الكلمة حَكَم لما تكون موجودة: ترتيب الحروف ممكن يختلف
                w = words.get(n)
                if w:
                    hit = [k for k, t in opts.items()
                           if clean(t).lower().strip('. ') == w.lower()]
                    if len(hit) == 1: truth = hit[0]
                if str(cur).lower() == str(truth).lower():
                    if a.show: print(f'  ✓ {m} {sid} {nr}: {cur}')
                    continue
                if (m, sid, str(nr)) in allow: known += 1; continue
                diffs.append((m, sid, nr, cur, (opts.get(cur) or '')[:34],
                              truth, (opts.get(truth.upper()) or opts.get(truth) or '')[:34],
                              f'ص{best+1}'))

    out_of = sum(n for _, _, n in skipped)
    print(f'المصدر: {os.path.basename(path)}')
    print(f'انفحص {checked} حلّ بـ{matched_secs} قسم ({", ".join(sorted(KEYED))})'
          f' · {known} مخالفة موثّقة')
    print(f'برّا الفحص {out_of} حلّ — المصدر ما بيطبع حلول لـ{", ".join(UNKEYED)}؛ '
          f'هدول انفحصوا بالقراءة.')
    gap = total_keyed[0] - checked - known
    if unmatched or gap:
        print(f'\n⚠ {gap} حلّ بأقسام إلها مفتاح بس ما وصلنا له:')
        for m, sid, n, why in unmatched:
            print(f'   نموذج {m} · {sid} ({n} سؤال): {why}')
        if gap and not unmatched:
            print('   (أسئلة مفردة ما طلع إلها رقم مطابق بصفحة المصدر)')
    if diffs:
        print('\n✗ فروق مو مكتوبة بـ' + ALLOW + ':')
        for m, sid, nr, cur, ct, tr, tt, org in diffs:
            print(f'   نموذج {m} · {sid} · سؤال {nr}:  المخزّن {cur} {ct}'
                  f'   ≠   المصدر {tr} {tt}   [{org}]')
        return 1
    print('✓ كل حلّ مطبوع بالمصدر مطابق للمخزّن (أو مخالفته موثّقة).')
    return 0


if __name__ == '__main__':
    sys.exit(main())
