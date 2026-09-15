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
  && [ -f "$TMP/ok/sw.js" ]
check "الملفات اللازمة موجودة" $?

# ---------- مسار اللوحة السرّي ----------
# اللوحة لازم تكون على المسار المضبوط، ومو على /admin/ — وإلا المسار
# السرّي بلا فايدة وأي حدا بيلاقي صفحة الدخول.
[ -f "$TMP/ok/kmh123475674/index.html" ] && [ ! -e "$TMP/ok/admin" ]
check "★ اللوحة على المسار السرّي، ومو على /admin/" $?

# قاعدة الـnoindex لازم تتبع المسار، وإلا بتضل تشير لمجلد مو موجود
grep -q '^/kmh123475674/\*' "$TMP/ok/_headers" && ! grep -q '^/admin/\*' "$TMP/ok/_headers"
check "قاعدة _headers اتبعت المسار" $?

# مسار مخصّص من البيئة
ADMIN_PATH=zzz9 ./tools/build_dist.sh "$TMP/custom" >/dev/null 2>&1 \
  && [ -f "$TMP/custom/zzz9/index.html" ] && [ ! -e "$TMP/custom/kmh123475674" ] \
  && grep -q '^/zzz9/\*' "$TMP/custom/_headers"
check "ADMIN_PATH بيغيّر المسار والترويسات" $?

# مسار فيه شرطة مائلة لازم ينرفض — بيعمل مجلدات متداخلة بلا قصد
! ADMIN_PATH=a/b ./tools/build_dist.sh "$TMP/bad" >/dev/null 2>&1
check "ADMIN_PATH فيه / بينرفض" $?

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

# ٣) ★ content/ — نصوص الامتحانات مع سطور «Lösung:»
sed 's|cp -r assets/icons "$OUT/assets/"|cp -r assets/icons "$OUT/assets/"\ncp -r content "$OUT/"|' \
  tools/build_dist.sh > tools/_leak_content.sh
chmod +x tools/_leak_content.sh
./tools/_leak_content.sh "$TMP/leak3" >/dev/null 2>&1
[ $? -ne 0 ]
check "★ الحارس بيرفض لما content/ توصل للناتج" $?

# ٤) ★ نصّ امتحان متنكّر: الاسم text.txt وحده كافي يوقف البناء
sed 's|cp -r assets/icons "$OUT/assets/"|cp -r assets/icons "$OUT/assets/"\nmkdir -p "$OUT/assets/x" \&\& cp docs/vorlage/b1-beispiel.txt "$OUT/assets/x/text.txt"|' \
  tools/build_dist.sh > tools/_leak_txt.sh
chmod +x tools/_leak_txt.sh
./tools/_leak_txt.sh "$TMP/leak4" >/dev/null 2>&1
[ $? -ne 0 ]
check "★ وبيمسك نصّ امتحان مدسوس بمجلّد تاني" $?

# ---------- مجلّد المحتوى ----------
node tools/check_content.mjs >/dev/null 2>&1
check "فحص content/ بيمرق" $?

# ★ نصوص telc B1 مولّدة من data/ — لو حدا عدّل وحدة بلا التانية بينكشف
node tools/sync_b1_content.mjs --check >/dev/null 2>&1
check "★ content/telc/b1 مطابق لـdata/ (ما نسيت تعيدي التوليد)" $?

# وكلهن لازم يكونوا معبّيين فعلاً، مو فاضيين.
# ★ العدد من data/index.json مو رقم مثبّت: النماذج بتزيد، والفحص
#   المثبّت بيفشل على إضافة صحيحة بدل ما يمسك خلل.
WANT=$(python3 -c "import json;print(len(json.load(open('data/index.json'))['modelle']))")
N=$(node tools/check_content.mjs telc/b1 2>/dev/null | grep -c '✓ telc/b1')
[ "$N" = "$WANT" ]
check "★ كل نماذج B1 موجودين ومقروئين ($N من $WANT)" $?

