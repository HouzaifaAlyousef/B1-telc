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
  tick: null,       // Timer
  left: 0,          // verbleibende Sekunden
  history: [],      // gespeicherte Ergebnisse
  view: 'home'
};

/* ============ Helfer ============ */
const esc = s => String(s ?? '').replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const mmss = s => `${String(Math.floor(Math.max(0,s)/60)).padStart(2,'0')}:${String(Math.max(0,s)%60).padStart(2,'0')}`;

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
  if (S.view === 'exam' || S.view === 'result'){
    if (S.view === 'exam' && !confirm('Prüfung verlassen? Ihre Antworten gehen verloren.')) return;
    stopTimer();
    screenModell(S.modell);
  } else {
    screenHome();
  }
};

/* ============ Startseite ============ */
async function boot(){
  S.history = load('b1.history', []);
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
    const done = load('b1.progress', {});
    const cards = S.index.modelle.map((m, i) => {
      const p = done[m.id] || {};
      const finished = Object.keys(p).length;
      const meta = finished
        ? `${finished} Teil(e) bearbeitet · ${m.aufgaben} Aufgaben`
        : `${m.aufgaben} Aufgaben · ${m.minutes} Minuten`;
      return `<button class="tile" data-id="${esc(m.id)}">
        <span class="n">${i + 1}</span>
        <span class="grow"><span style="font-weight:600">${esc(m.title)}</span>
          <div class="meta">${esc(meta)}</div></span>
        <span class="chev">›</span>
      </button>`;
    }).join('');

    const last = S.history.slice(-3).reverse().map(h =>
      `<div class="row" style="border-top:1px solid var(--line);padding-top:10px;margin-top:10px">
        <span class="grow"><b>${esc(h.section)}</b>
          <div class="meta" style="font-size:13px;color:var(--muted)">${esc(h.modell)} · ${esc(h.date)}</div></span>
        <span class="pill ${h.pct >= 60 ? 'ok' : 'bad'}">${h.score}/${h.max}</span>
      </div>`).join('');

    app.innerHTML = `
      <h1>Willkommen 👋</h1>
      <p class="sub">Wählen Sie einen Modelltest und danach einen Prüfungsteil.
        Der Timer startet, sobald Sie auf „Start“ tippen.</p>
      ${cards}
      ${last ? `<div class="card"><h3>Letzte Ergebnisse</h3>${last}
        <button class="btn grey sm wide" id="clr" style="margin-top:12px">Verlauf löschen</button></div>` : ''}`;

    app.querySelectorAll('.tile').forEach(b =>
      b.onclick = () => openModell(b.dataset.id));
    const clr = document.getElementById('clr');
    if (clr) clr.onclick = () => {
      if (!confirm('Alle Ergebnisse und den Fortschritt löschen?')) return;
      S.history = []; save('b1.history', []); save('b1.progress', {}); screenHome();
    };
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
    const badge = (id, mins) => {
      const r = prog[id];
      return r ? `<span class="pill ${r.pct >= 60 ? 'ok' : 'bad'}">${r.score}/${r.max}</span>`
               : `<span class="pill">${mins} Min.</span>`;
    };

    const blocks = (m.blocks || []).map(b => {
      const parts = b.parts.map(part).filter(Boolean);
      const n = parts.reduce((a, p) => a + p.items.length, 0);
      const sub = [b.hint, `${n} Aufgaben`].filter(Boolean).join(' · ');
      return `<button class="tile" data-run="block:${esc(b.id)}">
        <span class="grow"><span style="font-weight:600">${esc(b.title)}</span>
          <div class="meta">${esc(sub)}</div></span>
        ${badge(b.id, b.minutes)}
      </button>`;
    }).join('');

    const singles = m.sections.map(s => `
      <button class="tile" data-run="part:${esc(s.id)}">
        <span class="grow"><span style="font-weight:600">${esc(s.title)}</span>
          <div class="meta">${s.items.length} Aufgaben</div></span>
        ${badge(s.id, s.minutes)}
      </button>`).join('');

    app.innerHTML = `
      <h1>${esc(m.title)}</h1>
      <p class="sub">${esc(m.subtitle || '')}</p>
      <h3 class="grouphead">Wie in der Prüfung</h3>
      <p class="sub">Ein Prüfungsteil am Stück, mit der echten Prüfungszeit.</p>
      ${blocks}
      <h3 class="grouphead">Einzelne Teile üben</h3>
      <p class="sub">Ein Teil allein, mit anteiliger Zeit.</p>
      ${singles}`;

    app.querySelectorAll('[data-run]').forEach(b =>
      b.onclick = () => {
        const [kind, id] = b.dataset.run.split(':');
        screenIntro(kind === 'block' ? blockRun(m, id) : partRun(m, id));
      });
  });
}

