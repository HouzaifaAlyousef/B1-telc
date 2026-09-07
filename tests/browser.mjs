/* اختبار المتصفّح: بيشغّل التطبيق الحقيقي مع API مزيّف بيرد ببيانات
   مأخوذة من قاعدة Postgres الفعلية — وبيصحّح متل ما بيصحّح السيرفر.
   الهدف: نتأكد إن app.js شغّال بعد نقل التصحيح للسيرفر. */
import { chromium } from 'playwright';
import { readFileSync } from 'fs';
import http from 'http';
import path from 'path';

const ROOT = path.resolve(import.meta.dirname, '..');
/* SERVE_FROM=dist بيشغّل نفس الجولة على الناتج المنشور بدل المصدر.
   الناتج بتنشال منه التعليقات، والماسح ممكن يكسر شي — والاختبارات
   بتشتغل على المصدر، يعني الكسر بيوصل للمستخدم وحده. */
const SERVE = process.env.SERVE_FROM
  ? path.resolve(ROOT, process.env.SERVE_FROM) : ROOT;
const fx = JSON.parse(readFileSync(path.join(ROOT, 'tests/fixture.json'), 'utf8'));

/* نغمة WAV مولّدة بالاختبار — أنضف من رفع ملف ثنائي بالمستودع */
function makeWav(seconds = 0.6, rate = 8000, hz = 440){
  const n = Math.floor(seconds * rate);
  const buf = Buffer.alloc(44 + n * 2);
  buf.write('RIFF', 0); buf.writeUInt32LE(36 + n * 2, 4); buf.write('WAVE', 8);
  buf.write('fmt ', 12); buf.writeUInt32LE(16, 16); buf.writeUInt16LE(1, 20);
  buf.writeUInt16LE(1, 22); buf.writeUInt32LE(rate, 24);
  buf.writeUInt32LE(rate * 2, 28); buf.writeUInt16LE(2, 32); buf.writeUInt16LE(16, 34);
  buf.write('data', 36); buf.writeUInt32LE(n * 2, 40);
  for (let i = 0; i < n; i++)
    buf.writeInt16LE(Math.round(8000 * Math.sin(2 * Math.PI * hz * i / rate)), 44 + i * 2);
  return buf;
}
const TONE = makeWav();

const MIME = { '.html':'text/html', '.js':'text/javascript', '.css':'text/css', '.wav':'audio/wav',
               '.json':'application/json', '.webmanifest':'application/json',
               '.png':'image/png', '.jpg':'image/jpeg' };
const server = http.createServer((req, res) => {
  let f = req.url.split('?')[0];
  if (f === '/') f = '/index.html';
  if (f === '/tone.wav'){
    res.writeHead(200, { 'content-type':'audio/wav', 'content-length': TONE.length });
    return res.end(TONE);
  }
  try {
    const body = readFileSync(path.join(SERVE, f));
    res.writeHead(200, { 'content-type': MIME[path.extname(f)] || 'application/octet-stream' });
    res.end(body);
  } catch { res.writeHead(404); res.end('nope'); }
});
await new Promise(r => server.listen(0, r));
const PORT = server.address().port;

const results = [];
const check = (label, cond) => { results.push([label, !!cond]);
  console.log(`  ${cond ? '✓' : '✗'} ${label}`); };

const browser = await chromium.launch({ args: ['--no-sandbox', '--disable-dev-shm-usage'] });
const page = await browser.newPage();
page.on('pageerror', e => { console.log('  ✗ JS-Fehler:', e.message); results.push(['بلا أخطاء JS', false]); });

