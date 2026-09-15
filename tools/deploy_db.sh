#!/usr/bin/env bash
# بينشر السكيما والمحتوى بأمر واحد — بدل ١٤ لصقة بمحرّر SQL.
#
#   export DATABASE_URL='postgresql://postgres:PASS@db.xxxx.supabase.co:5432/postgres'
#   ./tools/deploy_db.sh                 # السكيما + كل المستويات + فحص الصحّة
#   ./tools/deploy_db.sh a1 goethe-a1    # مستويات محدّدة بس
#   ./tools/deploy_db.sh --schema        # السكيما لحالها
#
# الرابط: Supabase ← Settings ← Database ← Connection string ← URI
# ★ خدي الوصلة المباشرة (منفذ 5432)، مو الـpooler (6543): البذور بتجي
#   بمعاملة وحدة كبيرة، والـpooler بيقطعها.
#
# ★ الرابط فيه كلمة سرّ القاعدة. بالبيئة بس — هالملف ما بيكتبها ولا
#   بيطبعها، وpsql ما بيسجّلها بالهيستوري.
#
# كل شي هون آمن للإعادة: setup.sql بيمرق مرّات بلا خطأ، والبذور
# on conflict do update. شغّليه كل ما تغيّر المحتوى.
set -euo pipefail
cd "$(dirname "$0")/.."

: "${DATABASE_URL:?لازم DATABASE_URL بالبيئة — Supabase ← Settings ← Database ← Connection string (URI)}"
command -v psql >/dev/null 2>&1 || {
  echo "✗ لازم psql:  sudo apt install postgresql-client"; exit 1; }

SCHEMA_ONLY=0
ARGS=()
for a in "$@"; do
  case "$a" in
    --schema) SCHEMA_ONLY=1 ;;
    -*) echo "✗ خيار مو معروف: $a"; exit 1 ;;
    *)  ARGS+=("$a") ;;
  esac
done

run(){
  local f="$1"
  [ -f "$f" ] || { echo "✗ ما في $f"; exit 1; }
  printf '▸ %-34s' "$f"
  psql "$DATABASE_URL" -q -v ON_ERROR_STOP=1 -f "$f" >/dev/null
  echo "✓"
}

run supabase/setup.sql

if [ "$SCHEMA_ONLY" = 0 ]; then
  # الترتيب مو عشوائي: كل ملف بيدرج مستواه أول، والمستويات مستقلة
  if [ "${#ARGS[@]}" -gt 0 ]; then LVLS=("${ARGS[@]}")
  else LVLS=(a1 goethe-a1 dtz-b1 b1 b2); fi
  for l in "${LVLS[@]}"; do run "supabase/seed/$l.sql"; done
fi

echo
psql "$DATABASE_URL" -q -f supabase/health.sql 2>/dev/null \
  | sed -n '/الفحص/,$p'
