/* اختبار لوحة التحكّم بالمتصفّح.
   السيرفر الوهمي هون مو مزيّف بالكامل: كل نداء بينترجم لاستعلام حقيقي
   على قاعدة Postgres المحلية، وبينفّذ بهويّة الأدمن — يعني الدوال يلي
   بتنجرّب هي نفسها يلي رح تشتغل بالإنتاج. */
import { chromium } from 'playwright';
import { readFileSync } from 'fs';
import { execFileSync } from 'child_process';
import http from 'http';
import path from 'path';

const ROOT = path.resolve(import.meta.dirname, '..');
const ADMIN = 'aaaaaaaa-0000-0000-0000-000000000001';

const sql = (q) => {
  const out = execFileSync('psql', ['-h','/tmp','-p','5433','-U','postgres','-d','telc',
    '-tAc', q], { encoding: 'utf8', maxBuffer: 32 * 1024 * 1024 });
  return out.trim();
};
// كل نداء بينلفّ بـset role authenticated + هويّة الأدمن، متل Supabase بالضبط
const asAdmin = (inner) => {
  const out = sql(`set local role authenticated;
   select set_config('request.jwt.claim.sub', '${ADMIN}', true);
   ${inner}`);
  const lines = out.split('\n').map(l => l.trim()).filter(Boolean);
  return lines[lines.length - 1];        // آخر سطر = ناتج الاستعلام الأخير
};

const MIME = { '.html':'text/html', '.js':'text/javascript', '.css':'text/css' };
const server = http.createServer(async (req, res) => {
  const u = new URL(req.url, 'http://x');
  const send = (code, body) => {
    res.writeHead(code, { 'content-type':'application/json' });
    res.end(typeof body === 'string' ? body : JSON.stringify(body));
  };

  // ---- auth ----
  if (u.pathname === '/auth/v1/token'){
    let b = ''; for await (const c of req) b += c;
    const { email, password } = JSON.parse(b || '{}');
    if (email === 'admin@test.de' && password === 'geheim')
      return send(200, { access_token:'ADMIN', refresh_token:'R',
                         expires_at: Math.floor(Date.now()/1000) + 3600 });
    return send(400, { error_description: 'Invalid login credentials' });
  }

  // ---- rpc ----
  if (u.pathname.startsWith('/rest/v1/rpc/')){
    const fn = u.pathname.split('/').pop();
    let b = ''; for await (const c of req) b += c;
    const args = JSON.parse(b || '{}');
    // PostgREST بيحوّل JSON للأنواع المناسبة — منقلّده هون
    const q = x => `'${String(x).replace(/'/g, "''")}'`;
    const lit = v =>
        v === null || v === undefined ? 'null'
      : Array.isArray(v) ? `array[${v.map(x => q(x))}]::text[]`
      : typeof v === 'object' ? `${q(JSON.stringify(v))}::jsonb`
      : typeof v === 'number'  ? String(v)
      : typeof v === 'boolean' ? String(v)
      : q(v);
    const named = Object.entries(args).map(([k, v]) => `${k} => ${lit(v)}`).join(', ');
    try {
      // admin_create_codes بترجّع setof، الباقي قيمة وحدة
      const out = fn === 'admin_create_codes'
        ? asAdmin(`select coalesce(jsonb_agg(c), '[]'::jsonb) from ${fn}(${named}) c;`)
        : asAdmin(`select coalesce(to_jsonb(${fn}(${named})), 'null'::jsonb);`);
      return send(200, out);
    } catch (e){
      const m = String(e.stderr || e.message);
      return send(/privilege|not_admin/.test(m) ? 403 : 400,
                  { message: m.split('\n').find(l => l.includes('ERROR')) || 'error' });
    }
  }

  // ---- select على جدول ----
  if (u.pathname.startsWith('/rest/v1/')){
    const table = u.pathname.split('/').pop();
    const cols  = (u.searchParams.get('select') || '*').replace(/\s/g,'');
    const ord   = u.searchParams.get('order');
    const lim   = u.searchParams.get('limit');
    let q = `select coalesce(jsonb_agg(t), '[]'::jsonb) from (select ${cols} from ${table}`;
    if (ord){ const [c, d] = ord.split('.'); q += ` order by ${c} ${d === 'desc' ? 'desc':'asc'}`; }
    if (lim) q += ` limit ${Number(lim)}`;
    q += ') t;';
    try { return send(200, asAdmin(q)); }
    catch (e){ return send(400, { message: String(e.stderr || e.message).slice(0, 200) }); }
  }

  // ---- ملفات ----
  let f = u.pathname === '/' ? '/admin/index.html' : u.pathname;
  try {
    res.writeHead(200, { 'content-type': MIME[path.extname(f)] || 'text/plain' });
    res.end(readFileSync(path.join(ROOT, f)));
  } catch { res.writeHead(404); res.end('nope'); }
});
await new Promise(r => server.listen(0, r));
const PORT = server.address().port;

