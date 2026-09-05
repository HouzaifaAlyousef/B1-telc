/* اختبار المتصفّح: بيشغّل التطبيق الحقيقي مع API مزيّف بيرد ببيانات
   مأخوذة من قاعدة Postgres الفعلية — وبيصحّح متل ما بيصحّح السيرفر.
   الهدف: نتأكد إن app.js شغّال بعد نقل التصحيح للسيرفر. */
import { chromium } from 'playwright';
import { readFileSync } from 'fs';
import http from 'http';
import path from 'path';

const ROOT = path.resolve(import.meta.dirname, '..');
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
    const body = readFileSync(path.join(ROOT, f));
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
    sections: fx.sections.map(s => ({
      id: s.section_id, group: s.group, title: s.title, minutes: s.minutes,
      instruction: s.instruction, format: s.format,
      ...(s.section_id === 'hv1' ? { audio: 'test.wav', audioPlays: 2,
          passages: [{ paragraphs: [{ t: 'TRANSKRIPT-GEHEIM', b: false }] }] } : {}),
      items: s.items.map(i => ({ id: i.id, num: i.item_id, text: i.text,
        ...(i.options ? { options: i.options } : {}), ...(i.meta || {}) })),
      ...(s.config || {})
    }))
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
    // اشتراكين منفصلين: A2 بينتهي بعد ٣ أيام، B1 بعد سنين
    subscription: async () => state.redeemed ? {
      levels: ['b1','a2'],
      until: { b1: '2099-01-01T00:00:00Z',
               a2: new Date(Date.now() + 3*86400000).toISOString() },
      current_period_end: '2099-01-01T00:00:00Z' } : null,
    myLevels: async sub => [{ id:'b1', title:'telc Deutsch B1' },
                            { id:'a2', title:'telc Deutsch A2' }]
      .filter(l => sub.levels.includes(l.id)),
    resources: async lvl => lvl === 'b1'
      ? [{ id:'r1', title:'Wortschatz Reisen', kind:'text',
           body:'## Verben\n\nfahren, fliegen, ankommen\n\n## Nomen\n\nder Zug, das Gleis' }]
      : [],
    redeem: async code => code === 'B1-TEST-0001'
      ? (state.redeemed = true, { ok: true, levels: ['b1'] })
      : { ok: false, error: 'invalid_code' },
    index: async (lvl) => lvl !== 'b1' ? { modelle: [] } : ({ modelle: [{ id: fx.test.slug, uuid: fx.test.id,
      title: fx.test.title, subtitle: fx.test.subtitle,
      blocks: fx.test.blocks, aufgaben: 61,
      minutes: fx.test.blocks.reduce((a,b) => a + b.minutes, 0) }] }),
    test: async () => shape(),
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
await page.fill('#code', 'WRONG');
await page.evaluate(() => document.getElementById('godo').click());
await page.waitForTimeout(300);
check('الكود الغلط بيعطي رسالة', (await page.textContent('body')).includes('unbekannt'));

// ---- ٣) كود صح ----
await page.fill('#code', 'B1-TEST-0001');
await page.evaluate(() => document.getElementById('godo').click());
await page.waitForSelector('.tile[data-id]', { timeout: 5000 });
check('الكود الصح بيفتح القائمة', await page.locator('.tile[data-id]').count() > 0);

// ---- ٤) فتح الامتحان ----
await page.evaluate(() => document.querySelector('.tile[data-id]').click());
await page.waitForSelector('[data-block]', { timeout: 5000 });
check('الامتحان انفتح وفيه ٣ كتل', await page.locator('[data-block]').count() === 3);

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
await page.evaluate(() => {
  S.answers = {};
  runItems(S.run).forEach(it => { S.answers[it.id] = 'ZZZ'; });
  finish(S.run, true);
});
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

// ---- ٩) مبدّل المستويات ----
check('مبدّل المستويات ظهر (مستويين من اشتراكين)',
      await page.locator('.levels .lvl').count() === 2);
check('★ المستوى القريب من الانتهاء معلّم',
      await page.locator('.levels .lvl.soon').count() === 1);
check('وبيقول كم يوم باقي', (await page.textContent('.levels')).includes('3T'));
check('المستوى الحالي معلّم', await page.locator('.levels .lvl.on').textContent() === 'telc Deutsch B1');
await page.evaluate(() => document.querySelector('[data-lvl="a2"]').click());
await page.waitForTimeout(600);
check('التبديل لـA2 بيغيّر القائمة', await page.locator('.tile[data-id]').count() === 0);
check('A2 صار المعلّم',
      (await page.locator('.levels .lvl.on').textContent()).startsWith('telc Deutsch A2'));
check('الاختيار انحفظ', await page.evaluate(() => localStorage.getItem('b1.level')) === '"a2"');
await page.evaluate(() => document.querySelector('[data-lvl="b1"]').click());
await page.waitForTimeout(600);
check('الرجوع لـB1 بيرجّع الامتحانات', await page.locator('.tile[data-id]').count() === 1);

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
