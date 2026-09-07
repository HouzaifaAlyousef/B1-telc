/* telc B1 Training — einfache App, keine externen Bibliotheken */
'use strict';

const app    = document.getElementById('app');
const elBack = document.getElementById('btnBack');
const elTimer= document.getElementById('timer');
const elTime = document.getElementById('timerText');
const elToast= document.getElementById('toast');

const S = {
  index: null,      // Übersicht der Modelltests
  modell: null,     // geöffneter Modelltest
  run: null,        // laufender Durchgang: ein Teil oder ein ganzer Prüfungsteil
  answers: {},      // { itemId: Antwort }
  dropped: {},      // { itemId: [früher gewählte Buchstaben] } — werden durchgestrichen
  tick: null,       // Timer
  left: 0,          // verbleibende Sekunden
  view: 'home',
  level: 'b1',      // aktuelle Prüfungsstufe
  levels: [],       // Stufen, die das Abo abdeckt
  sub: null,        // laufendes Abonnement { levels, current_period_end }
  resources: null   // Lesematerial, beim ersten Öffnen geladen
};

/* ============ Helfer ============ */
const esc = s => String(s ?? '').replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const mmss = s => `${String(Math.floor(Math.max(0,s)/60)).padStart(2,'0')}:${String(Math.max(0,s)%60).padStart(2,'0')}`;

function ask(text, onYes, yes, no){
  yes = yes || t('yes'); no = no || t('no');
  const back = document.createElement('div');
  back.className = 'modalback';
  back.innerHTML = `<div class="modal" role="dialog" aria-modal="true">
    <p>${esc(text)}</p>
    <div class="modalbtns">
      <button class="btn grey" data-no>${esc(no)}</button>
      <button class="btn" data-yes>${esc(yes)}</button>
    </div></div>`;
  const close = () => back.remove();
  back.querySelector('[data-no]').onclick = close;
  back.querySelector('[data-yes]').onclick = () => { close(); onYes(); };
  back.onclick = e => { if (e.target === back) close(); };
  document.body.appendChild(back);
  back.querySelector('[data-yes]').focus();
}

function toast(msg, ms = 2400){
  elToast.textContent = msg; elToast.hidden = false;
  clearTimeout(toast._t); toast._t = setTimeout(() => elToast.hidden = true, ms);
}
function load(key, fallback){
  try { const v = localStorage.getItem(key); return v ? JSON.parse(v) : fallback; }
  catch { return fallback; }
}
function save(key, val){
  try { localStorage.setItem(key, JSON.stringify(val)); } catch {}
}

/* ============ Timer ============ */
function startTimer(seconds, onEnd){
  stopTimer();
  S.left = seconds;
  elTimer.hidden = false;
  paint();
  S.tick = setInterval(() => {
    S.left--;
    paint();
    if (S.left % 5 === 0) saveSession(S.run);
    if (S.left <= 0){ stopTimer(); onEnd && onEnd(); }
  }, 1000);

  function paint(){
    elTime.textContent = mmss(S.left);
    elTimer.classList.toggle('low', S.left <= 60);
  }
}
function stopTimer(){
  if (S.tick){ clearInterval(S.tick); S.tick = null; }
  elTimer.hidden = true;
  elTimer.classList.remove('low');
}

/* ============ Navigation ============ */
function go(view, fn){
  S.view = view;
  // آخر دالة رسم: تبديل اللغة بيعيد نداءها بمكانها. الشاشات بتاخد
  // وسائط (نتيجة، جولة…)، فإعادة بنائها من اسم الشاشة بيضيّعهن.
  S.render = fn;
  elBack.hidden = (view === 'home');
  elBack.textContent = t('back');
  window.scrollTo(0, 0);
  fn();
}
/* ============ الإعدادات ============ */
/* لغة، مظهر، حجم خط — شاشة كاملة مو قوائم بالشريط. الشريط ضيّق على
   الموبايل، وأزرار كبيرة واضحة أسهل بكتير لمين مو متعوّد على التقنية —
   وهدول بالضبط ناسنا.

   الواجهة بس بتنترجم: محتوى الامتحان بيضل ألماني، لأن قراءة التعليمة
   الألمانية جزء من الاختبار. */
const THEMES = ['system', 'light', 'dark'];
const SIZES  = [0.9, 1, 1.15, 1.35];      // مضروب بحجم الخط الأساسي

function applyLook(){
  const th = load('b1.theme', 'system');
  // 'system' = بلا سمة صريحة، فالـCSS بيتبع prefers-color-scheme
  if (th === 'system') delete document.documentElement.dataset.theme;
  else document.documentElement.dataset.theme = th;

  let sz = load('b1.size', 1);
  if (!SIZES.includes(sz)) sz = 1;
  document.documentElement.style.setProperty('--fs', (16 * sz) + 'px');
}

/* ★ الإعدادات بترويسة الصفحة الرئيسية، مو ورا زرّ ⚙.
   الزرّ كان بيفتح شاشة لحالها: يعني ضغطتين وخروج من الصفحة تا يكبّر
   الخط أو يبدّل لغته. ومين ما بيقرا الألماني ما كان يعرف إنّ ⚙ تعني
   إعدادات أصلاً. هلق الأعلام والأزرار ظاهرة أول ما يفتح التطبيق. */
function setbarHTML(){
  const th = load('b1.theme', 'system');
  let sz = load('b1.size', 1);
  if (!SIZES.includes(sz)) sz = 1;
  const i = SIZES.indexOf(sz);
  const ic = { system: '🖥', light: '☀', dark: '🌙' };

  return `<div class="setbar" role="group" aria-label="${esc(t('settings'))}">
    <div class="setgrp">
      ${I18N.LANGS.map(l => `<button class="chip${l.id === I18N.lang ? ' on' : ''}"
        data-lang="${esc(l.id)}" title="${esc(l.name)}"
        aria-label="${esc(l.name)}">${esc(l.flag)}</button>`).join('')}
    </div>
    <div class="setgrp">
      ${THEMES.map(x => `<button class="chip${x === th ? ' on' : ''}"
        data-theme="${esc(x)}" title="${esc(t(x === 'system' ? 'themeSystem'
          : x === 'light' ? 'themeLight' : 'themeDark'))}">${ic[x]}</button>`).join('')}
    </div>
    <div class="setgrp">
      <button class="chip" data-size="-" ${i === 0 ? 'disabled' : ''}
        title="${esc(t('smaller'))}" aria-label="${esc(t('smaller'))}">A−</button>
      <button class="chip" data-size="+" ${i === SIZES.length - 1 ? 'disabled' : ''}
        title="${esc(t('bigger'))}" aria-label="${esc(t('bigger'))}">A+</button>
    </div>
  </div>`;
}

/* بعد أي تبديل منعيد رسم الرئيسية: العلم المعلّم بيتغيّر، والاتجاه
   بينقلب مع العربي، وحجم الخط بيبان فوراً على نفس الصفحة. */
function wireSetbar(){
  app.querySelectorAll('[data-lang]').forEach(b => b.onclick = () => {
    I18N.setLang(b.dataset.lang); screenHome();
  });
  app.querySelectorAll('[data-theme]').forEach(b => b.onclick = () => {
    save('b1.theme', b.dataset.theme); applyLook(); screenHome();
  });
  app.querySelectorAll('[data-size]').forEach(b => b.onclick = () => {
    let sz = load('b1.size', 1);
    if (!SIZES.includes(sz)) sz = 1;
    const k = Math.min(SIZES.length - 1,
                Math.max(0, SIZES.indexOf(sz) + (b.dataset.size === '+' ? 1 : -1)));
    save('b1.size', SIZES[k]); applyLook(); screenHome();
  });
}

applyLook();
I18N.apply();

/* الكتالوج بيعرض الامتحانات المقفولة للتشويق — تحسين، مو شرط.
   فشله (قاعدة قديمة، أو واجهة ما بتعرفه) ما لازم يمنع التطبيق يشتغل. */
async function loadCatalog(id){
  try { return (API.catalog ? await API.catalog(id) : []) || []; }
  catch { return []; }
}

elBack.onclick = () => {
  if (S.view === 'exam'){
    ask(t('leaveAsk'),
        () => { stopTimer(); S.run && S.run.drill ? screenHome() : screenModell(S.modell); },
        t('leave'));
  } else if (S.view === 'result' || S.view === 'intro'){
    stopTimer();
    if (S.run && S.run.drill) screenHome(); else screenModell(S.modell);
  } else if (S.view === 'resource'){
    screenResources();
  } else {
    screenHome();
  }
};

/* ============ Start ============ */
/* Die Inhalte liegen jetzt auf dem Server und sind an ein Abonnement
   gebunden. Beim Start wird deshalb zuerst die Sitzung geprüft: ohne
   gültigen Zugang kommt der Code-Bildschirm, sonst die Übersicht. */
async function boot(){
  if (!API.configured()){
    app.innerHTML = `<div class="empty">${esc(t('notConfigured'))}
