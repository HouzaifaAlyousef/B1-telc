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

  // ---- ١١) التدقيق ----
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
