#!/usr/bin/env python3
"""بيقارن حلول DTZ B1 المخزّنة بمفتاح الحلول المطبوع بالمصدر.

    python3 tools/check_dtz_keys.py            # كل النماذج
    python3 tools/check_dtz_keys.py --show     # كل المطابقات، مو بس الفروق

★ مصادر DTZ مسح صور بلا طبقة نصّ — ما بتنقرا آلياً ولا بـpymupdf. فقرينا
  صفحة الحلول بالعين وكتبناها بـDoku/schluessel/dtz-b1.json، وهالأداة
  بتقارن. يعني الملف هو النسخة المقروءة من المطبوع، والأداة هي الحارس.

★ الترميز مختلف بين النماذج: في نماذج مخزّنة صح-خطأ كـA/B (والخيارات
  «Richtig»/«Falsch»)، وفي نماذج مخزّنة r/f مباشرة. منوحّد قبل المقارنة
  بالخيار نفسه مو بالحرف، وإلا بيطلع فرق كذب بكل سؤال صح-خطأ.
"""
import sys, os, re, json, argparse, subprocess

CONTENT = 'content/dtz/b1'
KEYS    = 'Doku/schluessel/dtz-b1.json'
ALLOW   = 'Doku/dtz-abweichungen.json'
TEILE   = [('hv1',4), ('hv2',5), ('hv3',8), ('hv4',3),
           ('lv1',5), ('lv2',5), ('lv3',6), ('lv4',3), ('lv5',6)]
LESEN   = {'lv1','lv2','lv3','lv4','lv5'}


def load_model(m):
    f = os.path.join(CONTENT, 'modell-%s' % m, 'text.txt')
    if not os.path.exists(f): return None
    out = subprocess.run(
        ['node', '-e',
         "const fs=require('fs'),M=require('./admin/parse.js');"
         "console.log(JSON.stringify(M.parse(fs.readFileSync(process.argv[1],'utf8')).test));",
         f], capture_output=True, text=True)
    return json.loads(out.stdout)


def truth_key(want, item):
    """الحلّ المطبوع → المفتاح يلي الطالب بيقدر يضغطه فعلاً.

    «r» ممكن يكون A لأنّ الخيار الأول «Richtig»، وممكن يكون «r» نفسه.
    وحرف عادي (a/b/c) ممكن يكون A/B/C. منقرّر من خيارات السؤال."""
    opts = {o['key']: (o.get('text') or '').strip().lower()
            for o in (item.get('options') or [])}
    if want in ('r', 'f'):
        woerter = {'r': ('richtig', 'wahr', 'true'), 'f': ('falsch', 'wrong', 'false')}[want]
        for k, t in opts.items():
            if t in woerter: return k
        return want                      # قسم truefalse بلا خيارات
    for k in opts:
        if k.lower() == want.lower(): return k
    return want.upper()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--show', action='store_true')
    a = ap.parse_args()
    if not os.path.exists(KEYS): sys.exit('✗ ما في %s' % KEYS)
    doc = json.load(open(KEYS, encoding='utf-8'))
    keys, ohne = doc['schluessel'], doc.get('_ohne', {})
    allow = {(x['m'], x['teil'], str(x['nr'])) for x in
             json.load(open(ALLOW, encoding='utf-8'))['abweichungen']} \
            if os.path.exists(ALLOW) else set()

    diffs, checked, known, lesen_n = [], 0, 0, 0
    fehlend = []
    for m in sorted(keys):
        t = load_model(m)
        if not t: fehlend.append(m); continue
        secs = {s['id']: s for s in t['sections']}
        vals = [w for teil in keys[m].split('|') for w in teil.split()]
        i = 0
        for sid, n in TEILE:
            s = secs.get(sid)
            for j in range(n):
                want = vals[i]; i += 1
                # «؟» = ما في مفتاح مطبوع لهالسؤال (نموذج ١٠ سماعه)
                if want == '?': continue
                if not s or j >= len(s.get('items') or []): continue
                it = s['items'][j]
                cur = it.get('answer')
                if cur is None: continue
                checked += 1
                if sid in LESEN: lesen_n += 1
                truth = truth_key(want, it)
                if str(cur).lower() == str(truth).lower():
                    if a.show: print('  ✓ %s %s %s: %s' % (m, sid, it['id'], cur))
                    continue
                if (m, sid, str(it['id'])) in allow: known += 1; continue
                opts = {o['key']: o.get('text','') for o in (it.get('options') or [])}
                diffs.append((m, sid, it['id'], cur, (opts.get(cur) or '')[:30],
                              truth, want, (opts.get(truth) or '')[:30]))

    print('انفحص %d حلّ بـ%d نموذج (منهن %d قراءة) · %d مخالفة موثّقة'
          % (checked, len(keys) - len(fehlend), lesen_n, known))
    if ohne:
        print('· بلا مفتاح مطبوع: %s — ما انفحصوا'
              % ', '.join('%s (%s)' % (k, v) for k, v in sorted(ohne.items())))
    if fehlend:
        print('· بالمفتاح بس مو بالمحتوى: %s' % ', '.join(fehlend))
    if diffs:
        print('\n✗ فروق مو مكتوبة بـ%s:' % ALLOW)
        for m, sid, nr, cur, ct, tr, want, tt in diffs:
            print('   نموذج %s · %s · سؤال %s:  المخزّن %s %s   ≠   المفتاح %s (%s) %s'
                  % (m, sid, nr, cur, ct, tr, want, tt))
        return 1
    print('✓ كل حلّ مطابق للمفتاح المطبوع (أو مخالفته موثّقة).')
    return 0


if __name__ == '__main__':
    sys.exit(main())
