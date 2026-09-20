#!/usr/bin/env python3
"""بيقارن حلول ÖSD A1 المخزّنة بصفحة الحلول المطبوعة بالمصدر.

    python3 tools/check_oesd_keys.py           # كل النماذج
    python3 tools/check_oesd_keys.py --show    # كل المطابقات

★ المصادر مسح صور بلا طبقة نصّ. فصفحة الحلول منقولة بالإيد لـ
  Doku/schluessel/oesd-a1.json **متل ما هي مطبوعة**، وهالأداة بتحوّل.
  منقل متل المطبوع مو متل المخزّن عن قصد: هيك يلي بيقرا الملف بيقدر
  يقابله بالصفحة بالعين بلا ما يفكّ ترميز.

★ التحويلة الوحيدة: hv1 مطبوع «صورة ← رقم النصّ»، والمخزّن «نصّ ← حرف
  الصورة». منعكسه هون. وفي صورة وحدة بلا نصّ («-») بتطير بالعكس.
"""
import sys, os, json, argparse, subprocess

CONTENT = 'content/oesd/a1'
KEYS    = 'Doku/schluessel/oesd-a1.json'
ALLOW   = 'Doku/oesd-abweichungen.json'
JA_NEIN = {'J': ('ja',), 'N': ('nein',)}


def load_model(m):
    f = os.path.join(CONTENT, 'modell-%s' % m, 'text.txt')
    if not os.path.exists(f): return None
    out = subprocess.run(
        ['node', '-e',
         "const fs=require('fs'),M=require('./admin/parse.js');"
         "console.log(JSON.stringify(M.parse(fs.readFileSync(process.argv[1],'utf8')).test));",
         f], capture_output=True, text=True)
    return json.loads(out.stdout)


def invert_hv1(printed):
    """«5 4 - 1 2 3» (صورة A..F ← نصّ) → {نصّ: حرف الصورة}"""
    out = {}
    for i, v in enumerate(printed.split()):
        if v == '-': continue
        out[v] = chr(ord('A') + i)
    return out


def expect(sid, want, item):
    """الحلّ المطبوع → المفتاح يلي الطالب بيقدر يضغطه."""
    opts = {o['key']: (o.get('text') or '').strip().lower()
            for o in (item.get('options') or [])}
    if sid == 'lv2':
        for k, t in opts.items():
            if t in JA_NEIN[want]: return k
        return want
    for k in opts:                       # lv1/lv3: الخيار نفسه رقم
        if k.lower() == want.lower(): return k
    return want


def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--show', action='store_true')
    a = ap.parse_args()
    if not os.path.exists(KEYS): sys.exit('✗ ما في %s' % KEYS)
    doc = json.load(open(KEYS, encoding='utf-8'))
    keys, ohne = doc['schluessel'], doc.get('_ohne', {})
    allow = {(x['m'], x['teil'], str(x['nr'])) for x in
             json.load(open(ALLOW, encoding='utf-8'))['abweichungen']} \
            if os.path.exists(ALLOW) else set()

    diffs, checked, known, lesen_n, fehlend = [], 0, 0, 0, []
    for m in sorted(keys):
        t = load_model(m)
        if not t: fehlend.append(m); continue
        secs = {s['id']: s for s in t['sections']}
        for sid in ('lv1', 'lv2', 'lv3', 'hv1'):
            s = secs.get(sid)
            if not s: continue
            items = s.get('items') or []
            if sid == 'hv1':
                mapping = invert_hv1(keys[m]['hv1'])
                wants = [mapping.get(str(i + 1)) for i in range(len(items))]
            else:
                wants = keys[m][sid].split()
            for it, want in zip(items, wants):
                if want is None or it.get('answer') is None: continue
                checked += 1
                if sid.startswith('lv'): lesen_n += 1
                truth = expect(sid, want, it) if sid != 'hv1' else want
                if str(it['answer']).lower() == str(truth).lower():
                    if a.show: print('  ✓ %s %s %s: %s' % (m, sid, it['id'], it['answer']))
                    continue
                if (m, sid, str(it['id'])) in allow: known += 1; continue
                opts = {o['key']: o.get('text', '') for o in (it.get('options') or [])}
                diffs.append((m, sid, it['id'], it['answer'],
                              (opts.get(it['answer']) or '')[:28], truth, want))

    print('انفحص %d حلّ بـ%d نموذج (منهن %d قراءة) · %d مخالفة موثّقة'
          % (checked, len(keys) - len(fehlend), lesen_n, known))
    if ohne:
        print('· بلا مصدر: %s' % ', '.join('%s (%s)' % (k, v) for k, v in sorted(ohne.items())))
    if fehlend:
        print('· بالمفتاح بس مو بالمحتوى: %s' % ', '.join(fehlend))
    print('· برّا الفحص: hv2 (نموذج التعبئة) وhv3 — سماع')
    if diffs:
        print('\n✗ فروق مو مكتوبة بـ%s:' % ALLOW)
        for m, sid, nr, cur, ct, tr, want in diffs:
            print('   نموذج %s · %s · سؤال %s:  المخزّن %s %s   ≠   المطبوع %s (%s)'
                  % (m, sid, nr, cur, ct, tr, want))
        return 1
    print('✓ كل حلّ مطابق للمطبوع (أو مخالفته موثّقة).')
    return 0


if __name__ == '__main__':
    sys.exit(main())
