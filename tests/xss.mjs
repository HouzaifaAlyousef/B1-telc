/* اختبار XSS حقيقي: منحقن حمولة تنفيذية بكل حقل نصّي بيوصل للشاشة،
   ومنشوف إذا اشتغلت بالمتصفّح. هاد بيحسم، مو متل الفحص الثابت. */
import { chromium } from 'playwright';
import { readFileSync } from 'fs';
import { execFileSync } from 'child_process';
import http from 'http';
import path from 'path';

const lit = (v) => v === null || v === undefined ? 'null'
  : Array.isArray(v) ? `array[${v.map(x => `'${String(x).replaceAll("'","''")}'`)}]::text[]`
  : typeof v === 'object' ? `'${JSON.stringify(v).replaceAll("'","''")}'::jsonb`
  : typeof v === 'number' || typeof v === 'boolean' ? String(v)
  : `'${String(v).replaceAll("'","''")}'`;

const ROOT = path.resolve(import.meta.dirname, '..');
const PAY = `<img src=x onerror="window.__XSS=(window.__XSS||0)+1">`;
const PAY2 = `"><script>window.__XSS=(window.__XSS||0)+1<\/script>`;

const MIME = { '.html':'text/html', '.js':'text/javascript', '.css':'text/css' };
const srv = http.createServer((req, res) => {
  let f = req.url.split('?')[0]; if (f === '/') f = '/index.html';
  try { res.writeHead(200,{'content-type':MIME[path.extname(f)]||'text/plain'});
        res.end(readFileSync(path.join(ROOT,f))); }
  catch { res.writeHead(404); res.end('x'); }
});
await new Promise(r => srv.listen(0, r));
const PORT = srv.address().port;

const R = [];
const check = (l,c) => { R.push([l,!!c]); console.log(`  ${c?'✓':'✗'} ${l}`); };

const browser = await chromium.launch({ args:['--no-sandbox','--disable-dev-shm-usage'] });
const page = await browser.newPage();
page.setDefaultTimeout(8000);
page.on('dialog', d => d.dismiss());

console.log('\n=== حقن XSS بكل حقل بيوصل للشاشة ===');

/* API مزيّف: كل حقل نصّي فيه الحمولة */
await page.addInitScript(({ p, p2 }) => {
  const item = (id) => ({ id, num: p, text: p, options: [{ key:'A', text:p }] });
  const sec = {
    id: 'lv1', group: p, title: p, minutes: 5, instruction: p, format: 'matching',
    bank: [{ key:'A', text:p }], bankTitle: p, note: p,
    items: [item('i1'), item('i2')],
    pointsPerItem: 1, maxPoints: 2, availablePoints: 2, missing: 0
  };
  window.__MOCK_API = {
    configured: () => true, hasSession: () => true,
    ensureSession: async () => ({}),
    subscription: async () => ({ levels:['b1','a2'], current_period_end:'2099-01-01T00:00:00Z' }),
    myLevels: async () => [{ id:'b1', title:p }, { id:'a2', title:p2 }],
    redeem: async () => ({ ok:true }),
    index: async () => ({ modelle: [{ id:'m1', uuid:'u1', title:p, subtitle:p,
      aufgaben:2, minutes:5,
      blocks:[{ id:'b1', title:p, minutes:5, hint:p, parts:['lv1'],
                maxPoints:2, availablePoints:2, missing:0 }] }] }),
    test: async () => ({ id:'m1', uuid:'u1', title:p, subtitle:p,
      blocks:[{ id:'b1', title:p, minutes:5, hint:p, parts:['lv1'],
                maxPoints:2, availablePoints:2, missing:0 }],
      sections:[sec] }),
    imageUrl: async () => null,
    reviewSummary: async () => ({ due:0, total:0, mastered:0, next_due:null }),
    mistakes: async () => [],
    resources: async () => [{ id:'r1', title:p, kind:'text', body:`${p}\n\n## ${p}\n\n${p2}` }],
    submitAttempt: async () => ({ ok:true, points:1, max_points:2, pct:50, attempt_id:'a1',
      results:[{ id:'i1', section:'lv1', item:p, given:'A', answer:'A', correct:true,
                 explanation:p },
               { id:'i2', section:'lv1', item:p, given:'B', answer:'A', correct:false,
                 explanation:p2 }] }),
    submitDrill: async () => ({ ok:true, right:0, total:0, results:[] }),
    writingFeedback: async () => null,
    correctWriting: async () => ({ ok:true, points:39, max_points:45,
      grades:[{criterion:p, key:'A', why:p2}],
      errors:[{type:p, original:p, correction:p2, why:p}],
      corrected:p, summary:p2 }),
    attempts: async () => [],
  };
}, { p: PAY, p2: PAY2 });

