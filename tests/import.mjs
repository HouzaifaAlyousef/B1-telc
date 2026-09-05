/* البرهان الكامل للاستيراد:
   نص ملصوق ← محلّل المتصفّح ← قاعدة البيانات ← امتحان قابل للتصحيح.
   وبنفس الوقت نتأكد إن الحلول المستوردة انحطّت بالجدول المقفول. */
import { createRequire } from 'module';
import { readFileSync } from 'fs';
import { execFileSync } from 'child_process';
import path from 'path';
const require = createRequire(import.meta.url);
const ROOT = path.resolve(import.meta.dirname, '..');
const M = require(path.join(ROOT, 'admin/parse.js'));

const ADMIN = 'aaaaaaaa-0000-0000-0000-000000000001';
const STUD  = 'bbbbbbbb-0000-0000-0000-000000000002';
const psql = q => execFileSync('psql',
  ['-h','/tmp','-p', process.env.PGPORT || '5433','-U','postgres','-d','telc','-tAq','-v','ON_ERROR_STOP=1','-c', q],
  { encoding:'utf8', maxBuffer: 64*1024*1024 }).trim();
const asRole = (uid, q) => psql(
  `set local role authenticated;
   select set_config('request.jwt.claim.sub','${uid}',true);
   ${q}`).split('\n').map(l=>l.trim()).filter(Boolean).pop();

/* الاختبار بيبني حالته بنفسه بدل ما يتّكل على اختبار تاني شغّل قبله —
   ترتيب التشغيل ما لازم يكون شرط للنجاح. */
psql(`
  delete from admin_audit_log; delete from mistakes; delete from attempts;
  delete from imports; delete from resources;
  delete from tests where level_id <> 'b1'; delete from levels where id <> 'b1';
  delete from devices; delete from subscriptions; delete from access_codes;
  delete from profiles; delete from auth.users;

  insert into auth.users (id) values ('${ADMIN}'), ('${STUD}');
  insert into profiles (id, is_admin, display_name) values
    ('${ADMIN}', true,  'Admin'),
    ('${STUD}',  false, 'Student');
  insert into subscriptions (user_id, levels, current_period_end)
  values ('${STUD}', array['b1'], now() + interval '30 days');
`);

const R = [];
const check = (l, c) => { R.push([l,!!c]); console.log(`  ${c?'✓':'✗'} ${l}`); };

