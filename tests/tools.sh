#!/usr/bin/env bash
# اختبار الأدوات: سكربت البناء وأدوات الرفع.
# الأهم فيها حارس التسريب — بينجرّب بزرع تسريب حقيقي، مو بقراءة الكود.
set -uo pipefail
cd "$(dirname "$0")/.."

PASS=0; FAIL=0
check(){ if [ "$2" = 0 ]; then echo "  ✓ $1"; PASS=$((PASS+1));
         else echo "  ✗ $1"; FAIL=$((FAIL+1)); fi; }

TMP=$(mktemp -d); trap 'rm -rf "$TMP" tools/_leak_*.sh' EXIT
echo
echo "=== الأدوات ==="

# ---------- build_dist.sh ----------
./tools/build_dist.sh "$TMP/ok" >/dev/null 2>&1
check "البناء العادي بينجح" $?

[ -f "$TMP/ok/index.html" ] && [ -f "$TMP/ok/assets/app.js" ] \
  && [ -f "$TMP/ok/admin/index.html" ] && [ -f "$TMP/ok/sw.js" ]
check "الملفات اللازمة موجودة" $?

[ ! -e "$TMP/ok/data" ] && [ ! -e "$TMP/ok/Doku" ] && [ ! -e "$TMP/ok/tools" ] \
  && [ ! -e "$TMP/ok/supabase" ] && [ ! -e "$TMP/ok/tests" ] && [ ! -e "$TMP/ok/docs" ]
check "ولا مجلد ممنوع وصل" $?

! grep -rqE '"answer"[[:space:]]*:' "$TMP/ok" 2>/dev/null
check "★ ولا مفتاح حل بالناتج" $?

# الحجم: لو قفز فجأة يعني في شي بينتسرّب
SZ=$(du -sk "$TMP/ok" | cut -f1)
[ "$SZ" -lt 700 ]
check "الحجم معقول (${SZ} كيلوبايت < 700)" $?

# ---------- الحارس: تسريب مزروع ----------
# ١) نسخ data/ كامل — الخطأ الكلاسيكي
sed 's|cp -r assets/icons "$OUT/assets/"|cp -r assets/icons "$OUT/assets/"\ncp -r data "$OUT/"|' \
  tools/build_dist.sh > tools/_leak_dir.sh
chmod +x tools/_leak_dir.sh
./tools/_leak_dir.sh "$TMP/leak1" >/dev/null 2>&1
[ $? -ne 0 ]
check "★ الحارس بيرفض لما data/ توصل للناتج" $?

# ٢) ملف حلول باسم تاني — الحارس لازم يقرا المحتوى مو الاسم
sed 's|cp -r assets/icons "$OUT/assets/"|cp -r assets/icons "$OUT/assets/"\ncp data/modell-01.json "$OUT/assets/lang.json"|' \
  tools/build_dist.sh > tools/_leak_file.sh
chmod +x tools/_leak_file.sh
./tools/_leak_file.sh "$TMP/leak2" >/dev/null 2>&1
[ $? -ne 0 ]
check "★ الحارس بيمسك ملف حلول متنكّر باسم تاني" $?

# ---------- أدوات الرفع ----------
python3 -c "import ast,sys; ast.parse(open('tools/upload_images.py').read())"
check "upload_images.py صحيح نحوياً" $?
python3 -c "import ast,sys; ast.parse(open('tools/upload_audio.py').read())"
check "upload_audio.py صحيح نحوياً" $?

# بلا مفاتيح بيئة لازم يوقف بوضوح مو ينهار
OUT=$(SUPABASE_URL= SUPABASE_SERVICE_KEY= python3 tools/upload_images.py data/img 2>&1)
echo "$OUT" | grep -q "SUPABASE_URL"
check "بلا مفاتيح بيئة بيطلع رسالة مفهومة" $?

# البادئة لازم تطابق ما هو محفوظ بـbankImage
WANT=$(python3 -c "
import json; d=json.load(open('data/modell-01.json'))
print([s['bankImage'] for s in d['sections'] if 'bankImage' in s][0])")
# السطر ٢ هو أول ملف؛ awk بيتجاهل المسافات البادئة فالحقل الأول هو المسار
GOT=$(python3 tools/upload_images.py data/img --dry-run 2>/dev/null | sed -n '2p' | awk '{print $1}')
[ "$WANT" = "$GOT" ]
check "★ مسار الرفع يطابق bankImage ($WANT)" $?

# الصوت بلا بادئة — config.audio اسم ملف مجرّد
mkdir -p "$TMP/audio" && : > "$TMP/audio/m01-hv1.mp3"
python3 tools/upload_audio.py "$TMP/audio" --dry-run 2>/dev/null | grep -q "^  m01-hv1.mp3"
check "الصوت بينرفع بلا بادئة" $?

# ---------- setup.sql مطابق للترحيلات ----------
./tools/build_setup.sh >/dev/null 2>&1
git diff --quiet -- supabase/setup.sql 2>/dev/null
check "★ setup.sql محدّث من الترحيلات (ما نسيت تعيدي التوليد)" $?

# آمن للإعادة: ثلاث تشغيلات على قاعدة نظيفة بلا خطأ
if psql -h /tmp -p "${PGPORT:-5433}" -U postgres -c '' 2>/dev/null; then
  psql -h /tmp -p "${PGPORT:-5433}" -U postgres -q \
    -c "drop database if exists setuptest;" -c "create database setuptest;" >/dev/null 2>&1
  psql -h /tmp -p "${PGPORT:-5433}" -U postgres -d setuptest -q >/dev/null 2>&1 <<'SQL'
create schema if not exists auth;
create table auth.users (id uuid primary key default gen_random_uuid());
create or replace function auth.uid() returns uuid language sql stable as
  $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
do $r$ begin
  if not exists (select 1 from pg_roles where rolname='anon') then create role anon; end if;
  if not exists (select 1 from pg_roles where rolname='authenticated') then create role authenticated; end if;
end $r$;
SQL
  ERRS=0
  for _ in 1 2 3; do
    N=$(psql -h /tmp -p "${PGPORT:-5433}" -U postgres -d setuptest \
        -f supabase/setup.sql 2>&1 | grep -cE "^psql.*ERROR")
    ERRS=$((ERRS + N))
  done
  [ "$ERRS" = 0 ]
  check "★ setup.sql بيمرق ٣ مرات بلا خطأ (آمن للإعادة)" $?

  # والفاحص لازم يشتكي من قاعدة بلا محتوى ولا أدمن
  psql -h /tmp -p "${PGPORT:-5433}" -U postgres -d setuptest -f supabase/verify.sql 2>&1 \
    | grep -q "فحص فشل"
  check "★ verify.sql بيمسك التركيب الناقص" $?

  psql -h /tmp -p "${PGPORT:-5433}" -U postgres -q -c "drop database setuptest;" >/dev/null 2>&1
else
  echo "  · Postgres مو شغّال — تخطّي فحص setup.sql"
fi

# ---------- run.sh ----------
bash -n run.sh;             check "run.sh سليم" $?
bash -n tools/build_dist.sh; check "build_dist.sh سليم" $?

echo
if [ "$FAIL" = 0 ]; then echo "✓ كل الـ$PASS اختبارات نجحت"; else
  echo "✗ $FAIL فشل من $((PASS+FAIL))"; exit 1; fi
