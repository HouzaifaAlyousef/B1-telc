/* تدريب telc B1 — محرّك بسيط بدون أي مكتبات خارجية */
'use strict';

const app    = document.getElementById('app');
const elBack = document.getElementById('btnBack');
const elTimer= document.getElementById('timer');
const elTime = document.getElementById('timerText');
const elToast= document.getElementById('toast');

const S = {
  index: null,      // فهرس النماذج
  modell: null,     // النموذج المفتوح
  section: null,    // القسم المفتوح
  answers: {},      // { itemId: value }
  tick: null,       // مؤقّت
  left: 0,          // ثواني متبقية
  history: [],      // نتائج محفوظة
  view: 'home'
};

/* ============ أدوات ============ */
const esc = s => String(s ?? '').replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const mmss = s => `${String(Math.floor(Math.max(0,s)/60)).padStart(2,'0')}:${String(Math.max(0,s)%60).padStart(2,'0')}`;

function toast(msg, ms = 2200){
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

/* ============ المؤقّت ============ */
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

/* ============ التنقّل ============ */
function go(view, fn){
  S.view = view;
  elBack.hidden = (view === 'home');
  window.scrollTo(0, 0);
  fn();
}
elBack.onclick = () => {
  if (S.view === 'exam' || S.view === 'result'){
    if (S.view === 'exam' && !confirm('بدك تطلع؟ الإجابات الحالية رح تروح.')) return;
    stopTimer();
    screenModell(S.modell);
  } else {
    screenHome();
  }
};

/* ============ شاشة النماذج ============ */
async function boot(){
  S.history = load('b1.history', []);
  try {
    S.index = await (await fetch('data/index.json?v=' + Date.now())).json();
  } catch {
    app.innerHTML = `<div class="empty">ما قدرت أقرأ ملفات النماذج.<br>
      شغّل التطبيق عن طريق سيرفر محلي: <code class="de">python3 -m http.server</code></div>`;
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
        ? `خلّصتِ ${finished} من ${m.sections} أقسام`
        : `${m.sections} أقسام · ${m.minutes} دقيقة`;
      return `<button class="tile" data-id="${esc(m.id)}">
        <span class="n">${i + 1}</span>
        <span class="grow"><span style="font-weight:600">${esc(m.title)}</span>
          <div class="meta">${esc(meta)}</div></span>
        <span class="chev">‹</span>
      </button>`;
    }).join('');

    const last = S.history.slice(-3).reverse().map(h =>
      `<div class="row" style="border-top:1px solid var(--line);padding-top:10px;margin-top:10px">
        <span class="grow"><b>${esc(h.section)}</b>
          <div class="meta" style="font-size:13px;color:var(--muted)">${esc(h.modell)} · ${esc(h.date)}</div></span>
        <span class="pill ${h.pct >= 60 ? 'ok' : 'bad'}">${h.score}/${h.max}</span>
      </div>`).join('');

    app.innerHTML = `
      <h1>أهلاً 👋</h1>
      <p class="sub">اختاري نموذج، بعدين اختاري القسم اللي بدك تتدربي عليه. المؤقّت بيبلش لما تضغطي «ابدأ».</p>
      ${cards}
      ${last ? `<div class="card"><h3>آخر النتائج</h3>${last}
        <button class="btn grey sm wide" id="clr" style="margin-top:12px">مسح السجل</button></div>` : ''}`;

    app.querySelectorAll('.tile').forEach(b =>
      b.onclick = () => openModell(b.dataset.id));
    const clr = document.getElementById('clr');
    if (clr) clr.onclick = () => {
      if (!confirm('مسح كل النتائج والتقدّم؟')) return;
      S.history = []; save('b1.history', []); save('b1.progress', {}); screenHome();
    };
  });
}

/* ============ شاشة أقسام النموذج ============ */
async function openModell(id){
  const entry = S.index.modelle.find(m => m.id === id);
  try {
    S.modell = await (await fetch(`data/${entry.file}?v=` + Date.now())).json();
  } catch {
    toast('ما قدرت أفتح النموذج'); return;
  }
  screenModell(S.modell);
}