await page.route('**/assets/api.js', r =>
  r.fulfill({ contentType:'text/javascript', body:'const API = window.__MOCK_API;' }));
await page.route('**/assets/config.js', r =>
  r.fulfill({ contentType:'text/javascript',
              body:"window.TELC_CONFIG={supabaseUrl:'http://mock',supabaseAnonKey:'k'};" }));

const fired = () => page.evaluate(() => window.__XSS || 0);

await page.goto(`http://127.0.0.1:${PORT}/`);
await page.waitForSelector('.tile[data-id]');
check('الشاشة الرئيسية (عناوين + مبدّل مستويات)', await fired() === 0);

await page.evaluate(() => document.getElementById('resbtn').click());
await page.waitForTimeout(400);
await page.evaluate(() => document.querySelector('[data-res]')?.click());
await page.waitForTimeout(300);
check('المراجع (عنوان + متن فيه ##)', await fired() === 0);

await page.evaluate(() => screenHome());
await page.waitForSelector('.tile[data-id]');
await page.evaluate(() => document.querySelector('.tile[data-id]').click());
await page.waitForSelector('[data-block]');
check('شاشة الامتحان (عناوين الكتل)', await fired() === 0);

await page.evaluate(() => document.querySelector('[data-block]').click());
await page.waitForTimeout(300);
check('شاشة البداية (تعليمات + ملاحظات)', await fired() === 0);

await page.evaluate(() => {
  const b = [...document.querySelectorAll('button')].find(x => /Start/i.test(x.textContent));
  if (b) b.click();
});
await page.waitForTimeout(400);
check('شاشة الأسئلة (نص السؤال + الخيارات + بنك الإجابات)', await fired() === 0);

await page.evaluate(() => finish(S.run, true));
await page.waitForSelector('.score');
check('شاشة النتيجة (الحلول + الشرح من السيرفر)', await fired() === 0);

const total = await fired();
check(`المجموع النهائي: ${total} تنفيذ`, total === 0);
const html = await page.content();
check('الحمولة ظاهرة كنص مو كوسم',
      html.includes('&lt;img src=x') || html.includes('&lt;img'));


/* ---------- لوحة التحكّم ----------
   هون البيانات أخطر: أسماء وملاحظات وأكواد، وبتنعرض لك إنت. */
const page2 = await browser.newPage();
page2.setDefaultTimeout(8000);
page2.on('dialog', d => d.dismiss());

const sql = q => execFileSync('psql',
  ['-h','/tmp','-p','5433','-U','postgres','-d','telc','-tAq','-v','ON_ERROR_STOP=1','-c',q],
  { encoding:'utf8', maxBuffer: 32*1024*1024 }).trim().split('\n').map(l=>l.trim()).filter(Boolean).pop() ?? '';

const A = 'aaaaaaaa-0000-0000-0000-00000000000a';
sql(`delete from writing_feedback; delete from admin_audit_log; delete from mistakes;
     delete from attempts; delete from imports; delete from resources;
     delete from devices; delete from subscriptions; delete from access_codes;
     delete from profiles; delete from auth.users;
     insert into auth.users (id) values ('${A}');
     insert into profiles (id, is_admin, display_name, note) values
       ('${A}', true, ${lit(PAY)}, ${lit(PAY2)});`);
sql(`insert into access_codes (code, levels, duration_days, note)
     values (${lit('B1-' + PAY.slice(0,8))}, array['b1'], 30, ${lit(PAY)});`);
sql(`insert into resources (title, body, published) values (${lit(PAY)}, ${lit(PAY2)}, true);`);
sql(`insert into admin_audit_log (admin_id, action, target_type, target_id, detail)
     values ('${A}', ${lit(PAY)}, 'x', ${lit(PAY2)}, jsonb_build_object('n', ${lit(PAY)}));`);