/* حالة نظيفة: الاختبار لازم يعطي نفس النتيجة كل مرة، فمنشيل يلي
   خلّفته تشغيلات سابقة قبل ما نبلّش. */
const ADMIN_ID = 'aaaaaaaa-0000-0000-0000-000000000001';
const STUD_ID  = 'bbbbbbbb-0000-0000-0000-000000000002';
sql(`delete from writing_feedback; delete from admin_audit_log; delete from mistakes;
     delete from attempts; delete from imports; delete from resources;
     delete from tests where level_id <> 'b1';
     delete from levels where id <> 'b1';
     delete from devices; delete from subscriptions; delete from access_codes;
     delete from profiles; delete from auth.users;

     insert into auth.users (id) values ('${ADMIN_ID}'), ('${STUD_ID}');
     insert into profiles (id, is_admin, display_name, note) values
       ('${ADMIN_ID}', true,  'Admin', null),
       ('${STUD_ID}',  false, 'أحمد', 'واتساب 0176…');
     insert into subscriptions (user_id, levels, current_period_end)
     values ('${STUD_ID}', array['b1'], now() + interval '30 days');
     insert into access_codes (code, levels, duration_days, redeemed_at, redeemed_by)
     values ('B1-SEED-0001', array['b1'], 30, now(), '${STUD_ID}');`);

const results = [];
const check = (l, c) => { results.push([l, !!c]); console.log(`  ${c ? '✓' : '✗'} ${l}`); };

const HARD = setTimeout(() => { console.log('\n✗ انتهت المهلة'); process.exit(2); }, 80000);
const browser = await chromium.launch({ args:['--no-sandbox','--disable-dev-shm-usage'] });
const page = await browser.newPage();
page.setDefaultTimeout(8000);
page.on('pageerror', e => { console.log('  ✗ JS-Fehler:', e.message);
                            results.push(['بلا أخطاء JS', false]); });

