#!/usr/bin/env python3
"""كم حلّ مخزّن، وكم منهن انفحص على مصدر — بالمستوى وبالقسم.

    python3 tools/coverage.py

★ الرقم يلي بيطلع من أدوات الفحص («انفحص ٣٨٥ حلّ») ما بيقول كم **ما**
  انفحص. هالأداة بتطرح: بتعدّ المخزّن كله، وبتشيل منه المغطّى، وبتسمّي
  الباقي بالاسم. هيك الثغرة بتضل مكتوبة بدل ما تنتسى.

★ «انفحص» هون = انقارن بمفتاح مطبوع أو انقرا من المصدر وانكتب بملف
  مفتاح. القسم يلي مكتوب «بالقراءة» بملف المفتاح محسوب مفحوص.
"""
import json, subprocess, glob, os, collections, sys

LESEN = ('lv', 'sb', 'lvs', 'fb', 's1', 's2')


def load(path):
    o = subprocess.run(['node', '-e',
        "const fs=require('fs'),M=require('./admin/parse.js');"
        "console.log(JSON.stringify(M.parse(fs.readFileSync(process.argv[1],'utf8')).test));",
        path], capture_output=True, text=True)
    return json.loads(o.stdout) if o.stdout.strip() else None


def stored():
    out = {}
    for d in sorted(glob.glob('content/*/*/')):
        lvl = '/'.join(d.strip('/').split('/')[1:])
        per = collections.Counter()
        for m in sorted(glob.glob(os.path.join(d, 'modell-*'))):
            f = os.path.join(m, 'text.txt')
            if not os.path.exists(f): continue
            t = load(f)
            if not t or not t.get('sections'): continue
            mm = os.path.basename(m).replace('modell-', '')
            for s in t['sections']:
                n = sum(1 for it in (s.get('items') or []) if it.get('answer') is not None)
                if n: per[(mm, s['id'])] += n
        if per: out[lvl] = per
    return out


# كم غطّت كل أداة — من مخرجاتها هي، مو من تقديرنا
TOOLS = {
    'telc/b1':   ['python3', 'tools/check_keys.py', '--feed', 'Doku/feed pdf/telc/b1'],
    'telc/b2':   ['python3', 'tools/check_b2_keys.py', '--pdf',
                  'Doku/feed pdf/telc/b2/Alle Informati B2 от 27.04.2026.pdf'],
    'dtz/b1':    ['python3', 'tools/check_dtz_keys.py'],
    'oesd/a1':   ['python3', 'tools/check_scan_keys.py', '--level', 'oesd/a1'],
    'goethe/a1': ['python3', 'tools/check_scan_keys.py', '--level', 'goethe/a1'],
}


GELESEN = 'Doku/schluessel/gelesen.json'


def read_verified(per, lvl):
    """الأقسام يلي انفحصت بالقراءة — مسجّلة بملف، مو مفترضة."""
    if not os.path.exists(GELESEN): return 0
    doc = json.load(open(GELESEN, encoding='utf-8'))
    n = 0
    for e in doc['gelesen']:
        if e['level'] != lvl: continue
        for t in e['teile']:
            n += per.get((e['m'], t), 0)
    return n


def covered(lvl):
    import re
    cmd = TOOLS.get(lvl)
    if not cmd: return None
    r = subprocess.run(cmd, capture_output=True, text=True)
    m = re.search(r'انفحص\s+(\d+)\s+حلّ', r.stdout)
    if not m: m = re.search(r'^\S+\s+(\d+)\s+حلّ', r.stdout, re.M)
    return int(m.group(1)) if m else None


def main():
    st = stored()
    tot = totc = 0
    print('%-11s %7s %7s %7s   %s' % ('المستوى', 'مخزّن', 'مفحوص', 'ناقص', 'قراءة/سماع'))
    print('—' * 66)
    for lvl, per in st.items():
        n = sum(per.values())
        lese = sum(v for (m, s), v in per.items() if s.startswith(LESEN))
        c = covered(lvl)
        g = read_verified(per, lvl)
        if c is not None: c += g
        tot += n; totc += (c or 0)
        print('%-11s %7d %7s %7s   قراءة %d · سماع %d%s'
              % (lvl, n, c if c is not None else '—',
                 (n - c) if c is not None else '—', lese, n - lese,
                 ('  (منهن %d بالقراءة)' % g) if g else ''))
    print('—' * 66)
    print('%-11s %7d %7d %7d' % ('المجموع', tot, totc, tot - totc))
    print()
    print('الناقص مكتوب بالتفصيل بـ_ohne جوّا ملفّات Doku/schluessel/،')
    print('وبمخرجات كل أداة فحص لحالها.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