function screenModell(m){
  stopTimer();
  go('modell', () => {
    const prog = load('b1.progress', {})[m.id] || {};
    const groups = {};
    m.sections.forEach(s => { (groups[s.group] ||= []).push(s); });

    const html = Object.entries(groups).map(([g, list]) => `
      <h3 style="margin:18px 0 8px">${esc(g)}</h3>
      ${list.map(s => {
        const r = prog[s.id];
        const badge = r
          ? `<span class="pill ${r.pct >= 60 ? 'ok' : 'bad'}">${r.score}/${r.max}</span>`
          : `<span class="pill">${s.minutes} د</span>`;
        return `<button class="tile" data-sec="${esc(s.id)}">
          <span class="grow"><span style="font-weight:600">${esc(s.titleAr)}</span>
            <div class="meta de">${esc(s.title)} · ${s.items.length} أسئلة</div></span>
          ${badge}
        </button>`;
      }).join('')}`).join('');

    app.innerHTML = `
      <h1>${esc(m.title)}</h1>
      <p class="sub">${esc(m.subtitle || '')}</p>
      ${html}`;

    app.querySelectorAll('[data-sec]').forEach(b =>
      b.onclick = () => screenIntro(m.sections.find(s => s.id === b.dataset.sec)));
  });
}

/* ============ شاشة «ابدأ» ============ */
function screenIntro(sec){
  S.section = sec;
  S.answers = {};
  stopTimer();
  go('intro', () => {
    app.innerHTML = `
      <div class="card">
        <span class="pill">${esc(sec.group)}</span>
        <h2 style="margin-top:10px">${esc(sec.titleAr)}</h2>
        <p class="de" style="color:var(--muted);margin:0 0 14px">${esc(sec.title)}</p>
        <div class="instr">
          ${esc(sec.instructionAr)}
          <div class="de">${esc(sec.instruction)}</div>
        </div>
        <div class="row" style="gap:18px;margin-bottom:16px">
          <div><div class="meta" style="color:var(--muted);font-size:13px">عدد الأسئلة</div>
               <b style="font-size:18px">${sec.items.length}</b></div>
          <div><div class="meta" style="color:var(--muted);font-size:13px">الوقت</div>
               <b style="font-size:18px">${sec.minutes} دقيقة</b></div>
        </div>
        <button class="btn wide" id="start">ابدأ ▶</button>
      </div>`;
    document.getElementById('start').onclick = () => screenExam(sec);
  });
}

/* ============ شاشة الامتحان ============ */
function screenExam(sec){
  go('exam', () => {
    app.innerHTML = renderPassages(sec) + renderBank(sec) +
      `<div id="qs">${sec.items.map((it, i) => renderItem(sec, it, i)).join('')}</div>` +
      `<div class="bottombar"><div class="inner">
         <span class="progress" id="prog">0 / ${sec.items.length}</span>
         <button class="btn grow" id="submit">تسليم وتصحيح</button>
       </div></div>`;

    bindInputs(sec);
    document.getElementById('submit').onclick = () => finish(sec, false);
    startTimer(sec.minutes * 60, () => { toast('انتهى الوقت ⏱'); finish(sec, true); });
  });
}

function renderPassages(sec){
  if (!sec.passages || !sec.passages.length) return '';
  return sec.passages.map(p => {
    const listen = p.audio
      ? `<button class="btn ghost sm" data-say="${esc(p.body)}">🔊 استمعي</button>`
      : '';
    // في أقسام الاستماع النص مخفي: اسمعي أول، وافتحي النص بعدين للمراجعة
    const text = p.audio
      ? `<details style="margin-top:10px"><summary style="cursor:pointer;color:var(--brand);font-size:14px">
           إظهار النص المكتوب</summary><div class="de" style="margin-top:8px">${esc(p.body)}</div></details>`
      : `<div class="de">${esc(p.body)}</div>`;
    return `<div class="passage">
      ${p.title ? `<h3 class="de">${esc(p.title)}</h3>` : ''}
      ${listen}${text}
    </div>`;
  }).join('');
}

function renderBank(sec){
  if (!sec.bank || !sec.bank.length) return '';
  return `<div class="bank"><h3>${esc(sec.bankTitleAr || 'الخيارات')}</h3>
    <ul>${sec.bank.map(o =>
      `<li><span class="k">${esc(o.key)}</span><span class="de">${esc(o.text)}</span></li>`).join('')}</ul></div>`;
}

