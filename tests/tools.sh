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
cp admin/vorlagen.js "$TMP/vorlagen-before.js"
./tools/build_vorlagen.sh >/dev/null 2>&1
cmp -s "$TMP/vorlagen-before.js" admin/vorlagen.js
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

  cp "$SEED" "$TMP/seed-before.sql"
  node tools/content_to_seed.mjs "$P/$L" "$SEED" >/dev/null 2>&1
  cmp -s "$TMP/seed-before.sql" "$SEED"
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

# ---------- ★★ كل حلّ لازم يكون شي يقدر الطالب يضغطه ----------
# الفحص فوق بيمشي على data/ بس (telc B1). هدول العطبين كانوا بـcontent/:
#
# · محتوى DTZ مكتوب بحروف صغيرة متل الامتحان الأصلي (a–h)، والمحلّل
#   بيرفع مفاتيح البنك لحروف كبيرة وما كان يرفع الحلّ. البنك «C»
#   والحلّ «c»، والمقارنة نصيّة ← ٧٢ سؤال ما فيها ولا جواب صح.
# · وDTZ بيخلط بالجزء الواحد: سؤال صح-خطأ وبعده A/B/C. القسم معلّم mc،
#   فسؤال الصح-خطأ انحفظ بلا خيارات وحلّه كلمة «falsch» ← renderItem
#   بيعمل undefined.map، شاشة بيضا، و٦٥ سؤال ما إلهن وجود.
#
# الاتنين ما بيرموا خطأ ولا بيفشّلوا بذرة — بيوصلوا للطالب.
node -e '
const fs=require("fs"), path=require("path"), M=require("./admin/parse.js");
const bad=[];
const audit=(where, secs)=>{
  for (const s of secs||[]){
    if (s.format==="writing") continue;
    const bank=new Set((s.bank||[]).map(o=>String(o.key)));
    for (const it of s.items||[]){
      if (it.answer==null){ bad.push(`${where} ${s.id}/${it.id}: بلا حلّ`); continue; }
      if (s.format==="truefalse"){
        if (it.answer!=="r" && it.answer!=="f")
          bad.push(`${where} ${s.id}/${it.id}: صح-خطأ بحلّ ${JSON.stringify(it.answer)}`);
        continue;
      }
      const keys=new Set([...bank, ...(it.options||[]).map(o=>String(o.key))]);
      if (!keys.size){ bad.push(`${where} ${s.id}/${it.id}: حلّ بلا خيارات`); continue; }
      if (!keys.has(String(it.answer)))
        bad.push(`${where} ${s.id}/${it.id}: حلّ «${it.answer}» مو من [${[...keys].join("")}]`);
    }
  }
};
for (const f of fs.readdirSync("data").filter(x=>/^modell-\d+\.json$/.test(x)))
  audit("data/"+f, JSON.parse(fs.readFileSync("data/"+f,"utf8")).sections);
for (const prov of fs.readdirSync("content").filter(d=>fs.statSync("content/"+d).isDirectory()))
  for (const lvl of fs.readdirSync(`content/${prov}`).filter(d=>fs.statSync(`content/${prov}/${d}`).isDirectory()))
    for (const m of fs.readdirSync(`content/${prov}/${lvl}`).filter(d=>d.startsWith("modell-"))){
      const f=`content/${prov}/${lvl}/${m}/text.txt`;
      if (!fs.existsSync(f)) continue;
      audit(`${prov}/${lvl}/${m}`, M.parse(fs.readFileSync(f,"utf8")).test.sections);
    }
if (bad.length){ console.error(`${bad.length} سؤال: `+bad.slice(0,3).join(" · ")); process.exit(1); }
'
check "★★ كل حلّ بكل المستويات هو مفتاح موجود بالخيارات (حرفياً)" $?

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

