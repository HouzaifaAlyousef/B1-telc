#!/usr/bin/env bash
# يجمّع كل الترحيلات بملف واحد للصق بمحرّر SQL تبع Supabase.
# لصق ١١ ملف بالترتيب تعب وسهل الغلط؛ ملف واحد بيلغي المشكلة.
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="${1:-supabase/setup.sql}"

{
  sed -n '1,16p' supabase/setup.sql 2>/dev/null | grep -q 'التركيب الكامل' \
    && sed -n '/^-- =\{20,\}$/,/^-- =\{20,\}$/p' supabase/setup.sql | head -16 \
    || cat <<'HDR'
-- =====================================================================
-- telc Training — التركيب الكامل بملف واحد
-- مولّد من supabase/migrations/ — لا تعدّليه، عدّلي الترحيلات.
-- =====================================================================
HDR
  for f in supabase/migrations/[0-9]*.sql; do
    printf '\n-- %s\n-- %s\n-- %s\n' \
      "═══════════════════════════════════════════════" \
      "$(basename "$f")" \
      "═══════════════════════════════════════════════"
    cat "$f"
  done
} > "$OUT"

echo "✓ $OUT — $(wc -l < "$OUT") سطر من $(ls supabase/migrations/[0-9]*.sql | wc -l) ترحيل"