<br>${esc(t('fillConfig'))}</div>`;
    return;
  }
  app.innerHTML = `<div class="empty">${esc(t('moment'))}</div>`;
  try {
    await API.ensureSession();
    S.sub = API.hasSession() ? await API.subscription() : null;
  } catch { S.sub = null; }

  if (!S.sub) return screenCode();

  try { S.levels = await API.myLevels(S.sub); } catch { S.levels = []; }
  // die zuletzt gewählte Stufe merken, sonst die erste des Abos
  const saved = load('b1.level', null);
  S.level = (saved && S.sub.levels.includes(saved)) ? saved
          : (S.sub.levels && S.sub.levels[0]) || 'b1';
  try {
    S.index = await API.index(S.level);
  } catch {
    app.innerHTML = `<div class="empty">${esc(t('noServer'))}<br>${esc(t('tryLater'))}</div>`;
    return;
  }
  S.catalog = await loadCatalog(S.level);
  screenHome();
}

/* Zugang per Code — es gibt keine E-Mail und kein Passwort. */
function screenCode(msg){
  stopTimer();
  go('code', () => {
    elBack.hidden = true;
    app.innerHTML = `
      <h1>${esc(t('codeTitle'))}</h1>
      <p class="sub">${esc(t('codeHint'))}</p>
      ${msg ? `<div class="instr" style="color:var(--bad)">${esc(msg)}</div>` : ''}
      <div class="card">
        <input id="code" class="codeinput" type="text" inputmode="text"
               autocapitalize="characters" autocorrect="off" spellcheck="false"
               autocomplete="one-time-code"
               placeholder="B14827519366" aria-label="${esc(t('codeTitle'))}">
        <p class="sub" style="margin:6px 0 0">${esc(t('codeExample'))}</p>
        <button class="btn" id="godo" style="width:100%;margin-top:10px">${esc(t('codeButton'))}</button>
      </div>`;

    const inp = document.getElementById('code');
    const btn = document.getElementById('godo');

    /* الكود بينكتب متل ما هو مكتوب بالرسالة: بلا فراغات ولا شرطات.
       كنا منضيف فراغات للقراءة، بس الكود بيوصل عبر واتساب — وهناك ما
       بينعرف إذا الفراغ واحد أو اتنين، فبيصير سؤال بلا داعي. يلي
       بيلصق كود قديم بشرطات ما بينكسر: بينشالوا هون وبـcode_norm.

       ★ وبلا maxlength: المتصفّح بيقصّ الملصوق **قبل** ما يوصلنا، فكود
       منسوخ من واتساب مع فراغاته (١٥ خانة) كان بيوصل ناقص آخر رقمين.
       الحدّ هون، بعد التنضيف، على الخانات الحقيقية. */
    inp.oninput = () => {
      inp.value = inp.value.toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 12);
    };

    const send = async () => {
      const code = inp.value.trim();
      if (!code) return inp.focus();
      btn.disabled = true; btn.textContent = t('codeChecking');
      let r;
      try { r = await API.redeem(code); }
      catch { r = { ok: false, error: 'network' }; }
      btn.disabled = false; btn.textContent = t('codeButton');
      if (r && r.ok) return boot();
      if (r && r.error === 'too_many_attempts'){
        const m = Math.ceil((r.retry_after || 900) / 60);
        return screenCode(t('codeErrTooMany', { t: I18N.plural(m, 'nMinute') }));
      }
      screenCode(t({
        invalid_code:   'codeErrUnknown',
        already_used:   'codeErrUsed',
        revoked:        'codeErrRevoked',
        code_exhausted: 'codeErrExhausted',
        device_limit:   'codeErrDevices',
        network:        'codeErrNetwork'
      }[r && r.error] || 'codeErrOther'));
    };
    btn.onclick = send;
    inp.onkeydown = e => { if (e.key === 'Enter') send(); };
    inp.focus();
  });
}

/* Wiederholung: nur was heute fällig ist. Der Rest wartet auf sein Datum —
   das ist der Sinn der Kästen. */
let review = { due: 0, total: 0, mastered: 0, next_due: null };
async function refreshMistakes(){
  try { review = await API.reviewSummary() || review; }
  catch { review = { due: 0, total: 0, mastered: 0, next_due: null }; }
}

function screenHome(){
  stopTimer();
  // Die Fehlerzahl kommt vom Server. Neu gezeichnet wird nur, wenn sie sich
  // geändert hat — sonst ruft sich der Bildschirm endlos selbst auf.
  const before = review.due;
  refreshMistakes().then(() => {
    if (S.view === 'home' && review.due !== before) screenHome();
  });
  go('home', () => {
    /* المقفولة بتنعرض بعنوانها وعدد أسئلتها بس — محتواها ما بينحمّل
       ولا بينوجد بالصفحة. هدفها إن صاحب التجريبي يعرف إنه في غير
       امتحان. المصدر level_catalog، وهي بترجّع بيانات وصفية فقط. */
    const open = new Set(S.index.modelle.map(m => m.id));
    const list = (S.catalog && S.catalog.length)
      ? S.catalog
      : S.index.modelle.map(m => ({ ...m, open: true }));

    const cards = list.map((m, i) => {
      const frei = m.open !== false && open.has(m.id);
      return `<button class="tile${frei ? '' : ' locked'}"
        ${frei ? `data-id="${esc(m.id)}"` : 'disabled'}>
        <span class="n">${frei ? i + 1 : '🔒'}</span>
        <span class="grow"><span style="font-weight:600">${esc(m.title)}</span>
          <div class="meta">${plural(m.aufgaben, 'nTask')} · ${
            plural(m.minutes, 'nMinute')}</div></span>
        <span class="chev">${frei ? '›' : ''}</span>
      </button>`;
    }).join('');

    const nLocked = list.filter(m => m.open === false).length;

    const nMist = review.due;
    const lvl = S.levels.find(l => l.id === S.level);

    /* «telc · B1». مستوى قديم بلا مؤسسة بيضل بعنوانه — ما منخترع وحدة. */
    const name = l => l.provider && l.stufe
      ? `${l.provider} · ${l.stufe}` : (l.title || l.id);

    /* الوقت الباقي. بالساعات لما يكون أقل من يومين: كود تجريبي مدّته
       ٢٤ ساعة كان بيطلع «١ يوم» طول عمره، وهاد مضلّل — الطالب بيظن
       إنه باقيله يوم كامل وهو باقيله ساعتين. */
    const leftMs = id => {
      const d = S.sub && S.sub.until && S.sub.until[id];
      return d ? new Date(d) - Date.now() : null;
    };
    const remaining = ms => {
      if (ms == null) return '';
      if (ms <= 0) return t('expired');
      if (ms >= 48 * 3600000) return plural(Math.ceil(ms / 86400000), 'daysLeft');
      const h = Math.ceil(ms / 3600000);
      if (h >= 1) return plural(h, 'hoursLeft');
      return t('lessThanHour');
    };
    const endsFmt = id => {
      const d = S.sub && S.sub.until && S.sub.until[id];
      if (!d) return '';
      const x = new Date(d);
      return x.toLocaleDateString('de-DE',
        { day: '2-digit', month: '2-digit', year: 'numeric' });
    };

    /* بطاقة الاشتراك: شو عنده، وكم باقيله — دايماً ظاهرة.
       قبل، هالمعلومة كانت تطلع بس لما يكون عنده أكتر من مستوى، فالطالب
       العادي ما كان يعرف لا شو اشترى ولا إمتى بينتهي. */
    const aboRow = l => {
      const ms = leftMs(l.id);
      const h  = ms == null ? null : Math.floor(ms / 3600000);
      const soon = h != null && h < 24 * 7;
      const only = S.sub && S.sub.scope && S.sub.scope[l.id];
      const n = only ? only.length
              : (l.id === S.level ? (S.index && S.index.modelle || []).length : 0);
      return `<button class="abo${l.id === S.level ? ' on' : ''}${
        soon ? ' soon' : ''}" data-lvl="${esc(l.id)}"
        ${S.levels.length > 1 ? '' : 'disabled'}>
        <span class="grow">
          <span class="who">${esc(name(l))}</span>
          <span class="what">${only
            ? `${esc(t('demo'))} · ${esc(plural(only.length, 'nTest'))}`
            : `${esc(t('fullAccess'))}${n ? ` · ${esc(plural(n, 'nTest'))}` : ''}`}</span>
        </span>
        <span class="when">
          <b>${esc(remaining(ms))}</b>
          <span class="bis">${esc(t('until', { date: endsFmt(l.id) }))}</span>
        </span>
      </button>`;
    };
    const abo = S.levels.length
      ? `<div class="abos">${S.levels.map(aboRow).join('')}</div>` : '';

    app.innerHTML = `
      ${setbarHTML()}
      <h1>${esc(t('welcome'))}</h1>
      ${abo}
      <p class="sub">${lvl ? esc(t('homeIntro', { level: name(lvl) }))
                            : esc(t('homeIntroPlain'))}</p>
      <button class="tile" id="resbtn">
        <span class="n">📖</span>
        <span class="grow"><span style="font-weight:600">${esc(t('material'))}</span>
          <div class="meta">${esc(t('materialMeta'))}</div></span>
        <span class="chev">›</span>
      </button>
      ${nLocked ? `<div class="upsell">
        ${esc(t('upsell', { n: plural(nLocked, 'nMore') }))}
      </div>` : ''}
      ${nMist ? `<button class="tile drill" id="drill">
        <span class="n">↻</span>
        <span class="grow"><span style="font-weight:600">${esc(t('repeat'))}</span>
          <div class="meta">${esc(t('due', { n: plural(nMist, 'nTask') }))}${
            review.mastered
              ? ' · ' + esc(t('sitting', { n: plural(review.mastered, 'nSits') })) : ''
            } · ${esc(t('noTime'))}</div></span>
        <span class="chev">›</span>
      </button>`
      : (review.total ? `<div class="tile drill done">
        <span class="n">✓</span>
        <span class="grow"><span style="font-weight:600">${esc(t('nothingDue'))}</span>
          <div class="meta">${review.mastered ? `${plural(review.mastered, 'nSits')}` : 'Alles wiederholt'}${
            review.next_due ? ` · weiter am ${new Date(review.next_due).toLocaleDateString('de-DE')}` : ''}</div></span>
      </div>` : '')}
      ${cards}`;

    wireSetbar();
    app.querySelectorAll('.tile[data-id]').forEach(b =>
      b.onclick = () => openModell(b.dataset.id));
    app.querySelectorAll('[data-lvl]').forEach(b =>
      b.onclick = () => switchLevel(b.dataset.lvl));
    document.getElementById('resbtn').onclick = screenResources;
    const dr = document.getElementById('drill');
    if (dr) dr.onclick = async () => {
      const run = await drillRun();
      if (run) screenIntro(run); else toast(t('noMistakes'));
    };
  });
}

/* Stufe wechseln: Inhalte, Cache und Merkposten hängen alle daran. */
async function switchLevel(id){
  if (id === S.level) return;
  S.level = id;
  save('b1.level', id);
  Object.keys(modellCache).forEach(k => delete modellCache[k]);
  app.innerHTML = `<div class="empty">${esc(t('moment'))}</div>`;
  try { S.index = await API.index(id); }
  catch { return void toast(t('levelFailed')); }
  S.catalog = await loadCatalog(id);
  screenHome();
}

/* ============ Lesematerial ============ */
/* Kein Test, keine Zeit: Texte, die die Kursleitung eingestellt hat. */
async function screenResources(){
  stopTimer();
  go('resources', () => { app.innerHTML = `<div class="empty">${esc(t('loading'))}</div>`; });
  let rows;
  try { rows = await API.resources(S.level); }
  catch { rows = null; }
  go('resources', () => {
    if (!rows || !rows.length){
      app.innerHTML = `<h1>${esc(t('material'))}</h1>
        <div class="empty">${esc(t('materialEmpty'))}</div>`;
      return;
    }
    app.innerHTML = `<h1>${esc(t('material'))}</h1>
      <p class="sub">${plural(rows.length, 'nText')}. Zum Öffnen tippen.</p>
      ${rows.map((r, i) => `<div class="blockcard">
        <button class="tile" data-res="${i}">
          <span class="grow"><span style="font-weight:600">${esc(r.title)}</span></span>
          <span class="chev">›</span>
        </button></div>`).join('')}`;
    app.querySelectorAll('[data-res]').forEach(b =>
      b.onclick = () => showResource(rows[Number(b.dataset.res)]));
  });
}

/* Sehr einfache Textdarstellung: ## Überschrift, Leerzeile trennt Absätze.
   Absichtlich kein Markdown-Parser — der Text kommt aus dem Adminbereich
   und soll als Text erscheinen, nicht als HTML. */
function showResource(r){
  go('resource', () => {
    const html = String(r.body || '').split(/\n{2,}/).map(p => {
      const t = p.trim();
      if (!t) return '';
      if (/^##\s+/.test(t)) return `<h2>${esc(t.replace(/^##\s+/, ''))}</h2>`;
      if (/^#\s+/.test(t))  return `<h2>${esc(t.replace(/^#\s+/, ''))}</h2>`;
      return `<p>${esc(t).replace(/\n/g, '<br>')}</p>`;
    }).join('');
    app.innerHTML = `<h1>${esc(r.title)}</h1>
      <div class="card readable">${html || `<p class="sub">${esc(t('empty'))}</p>`}</div>`;
  });
}

