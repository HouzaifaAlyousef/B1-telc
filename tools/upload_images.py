#!/usr/bin/env python3
"""رفع صور الإعلانات لدلو Supabase Storage الخاص.

صور Leseverstehen 3 هي محتوى امتحان متل الأسئلة تماماً، فبتنحط بدلو
**خاص** والتطبيق بيجيبها برابط موقّع بينتهي. الدلو العام بيلغي الحماية.

    export SUPABASE_URL=https://xxxx.supabase.co
    export SUPABASE_SERVICE_KEY=eyJ...        # service_role، مو anon
    python3 tools/upload_images.py data/img

مفتاح service_role بيتخطّى RLS — استعمليه من جهازك بس، ولا مرة بالمتصفّح
ولا برفعه على git.
"""
import os, sys, json, mimetypes, argparse, urllib.request, urllib.error
from pathlib import Path

BUCKET = 'exam-images'


def req(method, url, key, data=None, ctype=None, extra=None):
    r = urllib.request.Request(url, data=data, method=method)
    r.add_header('apikey', key)
    r.add_header('authorization', f'Bearer {key}')
    if ctype:
        r.add_header('content-type', ctype)
    for k, v in (extra or {}).items():
        r.add_header(k, v)
    try:
        with urllib.request.urlopen(r, timeout=60) as resp:
            return resp.status, resp.read()
    except urllib.error.HTTPError as e:
        return e.code, e.read()
    except Exception as e:                       # شبكة، DNS، مهلة
        return 0, str(e).encode()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('src', nargs='?', default='data/img', help='مجلد الصور')
    ap.add_argument('--bucket', default=BUCKET)
    ap.add_argument('--prefix', default=None,
                    help='بادئة المسار بالدلو (الافتراضي: اسم المجلد). لازم '
                         'تطابق sections.config.bankImage بالضبط')
    ap.add_argument('--dry-run', action='store_true', help='بس اعرض شو رح ينرفع')
    a = ap.parse_args()

    base = (os.environ.get('SUPABASE_URL') or '').rstrip('/')
    key  = os.environ.get('SUPABASE_SERVICE_KEY') or ''
    if not a.dry_run and (not base or not key):
        sys.exit('لازم SUPABASE_URL و SUPABASE_SERVICE_KEY بالبيئة.\n'
                 'Supabase ← Project Settings ← API ← service_role')

    src = Path(a.src)
    # bankImage محفوظ كـ"img/m01-lv3.jpg" — المسار بالدلو لازم يطابقه حرفياً،
    # فالبادئة بتنشتق من اسم المجلد إلا إذا انحدّدت.
    prefix = a.prefix if a.prefix is not None else src.name
    prefix = prefix.strip('/')
    files = sorted(p for p in src.iterdir() if p.is_file()
                   and p.suffix.lower() in ('.jpg', '.jpeg', '.png', '.webp')) \
            if src.is_dir() else []
    if not files:
        sys.exit(f'ما في صور بـ{src}')

    total = sum(f.stat().st_size for f in files)
    key_of = lambda f: f'{prefix}/{f.name}' if prefix else f.name
    print(f'{len(files)} صورة · {total/1048576:.1f} ميغا · '
          f'{a.bucket}/{prefix + "/" if prefix else ""}')
    if a.dry_run:
        for f in files:
            print(f'  {key_of(f):28} {f.stat().st_size/1024:6.0f} KB')
        return

    # الدلو لازم يكون خاص. إذا موجود ما بنلمسه — ممكن يكون متضبّط عن قصد.
    st, body = req('POST', f'{base}/storage/v1/bucket', key,
                   json.dumps({'name': a.bucket, 'public': False}).encode(),
                   'application/json')
    if st in (200, 201):
        print(f'✓ الدلو {a.bucket} انعمل (خاص)')
    elif st == 409:
        print(f'· الدلو {a.bucket} موجود')
    else:
        print(f'⚠ إنشاء الدلو رجع {st}: {body[:200].decode(errors="replace")}')

    ok = bad = 0
    for f in files:
        ctype = mimetypes.guess_type(f.name)[0] or 'application/octet-stream'
        st, body = req('POST', f'{base}/storage/v1/object/{a.bucket}/{key_of(f)}',
                       key, f.read_bytes(), ctype,
                       {'x-upsert': 'true'})       # إعادة الرفع بتستبدل
        if st in (200, 201):
            ok += 1
            print(f'  ✓ {key_of(f)}')
        else:
            bad += 1
            print(f'  ✗ {key_of(f)} — {st} {body[:150].decode(errors="replace")}')

    print(f'\n{ok} نجحت، {bad} فشلت')
    if ok:
        print(f'المسارات صارت متل "{prefix}/xxx.jpg" — لازم تطابق ما هو محفوظ')
        print('بـsections.config.bankImage. التطبيق بيوقّع الرابط عند العرض.')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