# ★ نصّ مكسور لازم يفشل الفحص، وإلا الفحص بلا فايدة
mkdir -p "$TMP/ctest/telc/zz/modell-01"
printf '# KAPUTT\n### Teil: x\nFormat: nonsense\n' > "$TMP/ctest/telc/zz/modell-01/text.txt"
( cd "$TMP" && ln -sfn "$OLDPWD/admin" admin 2>/dev/null || true )
check "★ ملف بلا كتل بينمسك (تحذيرات)" \
  "$(node -e "
    const M = require('./admin/parse.js');
    const r = M.parse('# KAPUTT\n### Teil: x\nFormat: nonsense\n');
    process.exit(r.warnings.length > 0 ? 0 : 1);
  " >/dev/null 2>&1; echo $?)"

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

# ---------- vorlagen.js مطابق لملفات القوالب ----------
# القوالب مصدرها الـ.txt، واللوحة بتقرا النسخة المولّدة. لو انحرفوا،
# الزرّ بيلزق شي غير يلي انفحص بالاختبارات.
./tools/build_vorlagen.sh >/dev/null 2>&1
git diff --quiet -- admin/vorlagen.js 2>/dev/null
check "★ vorlagen.js محدّث من docs/vorlage/*.txt" $?

# اللوحة لازم تحمّل الملف، وإلا VORLAGE_* مو معرّفة والزرّ بيرمي خطأ
grep -q 'src="vorlagen.js"' admin/index.html
check "اللوحة بتحمّل vorlagen.js" $?

# ---------- الترحيلات بتنقرا ----------
# ★ كان بالبايبلاين بس، فخطأ نحوي بيمرق محلياً وبيوقف البناء بعد
#   الدفع. Postgres حيّ ما بيكفي: بيقبل أشياء المحلّل السكوني
#   بيرفضها (الإسناد لحقل جوّا %rowtype مثلاً).
python3 tools/check_sql.py >/dev/null 2>&1
check "★ كل الترحيلات بتنقرا (نفس فحص البايبلاين)" $?

# ---------- بذور مولّدة من content/ ----------
# ★ انلدغنا قبل: أجزاء b1 ضلّت مولّدة من ١٦ نموذج بعد ما صاروا ١٧،
#   ومين لصقهن فاته نموذج كامل بلا ما ينتبه. الفحص هون بدل الانتباه.
#
# ★ وبالدوران على كل مستوى معبّى، مو بقايمة مكتوبة بالإيد: أي مستوى
#   جديد بينضاف بيندخل بالفحص لحاله. قايمة مثبّتة معناها إنّ مستوى
#   جديد بيمرق بلا فحص وما حدا بينتبه.
SEEDED=0
for D in content/*/*/; do
  P=$(basename "$(dirname "$D")"); L=$(basename "$D")

  # ★ الاسم بياخد المؤسسة كمان.
  # كان بيشتقّ «supabase/seed/<درجة>.sql» وبس — وأوّل ما صار في مؤسستين
  # بنفس الدرجة (ÖSD A1 وGoethe A1)، الملف صار ملك وحدة والتانية
  # انتخطّت **بصمت**: مستوى كامل برّا الفحص، وهاد بالضبط الشي يلي هالفحص
  # موجود ليمنعه. القديم بيضل شغّال، والجديد بياخد <مؤسسة>-<درجة>.sql.
  SEED=""
  for C in "supabase/seed/$P-$L.sql" "supabase/seed/$L.sql"; do
    [ -f "$C" ] && grep -q "content/$P/$L" "$C" 2>/dev/null && { SEED="$C"; break; }
  done

  WANT=$(node tools/check_content.mjs "$P/$L" 2>/dev/null | grep -c "✓ $P/$L")

  # ★ معبّى وبلا بذور = محتوى ما رح يوصل لولا طالب، وما حدا بينتبه.
  # القوالب الفاضية ما إلها بذور وهاد طبيعي، فالتنبيه بيطلع لما يكون
  # في نماذج معبّاية فعلاً.
  # telc/b1 بذوره مولّدة من data/ مو من content/ (ومعرّف مستواه «b1» من
  # أيام ما كان في مستوى واحد)، فما بينطبق عليه الدوران هون — بس إله
  # فحصه هو تحت، مو استثناء مفتوح.
  if [ -z "$SEED" ] && [ "$P/$L" = "telc/b1" ]; then continue; fi

  if [ -z "$SEED" ]; then
    if [ "$WANT" != 0 ]; then
      false
      check "★ content/$P/$L فيه $WANT نموذج معبّى بلا ملف بذور" $?
    fi
    continue
  fi
  SEEDED=$((SEEDED + 1))

  node tools/content_to_seed.mjs "$P/$L" "$SEED" >/dev/null 2>&1
  git diff --quiet -- "$SEED" 2>/dev/null
  check "★ $SEED مطابق لـcontent/$P/$L" $?

  # كل نموذج معبّى لازم يوصل للبذور — مو بس يمرق الفحص
  GOT=$(grep -c "^insert into tests" "$SEED")
  [ "$WANT" = "$GOT" ]
  check "★ وكل نماذجه وصلت ($GOT من $WANT)" $?