/* ============ Prüfungsteile eines Modelltests ============ */
/* Die Aufgaben kommen ohne Lösungen vom Server. Die Lösungen erreichen die
   App erst nach dem Abgeben, als Antwort von submit_attempt. */
const modellCache = {};
async function loadModell(id){
  if (!modellCache[id]) modellCache[id] = await API.test(id, S.level);
  return modellCache[id];
}

async function openModell(id){
  try {
    S.modell = await loadModell(id);
  } catch {
    toast(t('loadFailed')); return;
  }
  screenModell(S.modell);
}

function screenModell(m){
  stopTimer();
  go('modell', () => {
    const prog = load('b1.progress', {})[m.id] || {};
    const part = id => m.sections.find(s => s.id === id);

    const blocks = m.blocks.map(b => {
      const parts = b.parts.map(part).filter(Boolean);
      const n = parts.reduce((a, p) => a + p.items.length, 0);
      const r = prog[b.id];
      const saved = r && r.answers;                 // Prüfung liegt vor
      const done = r && r.points !== undefined && r.points !== null;
      const badge = `<span class="pills">
        <span class="pill">${b.minutes} Min.</span>
        ${done ? `<span class="pill ${r.pct >= 60 ? 'ok' : 'bad'}">${fmtP(r.points)}/${fmtP(r.max)}</span>` : ''}
      </span>`;
      const sub = [b.hint, plural(n, 'nTask'), `${fmtP(b.maxPoints)} Punkte`,
                   b.missing ? `${plural(b.missing, 'nMissing')} in der Vorlage` : '']
        .filter(Boolean).join(' · ');
      return `<div class="blockcard">
        <button class="tile" data-block="${esc(b.id)}">
          <span class="grow"><span style="font-weight:600">${esc(b.title)}</span>
            <div class="meta">${esc(sub)}</div></span>
          ${badge}
        </button>
        ${saved ? `<div class="lastrun">
          <span>Letzte Prüfung${r.date ? ' · ' + esc(r.date) : ''}<br>
            ${done ? `${fmtP(r.points)}/${fmtP(r.max)} Punkte · ${r.pct} %`
                   : 'noch nicht bewertet'}</span>
          <button class="btn ghost sm" data-review="${esc(b.id)}">${esc(t('view'))}</button>
          <button class="btn grey sm" data-clear="${esc(b.id)}">${esc(t('remove'))}</button>
        </div>` : ''}
      </div>`;
    }).join('');

    const total = m.blocks.reduce((a, b) => a + b.maxPoints, 0);
    app.innerHTML = `
      <h1>${esc(m.title)}</h1>
      <p class="sub">${esc(m.subtitle || '')}</p>
      ${blocks}
      <p class="sub" style="margin-top:16px">Schriftliche Prüfung insgesamt
        ${fmtP(total)} Punkte — bestanden ab ${fmtP(total * 0.6)} Punkten (60 %).</p>`;

    app.querySelectorAll('[data-block]').forEach(b =>
      b.onclick = () => screenIntro(blockRun(m, b.dataset.block)));
    app.querySelectorAll('[data-review]').forEach(b =>
      b.onclick = () => reviewRun(m, b.dataset.review));
    app.querySelectorAll('[data-clear]').forEach(b =>
      b.onclick = () => ask('Letzte Prüfung löschen?', () => {
        clearResult(m.id, b.dataset.clear);
        screenModell(m);
      }, 'Löschen'));
  });
}