console.log('\n=== استيراد: نص ← قاعدة بيانات ← تصحيح ===');
try {
  // ---- ١) نبني نص لصق من امتحان حقيقي ----
  const src = JSON.parse(readFileSync(path.join(ROOT,'data/modell-03.json'),'utf8'));
  src.title = 'IMPORTTEST';
  const raw = M.serialize(src);
  const { test: doc, warnings, counts } = M.parse(raw);
  check(`التحليل: ${counts.sections} قسم، ${counts.items} سؤال، ${counts.answers} حل، ${warnings.length} تحذير`,
        counts.sections === 9 && counts.items === 61 && counts.answers === 60 && warnings.length === 0);

  // ---- ٢) مستوى جديد: a2 ----
  const lvl = asRole(ADMIN, `select admin_upsert_level('a2','telc Deutsch A2',1,true);`);
  check('إنشاء مستوى A2', JSON.parse(lvl).ok === true);

  // ---- ٣) حفظ المسوّدة ثم اعتمادها ----
  const esc = s => s.replace(/\$/g, '');   // ما في $ بالمحتوى، بس للأمان مع dollar-quoting
  const impId = psql(`insert into imports (level_id, raw_text, parsed, status, created_by)
    values ('a2', $raw$${esc(raw)}$raw$, $doc$${JSON.stringify(doc)}$doc$::jsonb,
            'parsed', '${ADMIN}') returning id;`);
  check('المسوّدة انحفظت مع النص الخام', /^[0-9a-f-]{36}$/.test(impId));

  const applied = JSON.parse(asRole(ADMIN,
    `select admin_apply_import('${impId}','a2','modell-a2-01', true);`));
  check(`الاعتماد: ${applied.sections} قسم، ${applied.items} سؤال، ${applied.answers} حل`,
        applied.ok && applied.sections === 9 && applied.items === 61 && applied.answers === 60);
  check('حالة المسوّدة صارت applied',
        psql(`select status from imports where id='${impId}';`) === 'applied');

  // ---- ٤) الحلول بالجدول المقفول ----
  const inItems = psql(`select count(*) from items i join sections s on s.id=i.section_id
    join tests t on t.id=s.test_id where t.slug='modell-a2-01'
    and (i.text like '%answer%' or i.options::text like '%"answer"%');`);
  check('★ ما في حلول مخبّاية بجدول الأسئلة', Number(inItems) === 0);

  // ---- ٥) إعادة الاعتماد ما بتكرّر ----
  const again = JSON.parse(asRole(ADMIN,
    `select admin_apply_import('${impId}','a2','modell-a2-01', true);`));
  const total = psql(`select count(*) from items i join sections s on s.id=i.section_id
    join tests t on t.id=s.test_id where t.slug='modell-a2-01';`);
  check(`إعادة الاعتماد بتستبدل ما بتكرّر (${total} سؤال)`,
        again.ok && Number(total) === 61);

  // ---- ٦) طالب مشترك بـb1 ما بيشوف a2 ----
  const seen = asRole(STUD, `select count(*) from tests where level_id='a2';`);
  check('★ مشترك b1 ما بيشوف امتحانات a2', Number(seen) === 0);

  // ---- ٧) نعطيه a2 وبعدين يصحّح ----
  psql(`update subscriptions set levels = array['b1','a2'] where user_id='${STUD}';`);
  const seen2 = asRole(STUD, `select count(*) from tests where level_id='a2';`);
  check('بعد ما انضاف a2 لاشتراكه صار يشوفه', Number(seen2) === 1);

  const tid = psql(`select id from tests where slug='modell-a2-01';`);
  const answers = psql(`select coalesce(jsonb_object_agg(i.id::text, ia.answer),'{}'::jsonb)
    from items i join item_answers ia on ia.item_id=i.id
    join sections s on s.id=i.section_id
    where s.test_id='${tid}' and s.section_id in ('lv1','lv2','lv3','sb1','sb2');`);
  const res = JSON.parse(asRole(STUD,
    `select submit_attempt('${tid}','block-lv-sb', $a$${answers}$a$::jsonb);`));
  check(`تصحيح الامتحان المستورد: ${res.points}/${res.max_points} = ${res.pct}%`,
        res.ok && Number(res.pct) === 100);

  // ---- ٨) المراجع ----
  const rid = JSON.parse(asRole(ADMIN,
    `select admin_save_resource(null,'a2','Wortschatz A2',
       $b$## Verben\nsein, haben, gehen$b$, true, 0);`));
  check('حفظ مرجع', rid.ok);
  const rSeen = asRole(STUD, `select count(*) from resources where published;`);
  check('الطالب بيشوف المرجع المنشور', Number(rSeen) === 1);

  asRole(ADMIN, `select admin_save_resource('${rid.id}','a2','Wortschatz A2', $b$x$b$, false, 0);`);
  const rHid = asRole(STUD, `select count(*) from resources;`);
  check('المرجع غير المنشور بينخفي عن الطالب', Number(rHid) === 0);

  // ---- ٩) إخفاء امتحان ----
  asRole(ADMIN, `select admin_set_test_published('${tid}', false);`);
  const tHid = asRole(STUD, `select count(*) from tests where level_id='a2';`);
  check('إخفاء امتحان بيشيله عن الطالب فوراً', Number(tHid) === 0);

  // ---- ١٠) غير الأدمن ممنوع ----
  let blocked = false;
  try { asRole(STUD, `select admin_apply_import('${impId}','a2','x', true);`); }
  catch { blocked = true; }
  check('★ الطالب ممنوع من الاستيراد', blocked);

  // ---- ١١) القالب المرجعي: docs/vorlage/b1-beispiel.txt ----
  // هاد الملف هو يلي بينلزق من زر «Beispiel einfügen» وهو الأساس يلي
  // بيتعبّى منه الذكاء الاصطناعي. لازم يمرق للقاعدة بلا تحذير، ولازم
  // الصورة والصوت وملحقات التعبير الكتابي يوصلوا لآخر الطريق — هني
  // بالذات يلي بينضاعوا لأنهن بيسافروا جوّا config مو بأعمدة.
  const muster = readFileSync(path.join(ROOT,'docs/vorlage/b1-beispiel.txt'),'utf8');
  const mp = M.parse(muster);
  check(`القالب المرجعي: ${mp.counts.sections} قسم، ${mp.counts.items} سؤال، `
      + `${mp.warnings.length} تحذير`,
        mp.counts.sections === 9 && mp.warnings.length === 0
        && mp.test.title === 'MUSTER-01');
  check('القالب فيه الصيغ الخمسة كلها',
        new Set(mp.test.sections.map(x => x.format)).size === 5);

  const mId = psql(`insert into imports (level_id, raw_text, parsed, status, created_by)
    values ('a2', $raw$${muster.replace(/\$/g,'')}$raw$,
            $doc$${JSON.stringify(mp.test)}$doc$::jsonb, 'parsed', '${ADMIN}') returning id;`);
  const mApp = JSON.parse(asRole(ADMIN,
    `select admin_apply_import('${mId}','a2','muster-01', true);`));
  check('القالب المرجعي انعتمد', mApp.ok && mApp.sections === 9);

  const cfg = k => psql(`select config->>'${k}' from sections s
    join tests t on t.id=s.test_id where t.slug='muster-01' and s.section_id='lv3';`);
  check('★ مسار الصورة وصل للقاعدة', cfg('bankImage') === 'img/muster-01-lv3.jpg');

  const au = psql(`select config->>'audio' || '×' || (config->>'audioPlays') from sections s
    join tests t on t.id=s.test_id where t.slug='muster-01' and s.section_id='hv3';`);
  check('★ الهörtext وعدد التشغيلات وصلوا', au === 'muster-01-hv3.mp3×2');

  const sa = psql(`select jsonb_array_length(config->'criteria') || '/' ||
      (config->>'factor') || '/' || (config->'brief'->>'signature')
    from sections s join tests t on t.id=s.test_id
    where t.slug='muster-01' and s.section_id='sa';`);
  check('★ ملحقات التعبير الكتابي (معايير/معامل/رسالة) وصلوا', sa === '3/3/Petra');

  const wItem = psql(`select (i.meta->>'minWords') || '/' ||
      jsonb_array_length(i.meta->'points')
    from items i join sections s on s.id=i.section_id
    join tests t on t.id=s.test_id where t.slug='muster-01' and s.section_id='sa';`);
  check('★ الحد الأدنى للكلمات والنقاط الأربعة وصلوا', wItem === '100/4');

  const expl = psql(`select ia.explanation is not null from item_answers ia
    join items i on i.id=ia.item_id join sections s on s.id=i.section_id
    join tests t on t.id=s.test_id where t.slug='muster-01'
    and s.section_id='lv1' and i.item_id='1';`);
  check('شرح الحل وصل لجدول الحلول', expl === 't');

  // ---- ١٢) القالب الفاضي: نفس الهيكل، بلا حلول ----
  const leer = readFileSync(path.join(ROOT,'docs/vorlage/b1-leer.txt'),'utf8');
  const lp = M.parse(leer);
  check(`القالب الفاضي: ${lp.counts.sections} قسم، ${lp.counts.items} سؤال`,
        lp.counts.sections === 9 && lp.counts.items === 61);
  check('القالب الفاضي بيوصل نفس ٢٢٥ نقطة يلي بيوصلها امتحان حقيقي',
        lp.test.blocks.reduce((a,b) => a + b.maxPoints, 0) === 225);
  // ★ القالب الفاضي لازم يمرق بالهيكل، بس **ما** يمرق بصمت: كل خانة
  // <…> ما انتعبّت لازم تنبلّغ. بلا هالفحص، خانة نسيها الذكاء
  // الاصطناعي بتنستورد كأنها محتوى — «Lösung: <A bis J>» بتصير حل
  // ما بيطلع صح ولا مرة والطالب ما بيعرف ليش.
  const holes = lp.warnings.filter(w => /nicht ausgefüllt/.test(w));
  check('★ القالب الفاضي بينبّه على الخانات الفاضية', holes.length === 1);
  check('القالب المعبّى ما بينبّه ولا خانة',
        mp.warnings.filter(w => /nicht ausgefüllt/.test(w)).length === 0);

  // ---- ١٣) التدقيق ----
  const log = psql(`select count(*) from admin_audit_log
    where action in ('import.apply','level.upsert','resource.create','test.publish');`);
  check(`إجراءات المحتوى انسجّلت (${log})`, Number(log) >= 5);

} catch (e){
  console.log('\n✗ استثناء:', String(e.stderr || e.message).split('\n').slice(0,4).join('\n'));
  R.push(['اكتمل بلا استثناء', false]);
}
const bad = R.filter(r => !r[1]);
console.log(bad.length ? `\n✗ ${bad.length} فشل من ${R.length}` : `\n✓ كل الـ${R.length} اختبارات نجحت`);
process.exit(bad.length ? 1 : 0);