/* Ein Durchgang = Titel, Zeit und die Teile, die dazugehören. */
function partRun(m, id){
  const s = m.sections.find(x => x.id === id);
  return { id: s.id, title: s.title, minutes: s.minutes, parts: [s], isBlock: false };
}
function blockRun(m, id){
  const b = m.blocks.find(x => x.id === id);
  const parts = b.parts.map(p => m.sections.find(s => s.id === p)).filter(Boolean);
  return { id: b.id, title: b.title, minutes: b.minutes, hint: b.hint, parts, isBlock: true };
}
const runItems = run => run.parts.flatMap(p => p.items);

/* ============ Startbildschirm ============ */
function screenIntro(run){
  S.run = run;
  S.answers = {};
  stopTimer();
  go('intro', () => {
    const n = runItems(run).length;
    const notes = [...new Set(run.parts.map(p => p.note).filter(Boolean))];
    const list = run.isBlock && run.parts.length > 1
      ? `<ul class="partlist">${run.parts.map(p =>
          `<li><span class="grow">${esc(p.title)}</span>
             <span class="meta">${p.items.length} Aufgaben</span></li>`).join('')}</ul>`
      : `<div class="instr">${esc(run.parts[0].instruction)}</div>`;

    app.innerHTML = `
      <div class="card">
        <span class="pill">${esc(run.isBlock ? 'Wie in der Prüfung' : run.parts[0].group)}</span>
        <h2 style="margin-top:10px">${esc(run.title)}</h2>
        ${run.hint ? `<p class="sub" style="margin-bottom:14px">${esc(run.hint)}</p>` : ''}
        ${list}
        ${notes.map(t => `<div class="fb warn" style="margin-bottom:16px">${esc(t)}</div>`).join('')}
        <div class="row" style="gap:24px;margin-bottom:16px">
          <div><div class="meta" style="color:var(--muted);font-size:13px">Aufgaben</div>
               <b style="font-size:18px">${n}</b></div>
          <div><div class="meta" style="color:var(--muted);font-size:13px">Zeit</div>
               <b style="font-size:18px">${run.minutes} Minuten</b></div>
        </div>
        <button class="btn wide" id="start">Start ▶</button>
      </div>`;
    document.getElementById('start').onclick = () => screenExam(run);
  });
}