# الأجزاء المقسّمة لازم تتبع ملفاتها الكاملة. المقارنة مع نسخة على جنب
# مو مع git: البذرة بتتعدّل وبتتصحّح قبل ما تنحفظ، والفحص لازم يشتغل
# نفسه سواء الشجرة نظيفة أو لأ.
cp -a supabase/seed/parts "$TMP/parts-before"
for F in supabase/seed/parts/*-1.sql; do
  L=$(basename "$F" -1.sql)
  ./tools/split_seed.sh "$L" >/dev/null 2>&1
done
diff -rq "$TMP/parts-before" supabase/seed/parts >/dev/null 2>&1
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

# ---------- ★ نصّ السؤال لازم يكون سؤال ----------
# ★ تلات نماذج بـtelc/b2 كان نصّ أسئلتها «Lücke 52» حرفياً بدل المقتطف
#   يلي حوالين الفراغ. الطالب بيشوف رقم وبس، وما بيعرف شو المطلوب.
#   الفحص بيمسك أي نايب مكان رجع.
#
# ★ content/dtz برّا الفحص عن قصد: كل نماذجه التسعة بتكتب «Lücke 40:»
#   بنفس الشكل، والنصّ كامل فوق بعلامات (40)…(45). يعني اتّفاق مقصود مو
#   خلل — بخلاف telc/b2 يلي كان خمس نماذج فيه مقتطف وتلاتة لأ.
! grep -rqE --exclude='_vorlage.txt' \
    '^\[[0-9]+\] (Lücke|Lucke|TODO|Platzhalter) *[0-9]*$' \
    content/telc content/goethe content/oesd 2>/dev/null
check "★ ما في سؤال نصّه نايب مكان (Lücke 52) بدل المقتطف" $?

# ★ وفحص مفتاح B2 لازم يضل يقرا: المصدر مشال من الشجرة، فالأداة
#   بتوقف بوضوح بدل ما تنهار.
python3 -c "import ast,sys; ast.parse(open('tools/check_b2_keys.py').read())"
check "check_b2_keys.py صحيح نحوياً" $?

OUT=$(python3 tools/check_b2_keys.py --pdf /nope.pdf 2>&1); [ $? -ne 0 ]
check "★ وبلا مصدر بيوقف، ما بينهار" $?

# ---------- ★ مفتاح DTZ ----------
# ★ مصادر DTZ مسح صور، فالمفتاح منقول بالإيد لـDoku/schluessel/dtz-b1.json.
#   الفحص بيمشي بلا PDF، فبيشتغل بالبايبلاين كمان.
python3 -c "import ast,sys; ast.parse(open('tools/check_dtz_keys.py').read())"
check "check_dtz_keys.py صحيح نحوياً" $?

python3 -c "
import json
d=json.load(open('Doku/schluessel/dtz-b1.json',encoding='utf-8'))
want=[4,5,8,3,5,5,6,3,6]
for m,v in d['schluessel'].items():
    got=[len(t.split()) for t in v.split('|')]
    assert got==want, (m,got)
"
check "★ كل مفتاح منقول شكله صح (٤٥ حلّ بتسع أقسام)" $?

python3 tools/check_dtz_keys.py >/dev/null 2>&1
check "★★ كل حلّ DTZ مطابق للمفتاح المطبوع" $?

# ---------- ★ مفاتيح المستويات يلي مصدرها مسح صور ----------
# ★ ÖSD وGoethe بنفس الأداة مو بتنتين: نفس الشكل بالضبط، والفرق بترميز
#   الخيارات وهو مكتوب بالـJSON.
python3 -c "import ast,sys; ast.parse(open('tools/check_scan_keys.py').read())"
check "check_scan_keys.py صحيح نحوياً" $?

python3 -c "
import json, glob
for f in glob.glob('Doku/schluessel/*.json'):
    d=json.load(open(f,encoding='utf-8'))
    # ملف مفتاح منقول، أو ملف تسجيل قراءة — التنين لازم يقولوا من وين
    assert d.get('schluessel') or d.get('gelesen'), f
    assert d.get('_wie'), f + ' — لازم يقول من وين انجاب'
"
check "★ كل ملف مفتاح/قراءة بيقول من وين انجاب" $?

python3 tools/check_scan_keys.py >/dev/null 2>&1
check "★★ كل حلّ ÖSD وGoethe مطابق للمصدر" $?

# ---------- ★ الصور ----------
# ★ بأقسام كتير الصورة هي مصدر الجواب الوحيد: بنك telc B1 lv3 النصّي
#   فاضي تماماً، وDTZ lv1 نصّه كلّه بالصورة. صورة بمحلّ غلط = قسم بلا
#   جواب، وما في شي بيصرخ وقتها.
python3 -c "import ast,sys; ast.parse(open('tools/check_images.py').read())"
check "check_images.py صحيح نحوياً" $?

python3 tools/check_images.py >/dev/null 2>&1
check "★★ كل صورة موجودة، بمحلّها، بلا يتيم ولا مكرّر" $?

# ---------- ★ جرد التغطية ----------
python3 -c "import ast,sys; ast.parse(open('tools/coverage.py').read())"
check "coverage.py صحيح نحوياً" $?

python3 -c "
import json
d=json.load(open('Doku/schluessel/gelesen.json',encoding='utf-8'))
assert d['gelesen'] and d.get('_offen')
for e in d['gelesen']:
    assert e.get('grund'), e   # كل قسم مقروء لازم يقول ليش وكيف
"
check "★ كل قسم مفحوص بالقراءة مكتوب معه دليله" $?

# ---------- ربط التسجيلات ----------
# ★ الأداة بتنسخ وبتكتب `Hörtext:` بضربة. الفحص بيجرّبها على بنية
#   تحميل حقيقية الشكل — مجلّد لكل نموذج، وملفّ لكل جزء — وبيتأكّد إنّ
#   الاسم الناتج بيحمل مستواه. دلو الصوت مسطّح متل دلو الصور، و
#   «modell-01-hv1.mp3» موجود بتلات مستويات: بلا بادئة بيدعسوا بعض.
DL="$TMP/dl/modell-01_PETRA"; mkdir -p "$DL"
: > "$DL/hv1_Arbeitsplatz.mp3"; : > "$DL/hv2_Verein.mp3"
: > "$DL/modell-01_PETRA_hoeren_komplett.mp3"
: > "$TMP/before-dry"
OUT=$(node tools/link_audio.mjs "$TMP/dl" telc/b1 --dry-run 2>&1)
echo "$OUT" | grep -q 'audio/telc-b1-m01-hv1.mp3' \
  && echo "$OUT" | grep -q 'audio/telc-b1-m01-hv2.mp3'
check "★ ربط التسجيلات: الاسم بيحمل مستواه (telc-b1-m01-hv1.mp3)" $?

echo "$OUT" | grep -q 'للامتحان كامل'
check "★ وملفّ الامتحان الكامل بينتخطّى مع سببه، ما بينحطّ بقسم غلط" $?

[ -z "$(find data content -newer "$TMP/before-dry" -type f -print -quit 2>/dev/null)" ]
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

# ---------- الحلول مقابل مفتاح الكتاب ----------
# ★ الكتاب فيه صفحة Lösungen لكل نموذج. منقارن عليها كل حلّ مخزّن.
#   المفتاح مرجع مو حَكَم: الكتاب من إعداد مجموعة تدريس مو من telc، وفيه
#   أغلاط مثبتة («trotz» بمطرح ما بيصحّ فيه إلا «trotzdem»، «langer» بدل
#   «lange»…). فالمخالفات المقصودة مكتوبة بـDoku/loesungen-abweichungen.json
#   ومعها سببها من النصّ، وأي فرق غيرها بيفشّل — يعني حدا غيّر حلّ بلا سبب.
python3 -c "import ast; ast.parse(open('tools/check_keys.py').read())"
check "check_keys.py صحيح نحوياً" $?

python3 -c "import pymupdf" 2>/dev/null || python3 -c "import pypdf" 2>/dev/null
if [ $? = 0 ] && [ -f "Doku/B1 Telc.pdf" ]; then
  OUT=$(python3 tools/check_keys.py 2>&1); R=$?
  echo "$OUT" | grep -qE "بـ15 نموذج من 19"
  check "★ مفتاح الكتاب انقرا لـ١٥ نموذج" $?
  [ "$R" = 0 ]
  check "★★ كل حلّ مطابق للمفتاح أو مخالفته موثّقة ($(echo "$OUT" | grep -o '[0-9]* مخالفة موثّقة'))" $?
else
  echo "  · بلا مكتبة PDF أو بلا كتاب — تخطّي فحص check_keys.py"
fi

# ---------- تمييز التكرار: من الكتاب ولا من استخراج غلط ----------
# ★ تكرار نصّ بين نموذجين شي طبيعي — الكتاب بيعيد نصوص. الغلط إنّ
#   الاستخراج ياخد صفحة نموذج تاني. الفرق مو بالنصّ، بمطرحه: القسم
#   جوّا شريط صفحات نموذجه ولا برّاه.
python3 -c "import ast,sys; ast.parse(open('tools/check_source.py').read())"
check "check_source.py صحيح نحوياً" $?

python3 -c "import pypdf" 2>/dev/null
if [ $? = 0 ] && [ -f "Doku/B1 Telc.pdf" ]; then
  OUT=$(python3 tools/check_source.py "Doku/B1 Telc.pdf" data --show 2>&1)

  # نموذج 01 كامل بشريطه: تمان أقسام بصفحات متتالية صاعدة
  echo "$OUT" | grep -qE "^01 +2 +3 +5 +7 +8 +9 +10 +11"
  check "★ بيلاقي كل قسم بصفحته: نموذج 01 → ص ٢…١١ بالترتيب" $?

  # والحكم بشقّين: «من الكتاب» و«استخراج غلط» — مو رقم واحد
  echo "$OUT" | grep -q "تكرار من الكتاب نفسه" && echo "$OUT" | grep -q "استخراج غلط"
  check "★ بيفصل النوعين بالتقرير" $?

  # ★ والبرهان إنّه بيميّز فعلاً: sb1 تبع 01 و04 نصّ واحد بصفحتين
  #   مختلفتين، كل وحدة بشريط نموذجها ← «من الكتاب».
  #   وlv1 تبع 11 صفحته ٢، وهي شريط نموذج 01 ← «استخراج غلط».
  echo "$OUT" | sed -n '/من الكتاب/,/استخراج غلط/p' | grep -q "sb1: نموذج 01"
  check "★★ نفس النصّ بصفحتين مختلفتين = تكرار الكتاب (sb1 01≡04)" $?
  echo "$OUT" | sed -n '/استخراج غلط/,$p' | grep -q "نموذج 11 · lv1"
  check "★★ ونفس الصفحة لنموذجين = استخراج غلط (lv1 تبع 11 ← ص ٢)" $?
else
  echo "  · pypdf أو الكتاب مو موجودين — تخطّي فحص check_source.py"
fi

# ---------- إرجاع ربط الصوت من قائمة الدلو ----------
# ★ ملفّات الصوت مستثناة من git عن قصد، ومحلّها الدائم الدلو. يعني مين
#   ما مسح مجلّد التحميل بعد الرفع ما خسر شي — بس link_audio.mjs بده
#   المجلّد تا يعرف مين لمين. relink_audio بياخد نفس المعلومة من الاسم.
node --check tools/relink_audio.mjs;  check "relink_audio.mjs سليم" $?
node --check tools/lib/audio_link.mjs; check "audio_link.mjs سليم" $?

# كاتب واحد: link_audio ما عاد عنده نسخته الخاصة من setAudio
! grep -q "^function setAudio" tools/link_audio.mjs \
  && grep -q "lib/audio_link.mjs" tools/link_audio.mjs
check "★ كاتب واحد لسطر Hörtext (link_audio بيستورده، ما بيكرّره)" $?

OUT=$(node -e '
import("./tools/lib/audio_link.mjs").then(({ parseAudioName: p, setAudio }) => {
  const fs = require("fs"), os = require("os"), path = require("path");
  // ١) الاسم بينقرا صح، والمزبّط بس
  const ok = p("oesd-a1-m03-hv2.mp3");
  if (!ok || ok.prov !== "oesd" || ok.lvl !== "a1"
      || ok.model !== "modell-03" || ok.sec !== "hv2") throw new Error("parse");
  for (const bad of ["m01-hv1.mp3", "telc-b1-hv1.mp3", "x.txt", "telc-b1-m03-hv2.txt"])
    if (p(bad)) throw new Error("قبل اسم غلط: " + bad);
  // ٢) والكتابة بتصير فعلاً — على نسخة مؤقّتة، مو على المستودع
  const T = fs.mkdtempSync(path.join(os.tmpdir(), "relink-"));
  fs.mkdirSync(path.join(T, "data"), { recursive: true });
  fs.copyFileSync("data/modell-01.json", path.join(T, "data/modell-01.json"));
  const cd = path.join(T, "content/oesd/a1/modell-01");
  fs.mkdirSync(cd, { recursive: true });
  fs.copyFileSync("content/oesd/a1/modell-01/text.txt", path.join(cd, "text.txt"));

  setAudio(T, "telc", "b1", "modell-01", "hv1", "telc-b1-m01-hv1.mp3", 2);
  setAudio(T, "oesd", "a1", "modell-01", "hv2", "oesd-a1-m01-hv2.mp3", 2);

  const j = JSON.parse(fs.readFileSync(path.join(T, "data/modell-01.json"), "utf8"));
  const hv1 = j.sections.find(x => x.id === "hv1");
  if (hv1.audio !== "telc-b1-m01-hv1.mp3" || hv1.audioPlays !== 2)
    throw new Error("data/ ما انكتب");
  const t = fs.readFileSync(path.join(cd, "text.txt"), "utf8");
  if (!/^H(ö|oe)rtext: oesd-a1-m01-hv2\.mp3$/m.test(t)
      || !/^Wiedergaben: 2$/m.test(t)) throw new Error("text.txt ما انكتب");
  // والسطر لازم يكون جوّا قسم hv2، مو بأوّل الملفّ
  const seg = /^### Teil: hv2$([\s\S]*?)(?=^### Teil: |$(?![\s\S]))/m.exec(t);
  if (!seg || !/H(ö|oe)rtext: oesd-a1-m01-hv2/.test(seg[1]))
    throw new Error("انكتب بالقسم الغلط");
  fs.rmSync(T, { recursive: true, force: true });
  console.log("OK");
}).catch(e => { console.log("FAIL " + e.message); });' 2>&1 | tail -1)
[ "$OUT" = "OK" ]
check "★★ الاسم بيرجّع الربط لمحلّه الصح بالمصدرين ($OUT)" $?

# ---------- النشر بأمر واحد ----------
bash -n tools/deploy_db.sh; check "deploy_db.sh سليم" $?

# بلا رابط بينوقف، وبيقول من وين تجيب الرابط — مو «Zeile 21» تبع bash
OUT=$(DATABASE_URL= ./tools/deploy_db.sh 2>&1 || true)
case "$OUT" in *"Connection string"*) R=0 ;; *) R=1 ;; esac
case "$OUT" in *"export DATABASE_URL="*) : ;; *) R=1 ;; esac
check "★ بلا DATABASE_URL بيوقف وبيقول من وين تجيبيه وكيف" $R

# ★ ورابط غلط لازم يشرح، مو يموت بصمت. كان بيموت: تحت set -e،
#   `ERR=$(psql …)` بيورّث رقم خروج psql والسكربت بينتهي قبل الرسالة.
OUT=$(DATABASE_URL='postgresql://postgres:x@127.0.0.1:1/nixda' \
        ./tools/deploy_db.sh 2>&1 || true)
case "$OUT" in *"ما قدرت أوصل للقاعدة"*) R=0 ;; *) R=1 ;; esac
case "$OUT" in *pooler*) : ;; *) R=1 ;; esac
check "★★ رابط غلط بيشرح السبب، ما بيموت بصمت" $R

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

  # ★ التشغيلة التانية هي الصاخبة: setup.sql بيرمي مئات «already exists,
  #   skipping» وبيدفن سطر «✓». وPGOPTIONS ما بتنفع — الـpooler ما
  #   بيمرّرها، فالسكوت لازم يكون جملة SQL بنفس الجلسة.
  NOISE=$(DATABASE_URL="postgresql://postgres@127.0.0.1:${PGPORT:-5433}/deploytest" \
    ./tools/deploy_db.sh 2>&1 | grep -c "NOTICE:" || true)
  [ "$NOISE" = 0 ]
  check "★ إعادة التشغيل بلا جدار NOTICE ($NOISE سطر)" $?
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