// نحقن API مزيّف قبل ما يشتغل app.js
await page.addInitScript(fx => {
  const state = { redeemed: false, mistakes: [], mastered: 0, fb: null };
  const items = fx.sections.flatMap(s => s.items.map(i => ({ ...i, sec: s })));

  const shape = () => ({
    id: fx.test.slug, uuid: fx.test.id, title: fx.test.title,
    subtitle: fx.test.subtitle, blocks: fx.test.blocks,
    sections: fx.sections.map(s => {
      /* الصوت بينتحدّد هون بالتجهيزة، ما بينورث من قاعدة البيانات: أي
         اختبار SQL بيربط ملف بقسم تاني كان بيرسم مشغّل ثاني بالصفحة،
         والمنتقي بالوضع الصارم بيفشل على عنصرين. والحقن بيجي بعد نشر
         config تا يفوز — قبله كان config بيدعسه. */
      const { audio, audioPlays, ...cfg } = s.config || {};
      return {
        id: s.section_id, group: s.group, title: s.title, minutes: s.minutes,
        instruction: s.instruction, format: s.format,
        items: s.items.map(i => ({ id: i.id, num: i.item_id, text: i.text,
          ...(i.options ? { options: i.options } : {}), ...(i.meta || {}) })),
        ...cfg,
        ...(s.section_id === 'hv1' ? { audio: 'test.wav', audioPlays: 2,
            passages: [{ paragraphs: [{ t: 'TRANSKRIPT-GEHEIM', b: false }] }] } : {})
      };
    })
  });

  // نفس منطق submit_attempt: التصحيح من الحلول، والأسئلة ما بتحملها
  const grade = (blockId, answers) => {
    const parts = fx.test.blocks.find(b => b.id === blockId).parts;
    const rows = items.filter(i => parts.includes(i.sec.section_id)
                                && i.sec.format !== 'writing'
                                && fx.answers[i.id]);
    let pts = 0, max = 0; const out = [];
    for (const i of rows){
      const given = answers[i.id], ans = fx.answers[i.id];
      max += Number(i.points);
      if (given === ans) pts += Number(i.points);
      else if (!state.mistakes.includes(i.id)) state.mistakes.push(i.id);
      out.push({ id: i.id, section: i.sec.section_id, item: i.item_id,
                 given, answer: ans, correct: given === ans });
    }
    return { ok: true, points: pts, max_points: max,
             pct: max ? Math.round(1000 * pts / max) / 10 : null, results: out };
  };

  window.TELC_CONFIG = { supabaseUrl: 'http://mock', supabaseAnonKey: 'mock' };
  window.__MOCK_API = {
    configured: () => true,
    hasSession: () => true,
    ensureSession: async () => ({}),
    // اشتراكين منفصلين: B1 كامل لسنين، A2 تجريبي بينتهي بعد ٣ أيام
    subscription: async () => state.redeemed ? {
      levels: ['b1','a2'],
      until: { b1: '2099-01-01T00:00:00Z',
               a2: new Date(Date.now() + 3*86400000).toISOString() },
      scope: { b1: null, a2: ['modell-a2-01'] },
      current_period_end: '2099-01-01T00:00:00Z' } : null,
    myLevels: async sub => [{ id:'b1', title:'telc Deutsch B1',
                              provider:'telc', stufe:'B1' },
                            { id:'a2', title:'telc Deutsch A2',
                              provider:'telc', stufe:'A2' }]
      .filter(l => sub.levels.includes(l.id)),
    // كتالوج: امتحان مفتوح وواحد مقفول — حالة الكود التجريبي
    catalog: async lvl => lvl === 'b1' ? [
      { id: 'modell-01', title: 'PETRA', aufgaben: 61, minutes: 150, open: true },
      { id: 'modell-02', title: 'EVA1',  aufgaben: 60, minutes: 150, open: false },
      { id: 'modell-03', title: 'SOPHIE',aufgaben: 59, minutes: 150, open: false }
    ] : [],
    resources: async lvl => lvl === 'b1'
      ? [{ id:'r1', title:'Wortschatz Reisen', kind:'text',
           body:'## Verben\n\nfahren, fliegen, ankommen\n\n## Nomen\n\nder Zug, das Gleis' }]
      : [],
    // متل code_norm بالخادم: الشرطات والمسافات والحالة ما بتفرق
    redeem: async code =>
      String(code).toUpperCase().replace(/[^A-Z0-9]/g, '') === 'B14827519366'
        ? (state.redeemed = true, { ok: true, levels: ['b1'] })
        : { ok: false, error: 'invalid_code' },
    index: async (lvl) => lvl !== 'b1' ? { modelle: [] } : ({ modelle: [{ id: fx.test.slug, uuid: fx.test.id,
      title: fx.test.title, subtitle: fx.test.subtitle,
      blocks: fx.test.blocks, aufgaben: 61,
      minutes: fx.test.blocks.reduce((a,b) => a + b.minutes, 0) }] }),
    // منسجّل كل نداء تحميل: «ما بينحمّل محتوى المقفول» خاصية سلوكية،
    // مو شي بينفحص بالبحث عن كلمات بالصفحة
    test: async (id) => { (window.__loaded ||= []).push(id); return shape(); },
    imageUrl: async () => null,
    audioUrl: async () => '/tone.wav',
    reviewSummary: async () => ({
      due: state.mistakes.length, total: state.mistakes.length,
      mastered: state.mastered || 0, next_due: null }),
    mistakes: async () => state.mistakes.map(id => {
      const i = items.find(x => x.id === id);
      return { item_id: id, wrong_count: 1, items: { id: i.id, item_id: i.item_id,
        text: i.text, options: i.options, points: i.points, meta: i.meta,
        sections: { section_id: i.sec.section_id, title: i.sec.title,
                    format: i.sec.format, config: i.sec.config,
                    test_id: fx.test.id, tests: { slug: fx.test.slug, title: fx.test.title } } } };
    }),
    submitAttempt: async (uuid, blockId, answers) => ({
      ...grade(blockId, answers), attempt_id: 'att-1' }),
    writingFeedback: async () => state.fb || null,
    correctWriting: async () => {
      state.fb = { id:'f1', status:'done', points:39, max_points:45,
        grades:[{criterion:'Aufgabenbewältigung',key:'A',why:'Alle Punkte da.'},
                {criterion:'Kommunikative Gestaltung',key:'B',why:'Gruß knapp.'},
                {criterion:'Formale Richtigkeit',key:'A',why:'Wenige Fehler.'}],
        errors:[{type:'Grammatik',original:'Ich fliege',correction:'Ich fliege gern',why:'Adverb.'}],
        summary:'Guter Brief.', corrected:'Liebe Anna, …' };
      return { ok:true, ...state.fb };
    },
    submitDrill: async answers => {
      let right = 0; const out = [];
      for (const [id, given] of Object.entries(answers)){
        const ok = given === fx.answers[id];
        if (ok){ right++; state.mistakes = state.mistakes.filter(m => m !== id);
                 state.mastered++; }
        out.push({ id, given, answer: fx.answers[id], correct: ok });
      }
      const n = Object.keys(answers).length;
      return { ok: true, right, total: n, mastered: 0,
               pct: n ? Math.round(1000*right/n)/10 : null, results: out };
    },
    __answers: fx.answers
  };
}, fx);

