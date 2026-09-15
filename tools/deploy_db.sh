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

# ★ رسالة كاملة، مو «Zeile 21: DATABASE_URL» تبع bash. الأداة يلي
#   بتقول شو ناقص وما بتقول من وين تجيبه بتوقّف الشغل نص ساعة.
if [ -z "${DATABASE_URL:-}" ]; then
  cat >&2 <<'HELP'
✗ ناقص DATABASE_URL.

من وين تجيبه:
   Supabase ← ⚙ Project Settings ← Database ← Connection string ← URI
   خُد **Session pooler** (منفذ 5432). لو ما اشتغل، جرّب Direct connection.
   ولا تاخد Transaction pooler (منفذ 6543) — بيقطع المعاملات الكبيرة.

بعدها بنفس النافذة:
   export DATABASE_URL='postgresql://postgres.xxxx:PASS@aws-0-eu-central-1.pooler.supabase.com:5432/postgres'
   ./tools/deploy_db.sh

كلمة السرّ هي كلمة سرّ القاعدة (مو مفتاح API). نسيتها؟
   Settings ← Database ← Reset database password

★ الرابط فيه كلمة السرّ: بالنافذة بس. حطّ مسافة قبل export تا ما ينحفظ
  بالـhistory، أو استعمل ملف .env مستثنى من git.
HELP
  exit 2
fi

command -v psql >/dev/null 2>&1 || {
  echo "✗ لازم psql:  sudo apt install postgresql-client"; exit 1; }

# ★ setup.sql بيرمي مئات «NOTICE: policy … does not exist, skipping» —
#   وهاد طبيعي (آمن للإعادة)، بس بيدفن سطر «✓» بجدار نص. التحذيرات
#   والأخطاء بتضل تطلع.
export PGOPTIONS='-c client_min_messages=warning'

# وصلة قبل ما نبلّش: فشل بالسطر الأوّل أوضح من فشل بنص البذور
if ! psql "$DATABASE_URL" -q -tAc 'select 1' >/dev/null 2>&1; then
  # ★ `ERR=$(psql …)` لحاله بيوقّف السكربت فوراً تحت set -e — psql بيرجّع
  #   ٢، والإسناد بيورّث الرقم. يعني الرسالة تحت ما كانت تنطبع أبداً.
  ERR=$(psql "$DATABASE_URL" -tAc 'select 1' 2>&1 | head -3) || true
  cat >&2 <<HELP
✗ ما قدرت أوصل للقاعدة.

$ERR

· «Network is unreachable» ← الوصلة المباشرة بتشتغل على IPv6 بس.
  استعمل **Session pooler** من نفس الصفحة (اسم المستخدم فيه نقطة:
  postgres.xxxx@aws-0-...pooler.supabase.com:5432).
· «password authentication failed» ← كلمة سرّ القاعدة، مو مفتاح API.
  Settings ← Database ← Reset database password
· «Tenant or user not found» ← ناقص الـproject ref من اسم المستخدم.
HELP
  exit 1
fi

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
