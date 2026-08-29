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
  view: 'home'
};

/* ============ Helfer ============ */
const esc = s => String(s ?? '').replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const mmss = s => `${String(Math.floor(Math.max(0,s)/60)).padStart(2,'0')}:${String(Math.max(0,s)%60).padStart(2,'0')}`;

function ask(text, onYes, yes = 'Ja', no = 'Abbrechen'){
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
  elBack.hidden = (view === 'home');
  window.scrollTo(0, 0);
  fn();
}
elBack.onclick = () => {
  if (S.view === 'exam'){
    ask('Prüfung verlassen? Ihre Antworten gehen verloren.',
        () => { stopTimer(); screenModell(S.modell); }, 'Verlassen');
  } else if (S.view === 'result' || S.view === 'intro'){
    stopTimer();
    screenModell(S.modell);
  } else {
    screenHome();
  }
};

/* ============ Startseite ============ */
async function boot(){
  try {
    S.index = await (await fetch('data/index.json?v=' + Date.now())).json();
  } catch {
    app.innerHTML = `<div class="empty">Die Testdaten konnten nicht geladen werden.<br>
      Bitte über einen lokalen Server öffnen: <code>python3 -m http.server</code></div>`;
    return;
  }
  screenHome();
}

function screenHome(){
  stopTimer();
  go('home', () => {
    const cards = S.index.modelle.map((m, i) => `
      <button class="tile" data-id="${esc(m.id)}">
        <span class="n">${i + 1}</span>
        <span class="grow"><span style="font-weight:600">${esc(m.title)}</span>
          <div class="meta">${m.aufgaben} Aufgaben · ${m.minutes} Minuten</div></span>
        <span class="chev">›</span>
      </button>`).join('');

    app.innerHTML = `
      <h1>Willkommen 👋</h1>
      <p class="sub">Wählen Sie einen Modelltest. Jeder Test hat die drei Prüfungsteile
        der schriftlichen telc&nbsp;B1&nbsp;Prüfung — mit der echten Prüfungszeit.</p>
      ${cards}`;

    app.querySelectorAll('.tile').forEach(b =>
      b.onclick = () => openModell(b.dataset.id));
  });
}