// api.js بيعرّف `const API` وبيغطّي أي شي بـwindow — فمنبدّل الملف نفسه
await page.route('**/assets/api.js', route =>
  route.fulfill({ contentType: 'text/javascript',
                  body: 'const API = window.__MOCK_API;' }));

page.on('console', m => { if (m.type() === 'error') console.log('  · console:', m.text()); });

console.log('\n=== اختبار المتصفّح ===');
await page.goto(`http://127.0.0.1:${PORT}/`);
await page.waitForTimeout(300);

// ---- ١) شاشة الكود بتطلع لما ما في اشتراك ----
await page.waitForSelector('#code', { timeout: 5000 });
check('بلا اشتراك ← شاشة الكود', await page.locator('#code').isVisible());

// ---- ٢) كود غلط ----
await page.fill('#code', 'B10000000000');
await page.evaluate(() => document.getElementById('godo').click());
await page.waitForTimeout(300);
check('الكود الغلط بيعطي رسالة', (await page.textContent('body')).includes('unbekannt'));

// ---- ٢أ) ★ الحقل بينضّف وهو عم ينكتب، وبلا فراغات ----
// الكود بينوزّع بواتساب، وهناك ما بينعرف إذا الفراغ واحد أو اتنين —
// فالكود بيضل شكل واحد بكل مكان: حروف كبيرة وأرقام بس.
await page.fill('#code', '');
await page.type('#code', 'b1 4827-5193 66', { delay: 5 });
check('★ الفراغات والشرطات بتنشال وهو عم يكتب',
      await page.inputValue('#code') === 'B14827519366');

// ---- ٢ب) ★ الصيغة القديمة بشرطات لسا بتتقبل ----
await page.fill('#code', '');
await page.type('#code', 'b1-7k2m-9xqp', { delay: 5 });
check('★ والقديم بشرطات ما بينكسر',
      await page.inputValue('#code') === 'B17K2M9XQP');

// ---- ٢ج) ★ رسالة الخطأ بتتترجم كمان ----
// كل نصوص شاشة الكود كانت مكتوبة ألماني بالكود مباشرة — يعني طالب
// عربي بيغلط بالكود وبيقرا «Dieser Code ist unbekannt».
await page.evaluate(() => { I18N.setLang('ar'); screenCode(); });
await page.waitForSelector('#code');
await page.fill('#code', 'B10000000000');
await page.evaluate(() => document.getElementById('godo').click());
await page.waitForTimeout(300);
const arErr = await page.textContent('#app');
check('★ الخطأ بالعربي مو بالألماني',
      arErr.includes('مو معروف') && !arErr.includes('unbekannt'));
check('★ وعنوان الشاشة والزرّ كمان',
      arErr.includes('الدخول') && arErr.includes('تفعيل')
      && !arErr.includes('Freischalten'));
await page.evaluate(() => { I18N.setLang('de'); screenCode(); });
await page.waitForSelector('#code');

// ---- ٣) كود صح — ملصوق مع فراغات متل ما بينلصق من واتساب ----
await page.fill('#code', ' B1 4827 5193 66 ');
await page.evaluate(() => document.getElementById('godo').click());
await page.waitForSelector('.tile[data-id]', { timeout: 5000 });
check('الكود الصح بيفتح القائمة', await page.locator('.tile[data-id]').count() > 0);