/* ============ Prüfung ============ */
function screenExam(run){
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
         <button class="btn grow" id="submit">Abgeben &amp; korrigieren</button>
       </div></div>`;

    run.parts.forEach(p => bindInputs(p));
    document.getElementById('submit').onclick = () => finish(run, false);
    startTimer(run.minutes * 60, () => { toast('Die Zeit ist abgelaufen ⏱'); finish(run, true); });
  });
}

const shortTitle = t => t.replace('Leseverstehen', 'LV').replace('Sprachbausteine', 'SB')
                         .replace('Hörverstehen', 'HV').replace(', Teil ', ' ');

function renderPassages(sec){
  if (!sec.passages || !sec.passages.length) return '';
  return sec.passages.map(p => `
    <div class="passage">
      ${p.title ? `<h3>${esc(p.title)}</h3>` : ''}
      <div class="body">${esc(p.body)}</div>
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

  if (sec.format === 'mc' || sec.format === 'truefalse'){
    const opts = sec.format === 'truefalse'
      ? [{ key: 'r', text: 'Richtig' }, { key: 'f', text: 'Falsch' }]
      : it.options;
    body = `<div class="opts ${sec.format === 'truefalse' ? 'inline' : ''}">${
      opts.map(o => `<label class="opt" data-opt="${esc(it.id)}|${esc(o.key)}">
        <input type="radio" name="q_${esc(it.id)}" value="${esc(o.key)}">
        <span class="k">${esc(o.key)}</span><span class="grow">${esc(o.text)}</span>
      </label>`).join('')}</div>`;
  }
  else if (sec.format === 'matching' || sec.format === 'wordbank'){
    body = `<select data-sel="${esc(it.id)}">
      <option value="">— bitte wählen —</option>
      ${sec.bank.map(o => `<option value="${esc(o.key)}">${esc(o.key)}${o.text ? ' — ' + esc(o.text).slice(0, 70) : ''}</option>`).join('')}
    </select>`;
  }
  else if (sec.format === 'writing'){
    body = `<textarea data-txt="${esc(it.id)}" placeholder="Schreiben Sie hier Ihren Brief …"></textarea>
            <div class="counter" id="wc_${esc(it.id)}">0 Wörter (mindestens ${it.minWords || 100})</div>`;
  }
  return `<div class="q" id="q_${esc(it.id)}">${head}${body}</div>`;
}

