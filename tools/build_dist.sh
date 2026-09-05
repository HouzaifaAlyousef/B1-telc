#!/usr/bin/env bash
# بناء المجلد القابل للنشر.
#
# سبب وجوده الأساسي: منع خطأ واحد قاتل. مجلد data/ لسا فيه الـ٨٩٦ حل،
# ونشره بيلغي كل الحماية مهما عملت قاعدة البيانات. بدل ما نتذكّر نستثنيه
# كل مرة، هالسكربت بينسخ يلي لازم فقط — وبيفحص الناتج قبل ما يخلص.
#
#   ./tools/build_dist.sh            → dist/
#   ./tools/build_dist.sh out/       → out/
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="${1:-dist}"

rm -rf "$OUT"
mkdir -p "$OUT/assets" "$OUT/admin"

# ---- تطبيق الطلاب ----
cp index.html manifest.webmanifest sw.js "$OUT/"
cp assets/app.js assets/api.js assets/config.js assets/style.css "$OUT/assets/"
cp -r assets/icons "$OUT/assets/"

# ترويسات Cloudflare Pages — لازم تكون بجذر الناتج
[ -f _headers ] && cp _headers "$OUT/"

# ---- لوحة التحكّم على /admin/ ----
# نفس الموقع بمسار تاني: الحارس بقاعدة البيانات (profiles.is_admin) مو
# بسرّية الرابط. للنشر بمكان تاني، انسخي assets/config.js معها.
cp admin/index.html admin/admin.js admin/admin.css admin/parse.js "$OUT/admin/"

# ---- الفحص: ولا حل يطلع برّا ----
fail=0
if [ -e "$OUT/data" ]; then
  echo "✗ data/ وصل للناتج — كل مفاتيح الحلول مكشوفة" >&2; fail=1
fi
for bad in Doku tools docs supabase tests; do
  [ -e "$OUT/$bad" ] && { echo "✗ $bad/ وصل للناتج" >&2; fail=1; }
done
# فحص محتوى: نبحث عن أي بصمة لمفاتيح الحلول بالملفات المنشورة
if grep -rlE '"answer"[[:space:]]*:' "$OUT" 2>/dev/null | grep -q .; then
  echo "✗ في ملف بالناتج فيه مفاتيح حلول:" >&2
  grep -rlE '"answer"[[:space:]]*:' "$OUT" >&2
  fail=1
fi
if grep -q 'YOUR-PROJECT' "$OUT/assets/config.js" 2>/dev/null; then
  echo "⚠  assets/config.js لسا فيه قيم نائبة — املأيها قبل النشر" >&2
fi
[ "$fail" = 0 ] || { echo; echo "البناء فشل الفحص. ما ينتشر." >&2; exit 1; }

echo "✓ $OUT/ جاهز — $(find "$OUT" -type f | wc -l) ملف، $(du -sh "$OUT" | cut -f1)"
echo "  الطلاب:  $OUT/           →  الجذر"
echo "  اللوحة:  $OUT/admin/     →  /admin/"