// ---- ٤) فتح الامتحان ----
await page.evaluate(() => document.querySelector('.tile[data-id]').click());
await page.waitForSelector('[data-block]', { timeout: 5000 });
check('الامتحان انفتح وفيه ٣ كتل', await page.locator('[data-block]').count() === 3);

// ★ «Zurück» كان نص أزرق بلا إطار ولا أرضية — المستخدم ما كان يشوفه
//   كزرّ. الفحص بيقيسه وهو ظاهر فعلاً، مو مخفي بالرئيسية.
const bk = await page.evaluate(() => {
  const b = document.getElementById('btnBack');
  if (!b || b.offsetParent === null) return null;
  const st = getComputedStyle(b);
  return { h: b.getBoundingClientRect().height,
           border: parseFloat(st.borderTopWidth),
           bg: st.backgroundColor };
});
check(`★ زرّ الرجوع ظاهر كزرّ (ارتفاع ${bk && Math.round(bk.h)}, إطار ${
        bk && bk.border})`,
      !!bk && bk.h >= 44 && bk.border > 0
      && bk.bg !== 'rgba(0, 0, 0, 0)' && bk.bg !== 'transparent');

// ---- ٥) ★ الحلول مو موجودة بالمتصفّح قبل التسليم ----
const leaked = await page.evaluate(() => {
  const m = window.modellCache ? Object.values(window.modellCache)[0] : null;
  return JSON.stringify(m || {}).includes('"answer"');
});
check('★ ما في حلول بالذاكرة قبل التسليم', !leaked);

// ---- ٦) امتحان كامل بإجابات صح ----
await page.evaluate(() => document.querySelector('[data-block="block-lv-sb"]').click());
await page.waitForSelector('button', { timeout: 5000 });
await page.evaluate(() => {
  const btn = [...document.querySelectorAll('button')].find(b => /Start/i.test(b.textContent));
  if (btn) btn.click();
});
await page.waitForTimeout(400);

// ---- ٦أ) أزرار الحروف بدل القوائم المنسدلة ----
// قائمة بخمستعشر خيار على موبايل صعبة لمين مو متعوّد: ضغطة، قراءة،
// تمرير، إصابة. الأزرار بتبيّن كل الحروف مرة وحدة.
check('★ ما ضل ولا قائمة منسدلة بالأسئلة',
      await page.locator('.q select').count() === 0);
const nKeys = await page.locator('.keys .key').count();
check(`أزرار الحروف موجودة (${nKeys})`, nKeys > 0);
check('حجم الزرّ ≥ ٤٤ بكسل (قابل للضغط بالإصبع)',
      await page.evaluate(() => {
        const b = document.querySelector('.keys .key');
        const r = b.getBoundingClientRect();
        return Math.min(r.width, r.height) >= 44;
      }));

// الضغط بيختار، والضغط على ✕ بيمسح
await page.locator('.keys .key').first().click();
await page.waitForTimeout(250);
check('★ الضغط بيختار الحرف',
      await page.locator('.keys .key.sel').count() === 1);
check('وبيطلع زرّ مسح', await page.locator('.keys .key.clr').count() >= 1);

// نفس الحرف ما بينعاد بسؤال تاني («Jede Überschrift passt nur einmal»)
check('★ الحرف المستعمل بينقفل بباقي الأسئلة',
      await page.locator('.keys .key[disabled]').count() > 0);

await page.locator('.keys .key.clr').first().click();
await page.waitForTimeout(250);
check('★ زرّ المسح بيشيل الاختيار',
      await page.locator('.keys .key.sel').count() === 0);

// ---- ٦ب) شريط التقدّم ----
check('★ شريط التقدّم موجود', await page.locator('#progfill').count() === 1);
const p0 = await page.textContent('#prog');
check(`وبيقول كم انحلّ (${p0.trim()})`, /0.*40|40/.test(p0));
await page.locator('.keys .key').first().click();
await page.waitForTimeout(250);
const w = await page.evaluate(() => document.getElementById('progfill').style.width);
check(`★ وبيتحرّك مع الإجابة (${w})`, w && parseFloat(w) > 0);

// ---- ٦ج) تحذير قبل التسليم ----
// الوقت محدود والزرّ كبير — التسليم بالغلط بيصير.
await page.evaluate(() => document.getElementById('submit').click());
await page.waitForSelector('.modal', { timeout: 4000 });
check('★ نافذة وحدة بس، مو تنتين',
      await page.locator('.modalback').count() === 1);
