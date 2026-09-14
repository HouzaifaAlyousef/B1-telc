#!/usr/bin/env python3
"""تصغير صور الامتحانات: PNG ← JPEG، وتعديل سطور `Bild:` معها.

    python3 tools/shrink_images.py content --dry-run
    python3 tools/shrink_images.py content

ليش أصلاً: صور الامتحانات مسوحات — صفحات نص وإعلانات وصور فوتوغرافية.
PNG بلا خسارة، يعني بيخزّن ضجيج الماسح حرف بحرف: صفحة صور وحدة صارت
٢ ميغا. الطالب على موبايل بشبكة ضعيفة بيستنّاها. JPEG بجودة ٨٥ وبلا
تنعيم لوني (4:4:4) بينزّلها لعُشر، والنص بيضل مقروء متل ما هو — وهي
أصلاً صيغة صور telc B1 الموجودة من أوّل يوم.

★ الاسم بينتغيّر (.png ← .jpg)، فلازم:
  ١) سطر `Bild:` بـtext.txt يتعدّل — بيصير هون آلياً
  ٢) البذور تتولّد من جديد وتتلصق من جديد:
        node tools/content_to_seed.mjs <مؤسسة>/<درجة> supabase/seed/<...>.sql
     (البذور بتعمل `config = excluded.config`، فاللصقة بتحدّث المسار)
"""
import argparse, sys
from pathlib import Path

QUALITY = 85


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('src', nargs='?', default='content', help='مجلد المحتوى')
    ap.add_argument('--quality', type=int, default=QUALITY)
    ap.add_argument('--dry-run', action='store_true')
    a = ap.parse_args()

    try:
        from PIL import Image
    except ImportError:
        sys.exit('لازم pillow:  pip install pillow')

    src = Path(a.src)
    pngs = sorted(p for p in src.rglob('img/*') if p.suffix.lower() == '.png')
    if not pngs:
        print(f'ما في PNG بـ{src} — كلها JPEG أصلاً')
        return

    before = after = 0
    for p in pngs:
        out = p.with_suffix('.jpg')
        if out.exists():
            print(f'✗ {out.name} موجود أصلاً — تخطّي {p}')
            continue
        im = Image.open(p).convert('RGB')
        # ★ subsampling=0 مقصود: التنعيم اللوني الافتراضي بيلخبط حواف
        #   الحروف، وهدول صفحات نص قبل ما يكونوا صور.
        im.save(out, 'JPEG', quality=a.quality, optimize=True,
                progressive=True, subsampling=0)
        b, c = p.stat().st_size, out.stat().st_size
        before += b; after += c
        print(f'  {p.name:18} {b//1024:5} KB → {out.name:18} {c//1024:5} KB'
              f'  ({100 - c * 100 // b}%-)')
        if a.dry_run:
            out.unlink()
            continue
        p.unlink()
        # سطر Bild: بملف النموذج — الاسم هو الرابط الوحيد بين الاتنين
        txt = p.parent.parent / 'text.txt'
        if txt.exists():
            s = txt.read_text()
            n = s.replace(f'Bild: img/{p.name}', f'Bild: img/{out.name}')
            if n != s:
                txt.write_text(n)
            else:
                print(f'    ⚠ ما في `Bild: img/{p.name}` بـ{txt} — دوّر عليه بالإيد')

    tag = ' (تجربة — ما انحفظ شي)' if a.dry_run else ''
    print(f'\n{len(pngs)} صورة · {before/1048576:.1f} ← {after/1048576:.1f} ميغا'
          f'  ({100 - after * 100 // before}%-){tag}')
    if not a.dry_run:
        print('\n▸ ولّد البذور من جديد والصقها:')
        seen = {p.parts[1] + '/' + p.parts[2] for p in pngs if len(p.parts) > 2}
        for lvl in sorted(seen):
            print(f'   node tools/content_to_seed.mjs {lvl} supabase/seed/…sql')


if __name__ == '__main__':
    main()
