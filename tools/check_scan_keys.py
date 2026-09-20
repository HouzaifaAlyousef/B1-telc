#!/usr/bin/env python3
"""بيقارن الحلول المخزّنة بالمستويات يلي مصدرها مسح صور.

    python3 tools/check_scan_keys.py                    # كل المستويات
    python3 tools/check_scan_keys.py --level goethe/a1
    python3 tools/check_scan_keys.py --show

★ ÖSD وGoethe مصادرهن مسح صور بلا طبقة نصّ — ما بتنقرا آلياً. فالحلول
  منقولة بالإيد لـDoku/schluessel/<مؤسسة>-<درجة>.json **متل ما هي
  بالمصدر**، وهالأداة بتحوّل وبتقارن. منقل متل المصدر مو متل المخزّن عن
  قصد: هيك يلي بيقرا الملف بيقدر يقابله بالصفحة بالعين بلا فكّ ترميز.

★ أداة وحدة للتنين مو تنتين: نفس الشكل بالضبط (قوايم لكل قسم)، والفرق
  بس بترميز الخيارات — وهو مكتوب بالـJSON نفسه مو بالكود.

★ ÖSD إله تحويلة: hv1 مطبوع «صورة ← رقم النصّ» والمخزّن «نصّ ← حرف
  الصورة». منعكسه. وفي صورة وحدة بلا نصّ («-») بتطير بالعكس.

★ Goethe ما إله مفتاح مطبوع أصلاً — حلوله مقروءة من النصّ الألماني،
  والملف بيقول هالشي بصراحة. نفس الحارس بينطبق.
"""
import sys, os, json, argparse, subprocess

LEVELS  = ['oesd/a1', 'goethe/a1']
WORT    = {'J': ('ja',), 'N': ('nein',),
           'r': ('richtig', 'wahr'), 'f': ('falsch',)}


def load_model(level, m):
    f = os.path.join('content', level, 'modell-%s' % m, 'text.txt')
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


def expect(want, item):
    """الحلّ متل ما هو بالمصدر → المفتاح يلي الطالب بيقدر يضغطه.

    «J»/«N» و«r»/«f» منلاقيهن بنصّ الخيار (JA/NEIN، Richtig/Falsch)،
    وغيرهن (رقم أو a/b) هو نفسه مفتاح الخيار."""
    opts = {o['key']: (o.get('text') or '').strip().lower()
            for o in (item.get('options') or [])}
    if want in WORT:
        for k, t in opts.items():
            if t in WORT[want]: return k
    for k in opts:
        if k.lower() == want.lower(): return k
    return want


def run(level, show):
    slug = level.replace('/', '-')
    KEYS  = 'Doku/schluessel/%s.json' % slug
    ALLOW = 'Doku/%s-abweichungen.json' % slug
    if not os.path.exists(KEYS):
        print('· %s: ما في %s — تخطّي' % (level, KEYS)); return 0, 0, 0
    doc = json.load(open(KEYS, encoding='utf-8'))
    keys, ohne = doc['schluessel'], doc.get('_ohne', {})
    allow = {(x['m'], x['teil'], str(x['nr'])) for x in
             json.load(open(ALLOW, encoding='utf-8'))['abweichungen']} \
            if os.path.exists(ALLOW) else set()

    diffs, checked, known, lesen_n, fehlend = [], 0, 0, 0, []
    for m in sorted(keys):
        t = load_model(level, m)
        if not t: fehlend.append(m); continue
        secs = {s['id']: s for s in t['sections']}
        for sid in ('lv1', 'lv2', 'lv3', 'hv1'):
            s = secs.get(sid)
            if not s or sid not in keys[m]: continue
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
                truth = want if sid == 'hv1' else expect(want, it)
                if str(it['answer']).lower() == str(truth).lower():
                    if show: print('  ✓ %s %s %s %s: %s' % (level, m, sid, it['id'], it['answer']))
                    continue
                if (m, sid, str(it['id'])) in allow: known += 1; continue
                opts = {o['key']: o.get('text', '') for o in (it.get('options') or [])}
                diffs.append((m, sid, it['id'], it['answer'],
                              (opts.get(it['answer']) or '')[:28], truth, want))

    print('%-11s %3d حلّ بـ%d نموذج (منهن %d قراءة) · %d مخالفة موثّقة'
          % (level, checked, len(keys) - len(fehlend), lesen_n, known))
    for k, v in sorted(ohne.items()):
        print('            · بلا مصدر: %s (%s)' % (k, v))
    if fehlend:
        print('            · بالمفتاح بس مو بالمحتوى: %s' % ', '.join(fehlend))
    if diffs:
        print('\n✗ %s — فروق مو مكتوبة بـ%s:' % (level, ALLOW))
        for m, sid, nr, cur, ct, tr, want in diffs:
            print('   نموذج %s · %s · سؤال %s:  المخزّن %s %s   ≠   المصدر %s (%s)'
                  % (m, sid, nr, cur, ct, tr, want))
    return checked, len(diffs), lesen_n


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--level', default=None, help='oesd/a1 أو goethe/a1')
    ap.add_argument('--show', action='store_true')
    a = ap.parse_args()
    levels = [a.level] if a.level else LEVELS
    tot = bad = les = 0
    for lv in levels:
        c, d, l = run(lv, a.show); tot += c; bad += d; les += l
    print('—' * 46)
    print('المجموع: %d حلّ (منهن %d قراءة)' % (tot, les))
    if bad: return 1
    print('✓ كل حلّ مطابق للمصدر (أو مخالفته موثّقة).')
    print('· برّا الفحص: hv2/hv3 بـÖSD — سماع')
    return 0


if __name__ == '__main__':
    sys.exit(main())