const warn = await page.textContent('.modal');
check(`★ التسليم بأسئلة ناقصة بيسأل أول (${warn.replace(/\s+/g,' ').trim().slice(0,42)})`,
      /ohne Antwort/.test(warn));
await page.evaluate(() => document.querySelector('.modal [data-no]').click());
await page.waitForTimeout(300);
check('★ و«كمّل الحلّ» ما بيسلّم', await page.locator('.score').count() === 0);

// منعبّي الإجابات الصح مباشرةً بالحالة، وبعدين منسلّم
const submitted = await page.evaluate(() => {
  S.answers = {};
  runItems(S.run).forEach(it => { if (API.__answers[it.id]) S.answers[it.id] = API.__answers[it.id]; });
  finish(S.run, true);
  return Object.keys(S.answers).length;
});
check(`انعبّت ${submitted} إجابة صحيحة`, submitted === 40);
await page.waitForSelector('.score', { timeout: 5000 });
const pct = await page.textContent('.pct');
check(`النتيجة ١٠٠٪ (طلعت: ${pct.trim()})`, pct.includes('100'));

// ---- ٧) امتحان بإجابات غلط ← الأخطاء بتتسجّل ----
await page.evaluate(() => screenHome());
await page.waitForSelector('.tile[data-id]', { timeout: 5000 });
await page.evaluate(() => document.querySelector('.tile[data-id]').click());
await page.waitForSelector('[data-block]');
await page.evaluate(() => document.querySelector('[data-block="block-lv-sb"]').click());
await page.waitForTimeout(300);
await page.evaluate(() => {
  const btn = [...document.querySelectorAll('button')].find(b => /Start/i.test(b.textContent));
  if (btn) btn.click();
});
await page.waitForTimeout(400);
// ★ منسلّم من الزرّ الحقيقي مع أسئلة ناقصة — هون كان التحذير بيطلع
//   مرتين: الزرّ بيسأل، وfinish() بتسأل كمان بعد «نعم». الطالب كان
//   يضغط «سلّم» ويرجع يشوف نفس السؤال، فيظن إنّ الضغطة ما مشيت.
await page.evaluate(() => {
  S.answers = {};
  runItems(S.run).slice(2).forEach(it => { S.answers[it.id] = 'ZZZ'; });
  bindInputs && 0;                       // بس تا يضل الرسم متل ما هو
});
await page.evaluate(() => document.getElementById('submit').click());
await page.waitForSelector('.modal', { timeout: 4000 });
await page.evaluate(() => document.querySelector('.modal [data-yes]').click());
await page.waitForTimeout(600);
check('★ بعد «سلّم برضو» ما بيرجع يسأل مرة تانية',
      await page.locator('.modalback').count() === 0);
await page.waitForSelector('.score', { timeout: 5000 });
check('كل الإجابات غلط ← ٠٪', (await page.textContent('.pct')).includes('0 %'));
check('الحل الصحيح بيبيّن بعد التسليم',
      (await page.textContent('body')).includes('Lösung'));

// ---- ٨) تكرار الأخطاء ----
await page.evaluate(() => screenHome());
await page.waitForTimeout(600);
check('زرّ المراجعة ظهر', await page.locator('#drill').count() === 1);
check('الزرّ بيقول كم سؤال مستحقّ',
      /\d+ Aufgaben? fällig/.test(await page.textContent('#drill')));

// ---- ٨ب) الامتحانات المقفولة ----
// هدفها التسويق: صاحب التجريبي لازم يشوف إنه في غير امتحان. بس
// محتواها ما لازم يوصل الصفحة أبداً.
check('البلاطات: مفتوح + مقفولين', await page.locator('.tile.locked').count() === 2);
check('★ المقفولة ما بتنضغط',
      await page.locator('.tile.locked').first().isDisabled());
check('★ وما إلها data-id، فما في طريقة تفتحها',
      await page.locator('.tile.locked[data-id]').count() === 0);
const lockedTxt = await page.textContent('.tile.locked');
check(`عنوانها ظاهر للتشويق (${lockedTxt.replace(/\s+/g,' ').trim().slice(0,30)})`,
      /EVA1/.test(lockedTxt) && /60 Aufgaben/.test(lockedTxt));
check('★ وسطر «في غيرهن» ظاهر',
      /weitere Modelltests/.test(await page.textContent('.upsell')));

// ★ محتوى المقفول ما بينحمّل: منحاول نفتحه بالضغط ومنشوف إذا انطلب
await page.evaluate(() => {
  const b = document.querySelector('.tile.locked');
  b.disabled = false;            // نشيل القفل البصري ومنجرّب
  b.click();
});
await page.waitForTimeout(600);
const loaded = await page.evaluate(() => window.__loaded || []);
check(`★ ولا نداء لتحميل امتحان مقفول (${loaded.join(', ') || 'ولا واحد'})`,
      !loaded.includes('modell-02') && !loaded.includes('modell-03'));