done
[ "$SEEDED" -gt 0 ]
check "★ في بذور مولّدة من content/ ($SEEDED مستوى)" $?

# ---------- ★ صحّة data/ نفسها ----------
# الملفّات هدول مصدر B1 كله. غلطتين صاروا فيهن وما بان أثرهن إلا
# بالتصحيح عند الطالب:
#
# · جواب صح-خطأ مكتوب «+» أو «-» (علامات ورقة إجابات telc) بدل r/f.
#   التطبيق بيبعت r أو f، فولا وحدة كانت بتطابق: ٤٥ سؤال بتلات نماذج
#   كانوا بينحسبوا غلط دايماً. وأسوأ: التحويل لنصّ كان بيخلّي «+»
#   تصير «falsch»، يعني ٢٢ جواب صح انقلبوا غلط بصمت.
# · بلوك بيقول «ناقص ٩ أسئلة» بعد ما انكمّل — الطالب بيشوف تحذير كذب
#   وبتنعاد حسبة نقاطه على أساس غلط.
node -e '
const fs=require("fs"); const M=require("./admin/parse.js");
let bad=[];
for (const f of fs.readdirSync("data").filter(x=>/^modell-\d+\.json$/.test(x))){
  const o=JSON.parse(fs.readFileSync("data/"+f,"utf8"));
  for (const s of o.sections||[])
    if (s.format==="truefalse")
      for (const i of s.items||[])
        if (i.answer!=="r" && i.answer!=="f")
          bad.push(`${f} ${s.id}/${i.id}=${JSON.stringify(i.answer)}`);
  // ★ قسم ربط/بنك بلا بنك = أسئلة بلا خيارات: الطالب بيشوف السؤال
  //   وما بيلاقي شي يضغطه. صار فعلاً بنموذجين، لأنّ البنك انكتب باسم
  //   «pool» — اسم ما بيعرفه ولا مكان بالنظام، فانضاع بصمت.
  for (const s of o.sections||[])
    if (["matching","wordbank"].includes(s.format) && !(s.bank||[]).length)
      bad.push(`${f} ${s.id}: ${s.format} بلا bank`);
  for (const b of o.blocks||[]){
    const secs=(b.parts||[]).map(p=>(o.sections||[]).find(s=>s.id===p)).filter(Boolean);
    const av=secs.reduce((a,s)=>a+(s.availablePoints??0),0);
    const ms=secs.reduce((a,s)=>a+(s.missing??0),0);
    if (b.availablePoints!==av || b.missing!==ms)
      bad.push(`${f} ${b.id}: ${b.availablePoints}n/${b.missing} ← ${av}n/${ms}`);
  }
}
if (bad.length){ console.error(bad.slice(0,4).join(" · ")); process.exit(1); }
'
check "★ data/: أجوبة صح-خطأ r/f · بنوك موجودة · نقاط الكتل مطابقة" $?

# ---------- ★ بذرة B1: الثغرة الوحيدة يلي كانت مكشوفة ----------
# b1.sql مولّد من data/ بطريق تانية، فدوران البذور فوق ما بيلمسه. يعني
# كان الملف الوحيد يلي بيقدر يصير قديم بصمت — وهاد بالضبط يلي صار:
# نموذجين (TAMARA وJAN) ضلّوا بالقاعدة بنسخة ناقصة ١٨ سؤال، وما حدا
# انتبه إلا لما عدّينا الأسئلة بالإيد.
python3 tools/export_sql.py data "$TMP/b1.sql" --level b1 >/dev/null 2>&1
cmp -s "$TMP/b1.sql" supabase/seed/b1.sql
check "★ supabase/seed/b1.sql مطابق لـdata/ (ما نسيت تعيدي التوليد)" $?