/* Punkte kurz schreiben: 2.5 → "2,5", 25.0 → "25" */
const fmtP = n => (Math.round(n * 10) / 10).toString().replace('.', ',');

/* „1 Aufgabe", nicht „1 Aufgaben" — deutsche Zählung an einer Stelle. */
/* الترجمة بـassets/i18n.js. plural القديمة كانت شكلين ثابتين — والعربي
   ستة أشكال والأوكراني تلاتة، فالجمع صار من I18N حسب قواعد كل لغة. */
const t = (k, v) => I18N.t(k, v);
const plural = (n, key) => I18N.plural(n, key);

/* Ein Durchgang = Titel, Zeit, Punkte und die Teile, die dazugehören. */
function blockRun(m, id){
  const b = m.blocks.find(x => x.id === id);
  const parts = b.parts.map(p => m.sections.find(s => s.id === p)).filter(Boolean);
  return { id: b.id, title: b.title, minutes: b.minutes, hint: b.hint,
           maxPoints: b.maxPoints, availablePoints: b.availablePoints,
           missing: b.missing, parts };
}
const runItems = run => run.parts.flatMap(p => p.items);

/* Die letzte Prüfung noch einmal ansehen — mit den damals gegebenen Antworten. */
function reviewRun(m, blockId){
  const r = (load('b1.progress', {})[m.id] || {})[blockId];
  if (!r || !r.answers) return;
  const run = blockRun(m, blockId);
  S.run = run;
  S.answers = { ...r.answers };
  S.dropped = {};
  stopTimer();
  if (run.parts.length === 1 && run.parts[0].format === 'writing')
    return screenWriting(run, r);
  // Die Lösungen stehen im gespeicherten Ergebnis — die Aufgaben selbst
  // tragen sie nie. Ältere Ergebnisse ohne results sind nicht ansehbar.
  if (!r.results) return toast(t('noSolutions'));
  applyResults(run, r.results);
  const right = r.results.filter(x => x.correct).length;
  screenResult(run, r.points, r.max, r.pct, right, runItems(run).length);
}

/* ============ Startbildschirm ============ */
function screenIntro(run){
  S.run = run;
  S.answers = {};
  S.dropped = {};
  // Übungen kennen weder Entwurf noch angefangene Sitzung
  const sess = run.drill ? null : loadSession(run.id);
  stopTimer();
  go('intro', () => {
    const n = runItems(run).length;
    // Der Hinweis „keine Hörtexte" gilt nur, solange kein Audio hinterlegt ist
    const notes = [...new Set(run.parts
      .filter(p => !p.audio).map(p => p.note).filter(Boolean))];
    const list = run.parts.length > 1
      ? `<ul class="partlist">${run.parts.map(p =>
          `<li><span class="grow">${esc(p.title)}</span>
             <span class="meta">${plural(p.items.length, 'nTask')} · ${fmtP(p.maxPoints)} P.</span></li>`).join('')}</ul>`
      : `<div class="instr">${esc(run.parts[0].instruction)}</div>`;

    app.innerHTML = `
      <div class="card">
        <span class="pill">${run.drill ? 'Übung' : 'Wie in der Prüfung'}</span>
        <h2 style="margin-top:10px">${esc(run.title)}</h2>
        ${run.hint ? `<p class="sub" style="margin-bottom:14px">${esc(run.hint)}</p>` : ''}
        ${list}
        ${run.missing ? `<div class="fb warn" style="margin-bottom:16px">
          In diesem Modelltest fehlen ${run.missing} Aufgaben — sie sind in der
          Vorlage abgeschnitten. Ihr Ergebnis wird auf die offiziellen
          ${fmtP(run.maxPoints)} Punkte umgerechnet.</div>` : ''}
        ${notes.map(t => `<div class="fb warn" style="margin-bottom:16px">${esc(t)}</div>`).join('')}
        <div class="row" style="gap:24px;margin-bottom:16px">
          <div><div class="meta" style="color:var(--muted);font-size:13px">${esc(t('tasks'))}</div>
               <b style="font-size:18px">${n}</b></div>
          <div><div class="meta" style="color:var(--muted);font-size:13px">${esc(t('time'))}</div>
               <b style="font-size:18px">${run.drill ? 'ohne' : run.minutes + ' Minuten'}</b></div>
          <div><div class="meta" style="color:var(--muted);font-size:13px">${run.drill ? 'Richtig zu lösen' : 'Punkte'}</div>
               <b style="font-size:18px">${fmtP(run.maxPoints)}</b></div>
        </div>
        ${sess ? `<button class="btn wide" id="resume">Prüfung fortsetzen — ${mmss(sess.left)} übrig</button>
             <button class="btn ghost wide" id="start" style="margin-top:10px">${esc(t('restart'))}</button>`
               : `<button class="btn wide" id="start">${esc(t('start'))}</button>`}
      </div>`;
    document.getElementById('start').onclick = () => {
      clearSession(run.id);
      S.answers = {}; S.dropped = {};
      screenExam(run);
    };
    const res = document.getElementById('resume');
    if (res) res.onclick = () => {
      S.answers = { ...sess.answers }; S.dropped = { ...sess.dropped };
      screenExam(run, sess.left);
    };
  });
}

/* ============ Prüfung ============ */
function screenExam(run, resumeLeft){
  go('exam', () => {
    const nav = run.parts.length > 1
      ? `<nav class="partnav">${run.parts.map((p, i) =>
          `<a href="#part-${esc(p.id)}">${esc(shortTitle(p.title))}</a>`).join('')}</nav>`
      : '';

    const body = run.parts.map(p => `
      <section class="part" id="part-${esc(p.id)}">
        ${run.parts.length > 1 ? `<h2 class="parthead">${esc(p.title)}</h2>
          <div class="instr">${esc(p.instruction)}</div>` : ''}
        ${renderPassages(p)}${renderBank(p)}
        ${p.items.map(it => renderItem(p, it)).join('')}
      </section>`).join('');

    app.innerHTML = nav + body +
      `<div class="bottombar">
         <div class="progbar"><i id="progfill"></i></div>
         <div class="inner">
         <span class="progress" id="prog"></span>
         <button class="btn grey" id="pause">${esc(t('pause'))}</button>
         <button class="btn grow" id="submit">${esc(t('submit'))}</button>
       </div></div>`;

    run.parts.forEach(p => bindInputs(p));
    updateProgress();
    markCurrentPart();
    /* الوقت محدود والزرّ كبير — التسليم بالغلط بيصير. لو في أسئلة بلا
       إجابة، منسأل ومنقول كم، بدل ما نسلّم بصمت. */
    document.getElementById('submit').onclick = () => {
      const items = runItems(run);
      const open  = items.length - items.filter(answered).length;
      if (!open) return finish(run, false);
      ask(t('openAsk', { n: plural(open, 'nOpen') }),
          () => finish(run, false), t('submitAnyway'), t('keepGoing'));
    };
    const pz = document.getElementById('pause');
    if (run.drill) { pz.remove(); stopTimer(); }     // Übung läuft ohne Uhr
    else {
      pz.onclick = () => pauseExam(run);
      startTimer(resumeLeft || run.minutes * 60,
                 () => { toast(t('timeUp')); finish(run, true); });
    }
  });
}

/* Der Teil, in dem man gerade liest, wird in der Sprungleiste markiert.
   Ein einziger Zuhörer fürs Scrollen, der nichts tut, wenn keine Leiste da ist. */
