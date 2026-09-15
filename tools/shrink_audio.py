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

# ★ ٩٦ كيلوبت مونو، مو ٦٤.
# هدول تسجيلات امتحان: الطالب لازم يلقف رقم هاتف واسم شارع وتاريخ.
# ٦٤ كافية للكلام العادي، بس الفرق بالكلفة تافه (٧ ميغا مقابل ١١)
# والفرق بالطمأنينة مو تافه. مين بدّه أصغر: --bitrate=64k
BITRATE = '96k'
LIMIT_MB = 40


def need(binary):
    if not shutil.which(binary):
        sys.exit(f'لازم ffmpeg (فيه {binary}):\n'
                 '  Ubuntu/Pop!_OS:  sudo apt install ffmpeg\n'
                 '  macOS:           brew install ffmpeg')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('src', nargs='?', default='content')
    ap.add_argument('--over', type=float, default=LIMIT_MB,
                    help=f'صغّر الملفّات فوق كم ميغا (الافتراضي {LIMIT_MB})')
    ap.add_argument('--bitrate', default=BITRATE)
    ap.add_argument('--dry-run', action='store_true')
    ap.add_argument('--probe', action='store_true',
                    help='اعرض شو جوّا الملفّات ولا تلمس شي')
    ap.add_argument('--samples', metavar='FILE',
                    help='قصّ ٤٠ ثانية بتلات جودات تا تسمعهن وتقرّر')
    a = ap.parse_args()

    # ---- عيّنات للمقارنة بالأذن ----
    if a.samples:
        f = Path(a.samples)
        if not f.is_file(): sys.exit(f'ما في {f}')
        need('ffmpeg')
        out = f.parent / 'vergleich'
        out.mkdir(exist_ok=True)
        print(f'٤٠ ثانية من {f.name}، من الدقيقة الأولى:\n')
        for br in ('64k', '96k', '128k', None):
            dst = out / (f'{f.stem}__{br or "original"}.mp3')
            cmd = ['ffmpeg', '-y', '-loglevel', 'error', '-ss', '60', '-t', '40',
                   '-i', str(f)]
            cmd += ['-c', 'copy'] if br is None else ['-ac', '1', '-b:a', br]
            cmd.append(str(dst))
            if subprocess.run(cmd, capture_output=True).returncode or not dst.exists():
                print(f'  ✗ {br or "الأصل"}'); continue
            print(f'  {(br or "الأصل"):>8}  {dst.stat().st_size/1024:6.0f} KB   {dst}')
        print(f'\n▸ اسمعهن كلهن، وإذا ما فرقت معك خد الأصغر:'
              f'\n   python3 tools/shrink_audio.py content --bitrate=64k')
        return

    def probe(f):
        r = subprocess.run(['ffprobe', '-v', 'error', '-show_entries',
                            'format=duration,bit_rate:stream=channels,sample_rate',
                            '-of', 'default=nw=1:nk=1', str(f)],
                           capture_output=True, text=True)
        v = [x for x in r.stdout.split() if x]
        return v if len(v) >= 4 else None

    src = Path(a.src)
    if not src.is_dir():
        sys.exit(f'ما في {src}')

    EXT = ('.mp3', '.m4a', '.ogg', '.wav', '.aac')

    # ---- شو جوّاتهن فعلاً ----
    if a.probe:
        need('ffprobe')
        print(f'{"الملفّ":32} {"حجم":>8} {"مدّة":>7} {"معدّل":>9} {"قنوات":>6}')
        for f in sorted(x for x in src.rglob('audio/*')
                        if x.is_file() and x.suffix.lower() in EXT):
            v = probe(f)
            if not v: print(f'  {f.name:30} — ما قدرت أقراه'); continue
            ch, sr, dur, br = v[0], v[1], float(v[2]), int(v[3]) // 1000
            print(f'  {f.name:30} {f.stat().st_size/1048576:6.1f}م '
                  f'{dur/60:6.1f}د {br:6}kbps {ch:>6}')
        return

    big = sorted(f for f in src.rglob('audio/*')
                 if f.is_file() and f.suffix.lower() in EXT
                 and f.stat().st_size > a.over * 1048576)
    if not big:
        print(f'ما في ملفّ صوت فوق {a.over:.0f} ميغا بـ{src} — ما في شي نعمله')
        return

    if not a.dry_run:
        need('ffmpeg')

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