# وكل نموذج بـdata/ لازم يوصل للبذرة
WANT=$(ls data/modell-*.json 2>/dev/null | wc -l)
GOT=$(grep -c "^insert into tests" supabase/seed/b1.sql)
[ "$WANT" = "$GOT" ]
check "★ وكل نماذج data/ وصلت ($GOT من $WANT)" $?

# الأجزاء المقسّمة لازم تتبع ملفاتها الكاملة
for F in supabase/seed/parts/*-1.sql; do
  L=$(basename "$F" -1.sql)
  ./tools/split_seed.sh "$L" >/dev/null 2>&1
done
git diff --quiet -- supabase/seed/parts/ 2>/dev/null
check "★ والأجزاء مطابقة للملفات الكاملة" $?

# ---------- حجم الصور ----------
# ★ الطالب على موبايل بشبكة ضعيفة، وصور الامتحان بتنجاب وحدة وحدة برابط
#   موقّع. مسح صفحة بـPNG بيطلع ٢ ميغا — بلا خسارة يعني بيخزّن ضجيج
#   الماسح حرف بحرف. نفس الصفحة بـJPEG ٨٥ بتصير ٢٦٠ ك.ب والنص متل ما هو.
#   الحدّ هون تا ما ترجع وحدة كبيرة تندسّ بصمت.
#
# ★ العنوان بلا $( ) بداخله. استبدال الأمر بينفّذ **قبل** ما ينقرا `$?`
#   وبيدعسه بنتيجته هو — فالفحص كان بيطبع الملف المخالف وبيقول ✓ بنفس
#   السطر. منبدّل الأسطر بتوسيع متغيّر، وبلا صدفة تانية.
BIG=$(find content -path '*/img/*' -type f -size +500k 2>/dev/null | head -5)
[ -z "$BIG" ]
check "★ ما في صورة أكبر من ٥٠٠ ك.ب بـcontent/${BIG:+ — ${BIG//$'\n'/ }}" $?

# وPNG بمحتوى ممسوح = الصيغة الغلط. الأداة بتحوّلهن:
#   python3 tools/shrink_images.py content
PNGS=$(find content -path '*/img/*.png' -type f | wc -l)
[ "$PNGS" = 0 ]
check "★ ولا PNG بصور الامتحانات ($PNGS) — tools/shrink_images.py" $?

python3 -c "import ast,sys; ast.parse(open('tools/shrink_images.py').read())"
check "shrink_images.py صحيح نحوياً" $?

# ---------- ربط التسجيلات ----------
# ★ الأداة بتنسخ وبتكتب `Hörtext:` بضربة. الفحص بيجرّبها على بنية
#   تحميل حقيقية الشكل — مجلّد لكل نموذج، وملفّ لكل جزء — وبيتأكّد إنّ
#   الاسم الناتج بيحمل مستواه. دلو الصوت مسطّح متل دلو الصور، و
#   «modell-01-hv1.mp3» موجود بتلات مستويات: بلا بادئة بيدعسوا بعض.
DL="$TMP/dl/modell-01_PETRA"; mkdir -p "$DL"
: > "$DL/hv1_Arbeitsplatz.mp3"; : > "$DL/hv2_Verein.mp3"
: > "$DL/modell-01_PETRA_hoeren_komplett.mp3"
OUT=$(node tools/link_audio.mjs "$TMP/dl" telc/b1 --dry-run 2>&1)
echo "$OUT" | grep -q 'audio/telc-b1-m01-hv1.mp3' \
  && echo "$OUT" | grep -q 'audio/telc-b1-m01-hv2.mp3'
check "★ ربط التسجيلات: الاسم بيحمل مستواه (telc-b1-m01-hv1.mp3)" $?

echo "$OUT" | grep -q 'للامتحان كامل'
check "★ وملفّ الامتحان الكامل بينتخطّى مع سببه، ما بينحطّ بقسم غلط" $?

git diff --quiet -- data/ content/ 2>/dev/null
check "★ و--dry-run ما بيلمس ولا ملف" $?

# ★ بنية التحميل الحقيقية: مجلّدات مرقّمة باسم المستوى، وأسماء ملفّات
#   طويلة فيها اسم النموذج قبل الجزء. هون بالضبط غلطنا أوّل مرّة —
#   التعليمات كانت تفترض «~/downloads/telc-b1» والواقع «02_telc_b1».
B2="$TMP/dl/03_telc_b2_beruf/modell-08_FIRMENORGANIGRAMM"; mkdir -p "$B2"
: > "$B2/modell-08_FIRMENORGANIGRAMM_teil1.mp3"
: > "$B2/modell-08_FIRMENORGANIGRAMM_hoeren_schreiben.mp3"
mv "$TMP/dl/modell-01_PETRA" "$TMP/dl/02_telc_b1_modell" 2>/dev/null
mkdir -p "$TMP/dl/02_telc_b1"; mv "$TMP/dl/02_telc_b1_modell" "$TMP/dl/02_telc_b1/modell-01_PETRA"
OUT=$(node tools/link_audio.mjs "$TMP/dl" --dry-run 2>&1)
echo "$OUT" | grep -q '02_telc_b1  →  telc/b1' \
  && echo "$OUT" | grep -q '03_telc_b2_beruf  →  telc/b2'
check "★ المستوى بينستنتج من اسم المجلّد (02_telc_b1 · 03_telc_b2_beruf)" $?

echo "$OUT" | grep -q 'audio/telc-b2-m08-hv1.mp3' \
  && echo "$OUT" | grep -q 'audio/telc-b2-m08-hvs.mp3'
check "★ و«_teil1» و«_hoeren_schreiben» بيوصلوا hv1 وhvs" $?

# ★ الرفع لازم يلمّ الشجرة كلها. الصور انصلّحت من زمان والصوت ضلّ
#   ناقص — و`upload_audio.py content` كانت بتموت بـ«ما في ملفات صوت»
#   بينما ٥٥ ملفّ تحتها. ونفس حارس التصادم: الدلو مسطّح.
HERE=$PWD
AT="$TMP/at/content/telc/b1/modell-01/audio"; mkdir -p "$AT"
: > "$AT/telc-b1-m01-hv1.mp3"
( cd "$TMP/at" && python3 "$HERE/tools/upload_audio.py" content --dry-run ) \
  2>&1 | grep -q 'telc-b1-m01-hv1.mp3'
check "★ رفع الصوت بيلمّ الشجرة كلها (مو مجلّد واحد)" $?

mkdir -p "$TMP/at/content/oesd/a1/modell-01/audio"
: > "$TMP/at/content/oesd/a1/modell-01/audio/telc-b1-m01-hv1.mp3"
! ( cd "$TMP/at" && python3 "$HERE/tools/upload_audio.py" content --dry-run ) \
  >/dev/null 2>&1
check "★ وبيرفض اسمين متل بعض — الدلو مسطّح" $?

# ★ التسجيلات ما بتنحفظ بـgit: مئات الميغات بتتعلّق برقبة كل نسخة
git check-ignore -q content/telc/b1/modell-01/audio/x.mp3 \
  && ! git check-ignore -q content/telc/b1/modell-01/audio/.gitkeep
check "★ الصوت مستثنى من git، و.gitkeep محفوظ" $?

python3 -c "import ast,sys; ast.parse(open('tools/shrink_audio.py').read())"
check "shrink_audio.py صحيح نحوياً" $?

# ★ دلو Supabase بيرفض فوق ٥٠ ميغا («Payload too large»)، وأربع ملفّات
#   بـtelc B2 طلعوا ٦٤–٨٠ ميغا وفشل رفعهن. وحتى مع حدّ أعلى: ٨٠ ميغا
#   لقسم استماع واحد كارثة على طالب بالموبايل — باقي أقسام نفس المستوى
#   ٢٫٣ ميغا. الأداة بتمسك الكبير وبس.
SA="$TMP/sa/content/telc/b2/modell-08/audio"; mkdir -p "$SA"
python3 -c "
import pathlib,sys
p=pathlib.Path(sys.argv[1])
(p/'big.mp3').write_bytes(b'x'*(60*1024*1024))
(p/'small.mp3').write_bytes(b'x'*(2*1024*1024))" "$SA"
OUT=$(cd "$TMP/sa" && python3 "$HERE/tools/shrink_audio.py" content --dry-run 2>&1)
echo "$OUT" | grep -q 'big.mp3' && ! echo "$OUT" | grep -q 'small.mp3'
check "★ تصغير الصوت: بيمسك الكبير وبيترك الصغير" $?

# ★★ والترميز الحقيقي، مو بس الكشف.
#   أوّل نسخة كانت بتسمّي المؤقّت «hv1.mp3.tmp» — وffmpeg بيختار صيغة
#   الإخراج من الامتداد، فطلع «Unable to choose an output format» وفشلت
#   الأربعة كلها عند المستخدم. الفحص كان بيمرق لأنّه بيجرّب --dry-run بس.
if command -v ffmpeg >/dev/null 2>&1; then
  RE="$TMP/re/content/telc/b2/modell-08/audio"; mkdir -p "$RE"
  ffmpeg -y -loglevel error -f lavfi -i "sine=frequency=300:duration=20" \
    -ac 2 -b:a 320k "$RE/telc-b2-m08-hv1.mp3" 2>/dev/null
  SZ0=$(stat -c%s "$RE/telc-b2-m08-hv1.mp3")
  ( cd "$TMP/re" && python3 "$HERE/tools/shrink_audio.py" content --over=0.1 \
      --bitrate=64k ) >/dev/null 2>&1
  SZ1=$(stat -c%s "$RE/telc-b2-m08-hv1.mp3" 2>/dev/null || echo 0)
  [ "$SZ1" -gt 0 ] && [ "$SZ1" -lt "$SZ0" ]
  check "★★ الترميز بيشتغل فعلاً ($((SZ0/1024)) ← $((SZ1/1024)) ك.ب)" $?

  [ -z "$(find "$RE" -name '*__tmp__*' 2>/dev/null)" ]
  check "★ وما بيخلّي ملفّات مؤقّتة وراه" $?
else
  echo "  · ffmpeg مو مثبّت — تخطّي فحص الترميز"
fi

# ★ وما بيضلّ ملفّ فوق حدّ الدلو بالمحتوى
BIGA=$(find content -path '*/audio/*' -type f -size +49M 2>/dev/null | head -3 | tr '\n' ' ')
[ -z "$BIGA" ]
check "★ ولا تسجيل فوق ٤٩ ميغا (حدّ الدلو)${BIGA:+ — $BIGA}" $?

# ★ الدلو مسطّح: كل الصور بتنزل جنب بعض تحت img/، فالاسم لازم يكون
#   فريد بكل المستويات مو بالمستوى لحاله.
#
#   انلدغنا: ÖSD كان عنده m01-lv3.png وtelc عنده m01-lv3.jpg — الامتداد
#   لحاله كان بيفرق بينهن. أوّل ما انحوّلت ÖSD لـJPEG صاروا نفس الاسم،
#   وهاد ما بان إلا لما وقف الرفع بوجه المستخدم. الفحص هون بدل الوجع.
#   (الجداد بياخدوا بادئة مستواهم: oesd-a1-… · goethe-a1-… — وtelc B1
#    ضل بلا بادئة لأنّ صوره مرفوعة بالإنتاج من زمان.)
#   content/ لحاله: data/img نسخة منه لـtelc B1 (sync_b1_content.mjs)،
#   وضمّها بيعطي كل صور B1 «مكرّرة» وهي نفس الصورة. والرفع أصلاً من
#   content/.
DUP=$(find content -path '*/img/*' -type f ! -name '.gitkeep' -printf '%f\n' \
      | sort | uniq -d | head -5 | tr '\n' ' ')
[ -z "$DUP" ]
check "★ أسماء الصور فريدة بكل المستويات (الدلو مسطّح)${DUP:+ — $DUP}" $?

# ---------- فحص الجاهزية ----------
# ★ health.sql أداة تشخيص: لازم تشتغل **على قاعدة فاضية** كمان، لأنّ
#   هيك بالضبط حالة مين بيشغّلها. فحص بيموت على المشكلة يلي المفروض
#   يشخّصها بلا فايدة — وهاد صار بأوّل نسخة منه.
if psql -h /tmp -p "${PGPORT:-5433}" -U postgres -c '' 2>/dev/null; then
  psql -h /tmp -p "${PGPORT:-5433}" -U postgres -q \
    -c "drop database if exists healthtest;" -c "create database healthtest;" >/dev/null 2>&1

  OUT=$(psql -h /tmp -p "${PGPORT:-5433}" -U postgres -d healthtest \
        -f supabase/health.sql 2>&1)
  [ $? = 0 ] && ! echo "$OUT" | grep -q "^ERROR"
  check "★ health.sql بيشتغل على قاعدة فاضية بلا ما يموت" $?

  echo "$OUT" | grep -q "شغّل supabase/setup.sql"
  check "★ وبيقول شو لازم يعمل مو بس «فيه خطأ»" $?

  # وعلى قاعدة كاملة: لازم يمرق وما يشتكي من السكيما
  psql -h /tmp -p "${PGPORT:-5433}" -U postgres -d healthtest -q \
    -f supabase/tests/bootstrap.sql >/dev/null 2>&1
  psql -h /tmp -p "${PGPORT:-5433}" -U postgres -d healthtest -q \
    -f supabase/setup.sql >/dev/null 2>&1
  OUT=$(psql -h /tmp -p "${PGPORT:-5433}" -U postgres -d healthtest \
        -f supabase/health.sql 2>&1)
  ! echo "$OUT" | grep -q "^ERROR"
  check "★ وعلى سكيما كاملة كمان" $?

  echo "$OUT" | grep -qE "نسخة السكيما.*✅|✅.*نسخة السكيما"
  check "★ وبيعرف إنّ السكيما صارت محدّثة" $?

  # ★ والفحص لازم يمسك صور ناقصة — وإلا ما إله فايدة
  psql -h /tmp -p "${PGPORT:-5433}" -U postgres -d healthtest -q >/dev/null 2>&1 <<'SQL'
insert into levels (id, title, published, provider, stufe)
  values ('ht-b1','HT B1',true,'ht','B1') on conflict do nothing;
insert into tests (level_id, slug, title, blocks, aufgaben, published, sort)
  values ('ht-b1','ht-01','HT',  '[]'::jsonb, 1, true, 1) on conflict do nothing;
insert into sections (test_id, section_id, title, format, config, sort)
  select t.id,'lv3','LV3','matching','{"bankImage":"img/ht-01.jpg"}'::jsonb,0
    from tests t where t.slug='ht-01' on conflict do nothing;
SQL
  psql -h /tmp -p "${PGPORT:-5433}" -U postgres -d healthtest \
    -f supabase/health.sql 2>&1 | grep -q "ناقصة"
  check "★★ وبيمسك صورة مطلوبة ومو مرفوعة" $?

  # وبعد ما تنرفع بيرضى
  psql -h /tmp -p "${PGPORT:-5433}" -U postgres -d healthtest -q >/dev/null 2>&1 <<'SQL'
insert into storage.buckets (id, name) values ('exam-images','exam-images')
  on conflict do nothing;
insert into storage.objects (bucket_id, name) values ('exam-images','img/ht-01.jpg');
SQL
  psql -h /tmp -p "${PGPORT:-5433}" -U postgres -d healthtest \
    -f supabase/health.sql 2>&1 | grep -q "1 من 1 مرفوعة"
  check "★★ وبيرضى لما تنرفع" $?

  psql -h /tmp -p "${PGPORT:-5433}" -U postgres -q \
    -c "drop database healthtest;" >/dev/null 2>&1
else
  echo "  · Postgres مو شغّال — تخطّي فحص health.sql"
fi

# ---------- رقم السكيما مكتوب بتلات أمكنة ----------
# ★ الترحيل بيعلن schema_version()، واللوحة وhealth.sql بيقارنوا فيه —
#   وكل واحد فيهن رقم مكتوب بالإيد. 0031 انكتب والاتنين بقيوا على ٣٠:
#   health.sql بيقول «✅ عندك ٣١ · لازم ٣٠» واللوحة ما بتنبّه إنّ القاعدة
#   ورا. ما بينكسر شي، بس التحذير يلي مهمّته يمسك النقص بيصير كذب.
LAST_MIG=$(grep -l "create or replace function schema_version" \
             supabase/migrations/*.sql | sort | tail -1)
WANT=$(grep -oE "select [0-9]+" "$LAST_MIG" | tail -1 | grep -oE "[0-9]+")
HAVE_ADMIN=$(grep -oE "const SCHEMA_MIN = [0-9]+" admin/admin.js | grep -oE "[0-9]+")
HAVE_HEALTH=$(grep -oE "when v >= [0-9]+" supabase/health.sql | grep -oE "[0-9]+")
[ -n "$WANT" ] && [ "$HAVE_ADMIN" = "$WANT" ] && [ "$HAVE_HEALTH" = "$WANT" ]
check "★ رقم السكيما واحد بالترحيل واللوحة وhealth.sql ($WANT · $HAVE_ADMIN · $HAVE_HEALTH)" $?

# ---------- setup.sql مطابق للترحيلات ----------
./tools/build_setup.sh >/dev/null 2>&1
git diff --quiet -- supabase/setup.sql 2>/dev/null
check "★ setup.sql محدّث من الترحيلات (ما نسيت تعيدي التوليد)" $?

# آمن للإعادة: ثلاث تشغيلات على قاعدة نظيفة بلا خطأ
if psql -h /tmp -p "${PGPORT:-5433}" -U postgres -c '' 2>/dev/null; then
  psql -h /tmp -p "${PGPORT:-5433}" -U postgres -q \
    -c "drop database if exists setuptest;" -c "create database setuptest;" >/dev/null 2>&1
  psql -h /tmp -p "${PGPORT:-5433}" -U postgres -d setuptest -q \
    -f supabase/tests/bootstrap.sql >/dev/null 2>&1
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

# ---------- النشر بأمر واحد ----------
bash -n tools/deploy_db.sh; check "deploy_db.sh سليم" $?

# بلا رابط بينوقف، ما بيحاول يوصل لقاعدة ما إلها اسم
OUT=$(DATABASE_URL= ./tools/deploy_db.sh 2>&1 || true)
case "$OUT" in *DATABASE_URL*) R=0 ;; *) R=1 ;; esac
check "★ بلا DATABASE_URL بيوقف وبيقول من وين تجيبيه" $R

if psql -h /tmp -p "${PGPORT:-5433}" -U postgres -c '' 2>/dev/null; then
  # ★ الفحص الحقيقي: قاعدة فاضية ← أمر واحد ← المحتوى كامل جوّا.
  #   بلاه، «شغّلي هالأمر» بالتعليمات بيضل وعد ما انجرّب — وصار قبل:
  #   upload_audio.py content انكتب بالتعليمات وهو ما بيلمّ الشجرة.
  psql -h /tmp -p "${PGPORT:-5433}" -U postgres -q \
    -c "drop database if exists deploytest;" -c "create database deploytest;" >/dev/null 2>&1
  psql -h /tmp -p "${PGPORT:-5433}" -U postgres -d deploytest -q \
    -f supabase/tests/bootstrap.sql >/dev/null 2>&1
  DATABASE_URL="postgresql://postgres@127.0.0.1:${PGPORT:-5433}/deploytest" \
    ./tools/deploy_db.sh >/dev/null 2>&1
  GOT=$(psql -h /tmp -p "${PGPORT:-5433}" -U postgres -d deploytest -tAc \
    "select count(*)||'/'||(select count(*) from items) from tests;" 2>/dev/null)
  WANT_T=$(grep -c "^-- ================= modell-" supabase/seed/*.sql | \
           awk -F: '{s+=$2} END {print s}')
  [ "${GOT%%/*}" = "$WANT_T" ] && [ "${GOT##*/}" -gt 2000 ]
  check "★★ قاعدة فاضية ← أمر واحد ← كل المحتوى جوّا ($GOT امتحان/سؤال)" $?
  psql -h /tmp -p "${PGPORT:-5433}" -U postgres -q \
    -c "drop database deploytest;" >/dev/null 2>&1
else
  echo "  · Postgres مو شغّال — تخطّي فحص deploy_db.sh"
fi

# ---------- run.sh ----------
bash -n run.sh;             check "run.sh سليم" $?
bash -n tools/build_dist.sh; check "build_dist.sh سليم" $?

echo
if [ "$FAIL" = 0 ]; then echo "✓ كل الـ$PASS اختبارات نجحت"; else
  echo "✗ $FAIL فشل من $((PASS+FAIL))"; exit 1; fi