function renderItem(sec, it, i){
  const head = `<div class="qhead"><span class="qnum">${i + 1}</span>
    <span class="qtext grow ${sec.format === 'writing' ? '' : 'de'}">${esc(it.text)}</span></div>`;
  let body = '';

  if (sec.format === 'mc' || sec.format === 'truefalse'){
    const opts = sec.format === 'truefalse'
      ? [{ key: 'r', text: 'Richtig — صح' }, { key: 'f', text: 'Falsch — خطأ' }]
      : it.options;
    body = `<div class="opts ${sec.format === 'truefalse' ? 'inline' : ''}">${
      opts.map(o => `<label class="opt" data-opt="${esc(it.id)}|${esc(o.key)}">
        <input type="radio" name="q_${esc(it.id)}" value="${esc(o.key)}">
        <span class="k">${esc(o.key)}</span><span class="de grow">${esc(o.text)}</span>
      </label>`).join('')}</div>`;
  }
  else if (sec.format === 'matching' || sec.format === 'wordbank'){
    body = `<select data-sel="${esc(it.id)}">
      <option value="">— اختاري —</option>
      ${sec.bank.map(o => `<option value="${esc(o.key)}">${esc(o.key)} — ${esc(o.text).slice(0, 70)}</option>`).join('')}
    </select>`;
  }
  else if (sec.format === 'writing'){
    body = `<textarea data-txt="${esc(it.id)}" placeholder="اكتبي الرسالة بالألماني هون…"></textarea>
            <div class="counter" id="wc_${esc(it.id)}">0 كلمة (المطلوب ≈ ${it.minWords || 80})</div>`;
  }
  return `<div class="q" id="q_${esc(it.id)}">${head}${body}<div class="fbslot"></div></div>`;
}

function bindInputs(sec){
  app.querySelectorAll('[data-opt]').forEach(lb => {
    lb.onclick = () => {
      const [id, key] = lb.dataset.opt.split('|');
      S.answers[id] = key;
      lb.closest('.opts').querySelectorAll('.opt').forEach(x => x.classList.remove('sel'));
      lb.classList.add('sel');
      updateProgress(sec);
    };
  });
  app.querySelectorAll('[data-sel]').forEach(sl => {
    sl.onchange = () => {
      const v = sl.value;
      if (v) S.answers[sl.dataset.sel] = v; else delete S.answers[sl.dataset.sel];
      updateProgress(sec);
    };
  });
  app.querySelectorAll('[data-txt]').forEach(ta => {
    ta.oninput = () => {
      const id = ta.dataset.txt;
      S.answers[id] = ta.value;
      const n = ta.value.trim().split(/\s+/).filter(Boolean).length;
      const c = document.getElementById('wc_' + id);
      const min = sec.items.find(x => x.id === id).minWords || 80;
      if (c){ c.textContent = `${n} كلمة (المطلوب ≈ ${min})`; c.style.color = n >= min ? 'var(--ok)' : 'var(--muted)'; }
      updateProgress(sec);
    };
  });
  app.querySelectorAll('[data-say]').forEach(b => b.onclick = () => speak(b.dataset.say));
}

function updateProgress(sec){
  const n = sec.items.filter(it => {
    const v = S.answers[it.id];
    return v !== undefined && String(v).trim() !== '';
  }).length;
  const p = document.getElementById('prog');
  if (p) p.textContent = `${n} / ${sec.items.length}`;
}

/* نطق النصوص للاستماع (بديل عن ملفات الصوت) */
function speak(text){
  if (!('speechSynthesis' in window)) return toast('متصفحك ما بيدعم القراءة الصوتية');
  speechSynthesis.cancel();
  const u = new SpeechSynthesisUtterance(text);
  u.lang = 'de-DE'; u.rate = 0.92;
  const v = speechSynthesis.getVoices().find(x => x.lang.startsWith('de'));
  if (v) u.voice = v;
  speechSynthesis.speak(u);
}

/* ============ التصحيح ============ */
function finish(sec, auto){
  if (!auto){
    const missing = sec.items.length - sec.items.filter(it =>
      S.answers[it.id] !== undefined && String(S.answers[it.id]).trim() !== '').length;
    if (missing && !confirm(`في ${missing} سؤال بدون جواب. بدك تسلّمي؟`)) return;
  }
  stopTimer();

  if (sec.format === 'writing') return screenWriting(sec);

  let score = 0;
  sec.items.forEach(it => { if (S.answers[it.id] === it.answer) score++; });
  const max = sec.items.length;
  const pct = Math.round(score / max * 100);

  const prog = load('b1.progress', {});
  (prog[S.modell.id] ||= {})[sec.id] = { score, max, pct };
  save('b1.progress', prog);
  S.history.push({
    modell: S.modell.title, section: sec.titleAr, score, max, pct,
    date: new Date().toLocaleDateString('ar-EG')
  });
  save('b1.history', S.history.slice(-50));

  screenResult(sec, score, max, pct);
}