function markCurrentPart(){
  const links = [...document.querySelectorAll('.partnav a')];
  if (!links.length) return;
  const line = 130;                    // knapp unter Kopf- und Sprungleiste
  let cur = 0;
  links.forEach((a, i) => {
    const el = document.getElementById(a.getAttribute('href').slice(1));
    if (el && el.getBoundingClientRect().top <= line) cur = i;
  });
  links.forEach((a, i) => a.classList.toggle('active', i === cur));
}

/* Beim Antworten springt die Markierung sofort auf den Teil, in dem
   die Aufgabe steht — man sieht also, wo man gerade löst. */
function markPart(partId){
  const links = [...document.querySelectorAll('.partnav a')];
  links.forEach(a => a.classList.toggle('active',
    a.getAttribute('href') === '#part-' + partId));
}

let markRaf = 0;
addEventListener('scroll', () => {
  if (!markRaf) markRaf = requestAnimationFrame(() => { markRaf = 0; markCurrentPart(); });
}, { passive: true });

const shortTitle = t => t.replace('Leseverstehen', 'LV').replace('Sprachbausteine', 'SB')
                         .replace('Hörverstehen', 'HV').replace(', Teil ', ' ');

function renderBrief(sec){
  const b = sec.brief, it = sec.items[0];
  return `
    ${b.intro ? `<p class="briefintro">${esc(b.intro)}</p>` : ''}
    <div class="brief">
      <p class="anrede">${esc(b.greeting)}</p>
      ${b.paragraphs.map(p => `<p>${esc(p)}</p>`).join('')}
      ${b.signature ? `<p class="sig">${esc(b.signature)}</p>` : ''}
    </div>
    <div class="task">
      <p>${esc(sec.instruction)}</p>
      <ul>${it.points.map(p => `<li>${esc(p)}</li>`).join('')}</ul>
      ${(sec.hints || []).map(h => `<p class="hint">${esc(h)}</p>`).join('')}
      ${(sec.hints || []).some(h => /mindestens/i.test(h)) ? ''
        : `<p class="hint">Schreiben Sie mindestens ${it.minWords} Wörter.</p>`}
    </div>`;
}

/* ============ Hörverstehen ============
   Wie in der Prüfung: begrenzt oft abspielbar, kein Vor- und Zurückspulen.
   Der Text steht daneben erst nach der Abgabe. */
function renderAudio(sec){
  if (!sec.audio) return '';
  const slot = `au_${Math.random().toString(36).slice(2)}`;
  const plays = Math.max(1, Number(sec.audioPlays) || 1);

  API.audioUrl(sec.audio).then(url => {
    const el = document.getElementById(slot);
    if (!el) return;
    if (!url){ el.innerHTML = `<p class="sub">${esc(t('audioFailed'))}</p>`; return; }

    let left = plays;
    el.innerHTML = `
      <button class="btn" data-play>${esc(t('audioPlay'))}</button>
      <span class="sub" data-left>${esc(plural(left, 'audioLeft'))}</span>
      <div class="audiobar"><i></i></div>`;
    const audio = new Audio(url);
    audio.preload = 'auto';
    const btn  = el.querySelector('[data-play]');
    const info = el.querySelector('[data-left]');
    const bar  = el.querySelector('.audiobar i');

    audio.addEventListener('timeupdate', () => {
      if (audio.duration) bar.style.width = (audio.currentTime / audio.duration * 100) + '%';
    });
    audio.addEventListener('ended', () => {
      left--;
      btn.disabled = left <= 0;
      btn.textContent = left > 0 ? t('audioAgain') : t('audioDone');
      info.textContent = left > 0 ? plural(left, 'audioLeft') : t('audioNone');
      bar.style.width = '100%';
    });
    btn.onclick = () => {
      if (left <= 0) return;
      btn.disabled = true;
      btn.textContent = '⏸ Läuft …';
      // kein Zurückspulen: jede Wiedergabe startet von vorn und läuft durch
      audio.currentTime = 0;
      audio.play().catch(() => {
        btn.disabled = false; btn.textContent = t('audioPlay');
        info.textContent = 'Wiedergabe nicht möglich';
      });
    };
  }).catch(() => {});

  return `<div class="audio" id="${slot}"><p class="sub">${esc(t('audioLoading'))}</p></div>`;
}

function renderPassages(sec){
  if (sec.brief) return renderBrief(sec);
  // Bei einem echten Hörtext ist das Transkript die Lösung — während der
  // Prüfung bleibt es weg, in der Auswertung darf es erscheinen.
  if (sec.audio && S.view === 'exam') return renderAudio(sec);
  if (!sec.passages || !sec.passages.length) return renderAudio(sec);
  return renderAudio(sec) + sec.passages.map(p => `
    <div class="passage">
      ${p.title ? `<h3>${esc(p.title)}</h3>` : ''}
      ${(p.paragraphs || []).map(x =>
        `<p${x.b ? ' class="strong"' : ''}>${esc(x.t)}</p>`).join('')}
    </div>`).join('');
}

function renderBank(sec){
  if (sec.bankImage){
    // Die Anzeigen sind Prüfungsinhalt wie die Aufgaben: sie liegen in einem
    // privaten Bucket und werden über eine signierte URL nachgeladen.
    const slot = `img_${Math.random().toString(36).slice(2)}`;
    API.imageUrl(sec.bankImage).then(url => {
      const el = document.getElementById(slot);
      if (!el) return;
      if (!url) return void (el.textContent = 'Die Anzeigen konnten nicht geladen werden.');
      el.innerHTML = `<a href="${esc(url)}" target="_blank" rel="noopener">
        <img src="${esc(url)}" alt="Anzeigen" class="bankimg"></a>`;
    }).catch(() => {});
    return `<div class="bank"><h3>${esc(sec.bankTitle || 'Anzeigen')}</h3>
      <p class="sub" style="margin:0 0 10px">${esc(t('imgTap'))}</p>
      <div id="${slot}" class="bankslot">${esc(t('imgLoading'))}</div></div>`;
  }
  if (!sec.bank || !sec.bank.length) return '';
  return `<div class="bank"><h3>${esc(sec.bankTitle || 'Auswahl')}</h3>
    <ul>${sec.bank.map(o =>
      `<li><span class="k">${esc(o.key)}</span>${esc(o.text)}</li>`).join('')}</ul></div>`;
}

function renderItem(sec, it){
  const head = `<div class="qhead"><span class="qnum">${esc(it.num || it.id)}</span>
    <span class="qtext grow">${esc(it.text)}</span></div>`;
  let body = '';

  if (sec.format === 'writing'){
    const draft = S.answers[it.id] || '';
    const n = draft.trim().split(/\s+/).filter(Boolean).length;
    return `<div class="q" id="q_${esc(it.id)}">
      <textarea data-txt="${esc(it.id)}" placeholder="Schreiben Sie hier Ihren Brief …">${esc(draft)}</textarea>
      <div class="counter" id="wc_${esc(it.id)}">${n} Wörter (mindestens ${it.minWords || 100})</div>
    </div>`;
  }
  if (sec.format === 'mc' || sec.format === 'truefalse'){
    const opts = sec.format === 'truefalse'
      ? [{ key: 'r', text: 'Richtig' }, { key: 'f', text: 'Falsch' }]
      : it.options;
    const chosen = S.answers[it.id];
    const gone = S.dropped[it.id] || [];
    body = `<div class="opts ${sec.format === 'truefalse' ? 'inline' : ''}">${
      opts.map(o => `<label class="opt${o.key === chosen ? ' sel' : ''}${gone.includes(o.key) ? ' dropped' : ''}" data-opt="${esc(it.id)}|${esc(o.key)}">
        <input type="radio" name="q_${esc(it.id)}" value="${esc(o.key)}"${o.key === chosen ? ' checked' : ''}>
        <span class="k">${esc(o.key)}</span><span class="grow">${esc(o.text)}</span>
      </label>`).join('')}</div>`;
  }
  else if (sec.format === 'matching' || sec.format === 'wordbank'){
    const chosen = S.answers[it.id] || '';
    /* أزرار حروف بدل قائمة منسدلة.
       القائمة بتطلب: ضغطة، قراءة، تمرير، إصابة — وبخمستعشر خيار على
       موبايل هاد صعب لمين مو متعوّد. الأزرار بتبيّن كل الحروف مرة وحدة
       وبتنضغط بضغطة. ونصّ البنك أصلاً معروض فوق الأسئلة. */
    body = `<div class="keys" data-keys="${esc(it.id)}" role="group">${
      sec.bank.map(o => `<button type="button" class="key${
        o.key === chosen ? ' sel' : ''}" data-key="${esc(it.id)}|${esc(o.key)}"
        title="${esc(o.text || o.key)}">${esc(o.key)}</button>`).join('')}
      ${chosen ? `<button type="button" class="key clr" data-key="${esc(it.id)}|"
        title="${esc(t('choose'))}">✕</button>` : ''}
    </div>`;
  }
  return `<div class="q" id="q_${esc(it.id)}">${head}${body}</div>`;
}

