#!/usr/bin/env python3
"""جرد صور الامتحانات: كل مرجع إله ملف، وكل ملف بمحلّه الصح.

    python3 tools/check_images.py
    python3 tools/check_images.py --show

★ الصورة مو زينة: بأقسام كتير هي **مصدر الجواب الوحيد** (بنك إعلانات
  telc B1 lv3 بنكه النصّي فاضي تماماً، وDTZ lv1 نصّه كلّه بالصورة).
  فصورة بمحلّ غلط = قسم كامل بلا جواب، وما في شي بيصرخ وقتها.

بيفحص:
  · كل سطر «Bild:» إله ملف موجود
  · ما في ملف صورة بلا مرجع (يتيم)
  · اسم الملف بيحمل مؤسسته ودرجته ونموذجه وقسمه، ومطابق لمحلّه
  · ما في صورتين متطابقتين بمحلّين (نسخ-لصق)
  · ولا صورة فاضية أو أكبر من الحدّ

★ الأسماء القديمة (m01-lv3.jpg بلا بادئة telc-b1-) مقبولة بس لازم
  رقم نموذجها وقسمها يطابقوا محلّها — هيك يلي بيحمي فعلاً.
"""
import sys, os, re, glob, hashlib, argparse

MAXKB = 500
MINKB = 8


def refs():
    """(مسار الملف, المؤسسة, الدرجة, رقم النموذج, القسم, قيمة Bild)"""
    for f in sorted(glob.glob('content/*/*/modell-*/text.txt')):
        p = f.split('/')
        prov, lvl, mod = p[1], p[2], p[3].replace('modell-', '')
        sec = None
        for line in open(f, encoding='utf-8'):
            m = re.match(r'^### Teil:\s*(\S+)', line)
            if m: sec = m.group(1); continue
            m = re.match(r'^Bild:\s*(.+?)\s*$', line)
            if m: yield f, prov, lvl, mod, sec, m.group(1)


def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--show', action='store_true')
    a = ap.parse_args()
    seen, byhash, bad = {}, {}, []
    n = 0
    for f, prov, lvl, mod, sec, val in refs():
        n += 1
        path = os.path.join(os.path.dirname(f), val)
        where = '%s/%s modell-%s [%s]' % (prov, lvl, mod, sec)
        if not os.path.exists(path):
            bad.append('✗ مرجع بلا ملف: %s → %s' % (where, val)); continue
        seen[os.path.abspath(path)] = where

        kb = os.path.getsize(path) / 1024
        if kb < MINKB: bad.append('✗ صورة شبه فاضية (%.0f ك.ب): %s' % (kb, path))
        if kb > MAXKB: bad.append('✗ صورة أكبر من %d ك.ب (%.0f): %s' % (MAXKB, kb, path))

        h = hashlib.md5(open(path, 'rb').read()).hexdigest()
        if h in byhash:
            bad.append('✗ نفس الصورة بمحلّين: %s  ≡  %s' % (byhash[h], where))
        byhash[h] = where

        # الاسم لازم يطابق محلّه
        name = os.path.basename(val)
        g = re.match(r'^(?:([a-z]+)-([a-z0-9]+)-)?m(\d+)-([a-z0-9]+)\.', name)
        if not g:
            bad.append('✗ اسم برّا الاتّفاق: %s (%s)' % (name, where)); continue
        gp, gl, gm, gs = g.groups()
        if gp and gp != prov: bad.append('✗ %s: مؤسسة الاسم %s ≠ %s' % (where, gp, prov))
        if gl and gl != lvl:  bad.append('✗ %s: درجة الاسم %s ≠ %s' % (where, gl, lvl))
        if gm.lstrip('0') != mod.lstrip('0'):
            bad.append('✗ %s: نموذج الاسم %s ≠ %s' % (where, gm, mod))
        if gs != sec:
            bad.append('✗ %s: قسم الاسم %s ≠ %s' % (where, gs, sec))
        if a.show: print('  ✓ %-34s %s' % (where, name))

    ondisk = {os.path.abspath(p) for p in glob.glob('content/*/*/modell-*/img/*')
              if not p.endswith(('.md', '.txt'))}
    for o in sorted(ondisk - set(seen)):
        bad.append('✗ ملف صورة بلا مرجع: %s' % o.replace(os.getcwd() + '/', ''))

    print('مراجع: %d · ملفّات: %d' % (n, len(ondisk)))
    if bad:
        for b in bad: print('  ' + b)
        print('\n✗ %d مشكلة' % len(bad)); return 1
    print('✓ كل صورة موجودة، بمحلّها، وما في يتيم ولا مكرّر.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
