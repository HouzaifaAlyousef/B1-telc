#!/usr/bin/env python3
"""تصغير تسجيلات الاستماع الكبيرة — إعادة ترميز بجودة كلام.

    python3 tools/shrink_audio.py content --dry-run
    python3 tools/shrink_audio.py content

ليش: دلو Supabase بيرفض الملفّ فوق ٥٠ ميغا («Payload too large»)، وأربع
ملفّات بـtelc B2 طلعوا ٦٤–٨٠ ميغا. وحتى لو رفعنا الحدّ، ٨٠ ميغا لقسم
استماع واحد كارثة على طالب بالموبايل — باقي الأقسام بنفس المستوى ٢٫٣
ميغا، يعني هدول مرمّزين بجودة موسيقى بلا سبب.

الكلام مونو بـ٦٤ كيلوبت بالثانية نقي تماماً وبينزل عشرة أضعاف.

★ بيلمس الملفّات الكبيرة بس (الحدّ الافتراضي ٤٠ ميغا). يلي تحته ما
بينلمس — إعادة الترميز بتخسّر، وما في سبب تخسّر ملفّ حجمه منيح أصلاً.
"""
import argparse, shutil, subprocess, sys
from pathlib import Path

BITRATE = '64k'
LIMIT_MB = 40


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('src', nargs='?', default='content')
    ap.add_argument('--over', type=float, default=LIMIT_MB,
                    help=f'صغّر الملفّات فوق كم ميغا (الافتراضي {LIMIT_MB})')
    ap.add_argument('--bitrate', default=BITRATE)
    ap.add_argument('--dry-run', action='store_true')
    a = ap.parse_args()

    src = Path(a.src)
    if not src.is_dir():
        sys.exit(f'ما في {src}')

    EXT = ('.mp3', '.m4a', '.ogg', '.wav', '.aac')
    big = sorted(f for f in src.rglob('audio/*')
                 if f.is_file() and f.suffix.lower() in EXT
                 and f.stat().st_size > a.over * 1048576)
    if not big:
        print(f'ما في ملفّ صوت فوق {a.over:.0f} ميغا بـ{src} — ما في شي نعمله')
        return

    if not a.dry_run and not shutil.which('ffmpeg'):
        sys.exit('لازم ffmpeg:\n'
                 '  Ubuntu/Pop!_OS:  sudo apt install ffmpeg\n'
                 '  macOS:           brew install ffmpeg')

    before = after = 0
    for f in big:
        b = f.stat().st_size
        before += b
        print(f'  {f.name:32} {b/1048576:6.1f} ميغا', end='', flush=True)
        if a.dry_run:
            print(f'  → مونو {a.bitrate}')
            continue
        tmp = f.with_suffix(f.suffix + '.tmp')
        r = subprocess.run(
            ['ffmpeg', '-y', '-loglevel', 'error', '-i', str(f),
             '-ac', '1', '-b:a', a.bitrate, '-map_metadata', '-1', str(tmp)],
            capture_output=True, text=True)
        if r.returncode != 0 or not tmp.exists():
            tmp.unlink(missing_ok=True)
            print(f'  ✗ {r.stderr.strip()[:90]}')
            continue
        c = tmp.stat().st_size
        # ★ لو الناتج مو أصغر، خلّي الأصل: ما في فايدة نخسّر بلا مقابل
        if c >= b:
            tmp.unlink()
            print('  · الأصل أصغر — انترك متل ما هو')
            after += b
            continue
        tmp.replace(f)
        after += c
        print(f'  → {c/1048576:5.1f} ميغا  ({100 - c * 100 // b}%-)')

    tag = ' (تجربة — ما انحفظ شي)' if a.dry_run else ''
    if not a.dry_run and after:
        print(f'\n{len(big)} ملف · {before/1048576:.0f} ← {after/1048576:.0f} ميغا'
              f'  ({100 - after * 100 // before}%-)')
        print('\n▸ وبعدها: python3 tools/upload_audio.py content')
    else:
        print(f'\n{len(big)} ملف فوق الحدّ{tag}')


if __name__ == '__main__':
    main()
