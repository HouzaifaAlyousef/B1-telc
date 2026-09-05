#!/usr/bin/env bash
# بناء المجلد القابل للنشر.
#
# سبب وجوده الأساسي: منع خطأ واحد قاتل. مجلد data/ لسا فيه الـ٨٩٦ حل،
# ونشره بيلغي كل الحماية مهما عملت قاعدة البيانات. بدل ما نتذكّر نستثنيه
# كل مرة، هالسكربت بينسخ يلي لازم فقط — وبيفحص الناتج قبل ما يخلص.
#
# مسار اللوحة سرّي بالقصد: ما بدنا صفحة تسجيل دخول على /admin/ يلاقيها
# أي حدا. هاد مو الحارس — الحارس profiles.is_admin بقاعدة البيانات —
# بس بيوفّر عليكي محاولات دخول عمياء وفهرسة محرّكات البحث.
#
#   ./tools/build_dist.sh                    → dist/
#   ./tools/build_dist.sh out/               → out/
#   ADMIN_PATH=xyz ./tools/build_dist.sh     → اللوحة على /xyz/
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="${1:-dist}"
ADMIN_PATH="${ADMIN_PATH:-kmh123475674}"
ADMIN_PATH="${ADMIN_PATH#/}"; ADMIN_PATH="${ADMIN_PATH%/}"
case "$ADMIN_PATH" in
  ''|*/*|.*) echo "✗ ADMIN_PATH لازم يكون مقطع واحد بلا شرطات مائلة" >&2; exit 1 ;;
esac

rm -rf "$OUT"
mkdir -p "$OUT/assets" "$OUT/$ADMIN_PATH"

# ---- تطبيق الطلاب ----
cp index.html manifest.webmanifest sw.js "$OUT/"
cp assets/app.js assets/api.js assets/config.js assets/style.css "$OUT/assets/"
cp -r assets/icons "$OUT/assets/"

# ترويسات Cloudflare — لازم تكون بجذر الناتج. قاعدة الـnoindex مكتوبة
# على /admin/ بالمصدر وبتتحوّل هون للمسار الفعلي.
if [ -f _headers ]; then
  sed "s|^/admin/\*|/$ADMIN_PATH/*|" _headers > "$OUT/_headers"
fi

# ---- لوحة التحكّم ----
# نفس الموقع بمسار تاني: الحارس بقاعدة البيانات (profiles.is_admin) مو
# بسرّية الرابط. للنشر بمكان تاني، انسخي assets/config.js معها.
cp admin/index.html admin/admin.js admin/admin.css admin/parse.js "$OUT/$ADMIN_PATH/"

# ---- الفحص: ولا حل يطلع برّا ----
fail=0
if [ -e "$OUT/data" ]; then
  echo "✗ data/ وصل للناتج — كل مفاتيح الحلول مكشوفة" >&2; fail=1
fi
# اللوحة لازم تكون بمسارها الجديد بس — لو انلقت على /admin/ كمان يعني
# السكربت انكسر والمسار السرّي بلا فايدة
if [ "$ADMIN_PATH" != admin ] && [ -e "$OUT/admin" ]; then
  echo "✗ اللوحة لسا على /admin/ — المسار السرّي ما انطبّق" >&2; fail=1
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
echo "  الطلاب:  $OUT/                 →  الجذر"
echo "  اللوحة:  $OUT/$ADMIN_PATH/  →  /$ADMIN_PATH/"