function screenResult(sec, score, max, pct){
  go('result', () => {
    const cls = pct >= 60 ? 'ok' : 'bad';
    const verdict = pct >= 80 ? 'ممتاز! 🎉' : pct >= 60 ? 'ناجحة ✅ بس في مجال للتحسين' : 'محتاجة تدريب أكتر 💪';

    const corrections = sec.items.map((it, i) => {
      const mine = S.answers[it.id];
      const ok = mine === it.answer;
      const label = k => {
        if (sec.format === 'truefalse') return k === 'r' ? 'Richtig' : k === 'f' ? 'Falsch' : '—';
        if (sec.bank){ const o = sec.bank.find(x => x.key === k); return o ? `${k} — ${o.text}` : '—'; }
        const o = (it.options || []).find(x => x.key === k); return o ? `${k} — ${o.text}` : '—';
      };
      return `<div class="q ${ok ? 'isok' : 'isbad'}">
        <div class="qhead"><span class="qnum">${i + 1}</span>
          <span class="qtext grow de">${esc(it.text)}</span></div>
        <div class="fb ${ok ? 'ok' : 'bad'}">
          ${ok ? '✔ إجابة صحيحة' : `✘ جوابك: <span class="de">${esc(mine ? label(mine) : 'بدون جواب')}</span>
             <div style="margin-top:4px">الصح: <span class="de">${esc(label(it.answer))}</span></div>`}
          ${it.explainAr ? `<div class="why">${esc(it.explainAr)}</div>` : ''}
        </div>
      </div>`;
    }).join('');

    app.innerHTML = `
      <div class="card score">
        <div class="big" style="color:var(--${cls})">${score}<span style="font-size:26px;color:var(--muted)">/${max}</span></div>
        <div class="pct">${pct}% · ${esc(verdict)}</div>
        <div class="bar"><i class="${cls}" style="width:${pct}%"></i></div>
        <div class="meta" style="color:var(--muted);font-size:13px">حدّ النجاح التقريبي 60%</div>
      </div>
      <h2 style="margin:18px 0 10px">التصحيح</h2>
      ${corrections}
      <div class="bottombar"><div class="inner">
        <button class="btn ghost grow" id="again">إعادة القسم</button>
        <button class="btn grow" id="back">باقي الأقسام</button>
      </div></div>`;

    document.getElementById('again').onclick = () => screenIntro(sec);
    document.getElementById('back').onclick  = () => screenModell(S.modell);
  });
}

/* تصحيح التعبير الكتابي: تقييم ذاتي بقائمة تحقّق */
function screenWriting(sec){
  const it = sec.items[0];
  const mine = (S.answers[it.id] || '').trim();
  const words = mine.split(/\s+/).filter(Boolean).length;

  go('result', () => {
    app.innerHTML = `
      <div class="card">
        <h2>نصّك</h2>
        <p class="sub">${words} كلمة</p>
        <div class="passage de" style="margin:0">${esc(mine || '(ما كتبتِ شي)')}</div>
      </div>
      <div class="card">
        <h2>النقاط المطلوبة</h2>
        <p class="sub">حطّي علامة على كل نقطة ذكرتيها فعلاً بالنص.</p>
        ${it.points.map((p, i) => `<label class="opt" style="margin-bottom:8px">
          <input type="checkbox" class="chk" data-i="${i}">
          <span class="grow">${esc(p.ar)}<div class="de" style="color:var(--muted);font-size:14px">${esc(p.de)}</div></span>
        </label>`).join('')}
        <div class="fb ok" id="wres" style="display:none"></div>
        <button class="btn wide" id="calc" style="margin-top:12px">احسبي النتيجة</button>
      </div>
      <div class="card">
        <h2>نموذج إجابة</h2>
        <div class="passage de" style="margin:0">${esc(it.model)}</div>
      </div>
      <div class="bottombar"><div class="inner">
        <button class="btn ghost grow" id="again">إعادة</button>
        <button class="btn grow" id="back">باقي الأقسام</button>
      </div></div>`;

    document.getElementById('calc').onclick = () => {
      const chks = [...app.querySelectorAll('.chk')];
      const done = chks.filter(c => c.checked).length;
      const long = words >= (it.minWords || 80);
      const box = document.getElementById('wres');
      box.style.display = 'block';
      box.className = 'fb ' + (done === chks.length && long ? 'ok' : 'bad');
      box.innerHTML = `غطّيتِ ${done} من ${chks.length} نقاط.` +
        (long ? ' وطول النص كافي ✔' : ` لكن النص قصير (${words} كلمة، المطلوب ≈ ${it.minWords || 80}) ✘`);

      const score = done + (long ? 1 : 0), max = chks.length + 1;
      const prog = load('b1.progress', {});
      (prog[S.modell.id] ||= {})[sec.id] = { score, max, pct: Math.round(score / max * 100) };
      save('b1.progress', prog);
    };
    document.getElementById('again').onclick = () => screenIntro(sec);
    document.getElementById('back').onclick  = () => screenModell(S.modell);
  });
}

boot();