/* In Zuordnungsaufgaben passt jede Antwort nur einmal ("Jede Überschrift /
   jedes Wort passt nur einmal"). Schon vergebene Antworten werden in den
   anderen Aufgaben gesperrt. Ausnahme: X in Leseverstehen Teil 3 — das darf
   mehrfach vorkommen, wenn zu einer Situation keine Anzeige passt. */
function syncBank(sec){
  if (sec.format !== 'matching' && sec.format !== 'wordbank') return;
  const scope = document.getElementById('part-' + sec.id) || app;
  const used = new Map();
  sec.items.forEach(it => {
    const v = S.answers[it.id];
    if (v && v !== 'X') used.set(v, it.id);
  });
  scope.querySelectorAll('[data-keys]').forEach(box => {
    const id = box.dataset.keys;
    box.querySelectorAll('[data-key]').forEach(b => {
      const k = b.dataset.key.split('|')[1];
      b.disabled = !!k && used.has(k) && used.get(k) !== id;
    });
  });
}

function bindInputs(sec){
  const scope = document.getElementById('part-' + sec.id) || app;
  scope.querySelectorAll('[data-opt]').forEach(lb => {
    lb.onclick = () => {
      const [id, key] = lb.dataset.opt.split('|');
      const before = S.answers[id];
      if (before && before !== key){          // frühere Wahl durchstreichen
        (S.dropped[id] ||= []).push(before);
      }
      S.dropped[id] = (S.dropped[id] || []).filter(k => k !== key);
      S.answers[id] = key;
      markPart(sec.id);
      const box = lb.closest('.opts');
      box.querySelectorAll('.opt').forEach(x => {
        const k = x.dataset.opt.split('|')[1];
        x.classList.toggle('sel', k === key);
        x.classList.toggle('dropped', (S.dropped[id] || []).includes(k));
      });
      updateProgress();
    };
  });
  scope.querySelectorAll('[data-key]').forEach(b => b.onclick = () => {
    const [id, key] = b.dataset.key.split('|');
    if (key) S.answers[id] = key; else delete S.answers[id];
    markPart(sec.id);
    // نعيد رسم المجموعة: التحديد بيتغيّر وزرّ المسح بيظهر أو بيختفي
    const q  = b.closest('.q');
    const it = sec.items.find(x => x.id === id);
    q.outerHTML = renderItem(sec, it);
    bindInputs(sec);
    syncBank(sec);
    updateProgress();
  });
  syncBank(sec);
  scope.querySelectorAll('[data-txt]').forEach(ta => {
    ta.oninput = () => {
      const id = ta.dataset.txt;
      S.answers[id] = ta.value;
      markPart(sec.id);
      const n = ta.value.trim().split(/\s+/).filter(Boolean).length;
      const c = document.getElementById('wc_' + id);
      const min = sec.items.find(x => x.id === id).minWords || 100;
      if (c){ c.textContent = `${n} Wörter (mindestens ${min})`; c.style.color = n >= min ? 'var(--ok)' : 'var(--muted)'; }
      updateProgress();
    };
  });
}

const answered = it => {
  const v = S.answers[it.id];
  return v !== undefined && String(v).trim() !== '';
};

function updateProgress(){
  saveSession(S.run);
  const items = runItems(S.run);
  const done  = items.filter(answered).length;
  const p = document.getElementById('prog');
  // «١٢ من ٤٠» أوضح من «12 / 40» لواحد مو متعوّد على الاختصارات
  if (p) p.textContent = t('progress', { done, total: items.length });
  const f = document.getElementById('progfill');
  if (f) f.style.width = items.length ? (done / items.length * 100) + '%' : '0';
}

/* Pause: der Timer hält an und die Aufgaben werden verdeckt — wie eine
   echte Pause. Der Stand ist gesichert, die App darf auch zugehen. */
function pauseExam(run){
  stopTimer();
  saveSession(run);
  document.body.classList.add('paused');     // Aufgaben verdecken
  const box = document.createElement('div');
  box.className = 'modalback';
  box.innerHTML = `<div class="modal" role="dialog" aria-modal="true">
    <h2 style="margin:0 0 6px">${esc(t('pause'))}</h2>
    <p>${esc(t('timerPaused'))}</p>
    <p class="pausetime">${mmss(S.left)} übrig</p>
    <div class="modalbtns">
      <button class="btn grey" data-exit>${esc(t('finish'))}</button>
      <button class="btn" data-go>${esc(t('resume'))}</button>
    </div></div>`;
  document.body.appendChild(box);
  const close = () => { box.remove(); document.body.classList.remove('paused'); };
  box.querySelector('[data-go]').onclick = () => {
    close();
    startTimer(S.left, () => { toast(t('timeUp')); finish(run, true); });
  };
  box.querySelector('[data-exit]').onclick = () => { close(); screenModell(S.modell); };
}

/* ============ Fehlerliste ============ */
/* Die Fehler stehen jetzt in der Datenbank: submit_attempt trägt sie ein,
   submit_drill nimmt sie wieder heraus, sobald die Aufgabe sitzt. Die App
   holt sie nur noch ab. */

/* Baut aus den Fehlern einen Übungsdurchgang: je Modelltest und Teil ein
   Abschnitt mit seinem Text und seiner Wortliste — sonst wären die Aufgaben
   gar nicht lösbar — aber nur mit den Aufgaben, die falsch waren. */
async function drillRun(){
  let rows;
  try { rows = await API.mistakes(); } catch { return null; }
  if (!rows || !rows.length) return null;

  // nach Modelltest und Abschnitt gruppieren
  const bySec = new Map();
  rows.forEach(row => {
    const it  = row.items;         if (!it) return;
    const sec = it.sections;       if (!sec || sec.format === 'writing') return;
    const key = `${sec.tests ? sec.tests.slug : '?'}~${sec.section_id}`;
    if (!bySec.has(key)) bySec.set(key, { sec, items: [] });
    bySec.get(key).items.push({
      id: it.id, num: it.item_id, text: it.text,
      ...(it.options ? { options: it.options } : {}),
      ...(it.meta || {})
    });
  });

  const parts = [];
  for (const [key, g] of bySec){
    const cfg = g.sec.config || {};
    parts.push({
      ...cfg, id: key, sid: g.sec.section_id, format: g.sec.format,
      title: `${g.sec.tests ? g.sec.tests.title : ''} · ${g.sec.title}`,
      instruction: '', items: g.items,
      pointsPerItem: 1, maxPoints: g.items.length,
      availablePoints: g.items.length
    });
  }
  if (!parts.length) return null;
  const n = parts.reduce((a, p) => a + p.items.length, 0);
  return { id: 'drill', title: 'Fehler wiederholen', drill: true, parts,
           minutes: 0, maxPoints: n, availablePoints: n, missing: 0 };
}

/* ============ Korrektur ============ */

/* Notenstufen laut telc: 90 / 80 / 70 / 60 % der Höchstpunktzahl. */
function noteOf(pct){
  if (pct >= 90) return 'sehr gut';
  if (pct >= 80) return 'gut';
  if (pct >= 70) return 'befriedigend';
  if (pct >= 60) return 'ausreichend';
  return 'nicht bestanden';
}

function saveResult(run, points, max, extra = {}){
  // points === null: Text abgegeben, aber noch nicht bewertet
  const pct = points === null ? null : Math.round(points / max * 100);
  const prog = load('b1.progress', {});
  // nur die letzte Prüfung je Prüfungsteil — eine neue ersetzt die alte
  (prog[S.modell.id] ||= {})[run.id] = {
    points, max, pct,
    date: new Date().toLocaleDateString('de-DE'),
    answers: { ...S.answers },
    ...extra
  };
  save('b1.progress', prog);
  return pct;
}