console.log('\n=== اختبار لوحة التحكّم ===');
try {
  // config.js الحقيقي فيه قيم نائبة وبيغطّي أي شي منحطّه قبله
  await page.route('**/assets/config.js', r => r.fulfill({
    contentType: 'text/javascript',
    body: `window.TELC_CONFIG = { supabaseUrl: 'http://127.0.0.1:${PORT}', supabaseAnonKey: 'test' };`
  }));
  await page.goto(`http://127.0.0.1:${PORT}/admin/index.html`);

  await page.waitForSelector('#mail');
  check('شاشة الدخول بتطلع', await page.locator('#mail').isVisible());

  await page.fill('#mail', 'admin@test.de'); await page.fill('#pw', 'ghalat');
  await page.evaluate(() => document.getElementById('go').click());
  await page.waitForTimeout(500);
  check('كلمة سر غلط بترفض', (await page.textContent('body')).includes('Invalid'));

  await page.fill('#mail', 'admin@test.de'); await page.fill('#pw', 'geheim');
  await page.evaluate(() => document.getElementById('go').click());
  await page.waitForSelector('.stats');
  const stats = await page.textContent('.stats');
  check('الدخول نجح وطلعت الأرقام', stats.includes('Nutzer'));
  check('بيعرض المستخدم والاشتراك الفعّال', /1[\s\S]*Nutzer/.test(stats));

  // ---- نشاط إدخال الأكواد ----
  const home = await page.textContent('#app');
  check('بطاقة نشاط الأكواد ظاهرة بالصفحة الرئيسية',
        /Code-Eingaben/.test(home));
  check('★ وبتشرح متى بينقفل الإدخال',
        /Fehlversuchen in \d+/.test(home));

  // ---- المستخدمون ----
  await page.evaluate(() => document.querySelector('[data-tab="users"]').click());
  await page.waitForSelector('table');
  check('جدول المستخدمين فيه أحمد', (await page.textContent('table')).includes('أحمد'));

  const before = sql(`select current_period_end::date from subscriptions
                      where user_id='bbbbbbbb-0000-0000-0000-000000000002';`);
  await page.evaluate(() => document.querySelector('[data-shift="30"]').click());
  await page.waitForTimeout(900);
  const after = sql(`select current_period_end::date from subscriptions
                     where user_id='bbbbbbbb-0000-0000-0000-000000000002';`);
  check(`زرّ +30 مدّد فعلياً بقاعدة البيانات (${before} ← ${after})`,
        new Date(after) - new Date(before) === 30 * 86400000);

  const logged = sql(`select count(*) from admin_audit_log where action='sub.extend';`);
  check(`الإجراء انسجّل بالتدقيق (${logged})`, Number(logged) >= 1);

  // ---- الأكواد ----
  await page.evaluate(() => document.querySelector('[data-tab="codes"]').click());
  await page.waitForSelector('#c_go');
  const codesBefore = Number(sql('select count(*) from access_codes;'));
  await page.fill('#c_n', '3');
  await page.evaluate(() => document.getElementById('c_go').click());
  await page.waitForSelector('.codes');
  const shown = await page.locator('.codes div').count();
  const codesAfter = Number(sql('select count(*) from access_codes;'));
  check(`توليد ٣ أكواد: ظهروا ${shown} وانحفظوا ${codesAfter - codesBefore}`,
        shown === 3 && codesAfter - codesBefore === 3);

  // ---- التدقيق ----
  await page.evaluate(() => document.querySelector('[data-tab="audit"]').click());
  await page.waitForSelector('table');
  check('صفحة التدقيق بتعرض الإجراءات',
        (await page.textContent('table')).includes('code.create'));

  // ---- المحتوى: إنشاء مستوى ----
  await page.evaluate(() => document.querySelector('[data-tab="content"]').click());
  await page.waitForSelector('#l_go');
  await page.fill('#l_id', 'a1'); await page.fill('#l_title', 'telc Deutsch A1');
  await page.evaluate(() => document.getElementById('l_go').click());
  // ننتظر إعادة الرسم فعلياً بدل مهلة عمياء — إعادة الرسم بتمسح الحقول
  await page.waitForFunction(() =>
    document.querySelector('table') && document.body.textContent.includes('telc Deutsch A1'));
  await page.waitForTimeout(300);
  check('إنشاء مستوى A1 وصل لقاعدة البيانات',
        sql(`select title from levels where id='a1';`) === 'telc Deutsch A1');

  // ---- المراجع ----
  await page.fill('#r_title', 'Wortschatz A1');
  await page.fill('#r_body', '## Verben\n\nsein, haben');
  await page.evaluate(() => document.getElementById('r_save').click());
  await page.waitForFunction(() => document.body.textContent.includes('Wortschatz A1'));
  await page.waitForTimeout(300);
  check('حفظ مرجع منشور',
        sql(`select count(*) from resources where title='Wortschatz A1' and published;`) === '1');

  // ---- الأكواد: شو بيفتح الكود ----
  await page.evaluate(() => document.querySelector('[data-tab="codes"]').click());
  await page.waitForSelector('#c_hint');
  await page.waitForTimeout(400);
  const hint = await page.textContent('#c_hint');
  check(`سطر «شو بيفتح» ظاهر (${hint.replace(/\s+/g,' ').trim().slice(0,60)})`,
        /Öffnet|Stufe hat gerade/.test(hint));
  check('★ بيقول إن باقي المستويات بتضل مقفولة',
        /Andere Stufen bleiben zu/.test(hint) || /keine/.test(hint));

  check('★ بيقول على كم جهاز الكود بينفّذ', /Gerät/.test(hint));
  check('★ وبيقول إن المستوى التاني بده كود تاني',
        /zweiten Code/.test(hint) || /keine/.test(hint));

  // عدد التفعيلات بيتغيّر ← السطر بيتحدّث
  await page.fill('#c_uses', '1');
  await page.waitForTimeout(200);
  check('تبديل عدد التفعيلات بيتحدّث بالسطر',
        /1 Gerät\b/.test(await page.textContent('#c_hint')));
  await page.fill('#c_uses', '2');

  // تبديل المدّة بيحدّث السطر
  await page.selectOption('#c_days', '90');
  await page.waitForTimeout(200);
  check('السطر بيتحدّث مع تغيير المدّة',
        (await page.textContent('#c_hint')).includes('90'));

  // الكود المولّد بياخد المستوى المختار فقط
  const lvlNow = await page.evaluate(() => document.getElementById('c_lvl').value);
  await page.fill('#c_n', '1');
  await page.evaluate(() => document.getElementById('c_go').click());
  await page.waitForSelector('.codes');
  const lastLevels = sql(`select levels::text from access_codes
    order by created_at desc limit 1;`);
  check(`★ الكود انولّد لمستوى واحد فقط (${lastLevels})`, lastLevels === `{${lvlNow}}`);
  const lastUses = sql(`select max_uses::text from access_codes
    order by created_at desc limit 1;`);
  check(`★ وبتفعيلين (${lastUses})`, lastUses === '2');

  // الجدول بيعرض العدّاد
  await page.waitForTimeout(300);
  const tbl = await page.textContent('table');
  check('الجدول بيعرض «2× frei»', /2×\s*frei/.test(tbl));

  // ---- الاستيراد: المثال ----
  await page.evaluate(() => document.querySelector('[data-tab="import"]').click());
  await page.waitForSelector('#i_sample');
  await page.evaluate(() => document.getElementById('i_sample').click());
  await page.waitForSelector('.preview');
  const nums = await page.locator('.stat b').allTextContents();
  check(`المعاينة عدّت صح (${nums.join('/')})`, nums[2] === '2' && nums[3] === '2');
  check('زرّ النشر مفتوح لأن ما في أخطاء',
        !(await page.locator('#i_apply').isDisabled()));

  // ---- الاستيراد: نص فيه خطأ ----
  await page.fill('#i_text', '# KAPUTT\n\n## Block: b1\nTeile: nichtda\n');
  await page.evaluate(() => document.getElementById('i_parse').click());
  await page.waitForSelector('.warns');
  check('النص الناقص بيعطي تحذير وبيقفل النشر',
        (await page.textContent('.warns')).includes('nichtda')
        && await page.locator('#i_apply').isDisabled());

  // ---- الاستيراد: نشر فعلي ----
  await page.evaluate(() => document.getElementById('i_sample').click());
  await page.waitForSelector('.preview');
  await page.selectOption('#i_lvl', 'a1');
  await page.fill('#i_slug', 'probe-a1-01');
  await page.evaluate(() => document.getElementById('i_apply').click());
  await page.waitForTimeout(1500);
  const made = sql(`select count(*) from items i
    join sections s on s.id=i.section_id join tests t on t.id=s.test_id
    where t.slug='probe-a1-01';`);
  const ans = sql(`select count(*) from item_answers ia join items i on i.id=ia.item_id
    join sections s on s.id=i.section_id join tests t on t.id=s.test_id
    where t.slug='probe-a1-01';`);
  check(`النشر أنشأ الامتحان بقاعدة البيانات (${made} سؤال، ${ans} حل)`,
        made === '2' && ans === '2');
  check('الحلول راحت للجدول المقفول مو للأسئلة',
        sql(`select count(*) from items i join sections s on s.id=i.section_id
             join tests t on t.id=s.test_id where t.slug='probe-a1-01'
             and i.options::text like '%answer%';`) === '0');

  // ---- الحارس: مستخدم عادي ما بيدخل ----
  await page.evaluate(() => localStorage.clear());
  await page.reload();
  await page.waitForSelector('#mail');
  check('بعد الخروج بيرجع لشاشة الدخول', await page.locator('#mail').isVisible());

} catch (err){
  console.log('\n✗ وقف عند:', err.message.split('\n')[0]);
  console.log((await page.textContent('body').catch(() => '')).slice(0, 300));
  results.push(['اكتمل بلا استثناء', false]);
}
clearTimeout(HARD);
await browser.close();
server.close();
const bad = results.filter(r => !r[1]);
console.log(bad.length ? `\n✗ ${bad.length} فشل من ${results.length}`
                       : `\n✓ كل الـ${results.length} اختبارات نجحت`);
process.exit(bad.length ? 1 : 0);
