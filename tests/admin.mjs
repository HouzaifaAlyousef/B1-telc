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
/* كل نداء بيولّد عملية psql جديدة، وexecFileSync بيوقف حلقة الأحداث
   لحد ما تخلص — يعني نداءين متوازيين من اللوحة بينفّذوا واحد ورا التاني.
   على عدّاء CI محمّل هاد بيتراكم. الفشل ما بيقول أي نداء تأخّر، فمنقيسه. */
let slowest = { ms: 0, path: '—' };
const server = http.createServer(async (req, res) => {
  const u = new URL(req.url, 'http://x');
  const t0 = Date.now();
  res.on('finish', () => {
    const ms = Date.now() - t0;
    if (ms > slowest.ms) slowest = { ms, path: u.pathname };
    if (ms > 2000) console.log(`  · بطيء ${ms}ms — ${u.pathname}`);
  });
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
    // القراءة قبل الترويسة — بالعكس، ملف ناقص بينهي العملية بـ
    // ERR_HTTP_HEADERS_SENT بدل ما يرجّع ٤٠٤
    const body = readFileSync(path.join(ROOT, f));
    res.writeHead(200, { 'content-type': MIME[path.extname(f)] || 'text/plain' });
    res.end(body);
  } catch { res.writeHead(404); res.end('nope'); }
});
await new Promise(r => server.listen(0, r));
const PORT = server.address().port;

/* حالة نظيفة: الاختبار لازم يعطي نفس النتيجة كل مرة، فمنشيل يلي
   خلّفته تشغيلات سابقة قبل ما نبلّش. */
const ADMIN_ID = 'aaaaaaaa-0000-0000-0000-000000000001';
const STUD_ID  = 'bbbbbbbb-0000-0000-0000-000000000002';

/* ★ القاعدة لازم تكون كاملة قبل ما نبلّش.
   لو تشغيل سابق مات بنص اختبار «القاعدة ورا»، بتضل schema_version على
   ١٢ وadmin_assets مشالة — والفشل وقتها بيطلع كمهلة عند شاشة الملفات
   بعد ٣٨ فحص، وما بيقول ولا كلمة عن السبب. سطر واضح أرخص بكتير. */
{
  const have = Number(sql('select schema_version();') || 0);
  const fns  = sql(`select count(*) from pg_proc
                     where proname in ('admin_assets','code_norm');`);
  if (have < 21 || fns !== '2'){
    console.log(`\n✗ القاعدة ناقصة (schema_version=${have}, دوال=${fns}/2).`);
    console.log('  شغّل: sudo -E ./supabase/tests/run.sh');
    process.exit(2);
  }
}
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
/* منتقي الامتحان حقلين: المؤسسة ثم الدرجة. الاختيار المباشر للدرجة
   بينجح فقط إذا مؤسستها هي المختارة — وهاد بالضبط سلوك الواجهة. */
async function pick(page, base, provider, levelId){
  await page.selectOption(`#${base}_prov`, provider);
  await page.waitForTimeout(250);
  if (levelId != null) await page.selectOption(`#${base}`, levelId);
  await page.waitForTimeout(350);
}

const check = (l, c) => { results.push([l, !!c]); console.log(`  ${c ? '✓' : '✗'} ${l}`); };

// ٨ ثواني كانت ضيّقة: شاشة الملفات بتنده admin_assets وadmin_content
// سوا، وكل واحد عملية psql — على عدّاء بنواتين مع Chromium شغّال هاد
// بيتخطّاها وبيفشل بلا ما يكون في خلل. الحارس تحت بيمسك التعليق الحقيقي.
const HARD = setTimeout(() => { console.log('\n✗ انتهت المهلة'); process.exit(2); }, 240000);

/* ★ اختبار «القاعدة ورا» بينزّل schema_version لـ١٢ وبيشيل admin_assets
   عن قصد. الترجيع كان بـfinally لحاله — وfinally ما بتنفّذ لما الحارس
   يندي process.exit أو تنقتل العملية. وقتها القاعدة بتضل مكسورة، وكل
   تشغيل جاي بيفشل عند شاشة الملفات بمهلة ما بتقول السبب. صرت أسجّله
   على exit كمان، وبيشتغل مرة وحدة. */