/* Der Text im Schriftlichen Ausdruck lebt sonst nur im Speicher — geht die
   Seite zu, ist eine halbe Stunde Arbeit weg. Darum wird beim Tippen laufend
   ein Entwurf gesichert und beim nächsten Start wieder eingesetzt. */

/* جلسة امتحان جارية: الإجابات والوقت المتبقّي. منحفظها باستمرار تا لو
   سكّرت الصفحة أو طلعت تتغدّى، ترجع من وين وقّفتي — والمؤقّت ما بيمشي وأنت
   برّا، لأنه بينحفظ الوقت المتبقّي مو وقت البداية. */
const sessKey = runId => `b1.session.${S.modell ? S.modell.id : '-'}.${runId}`;

function saveSession(run){
  if (!run || run.drill || S.view !== 'exam') return;
  save(sessKey(run.id), {
    answers: S.answers, dropped: S.dropped, left: S.left,
    date: new Date().toLocaleDateString('de-DE')
  });
}
const loadSession = runId => load(sessKey(runId), null);
function clearSession(runId){
  try { localStorage.removeItem(sessKey(runId)); } catch {}
}

function clearResult(modellId, runId){
  const prog = load('b1.progress', {});
  if (prog[modellId]) delete prog[modellId][runId];
  if (prog[modellId] && !Object.keys(prog[modellId]).length) delete prog[modellId];
  save('b1.progress', prog);
}

/* Die Lösungen kommen mit der Korrektur zurück. Sie werden hier auf die
   Aufgaben gelegt, damit die Ergebnisanzeige unverändert weiterläuft —
   vor dem Abgeben ist it.answer schlicht nicht vorhanden. */
function applyResults(run, results){
  const by = {};
  (results || []).forEach(r => { if (r.id) by[r.id] = r; });
  run.parts.forEach(p => p.items.forEach(it => {
    const r = by[it.id];
    if (!r) return;
    it.answer = r.answer;
    if (r.explanation) it.explain = r.explanation;
  }));
}

/* Korrigiert wird auf dem Server. Die App schickt die Antworten und
   bekommt Punkte und Lösungen zurück; sie kann nicht selbst rechnen. */
async function grade(run){
  app.innerHTML = `<div class="empty">${esc(t('aiWorking'))}</div>`;
  let res;
  try {
    res = run.drill
      ? await API.submitDrill(S.answers)
      : await API.submitAttempt(S.modell.uuid, run.id, S.answers);
  } catch {
    res = null;
  }
  if (!res || !res.ok){
    app.innerHTML = `<div class="empty">${esc(t('aiFailed'))}<br>${
      esc(t('savedOffline'))}</div>`;
    saveSession(run);
    return;
  }
  applyResults(run, res.results);
  refreshMistakes();

  // In manchen Modelltests fehlen Aufgaben (in der Vorlage abgeschnitten).
  // Der Server rechnet über die vorhandenen; hier wird auf die offizielle
  // Höchstpunktzahl hochgerechnet, damit alle Tests vergleichbar bleiben.
  if (run.drill && res.mastered)
    toast(`${plural(res.mastered, 'nSits')} jetzt ✓`, 3500);
  const points = run.drill
    ? res.right
    : Math.round(res.points / (res.max_points || 1) * run.maxPoints * 10) / 10;
  const total  = runItems(run).length;
  const right  = (res.results || []).filter(r => r.correct).length;
  const pct    = run.drill ? Math.round(points / max * 100)
                           : saveResult(run, points, run.maxPoints,
                                        { results: res.results, attemptId: res.attempt_id });
  screenResult(run, points, run.drill ? max : run.maxPoints, pct, right, total);
}

function finish(run, auto){
  const go2 = () => {
    stopTimer();
    clearSession(run.id);
    if (run.parts.length === 1 && run.parts[0].format === 'writing'){
      // Der Text wird sofort gesichert. Die Abgabe wandert auch auf den
      // Server — ohne attempt_id gibt es keine KI-Korrektur.
      saveResult(run, null, run.parts[0].maxPoints);
      screenWriting(run);
      API.submitAttempt(S.modell.uuid, run.id, S.answers)
        .then(res => {
          if (!res || !res.ok) return;
          const prog = load('b1.progress', {});
          const rec = (prog[S.modell.id] || {})[run.id];
          if (rec){ rec.attemptId = res.attempt_id; save('b1.progress', prog); }
          const el = document.getElementById('aiwrap');
          if (el) renderAiBox(el, run, res.attempt_id, null);
        })
        .catch(() => {});
      return;
    }

    grade(run);
  };

  /* ★ السؤال عن الأسئلة الفاضية بيصير عند زرّ التسليم، مو هون.
     كان بالاتنين — فالطالب يلي بيسلّم ناقص كان يشوف نفس التحذير مرتين
     ورا بعض. وهاد كمان كان آخر نص ألماني مثبّت بالتطبيق.
     هون منسلّم على طول: مين وصل لهون خلص قرّر. */
  go2();
}

/* Antwort lesbar machen: "B — Bildband: Babys im Garten" */
function answerLabel(sec, it, k){
  if (!k) return 'keine Antwort';
  if (sec.format === 'truefalse') return k === 'r' ? 'Richtig' : 'Falsch';
  if (sec.bank){
    const o = sec.bank.find(x => x.key === k);
    return o ? (o.text ? `${k} — ${o.text}` : k) : '—';
  }
  const o = (it.options || []).find(x => x.key === k);
  return o ? `${k} — ${o.text}` : '—';
}

function scoreCard(points, max, pct, extra){
  const cls = pct >= 60 ? 'ok' : 'bad';
  return `<div class="card score">
    <div class="big" style="color:var(--${cls})">${fmtP(points)}<span style="font-size:26px;color:var(--muted)">/${fmtP(max)}</span></div>
    <div class="pct">${pct} % · ${esc(noteOf(pct))}</div>
    <div class="bar"><i class="${cls}" style="width:${pct}%"></i></div>
    <div class="meta" style="color:var(--muted);font-size:13px">
      ${esc(t('passFrom', { p: fmtP(max * 0.6) }))}${
        extra ? ' · ' + esc(extra) : ''}</div>
  </div>`;
}

function screenResult(run, points, max, pct, right, total){
  go('result', () => {
    const perPart = run.parts.map(p => {
      const ok = p.items.filter(it => S.answers[it.id] === it.answer).length;
      // Nach der Abgabe darf das Transkript erscheinen: jetzt hilft es beim
      // Nachlesen, statt die Lösung zu verraten.
      const script = (p.audio && p.passages && p.passages.length)
        ? `<div class="passage"><h3>${esc(t('transcript'))}</h3>${p.passages.map(x =>
             (x.paragraphs || []).map(y =>
               `<p${y.b ? ' class="strong"' : ''}>${esc(y.t)}</p>`).join('')).join('')}</div>`
        : '';
      const pts = Math.round(ok * p.pointsPerItem / p.availablePoints * p.maxPoints * 10) / 10;
      const head = run.parts.length > 1
        ? `<div class="partscore"><span class="grow">${esc(p.title)}</span>
             <span class="meta">${ok}/${p.items.length} richtig</span>
             <span class="pill ${pts / p.maxPoints >= 0.6 ? 'ok' : 'bad'}">${fmtP(pts)}/${fmtP(p.maxPoints)} P.</span>
           </div>` : '';
      const cards = p.items.map(it => {
        const mine = S.answers[it.id];
        const good = mine === it.answer;
        return `<div class="q ${good ? 'isok' : 'isbad'}">
          <div class="qhead"><span class="qnum">${esc(it.num || it.id)}</span>
            <span class="qtext grow">${esc(it.text)}</span></div>
          <div class="fb ${good ? 'ok' : 'bad'}">
            ${good ? `<b>✔ Richtig · ${fmtP(p.pointsPerItem)} P.</b>` : `<b>${esc(t('wrong'))}</b>
               <div class="fbrow"><span class="lbl">${esc(t('yourAnswer'))}</span>
                 <span class="val">${esc(answerLabel(p, it, mine))}</span></div>
               <div class="fbrow"><span class="lbl">${esc(t('solution'))}</span>
                 <span class="val">${esc(answerLabel(p, it, it.answer))}</span></div>`}
            ${it.explain ? `<div class="why">${esc(it.explain)}</div>` : ''}
          </div>
        </div>`;
      }).join('');
      return head + script + cards;
    }).join('');

    app.innerHTML =
      scoreCard(points, max, pct, `${right} von ${total} Aufgaben richtig`) +
      `<h2 style="margin:18px 0 10px">${esc(t('correction'))}</h2>${perPart}
      <div class="bottombar"><div class="inner">
        <button class="btn ghost grow" id="again">${esc(t('again'))}</button>
        <button class="btn grow" id="back">${esc(t('overview'))}</button>
      </div></div>`;

    document.getElementById('again').onclick = () =>
      run.drill ? drillRun().then(r => r ? screenIntro(r) : screenHome())
                : screenIntro(run);
    document.getElementById('back').onclick  = () =>
      run.drill ? screenHome() : screenModell(S.modell);
  });
}