const asAdmin = (inner) => {
  const out = sql(`set local role authenticated;
    select set_config('request.jwt.claim.sub','${A}',true);
    ${inner}`);
  return out;
};

const CORS = {
  'access-control-allow-origin': '*',
  'access-control-allow-headers': 'authorization, content-type, apikey, prefer',
  'access-control-allow-methods': 'GET, POST, OPTIONS',
};
const supa = http.createServer(async (req, res) => {
  const u = new URL(req.url, 'http://x');
  const send = (c, b) => { res.writeHead(c, {...CORS, 'content-type':'application/json'});
                           res.end(typeof b === 'string' ? b : JSON.stringify(b)); };
  if (req.method === 'OPTIONS'){ res.writeHead(204, CORS); return res.end(); }
  if (u.pathname === '/auth/v1/token'){
    return send(200, { access_token:'A', refresh_token:'R',
                       expires_at: Math.floor(Date.now()/1000)+3600 });
  }
  if (u.pathname.startsWith('/rest/v1/rpc/')){
    const fn = u.pathname.split('/').pop();
    let b=''; for await (const c of req) b += c;
    const args = JSON.parse(b || '{}');
    const named = Object.entries(args).map(([k,v]) => `${k} => ${lit(v)}`).join(', ');
    try { return send(200, asAdmin(`select coalesce(to_jsonb(${fn}(${named})),'null'::jsonb);`)); }
    catch(e){ return send(400, { message: String(e).slice(0,150) }); }
  }
  if (u.pathname.startsWith('/rest/v1/')){
    const t = u.pathname.split('/').pop();
    const cols = (u.searchParams.get('select')||'*').replace(/\s/g,'');
    const ord = u.searchParams.get('order'); const lim = u.searchParams.get('limit');
    let q = `select coalesce(jsonb_agg(t),'[]'::jsonb) from (select ${cols} from ${t}`;
    if (ord){ const [c,d]=ord.split('.'); q += ` order by ${c} ${d==='desc'?'desc':'asc'}`; }
    if (lim) q += ` limit ${Number(lim)}`;
    q += ') t;';
    try { return send(200, asAdmin(q)); } catch(e){ return send(400, { message:'x' }); }
  }
  send(404, {});
});
await new Promise(r => supa.listen(0, r));
const SPORT = supa.address().port;

await page2.route('**/assets/config.js', r => r.fulfill({ contentType:'text/javascript',
  body:`window.TELC_CONFIG={supabaseUrl:'http://127.0.0.1:${SPORT}',supabaseAnonKey:'k'};` }));
await page2.goto(`http://127.0.0.1:${PORT}/admin/index.html`);
await page2.waitForSelector('#mail');
await page2.fill('#mail','a@b.de'); await page2.fill('#pw','x');
await page2.evaluate(() => document.getElementById('go').click());
try { await page2.waitForSelector('.stats'); }
catch { console.log('   شاشة اللوحة وقتها:',
  (await page2.textContent('body')).replace(/\s+/g,' ').slice(0,220)); throw new Error('لوحة ما فتحت'); }

const fired2 = () => page2.evaluate(() => window.__XSS || 0);
check('لوحة: الصفحة الرئيسية', await fired2() === 0);

for (const tab of ['users','codes','content','audit']){
  await page2.evaluate(t => document.querySelector(`[data-tab="${t}"]`).click(), tab);
  await page2.waitForTimeout(700);
  check(`لوحة: تبويب ${tab}`, await fired2() === 0);
}
await page2.evaluate(() => document.querySelector('[data-more]')?.click());
await page2.waitForTimeout(400);
check('لوحة: حوار تفاصيل المستخدم', await fired2() === 0);

const t2 = await fired2();
check(`لوحة: المجموع ${t2} تنفيذ`, t2 === 0);

await supa.close();
await browser.close(); srv.close();
const bad = R.filter(x => !x[1]);
console.log(bad.length ? `\n✗ ${bad.length} فشل من ${R.length}` : `\n✓ كل الـ${R.length} فحوص نجحت — ما في XSS`);
process.exit(bad.length ? 1 : 0);