/* ============ Prüfungsteile eines Modelltests ============ */
async function openModell(id){
  const entry = S.index.modelle.find(m => m.id === id);
  try {
    S.modell = await (await fetch(`data/${entry.file}?v=` + Date.now())).json();
  } catch {
    toast('Der Modelltest konnte nicht geladen werden.'); return;
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
      const sub = [b.hint, `${n} Aufgaben`, `${fmtP(b.maxPoints)} Punkte`,
                   b.missing ? `${b.missing} Aufgaben fehlen in der Vorlage` : '']
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
          <button class="btn ghost sm" data-review="${esc(b.id)}">Ansehen</button>
          <button class="btn grey sm" data-clear="${esc(b.id)}">Löschen</button>
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
  let right = 0, total = 0;
  run.parts.forEach(p => p.items.forEach(it => {
    total++;
    if (S.answers[it.id] === it.answer) right++;
  }));
  screenResult(run, r.points, r.max, r.pct, right, total);
}

/* ============ Startbildschirm ============ */
function screenIntro(run){
  S.run = run;
  S.answers = {};
  S.dropped = {};
  const draft = loadDraft(run.id);          // unfertigen Text weiterführen
  if (draft && run.parts.length === 1 && run.parts[0].format === 'writing')
    S.answers[run.parts[0].items[0].id] = draft;
  const sess = loadSession(run.id);         // angefangene Prüfung fortsetzen
  stopTimer();
  go('intro', () => {
    const n = runItems(run).length;
    const notes = [...new Set(run.parts.map(p => p.note).filter(Boolean))];
    const list = run.parts.length > 1
      ? `<ul class="partlist">${run.parts.map(p =>
          `<li><span class="grow">${esc(p.title)}</span>
             <span class="meta">${p.items.length} Aufgaben · ${fmtP(p.maxPoints)} P.</span></li>`).join('')}</ul>`
      : `<div class="instr">${esc(run.parts[0].instruction)}</div>`;

    app.innerHTML = `
      <div class="card">
        <span class="pill">Wie in der Prüfung</span>
        <h2 style="margin-top:10px">${esc(run.title)}</h2>
        ${run.hint ? `<p class="sub" style="margin-bottom:14px">${esc(run.hint)}</p>` : ''}
        ${list}
        ${run.missing ? `<div class="fb warn" style="margin-bottom:16px">
          In diesem Modelltest fehlen ${run.missing} Aufgaben — sie sind in der
          Vorlage abgeschnitten. Ihr Ergebnis wird auf die offiziellen
          ${fmtP(run.maxPoints)} Punkte umgerechnet.</div>` : ''}
        ${notes.map(t => `<div class="fb warn" style="margin-bottom:16px">${esc(t)}</div>`).join('')}
        <div class="row" style="gap:24px;margin-bottom:16px">
          <div><div class="meta" style="color:var(--muted);font-size:13px">Aufgaben</div>
               <b style="font-size:18px">${n}</b></div>
          <div><div class="meta" style="color:var(--muted);font-size:13px">Zeit</div>
               <b style="font-size:18px">${run.minutes} Minuten</b></div>
          <div><div class="meta" style="color:var(--muted);font-size:13px">Punkte</div>
               <b style="font-size:18px">${fmtP(run.maxPoints)}</b></div>
        </div>
        ${sess ? `<button class="btn wide" id="resume">Prüfung fortsetzen — ${mmss(sess.left)} übrig</button>
             <button class="btn ghost wide" id="start" style="margin-top:10px">Neu beginnen</button>`
               : `<button class="btn wide" id="start">Start ▶</button>`}
      </div>`;
    document.getElementById('start').onclick = () => {
      clearSession(run.id);
      clearDraft(run.id);
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
      `<div class="bottombar"><div class="inner">
         <span class="progress" id="prog">0 / ${runItems(run).length}</span>
         <button class="btn grey" id="pause">Pause</button>
         <button class="btn grow" id="submit">Abgeben &amp; korrigieren</button>
       </div></div>`;

    run.parts.forEach(p => bindInputs(p));
    updateProgress();
    document.getElementById('submit').onclick = () => finish(run, false);
    document.getElementById('pause').onclick = () => pauseExam(run);
    startTimer(resumeLeft || run.minutes * 60,
               () => { toast('Die Zeit ist abgelaufen ⏱'); finish(run, true); });
  });
}

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

function renderPassages(sec){
  if (sec.brief) return renderBrief(sec);
  if (!sec.passages || !sec.passages.length) return '';
  return sec.passages.map(p => `
    <div class="passage">
      ${p.title ? `<h3>${esc(p.title)}</h3>` : ''}
      ${(p.paragraphs || [p.body]).map(t => `<p>${esc(t)}</p>`).join('')}
    </div>`).join('');
}

function renderBank(sec){
  if (sec.bankImage){
    // Pfade in den JSON-Dateien sind relativ zum data-Ordner.
    // In der Einzeldatei-Version steht hier schon eine data:-URI.
    const src = sec.bankImage.startsWith('data:') ? sec.bankImage : 'data/' + sec.bankImage;
    return `<div class="bank"><h3>${esc(sec.bankTitle || 'Anzeigen')}</h3>
      <p class="sub" style="margin:0 0 10px">Zum Vergrößern auf das Bild tippen</p>
      <a href="${esc(src)}" target="_blank" rel="noopener">
        <img src="${esc(src)}" alt="Anzeigen" class="bankimg"></a></div>`;
  }
  if (!sec.bank || !sec.bank.length) return '';
  return `<div class="bank"><h3>${esc(sec.bankTitle || 'Auswahl')}</h3>
    <ul>${sec.bank.map(o =>
      `<li><span class="k">${esc(o.key)}</span>${esc(o.text)}</li>`).join('')}</ul></div>`;
}

function renderItem(sec, it){
  const head = `<div class="qhead"><span class="qnum">${esc(it.id)}</span>
    <span class="qtext grow">${esc(it.text)}</span></div>`;
  let body = '';

  if (sec.format === 'writing'){
    const draft = S.answers[it.id] || '';
    const n = draft.trim().split(/\s+/).filter(Boolean).length;
    return `<div class="q" id="q_${esc(it.id)}">
      ${draft ? `<div class="fb warn" style="margin-bottom:10px">Entwurf wiederhergestellt.</div>` : ''}
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
    body = `<select data-sel="${esc(it.id)}">
      <option value="">— bitte wählen —</option>
      ${sec.bank.map(o => `<option value="${esc(o.key)}"${o.key === chosen ? ' selected' : ''}>${esc(o.key)}${o.text ? ' — ' + esc(o.text).slice(0, 70) : ''}</option>`).join('')}
    </select>`;
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
  scope.querySelectorAll('[data-sel]').forEach(sl => {
    const id = sl.dataset.sel;
    [...sl.options].forEach(o => {
      if (o.value) o.disabled = used.has(o.value) && used.get(o.value) !== id;
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
      const box = lb.closest('.opts');
      box.querySelectorAll('.opt').forEach(x => {
        const k = x.dataset.opt.split('|')[1];
        x.classList.toggle('sel', k === key);
        x.classList.toggle('dropped', (S.dropped[id] || []).includes(k));
      });
      updateProgress();
    };
  });
  scope.querySelectorAll('[data-sel]').forEach(sl => {
    sl.onchange = () => {
      const v = sl.value;
      if (v) S.answers[sl.dataset.sel] = v; else delete S.answers[sl.dataset.sel];
      syncBank(sec);
      updateProgress();
    };
  });
  syncBank(sec);
  scope.querySelectorAll('[data-txt]').forEach(ta => {
    ta.oninput = () => {
      const id = ta.dataset.txt;
      S.answers[id] = ta.value;
      const n = ta.value.trim().split(/\s+/).filter(Boolean).length;
      const c = document.getElementById('wc_' + id);
      const min = sec.items.find(x => x.id === id).minWords || 100;
      if (c){ c.textContent = `${n} Wörter (mindestens ${min})`; c.style.color = n >= min ? 'var(--ok)' : 'var(--muted)'; }
      saveDraft(S.run.id, ta.value);
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
  const p = document.getElementById('prog');
  if (p) p.textContent = `${items.filter(answered).length} / ${items.length}`;
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
    <h2 style="margin:0 0 6px">Pause</h2>
    <p>Der Timer steht. Sie können die App schließen und später weitermachen.</p>
    <p class="pausetime">${mmss(S.left)} übrig</p>
    <div class="modalbtns">
      <button class="btn grey" data-exit>Beenden</button>
      <button class="btn" data-go>Weiter</button>
    </div></div>`;
  document.body.appendChild(box);
  const close = () => { box.remove(); document.body.classList.remove('paused'); };
  box.querySelector('[data-go]').onclick = () => {
    close();
    startTimer(S.left, () => { toast('Die Zeit ist abgelaufen ⏱'); finish(run, true); });
  };
  box.querySelector('[data-exit]').onclick = () => { close(); screenModell(S.modell); };
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
const draftKey = runId => `b1.draft.${S.modell.id}.${runId}`;
const loadDraft = runId => load(draftKey(runId), '');
const saveDraft = (runId, text) => save(draftKey(runId), text);
function clearDraft(runId){
  try { localStorage.removeItem(draftKey(runId)); } catch {}
}

/* جلسة امتحان جارية: الإجابات والوقت المتبقّي. منحفظها باستمرار تا لو
   سكّرت الصفحة أو طلعت تتغدّى، ترجع من وين وقّفتي — والمؤقّت ما بيمشي وأنت
   برّا، لأنه بينحفظ الوقت المتبقّي مو وقت البداية. */
const sessKey = runId => `b1.session.${S.modell.id}.${runId}`;

function saveSession(run){
  if (!run || S.view !== 'exam') return;
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

function finish(run, auto){
  const go2 = () => {
    stopTimer();
    clearSession(run.id);
    if (run.parts.length === 1 && run.parts[0].format === 'writing'){
      // Den Text sofort sichern — auch wenn noch keine Bewertung erfolgt ist.
      saveResult(run, null, run.parts[0].maxPoints);
      clearDraft(run.id);
      return screenWriting(run);
    }

    // In manchen Modelltests fehlen Aufgaben (in der Vorlage abgeschnitten).
    // Damit alle Tests vergleichbar bleiben, wird das Ergebnis auf die
    // offizielle Höchstpunktzahl umgerechnet.
    let earned = 0, right = 0, total = 0;
    run.parts.forEach(p => {
      p.items.forEach(it => {
        total++;
        if (S.answers[it.id] === it.answer){ earned += p.pointsPerItem; right++; }
      });
    });
    const max = run.maxPoints;
    const points = Math.round(earned / run.availablePoints * max * 10) / 10;
    screenResult(run, points, max, saveResult(run, points, max), right, total);
  };

  if (auto) return go2();
  const missing = runItems(run).filter(it => !answered(it)).length;
  if (!missing) return go2();
  ask(`${missing} Aufgabe(n) ohne Antwort. Trotzdem abgeben?`, go2, 'Abgeben');
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
      bestanden ab ${fmtP(max * 0.6)} Punkten (60 %)${extra ? ' · ' + esc(extra) : ''}</div>
  </div>`;
}

function screenResult(run, points, max, pct, right, total){
  go('result', () => {
    const perPart = run.parts.map(p => {
      const ok = p.items.filter(it => S.answers[it.id] === it.answer).length;
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
          <div class="qhead"><span class="qnum">${esc(it.id)}</span>
            <span class="qtext grow">${esc(it.text)}</span></div>
          <div class="fb ${good ? 'ok' : 'bad'}">
            ${good ? `<b>✔ Richtig · ${fmtP(p.pointsPerItem)} P.</b>` : `<b>✘ Falsch · 0 P.</b>
               <div class="fbrow"><span class="lbl">Ihre Antwort</span>
                 <span class="val">${esc(answerLabel(p, it, mine))}</span></div>
               <div class="fbrow"><span class="lbl">Lösung</span>
                 <span class="val">${esc(answerLabel(p, it, it.answer))}</span></div>`}
            ${it.explain ? `<div class="why">${esc(it.explain)}</div>` : ''}
          </div>
        </div>`;
      }).join('');
      return head + cards;
    }).join('');

    app.innerHTML =
      scoreCard(points, max, pct, `${right} von ${total} Aufgaben richtig`) +
      `<h2 style="margin:18px 0 10px">Korrektur</h2>${perPart}
      <div class="bottombar"><div class="inner">
        <button class="btn ghost grow" id="again">Wiederholen</button>
        <button class="btn grow" id="back">Übersicht</button>
      </div></div>`;

    document.getElementById('again').onclick = () => screenIntro(run);
    document.getElementById('back').onclick  = () => screenModell(S.modell);
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
        <h2>Ihr Text</h2>
        <p class="sub">${words} Wörter${words < (it.minWords || 100)
          ? ` — mindestens ${it.minWords || 100} verlangt` : ''}</p>
        <div class="passage" style="margin:0"><div class="body">${esc(mine || '(kein Text geschrieben)')}</div></div>
      </div>
      <div class="card">
        <h2>Aufgabe</h2>
        ${renderBrief(sec)}
      </div>
      <div class="card">
        <h2>Bewertung</h2>
        <p class="sub">Bewerten Sie jedes Kriterium selbst — so wie telc bewertet.</p>
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
      <div class="bottombar"><div class="inner">
        <button class="btn ghost grow" id="again">Wiederholen</button>
        <button class="btn grow" id="back">Übersicht</button>
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
  });
}

// beim Schließen/Wegwischen den Stand sichern
addEventListener('pagehide', () => saveSession(S.run));
addEventListener('visibilitychange', () => { if (document.hidden) saveSession(S.run); });

boot();