/* Schriftlicher Ausdruck: Selbstbewertung nach den drei telc Kriterien.
   Jedes Kriterium A=5 / B=3 / C=1 / D=0, die Summe wird mit 3 multipliziert. */
function screenWriting(run, saved){
  const sec = run.parts[0];
  const it = sec.items[0];
  const mine = (S.answers[it.id] || '').trim();
  const words = mine.split(/\s+/).filter(Boolean).length;
  const grades = { ...(saved && saved.grades || {}) };

  go('result', () => {
    app.innerHTML = `
      <div class="card">
        <h2>${esc(t('yourText'))}</h2>
        <p class="sub">${esc(plural(words, 'words'))}${
          words < (it.minWords || 100)
            ? ' ' + esc(t('minWords', { n: it.minWords || 100 })) : ''}</p>
        <div class="passage" style="margin:0"><div class="body">${esc(mine || '(kein Text geschrieben)')}</div></div>
      </div>
      <div class="card">
        <h2>${esc(t('taskHead'))}</h2>
        ${renderBrief(sec)}
      </div>
      <div class="card">
        <h2>${esc(t('grading'))}</h2>
        <p class="sub">${esc(t('rateSelf'))}</p>
        ${sec.criteria.map((c, i) => `
          <div class="crit">
            <h3>${esc(c.title)}</h3>
            <p class="sub" style="margin:0 0 8px">${esc(c.hint)}</p>
            <div class="opts inline">${sec.grades.map(g =>
              `<label class="opt" data-crit="${i}|${esc(g.key)}">
                 <input type="radio" name="crit${i}" value="${esc(g.key)}">
                 <span class="k">${esc(g.key)}</span>
                 <span class="grow">${g.points} P.</span>
               </label>`).join('')}</div>
          </div>`).join('')}
        <div id="wres"></div>
      </div>
      <div class="card" id="aiwrap">
        <h2>${esc(t('correction'))}</h2>
        <p class="sub" style="margin:0">${esc(t('preparing'))}</p>
      </div>
      <div class="bottombar"><div class="inner">
        <button class="btn ghost grow" id="again">${esc(t('again'))}</button>
        <button class="btn grow" id="back">${esc(t('overview'))}</button>
      </div></div>`;

    app.querySelectorAll('[data-crit]').forEach(lb => {
      lb.onclick = () => {
        const [i, key] = lb.dataset.crit.split('|');
        grades[i] = sec.grades.find(g => g.key === key).points;
        lb.closest('.opts').querySelectorAll('.opt').forEach(x => x.classList.remove('sel'));
        lb.classList.add('sel');
        if (Object.keys(grades).length < sec.criteria.length) return;

        const points = Object.values(grades).reduce((a, b) => a + b, 0) * sec.factor;
        const pct = saveResult(run, points, sec.maxPoints, { grades: { ...grades } });
        document.getElementById('wres').innerHTML =
          scoreCard(points, sec.maxPoints, pct, '');
      };
    });
    if (saved){                              // gespeicherte Bewertung wiederherstellen
      Object.entries(grades).forEach(([i, pts]) => {
        const g = sec.grades.find(x => x.points === pts);
        const lb = g && app.querySelector(`[data-crit="${i}|${g.key}"]`);
        if (lb){ lb.classList.add('sel'); lb.querySelector('input').checked = true; }
      });
      if (saved.points !== null && saved.points !== undefined)
        document.getElementById('wres').innerHTML =
          scoreCard(saved.points, sec.maxPoints, saved.pct, '');
    }
    document.getElementById('again').onclick = () => screenIntro(run);
    document.getElementById('back').onclick  = () => screenModell(S.modell);

    const box = document.getElementById('aiwrap');
    if (box) renderAiBox(box, run, saved && saved.attemptId, mine);
  });
}

/* ============ KI-Korrektur des Briefs ============
   Die Selbstbewertung oben bleibt: sie ist die Übung, die telc verlangt.
   Die Korrektur kommt daneben — sie sagt, was tatsächlich im Text steht. */
function renderAiBox(box, run, attemptId, text){
  if (!attemptId){
    box.innerHTML = `<h2>${esc(t('correction'))}</h2>
      <p class="sub" style="margin:0">${esc(t('aiOffline'))}</p>`;
    return;
  }
  box.innerHTML = `<h2>${esc(t('correction'))}</h2>
    <p class="sub" style="margin:0 0 10px">${esc(t('aiIntro'))}</p>
    <button class="btn" id="aigo">${esc(t('aiRequest'))}</button>
    <div id="aiout"></div>`;

  const out = document.getElementById('aiout');
  const btn = document.getElementById('aigo');

  // schon einmal korrigiert? dann nicht noch einmal bezahlen
  API.writingFeedback(attemptId).then(fb => { if (fb) showAi(out, btn, fb); })
    .catch(() => {});

  btn.onclick = async () => {
    btn.disabled = true; btn.textContent = 'Wird korrigiert … (bis zu 1 Minute)';
    let r;
    try { r = await API.correctWriting(attemptId); }
    catch { r = { ok: false, error: 'network' }; }
    btn.disabled = false; btn.textContent = 'Korrektur anfordern';
    if (r && r.ok) return showAi(out, btn, r);
    out.innerHTML = `<p class="sub" style="color:var(--bad)">${esc({
      quota_exceeded: 'Das Korrektur-Kontingent für diesen Zeitraum ist aufgebraucht.',
      not_entitled:   'Kein aktives Abo.',
      empty_text:     'Es ist kein Text zum Korrigieren da.',
      not_configured: 'Die Korrektur ist noch nicht eingerichtet.',
      refused:        'Der Text konnte nicht bewertet werden.',
      network:        'Keine Verbindung.'
    }[r && r.error] || 'Die Korrektur ist fehlgeschlagen.')}</p>`;
  };
}

function showAi(out, btn, fb){
  if (btn) btn.hidden = true;
  const GRADE_PTS = g => (g && g.points != null) ? g.points : '';
  out.innerHTML = `
    ${fb.points != null ? scoreCard(fb.points, fb.max_points,
        Math.round(fb.points / fb.max_points * 100), 'KI-Korrektur') : ''}
    ${(fb.grades || []).map(g => `<div class="crit">
      <h3>${esc(g.criterion)} <span class="pill">${esc(g.key)}</span></h3>
      <p class="sub" style="margin:0">${esc(g.why)}</p>
    </div>`).join('')}
    ${fb.summary ? `<div class="why" style="margin:12px 0">${esc(fb.summary)}</div>` : ''}
    ${(fb.errors || []).length ? `<h3 style="margin:14px 0 6px">${esc(t('errorDetail'))}</h3>
      ${fb.errors.map(e => `<div class="q isbad">
        <div class="qhead"><span class="qnum">${esc(e.type)}</span></div>
        <div class="fb bad">
          <div class="fbrow"><span class="lbl">Ihr Text</span>
            <span class="val">${esc(e.original)}</span></div>
          <div class="fbrow"><span class="lbl">${esc(t('better'))}</span>
            <span class="val">${esc(e.correction)}</span></div>
          ${e.why ? `<div class="why">${esc(e.why)}</div>` : ''}
        </div></div>`).join('')}` : ''}
    ${fb.corrected ? `<details style="margin-top:12px">
       <summary class="sub">${esc(t('aiView'))}</summary>
       <div class="passage" style="margin:8px 0 0"><div class="body">${esc(fb.corrected)}</div></div>
     </details>` : ''}`;
}

// beim Schließen/Wegwischen den Stand sichern
addEventListener('pagehide', () => saveSession(S.run));
addEventListener('visibilitychange', () => { if (document.hidden) saveSession(S.run); });

boot();