// ---- ٨ج) الإعدادات: بترويسة الرئيسية مباشرة ----
// كانت ورا زرّ ⚙: ضغطتين وخروج من الصفحة تا يبدّل لغته. ومين ما بيقرا
// الألماني ما بيعرف إنّ الترس يعني إعدادات — العلم بيعرفه بلا قراءة.
await page.waitForSelector('.setbar');
check('★ ما ضل زرّ ⚙ بالشريط العلوي',
      await page.locator('#btnSet').count() === 0);
check('★ الإعدادات ظاهرة بالرئيسية بلا ما يضغط شي',
      await page.locator('.setbar').isVisible());
// أهداف اللمس: أي زرّ أصغر من ٤٤ بكسل بينضغط غلط على الموبايل
const small = await page.evaluate(() => [...document.querySelectorAll('.btn,.chip,.icon-btn')]
  .filter(b => b.offsetParent !== null)          // المخفي مو هدف لمس
  .filter(b => b.getBoundingClientRect().height < 44)
  .map(b => b.textContent.trim().slice(0, 20)));
check(`★ ولا زرّ أصغر من ٤٤ بكسل${small.length ? ' — ' + small.join(', ') : ''}`,
      small.length === 0);

check('اللغات التلاتة أزرار مو قائمة',
      await page.locator('[data-lang]').count() === 3);
check('والمظهر تلات خيارات',
      await page.locator('[data-theme]').count() === 3);
// ★ علم مو اسم لغة: الاسم بالألماني ما بيساعد مين ما بيقرا الألماني
const flags = await page.locator('[data-lang]').allTextContents();
check(`★ الأزرار أعلام مو أسامي (${flags.join(' ')})`,
      flags.includes('🇩🇪') && flags.includes('🇺🇦')
      && !flags.some(f => /Deutsch|Українська/.test(f)));

// --- المظهر ---
await page.evaluate(() => document.querySelector('[data-theme="dark"]').click());
await page.waitForTimeout(300);
check('★ الوضع الغامق بيشتغل',
      await page.getAttribute('html', 'data-theme') === 'dark');
check('وبينحفظ', await page.evaluate(() => localStorage.getItem('b1.theme')) === '"dark"');
await page.evaluate(() => document.querySelector('[data-theme="system"]').click());
await page.waitForTimeout(300);
check('★ و«متل الجهاز» بيشيل السمة الصريحة',
      await page.getAttribute('html', 'data-theme') === null);

// --- حجم الخط ---
const fs0 = await page.evaluate(() =>
  getComputedStyle(document.body).fontSize);
await page.evaluate(() => document.querySelector('[data-size="+"]').click());
await page.waitForTimeout(300);
const fs1 = await page.evaluate(() => getComputedStyle(document.body).fontSize);
check(`★ A+ بيكبّر الخط (${fs0} → ${fs1})`, parseFloat(fs1) > parseFloat(fs0));
await page.evaluate(() => document.querySelector('[data-size="-"]').click());
await page.waitForTimeout(300);
check('وA− بيرجّعه',
      (await page.evaluate(() => getComputedStyle(document.body).fontSize)) === fs0);

// --- اللغة ---
await page.evaluate(() => document.querySelector('[data-lang="ar"]').click());
await page.waitForTimeout(400);
check('★ الواجهة صارت عربي',
      /أهلاً/.test(await page.textContent('#app')));
check('★ والاتجاه انقلب لليمين',
      await page.getAttribute('html', 'dir') === 'rtl');

await page.evaluate(() => document.querySelector('[data-lang="uk"]').click());
await page.waitForTimeout(400);
check('★ والأوكرانية شغّالة',
      /Вітаємо/.test(await page.textContent('#app')));
check('والاتجاه رجع لليسار',
      await page.getAttribute('html', 'dir') === 'ltr');
check('★ اللغة انحفظت',
      await page.evaluate(() => localStorage.getItem('b1.lang')) === 'uk');

await page.evaluate(() => document.querySelector('[data-lang="de"]').click());
await page.waitForTimeout(400);
await page.waitForSelector('.tile');
check('★ التبديل ما بيطلّع الطالب من الرئيسية',
      /Willkommen/.test(await page.textContent('#app')));
check('★ عناوين الامتحانات ضلّت متل ما هي',
      /PETRA/.test(await page.textContent('#app')));