function bindInputs(sec){
  const scope = document.getElementById('part-' + sec.id) || app;
  scope.querySelectorAll('[data-opt]').forEach(lb => {
    lb.onclick = () => {
      const [id, key] = lb.dataset.opt.split('|');
      S.answers[id] = key;
      lb.closest('.opts').querySelectorAll('.opt').forEach(x => x.classList.remove('sel'));
      lb.classList.add('sel');
      updateProgress();
    };
  });
  scope.querySelectorAll('[data-sel]').forEach(sl => {
    sl.onchange = () => {
      const v = sl.value;
      if (v) S.answers[sl.dataset.sel] = v; else delete S.answers[sl.dataset.sel];
      updateProgress();
    };
  });
  scope.querySelectorAll('[data-txt]').forEach(ta => {
    ta.oninput = () => {
      const id = ta.dataset.txt;
      S.answers[id] = ta.value;
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
  const items = runItems(S.run);
  const p = document.getElementById('prog');
  if (p) p.textContent = `${items.filter(answered).length} / ${items.length}`;
}

/* ============ Korrektur ============ */
function finish(run, auto){
  if (!auto){
    const missing = runItems(run).filter(it => !answered(it)).length;
    if (missing && !confirm(`${missing} Aufgabe(n) ohne Antwort. Trotzdem abgeben?`)) return;
  }
  stopTimer();

  if (run.parts.length === 1 && run.parts[0].format === 'writing')
    return screenWriting(run);

  let score = 0, max = 0;
  run.parts.forEach(p => {
    if (p.format === 'writing') return;        // wird getrennt bewertet
    p.items.forEach(it => { max++; if (S.answers[it.id] === it.answer) score++; });
  });
  const pct = Math.round(score / max * 100);

  const prog = load('b1.progress', {});
  (prog[S.modell.id] ||= {})[run.id] = { score, max, pct };
  save('b1.progress', prog);
  S.history.push({
    modell: S.modell.title, section: run.title, score, max, pct,
    date: new Date().toLocaleDateString('de-DE')
  });
  save('b1.history', S.history.slice(-50));

  screenResult(run, score, max, pct);
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

function screenResult(run, score, max, pct){
  go('result', () => {
    const cls = pct >= 60 ? 'ok' : 'bad';
    const verdict = pct >= 80 ? 'Sehr gut! 🎉'
                  : pct >= 60 ? 'Bestanden ✅ — weiter üben!'
                  : 'Noch nicht bestanden 💪';

    const perPart = run.parts.filter(p => p.format !== 'writing').map(p => {
      const right = p.items.filter(it => S.answers[it.id] === it.answer).length;
      const head = run.parts.length > 1
        ? `<div class="partscore"><span class="grow">${esc(p.title)}</span>
             <span class="pill ${right / p.items.length >= 0.6 ? 'ok' : 'bad'}">${right}/${p.items.length}</span>
           </div>` : '';
      const cards = p.items.map(it => {
        const mine = S.answers[it.id];
        const ok = mine === it.answer;
        return `<div class="q ${ok ? 'isok' : 'isbad'}">
          <div class="qhead"><span class="qnum">${esc(it.id)}</span>
            <span class="qtext grow">${esc(it.text)}</span></div>
          <div class="fb ${ok ? 'ok' : 'bad'}">
            ${ok ? '<b>✔ Richtig</b>' : `<b>✘ Falsch</b>
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

    app.innerHTML = `
      <div class="card score">
        <div class="big" style="color:var(--${cls})">${score}<span style="font-size:26px;color:var(--muted)">/${max}</span></div>
        <div class="pct">${pct} % · ${esc(verdict)}</div>
        <div class="bar"><i class="${cls}" style="width:${pct}%"></i></div>
        <div class="meta" style="color:var(--muted);font-size:13px">Bestehensgrenze ca. 60 %</div>
      </div>
      <h2 style="margin:18px 0 10px">Korrektur</h2>
      ${perPart}
      <div class="bottombar"><div class="inner">
        <button class="btn ghost grow" id="again">Wiederholen</button>
        <button class="btn grow" id="back">Übersicht</button>
      </div></div>`;

    document.getElementById('again').onclick = () => screenIntro(run);
    document.getElementById('back').onclick  = () => screenModell(S.modell);
  });
}

/* Schriftlicher Ausdruck: Selbstkontrolle über eine Checkliste */
function screenWriting(run){
  const sec = run.parts[0];
  const it = sec.items[0];
  const mine = (S.answers[it.id] || '').trim();
  const words = mine.split(/\s+/).filter(Boolean).length;

  go('result', () => {
    app.innerHTML = `
      <div class="card">
        <h2>Ihr Text</h2>
        <p class="sub">${words} Wörter</p>
        <div class="passage" style="margin:0"><div class="body">${esc(mine || '(kein Text geschrieben)')}</div></div>
      </div>
      <div class="card">
        <h2>Inhaltspunkte</h2>
        <p class="sub">Haken Sie ab, was Sie wirklich geschrieben haben.</p>
        ${it.points.map((pt, i) => `<label class="opt" style="margin-bottom:8px">
          <input type="checkbox" class="chk" data-i="${i}">
          <span class="grow">${esc(pt)}</span>
        </label>`).join('')}
        <div class="fb ok" id="wres" style="display:none"></div>
        <button class="btn wide" id="calc" style="margin-top:12px">Ergebnis berechnen</button>
      </div>
      <div class="bottombar"><div class="inner">
        <button class="btn ghost grow" id="again">Wiederholen</button>
        <button class="btn grow" id="back">Übersicht</button>
      </div></div>`;

    document.getElementById('calc').onclick = () => {
      const chks = [...app.querySelectorAll('.chk')];
      const done = chks.filter(c => c.checked).length;
      const long = words >= (it.minWords || 100);
      const box = document.getElementById('wres');
      box.style.display = 'block';
      box.className = 'fb ' + (done === chks.length && long ? 'ok' : 'bad');
      box.innerHTML = `${done} von ${chks.length} Inhaltspunkten bearbeitet.` +
        (long ? ' Die Textlänge ist ausreichend ✔'
              : ` Der Text ist zu kurz (${words} Wörter, mindestens ${it.minWords || 100}) ✘`);

      const score = done + (long ? 1 : 0), max = chks.length + 1;
      const prog = load('b1.progress', {});
      (prog[S.modell.id] ||= {})[run.id] = { score, max, pct: Math.round(score / max * 100) };
      save('b1.progress', prog);
    };
    document.getElementById('again').onclick = () => screenIntro(run);
    document.getElementById('back').onclick  = () => screenModell(S.modell);
  });
}

boot();