let downgraded = false;
const restoreSchema = () => {
  if (!downgraded) return;
  downgraded = false;
  for (const f of ['supabase/migrations/0015_admin_upload.sql',
                   'supabase/migrations/0019_version.sql'])
    try {
      execFileSync('psql', ['-h','/tmp','-p', process.env.PGPORT || '5433','-U','postgres',
        '-d','telc','-q','-v','ON_ERROR_STOP=1','-f', f], { encoding:'utf8' });
    } catch (e){ console.log('  ✗ ما قدرت أرجّع', f, String(e.message).slice(0,120)); }
};
process.on('exit', restoreSchema);
const browser = await chromium.launch({ args:['--no-sandbox','--disable-dev-shm-usage'] });
const page = await browser.newPage();
page.setDefaultTimeout(25000);
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

  // ★ الافتراضي كود واحد: الغالب إنّ الأدمن بده كود لطالب واحد.
  //   كان ٥، فكل مرة بده يمسح ويكتب ١.
  check(`★ الافتراضي كود واحد (${await page.inputValue('#c_n')})`,
        await page.inputValue('#c_n') === '1');

  // ★ «Art» أول حقل: هي يلي بتقرّر شو بيعني يلي بعدها — أيام ولا
  //   ساعات، وهل في اختيار امتحانات أصلاً.
  const order = await page.evaluate(() => [...document.querySelectorAll(
    '#c_kind, #c_n, #c_lvl_prov, #c_lvl, #c_days, #c_uses')].map(e => e.id));
  check(`★ «Art» قبل باقي المنتقيات (${order.slice(0,3).join(' → ')})`,
        order[0] === 'c_kind');

  await page.fill('#c_n', '3');
  await page.evaluate(() => document.getElementById('c_go').click());
  await page.waitForSelector('.codes');
  const shown = await page.locator('.codes div').count();
  // ★ بلا فراغات: الكود بينوزّع بواتساب، وفراغ زيادة بيصير سؤال
  const shownCodes = await page.locator('.codes div').allTextContents();
  check(`★ الكود بينعرض بلا فراغات (${shownCodes[0]})`,
        shownCodes.every(c => /^[A-Z0-9]+$/.test(c.trim())));
  const codesAfter = Number(sql('select count(*) from access_codes;'));
  check(`توليد ٣ أكواد: ظهروا ${shown} وانحفظوا ${codesAfter - codesBefore}`,
        shown === 3 && codesAfter - codesBefore === 3);

  // ---- التدقيق ----
  await page.evaluate(() => document.querySelector('[data-tab="audit"]').click());
  await page.waitForSelector('table');
  check('صفحة التدقيق بتعرض الإجراءات',
        (await page.textContent('table')).includes('code.create'));

  // ---- المحتوى: إنشاء امتحان (مؤسسة + درجة) ----
  // «A1» لحالها مو منتج: A1 من telc غير A1 من Goethe. فالنموذج بياخد
  // الاتنين، والمعرّف والعنوان بيتولّدوا بقاعدة البيانات.
  await page.evaluate(() => document.querySelector('[data-tab="content"]').click());
  await page.waitForSelector('#l_go');
  await page.fill('#l_prov', 'telc'); await page.fill('#l_stufe', 'A1');
  await page.evaluate(() => document.getElementById('l_go').click());
  // ننتظر إعادة الرسم فعلياً بدل مهلة عمياء — إعادة الرسم بتمسح الحقول
  await page.waitForFunction(() =>
    document.querySelector('table') && document.body.textContent.includes('telc A1'));
  await page.waitForTimeout(300);
  check('★ إنشاء telc · A1 وصل لقاعدة البيانات',
        sql(`select id||'/'||provider||'/'||stufe||'/'||title
               from levels where provider='telc' and stufe='A1';`)
        === 'telc-a1/telc/A1/telc A1');

  // مؤسسة بلا درجة لازم تنرفض قبل ما توصل للقاعدة
  await page.fill('#l_prov', 'Goethe'); await page.fill('#l_stufe', '');
  await page.evaluate(() => document.getElementById('l_go').click());
  await page.waitForTimeout(500);
  check('★ مؤسسة بلا درجة ما بتنحفظ',
        sql(`select count(*) from levels where provider='Goethe';`) === '0');

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

  // ---- إنشاء ستوفة من المنتقي مباشرة ----
  // كان لازم المستخدم يروح للإنهالته يعمل الستوفة ويرجع. الخيار الأخير
  // بالمنتقي بيعملها بمكانها. الفحص: الخيار موجود بكل منتقي، والستوفة
  // بتوصل للقاعدة، وبتنعمل مخفية (نشرها فاضية بتوصّل ستوفة بلا امتحانات).
  await page.evaluate(() => document.querySelector('[data-tab="import"]').click());
  await page.waitForSelector('#i_lvl');
  check('★ خيار «neue Stufe» بمنتقي الاستيراد',
        (await page.locator('#i_lvl option[value="__neu__"]').count()) === 1);

  const answers = ['Goethe', 'C1'];
  const onDialog = d => d.accept(answers.shift() ?? '');
  page.on('dialog', onDialog);
  await page.selectOption('#i_lvl', '__neu__');
  await page.waitForTimeout(1500);

  page.off('dialog', onDialog);
  const newLvl = sql(`select id||'/'||title||'/'||published
                        from levels where provider='Goethe' and stufe='C1';`);
  check(`★ الامتحان انعمل من المنتقي (${newLvl})`,
        newLvl === 'goethe-c1/Goethe C1/false');
  check('وانختار بعد الإنشاء',
        (await page.locator('#i_lvl').inputValue()) === 'goethe-c1');

  await page.evaluate(() => document.querySelector('[data-tab="codes"]').click());
  await page.waitForSelector('#c_lvl');
  check('★ ونفس الخيار بمنتقي الأكواد',
        (await page.locator('#c_lvl option[value="__neu__"]').count()) === 1);

  // ---- الإنهالته: تصفية وتعديل ----
  await page.evaluate(() => document.querySelector('[data-tab="content"]').click());
  await page.waitForSelector('#t_lvl');
  const allTests = await page.locator('[data-tedit]').count();
  check(`كل الامتحانات ظاهرة (${allTests})`, allTests > 0);

  await pick(page, 't_lvl', 'telc', 'telc-a1');
  const a1Tests = await page.locator('[data-tedit]').count();
  check(`★ التصفية بالستوفة بتشتغل (a1: ${a1Tests})`, a1Tests < allTests);

  // «bearbeiten» لازم يفتح المحرّر بنفس الستوفة ونفس الاسم — لو اختلف
  // واحد منهن، الحفظ بيعمل امتحان جديد بدل ما يستبدل هاد.
  // منرجّع التصفية لكل الستوفات: a1 لسا بلا امتحانات، ولف الفحص جوّا
  // شرط بيخلّيه ينجح بصمت لما ما يكون في شي يُضغط.
  await pick(page, 't_lvl', '');
  await page.locator('[data-tedit]').first().click();
  await page.waitForSelector('#i_text');
  await page.waitForTimeout(1200);
  const lvl  = await page.locator('#i_lvl').inputValue();
  const slug = await page.locator('#i_slug').inputValue();
  const txt  = await page.locator('#i_text').inputValue();
  check(`★ التعديل فتح المحرّر بالستوفة والاسم (${lvl}/${slug})`,
        lvl === 'b1' && /^modell-/.test(slug));
  check('★ والنص طالع بصيغة القالب',
        /^# /.test(txt) && /### Teil:/.test(txt) && /Lösung:/.test(txt));
  const st = await page.locator('.stat b').allTextContents();
  check(`★ والمعاينة انفحصت لحالها (${st.join('/')})`,
        st[1] === '9' && Number(st[2]) > 40);

  // ---- المنتقي حقلين: مؤسسة ثم درجة ----
  // جرّبنا قائمة وحدة مجمّعة بـoptgroup: بتخفي المؤسسة. الصندوق المقفول
  // بيعرض «B1» بس، والمؤسسة ما بتبيّن إلا لما تفتحيه — وهي نص القرار.
  await page.evaluate(() => document.querySelector('[data-tab="codes"]').click());
  await page.waitForSelector('#c_lvl');
  await page.waitForTimeout(300);

  check('★ في منتقي مؤسسة منفصل بالأكواد',
        (await page.locator('#c_lvl_prov').count()) === 1);
  const provOpts = await page.locator('#c_lvl_prov option').allTextContents();
  check(`وبيعرض المؤسسات (${provOpts.join(', ')})`,
        provOpts.includes('telc') && provOpts.includes('Goethe'));

  // تبديل المؤسسة لازم يعيد ملء الدرجات — وإلا بتضل درجات القديمة
  await page.selectOption('#c_lvl_prov', 'Goethe');
  await page.waitForTimeout(300);
  const gStufen = await page.locator('#c_lvl option').allTextContents();
  check(`★ تبديل المؤسسة بيعيد ملء الدرجات (${gStufen.join(', ')})`,
        gStufen.length > 0 && gStufen.every(t => !/A1|B1/.test(t) || /C1/.test(t)));

  await page.selectOption('#c_lvl_prov', 'telc');
  await page.waitForTimeout(300);
  const tStufen = await page.locator('#c_lvl option').allTextContents();
  check(`وبالرجوع لـtelc بتطلع درجاته (${tStufen.join(', ')})`,
        tStufen.some(t => /B1/.test(t)) && tStufen.some(t => /A1/.test(t)));

  // والافتراضي لازم يقع على امتحان إله محتوى، مو على أول صف بالترتيب
  await page.selectOption('#c_lvl', 'b1');
  await page.waitForTimeout(400);
  const hint0 = await page.textContent('#c_hint');
  check('★ سطر «شو بيفتح» بيتبع الاختيار',
        /Öffnet/.test(hint0) && /16/.test(hint0));

  // ---- الملفات: رفع من اللوحة ----
  // الرفع الحقيقي بده Storage شغّال، وما عندنا هون. يلي منفحصه إنو
  // الشاشة بتعرف شو ناقص وإنها بتربط اسم الملف بالقسم قبل الرفع —
  // هاد الجزء يلي بينكسر بصمت لو انعكس ترتيبه.
  await page.evaluate(() => document.querySelector('[data-tab="assets"]').click());
  await page.waitForSelector('#as_lvl');
  const asTxt = await page.textContent('#app');
  check('شاشة الملفات فيها الصور والهörtexte',
        /Bilder/.test(asTxt) && /Hörtexte/.test(asTxt));

  const rowsN = await page.locator('[data-pick]').count();
  check(`فيها صفوف للرفع (${rowsN})`, rowsN > 0);

  // أقسام الاستماع بلا ملف لازم تطلع باسم مقترح قابل للتعديل
  const nameN = await page.locator('[data-name]').count();
  check(`★ أقسام الاستماع إلها حقل اسم (${nameN})`, nameN > 0);
  const firstName = await page.locator('[data-name]').first().inputValue();
  check(`الاسم المقترح شكله ملف صوت (${firstName})`, /\.mp3$/.test(firstName));

  // التصفية بالستوفة
  await pick(page, 'as_lvl', 'telc', 'telc-a1');
  check('★ التصفية بالستوفة بتشتغل',
        (await page.locator('[data-pick]').count()) < rowsN);
  await pick(page, 'as_lvl', '');

  await page.evaluate(() => document.querySelector('[data-tab="codes"]').click());
  await page.waitForSelector('#c_kind');

  // ---- الكود التجريبي ----
  // زرّ واحد بيبدّل بين يومين نموذجين: كامل بالأيام، تجريبي بالساعات
  // وامتحان محدّد. لازم النداء يوصل بالقيم الصح، وإلا الكود «التجريبي»
  // بيفتح المستوى كامل ٣٠ يوم وحدا بياخد كل شي ببلاش.
  await page.selectOption('#c_kind', 'demo');
  await page.waitForTimeout(200);
  check('★ Demo بيبيّن الساعات وبيخفي الأيام',
        !(await page.locator('#c_hours_l').isHidden())
        && await page.locator('#c_days_l').isHidden());
  check('★ وبيبيّن قائمة الامتحانات',
        !(await page.locator('#c_tests_row').isHidden()));

  const nOpts = await page.locator('#c_tests option').count();
  check(`قائمة الامتحانات معبّاية (${nOpts})`, nOpts > 0);

  await page.fill('#c_hours', '24');
  await page.fill('#c_uses', '3');
  await page.evaluate(() => document.getElementById('c_go').click());
  await page.waitForTimeout(1200);

  const demoRow = sql(`select duration_days||'/'||duration_hours||'/'||
      coalesce(array_length(test_slugs,1),0)||'/'||max_uses
    from access_codes order by created_at desc limit 1;`);
  check(`★ الكود التجريبي انحفظ صح (${demoRow} = يوم/ساعة/امتحان/تفعيل)`,
        demoRow === '0/24/1/3');

  // ونرجّع النموذج لوضع الكامل تا ما نأثّر على الاختبارات الجاية
  await page.selectOption('#c_kind', 'full');
  await page.waitForTimeout(200);

  // ---- الاستيراد: المثال ----
  await page.evaluate(() => document.querySelector('[data-tab="import"]').click());
  await page.waitForSelector('#i_sample');
  await page.evaluate(() => document.getElementById('i_sample').click());
  await page.waitForSelector('.preview');
  const nums = await page.locator('.stat b').allTextContents();
  // المثال امتحان B1 كامل الهيكل: ٣ كتل، ٩ أقسام، ١٧ سؤال، ١٦ حل
  // (التعبير الكتابي بلا حل — بيتصحّح بالذكاء الاصطناعي).
  check(`المعاينة عدّت صح (${nums.join('/')})`,
        nums[0] === '3' && nums[1] === '9' && nums[2] === '17' && nums[3] === '16');
  check('زرّ النشر مفتوح لأن ما في أخطاء',
        !(await page.locator('#i_apply').isDisabled()));

  // ---- الاستيراد: القالب الفاضي ----
  // لازم يمرق بالهيكل الكامل (٦١ سؤال) بس ينبّه على الخانات الفاضية،
  // وإلا بينتشر امتحان حلوله «<A bis J>» وما بيطلع صح ولا مرة.
  await page.evaluate(() => document.getElementById('i_leer').click());
  await page.waitForSelector('.preview');
  const leerNums = await page.locator('.stat b').allTextContents();
  check(`القالب الفاضي: ${leerNums.join('/')} (٦١ سؤال)`, leerNums[2] === '61');
  const leerWarn = await page.textContent('.warns');
  check('★ القالب الفاضي بينبّه على الخانات <…>',
        /nicht ausgefüllt/.test(leerWarn));

  // ونرجّع المثال المعبّى للاختبارات الجاية
  await page.evaluate(() => document.getElementById('i_sample').click());
  await page.waitForSelector('.preview');

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
  await pick(page, 'i_lvl', 'telc', 'telc-a1');
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
        made === '17' && ans === '16');

  // ---- الملفات بصفحة الاستيراد نفسها ----
  // الملفات بتخصّ امتحان محدّد، فمنطقي تكون معه — مو بتبويب تاني لازم
  // تدوّري فيه على اسمه بين كل الامتحانات.
  await page.waitForTimeout(1200);
  const box = await page.textContent('#i_files');
  check('★ صندوق الملفات ظهر بعد النشر باسم الامتحان',
        /probe-a1-01/.test(box) && /Bilder/.test(box) && /Hörtexte/.test(box));

  const upBtns = await page.locator('#i_files [data-pick]').count();
  check(`★ وفيه أزرار رفع لملفات هالامتحان (${upBtns})`, upBtns >= 4);

  // ما بيعرض ملفات امتحانات تانية
  const slugsInBox = await page.locator('#i_files td .mono').allTextContents();
  check('★ وبس ملفات هالامتحان',
        slugsInBox.filter(t => /^modell-/.test(t)).length === 0);

  // امتحان مو موجود: بيقول متى بيظهر بدل ما يفضى
  await page.fill('#i_slug', 'gibt-es-nicht');
  await page.dispatchEvent('#i_slug', 'change');
  await page.waitForTimeout(700);
  check('★ امتحان لسا ما انتشر بيشرح بدل ما يفضى',
        /noch nicht veröffentlicht/.test(await page.textContent('#i_files')));

  // ★ وبلا اسم كمان لازم يشرح. أول نسخة كانت تفرّغ الصندوق، فالمستخدم
  // ما بيشوف ولا إشارة إنه في رفع ملفات أصلاً.
  await page.fill('#i_slug', '');
  await page.dispatchEvent('#i_slug', 'change');
  await page.waitForTimeout(700);
  const emptyBox = await page.textContent('#i_files');
  check('★ وبلا اسم بيضل يشرح، ما بيفضى',
        /Bilder und Hörtexte/.test(emptyBox) && emptyBox.trim().length > 40);

  // الصورة والصوت بيسافروا جوّا config مو بأعمدة — هني يلي بينضاعوا
  check('★ الصورة والصوت وصلوا للقاعدة عبر اللوحة',
        sql(`select count(*) from sections s join tests t on t.id=s.test_id
             where t.slug='probe-a1-01'
               and (s.config ? 'bankImage' or s.config ? 'audio');`) === '4');
  check('الحلول راحت للجدول المقفول مو للأسئلة',
        sql(`select count(*) from items i join sections s on s.id=i.section_id
             join tests t on t.id=s.test_id where t.slug='probe-a1-01'
             and i.options::text like '%answer%';`) === '0');

  // ---- قاعدة بيانات لسا ما انحدّثت ----
  // اللوحة بتنرفع لـCloudflare قبل ما ينشغل setup.sql — وهاد بيصير فعلاً.
  // لازم تقول شو لازم يعمل المستخدم، مو تطلع فاضية ولا برسالة عامة.
  try {
    // ★ نسخة أقدم: الشريط لازم يطلع بكل شاشة ويقول كم ترحيل ناقص.
    // بلاه، كل ميزة بتفشل بصمت بطريقتها وما حدا بيعرف السبب — وهاد صار
    // فعلاً: المستخدم دفع اللوحة وما شغّل setup.sql، فالامتحانات
    // المقفولة ما ظهرت ولا شي قال ليش.
    downgraded = true;
    sql("create or replace function schema_version() returns int "
        + "language sql immutable as $x$ select 12 $x$;");
    await page.evaluate(() => location.reload());
    await page.waitForSelector('[data-tab="home"]');
    await page.waitForTimeout(1500);
    const banner = await page.textContent('#app');
    check('★ شريط «القاعدة ورا» ظهر',
          /Datenbank ist \d+ Migration/.test(banner) && /setup\.sql/.test(banner));
    check(`★ وبيقول كم ترحيل ناقص`,
          /Stand 12/.test(banner) && /gebraucht 21/.test(banner));
    await page.evaluate(() => document.querySelector('[data-tab="codes"]').click());
    await page.waitForTimeout(900);
    check('★ وبيطلع بالشاشات التانية كمان',
          /Datenbank ist \d+ Migration/.test(await page.textContent('#app')));

    sql('drop function if exists admin_assets(text);');
    await page.evaluate(() => document.querySelector('[data-tab="assets"]').click());
    await page.waitForTimeout(1200);
    const stale = await page.textContent('#app');
    check('★ قاعدة قديمة: شاشة الملفات بتقول شغّلي setup.sql',
          /setup\.sql/.test(stale) && /nicht aktualisiert/.test(stale));

    await page.evaluate(() => document.querySelector('[data-tab="import"]').click());
    await page.waitForSelector('#i_slug');
    await page.fill('#i_slug', 'probe-a1-01');
    await pick(page, 'i_lvl', 'telc', 'telc-a1');
    await page.dispatchEvent('#i_slug', 'change');
    await page.waitForTimeout(900);
    check('★ ونفس الرسالة بصندوق ملفات الاستيراد',
          /setup\.sql/.test(await page.textContent('#i_files')));
  } finally {
    restoreSchema();      // وكمان على exit، لأن الحارس بيقتل العملية
  }

  // ---- الحارس: مستخدم عادي ما بيدخل ----
  await page.evaluate(() => localStorage.clear());
  await page.reload();
  await page.waitForSelector('#mail');
  check('بعد الخروج بيرجع لشاشة الدخول', await page.locator('#mail').isVisible());

} catch (err){
  // ★ كانت ٣٠٠ حرف — بتخلص عند العنوان، قبل الجزء يلي بيقول شو صار.
  //   فشل CI راح عليه وقت لأن الدليل كان مقصوص.
  console.log('\n✗ وقف عند:', err.message.split('\n')[0]);
  console.log(`  أبطأ نداء: ${slowest.ms}ms — ${slowest.path}`);
  console.log((await page.textContent('body').catch(() => '')).slice(0, 2000));
  results.push(['اكتمل بلا استثناء', false]);
}
clearTimeout(HARD);
await browser.close();
server.close();
const bad = results.filter(r => !r[1]);
console.log(bad.length ? `\n✗ ${bad.length} فشل من ${results.length}`
                       : `\n✓ كل الـ${results.length} اختبارات نجحت`);
process.exit(bad.length ? 1 : 0);