// ★ ولا كلمة ألمانية بواجهة غير ألمانية.
// بلاطة «المراجعة» ضلّت ألمانية بالعربي شهر كامل — المفاتيح كانت
// بالقاموس، بس نسيت أستعملها. الفحص بيدوّر على الكلمات الألمانية
// الشائعة بالواجهة بدل ما يتّكل على المراجعة بالعين.
await page.evaluate(() => document.querySelector('[data-lang="ar"]').click());
await page.waitForTimeout(300);
await page.waitForSelector('.tile');
const arTxt = await page.textContent('#app');
const leftDe = ['fällig', 'sitzen schon', 'ohne Zeit', 'Wörter', 'Willkommen',
                'Modelltest', 'beantwortet'].filter(w => arTxt.includes(w));
check(`★ ما ضلّت كلمة ألمانية بالواجهة العربية${
        leftDe.length ? ' — ' + leftDe.join(', ') : ''}`, leftDe.length === 0);

await page.evaluate(() => document.querySelector('[data-lang="de"]').click());
await page.waitForTimeout(300);
await page.waitForSelector('.tile');

// ---- ٩) بطاقة الاشتراك ----
// كانت المعلومة تطلع بس لما يكون في أكتر من مستوى، فالطالب العادي ما
// كان يعرف لا شو اشترى ولا إمتى بينتهي. صارت بطاقة دايمة.
check('بطاقة الاشتراك ظهرت لكل مستوى', await page.locator('.abo').count() === 2);
const aboTxt = await page.textContent('.abos');
check(`★ بتقول شو عنده (${aboTxt.replace(/\s+/g,' ').trim().slice(0,60)})`,
      /telc · B1/.test(aboTxt) && /telc · A2/.test(aboTxt));
check('★ وبتقول كم باقي', /noch 3 Tage/.test(aboTxt));
check('★ وبتفرّق التجريبي عن الكامل',
      /Voller Zugang/.test(aboTxt) && /Demo · 1 Modelltest/.test(aboTxt));
check('وبتقول لإيمتى بالتاريخ', /bis \d{2}\.\d{2}\.\d{4}/.test(aboTxt));
// ★ عدد الامتحانات لازم يجي من المستوى الصح. S.index هي قائمة المستوى
// المعروض حالياً، فاستعمالها لصفّ مستوى تاني بيعطي رقم غلط.
check('★ عدد الامتحانات مو مأخوذ من المستوى الغلط',
      (aboTxt.match(/Voller Zugang · 1 Modelltest/g) || []).length === 1
      && !/Voller Zugang · \d+ Modelltests? *\n?.*Voller Zugang/.test(aboTxt));
check('★ القريب من الانتهاء معلّم', await page.locator('.abo.soon').count() === 1);
check('المستوى الحالي معلّم',
      /telc · B1/.test(await page.locator('.abo.on').textContent()));

await page.evaluate(() => document.querySelector('[data-lvl="a2"]').click());
await page.waitForTimeout(600);
check('التبديل لـA2 بيغيّر القائمة', await page.locator('.tile[data-id]').count() === 0);
check('A2 صار المعلّم',
      /telc · A2/.test(await page.locator('.abo.on').textContent()));
check('الاختيار انحفظ', await page.evaluate(() => localStorage.getItem('b1.level')) === '"a2"');
await page.evaluate(() => document.querySelector('[data-lvl="b1"]').click());
await page.waitForTimeout(600);
check('الرجوع لـB1 بيرجّع الامتحانات', await page.locator('.tile[data-id]').count() === 1);

// ★ كود تجريبي مدّته ٢٤ ساعة: «١ يوم» طول عمره بيضلّل — الطالب بيظن
// إنه باقيله يوم كامل وهو باقيله ساعتين. تحت اليومين منعدّ بالساعات.
await page.evaluate(() => {
  const s = window.__MOCK_API;
  const orig = s.subscription;
  s.subscription = async () => ({
    levels: ['b1'], scope: { b1: ['modell-01'] },
    until: { b1: new Date(Date.now() + 5*3600000).toISOString() },
    current_period_end: new Date(Date.now() + 5*3600000).toISOString() });
  s.__orig = orig;
});
await page.evaluate(() => boot());
await page.waitForSelector('.abo');
const demoTxt = await page.textContent('.abos');
check(`★ أقل من يومين بينعدّ بالساعات (${demoTxt.replace(/\s+/g,' ').trim().slice(0,44)})`,
      /noch [45] Stunden/.test(demoTxt) && !/Tage/.test(demoTxt));
check('وبيقول إنه تجريبي', /Demo · 1 Modelltest/.test(demoTxt));
await page.evaluate(() => { window.__MOCK_API.subscription = window.__MOCK_API.__orig; });
await page.evaluate(() => boot());
await page.waitForSelector('.abo');

// ---- ١٠) المراجع ----
await page.evaluate(() => document.getElementById('resbtn').click());
await page.waitForTimeout(500);
check('قائمة المراجع بتفتح', (await page.textContent('body')).includes('Wortschatz Reisen'));
await page.evaluate(() => document.querySelector('[data-res]').click());
await page.waitForTimeout(300);
const rb = await page.textContent('.readable');
check('المرجع بينعرض مع عناوينه', rb.includes('Verben') && rb.includes('fahren, fliegen'));
check('العناوين انعملت h2', await page.locator('.readable h2').count() === 2);

// ---- ١٠ب) مشغّل الاستماع ----
await page.evaluate(() => screenHome());
await page.waitForSelector('.tile[data-id]');
await page.evaluate(() => document.querySelector('.tile[data-id]').click());
await page.waitForSelector('[data-block]');
await page.evaluate(() => document.querySelector('[data-block="block-hv"]').click());
await page.waitForTimeout(300);
await page.evaluate(() => {
  const b = [...document.querySelectorAll('button')].find(x => /Start/i.test(x.textContent));
  if (b) b.click();
});
await page.waitForSelector('.audio [data-play]', { timeout: 8000 });
check('مشغّل الصوت ظهر بقسم الاستماع', true);
// ★ مشغّل واحد بالضبط. أكتر يعني إن التجهيزة ورّثت صوت من قاعدة
// البيانات — وهاد بيفشّل كل منتقي بالوضع الصارم تحت.
check('★ مشغّل واحد بالضبط بالصفحة',
      await page.locator('.audio [data-play]').count() === 1);
check('بيقول كم مرة باقية', (await page.textContent('.audio [data-left]')).includes('2'));
check('★ نص الاستماع المكتوب مخفي وقت الامتحان',
      !(await page.textContent('#app')).includes('TRANSKRIPT-GEHEIM'));

// نشغّله مرتين ونشوف إذا الزرّ بينقفل
for (let k = 0; k < 2; k++){
  await page.evaluate(() => document.querySelector('.audio [data-play]').click());
  await page.waitForFunction(
    () => /Noch einmal|Abgespielt/.test(document.querySelector('.audio [data-play]').textContent),
    { timeout: 8000 });
}
check('★ بعد مرتين الزرّ بينقفل',
      await page.locator('.audio [data-play]').isDisabled());
check('الرسالة صارت «ما في تشغيل بعد»',
      (await page.textContent('.audio [data-left]')).includes('keine'));

await page.evaluate(() => { S.answers = {}; finish(S.run, true); });
await page.waitForSelector('.score');
check('★ وبعد التسليم النص بيبيّن للمراجعة',
      (await page.textContent('#app')).includes('TRANSKRIPT-GEHEIM'));

// ---- ١١) تصحيح التعبير الكتابي ----
await page.evaluate(() => screenHome());
await page.waitForSelector('.tile[data-id]');
await page.evaluate(() => document.querySelector('.tile[data-id]').click());
await page.waitForSelector('[data-block]');
await page.evaluate(() => document.querySelector('[data-block="block-sa"]').click());
await page.waitForTimeout(300);
await page.evaluate(() => {
  const b = [...document.querySelectorAll('button')].find(x => /Start/i.test(x.textContent));
  if (b) b.click();
});
await page.waitForTimeout(400);
await page.evaluate(() => {
  const it = runItems(S.run)[0];
  S.answers[it.id] = 'Liebe Anna, danke fuer deinen Brief. Ich moechte gern kommen.';
  finish(S.run, true);
});
await page.waitForSelector('#aiwrap');
await page.waitForTimeout(600);
check('صندوق التصحيح ظهر بشاشة الكتابة',
      (await page.textContent('#aiwrap')).includes('Korrektur'));
check('التقييم الذاتي لسا موجود جنبه',
      (await page.textContent('body')).includes('Bewerten Sie jedes Kriterium selbst'));
await page.waitForSelector('#aigo');
await page.evaluate(() => document.getElementById('aigo').click());
await page.waitForSelector('#aiout .crit', { timeout: 8000 });
const ai = await page.textContent('#aiwrap');
check('النتيجة ٣٩ نقطة بتبيّن', ai.includes('39'));
check('المعايير الثلاثة مع تبريرها', await page.locator('#aiout .crit').count() === 3);
check('الخطأ معروض مع البديل',
      ai.includes('Ich fliege') && ai.includes('Ich fliege gern'));
check('زرّ الطلب اختفى بعد النجاح', await page.locator('#aigo').isHidden());

await browser.close();
server.close();

const bad = results.filter(r => !r[1]);
console.log(bad.length ? `\n✗ ${bad.length} فشل من ${results.length}`
                       : `\n✓ كل الـ${results.length} اختبارات نجحت`);
process.exit(bad.length ? 1 : 0);
