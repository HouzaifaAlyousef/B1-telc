/* لوحة تحكّم telc — تطبيق منفصل عن تطبيق الطلاب عن قصد:
   جمهور مختلف، خطر مختلف، وبينتشر بمكان تاني.

   الدخول هون بإيميل وكلمة سر (حساب أدمن بتعمليه من Supabase)، مو بكود.
   كل قراءة بتمرق من RLS، وكل كتابة بتمرق من دالة admin_* بتسجّل بالتدقيق —
   يعني اللوحة ما بتقدر تعمل شي بلا أثر حتى لو بدها. */
'use strict';

const cfg  = window.TELC_CONFIG || {};
const BASE = (cfg.supabaseUrl || '').replace(/\/+$/, '');
const KEY  = cfg.supabaseAnonKey || '';
const SKEY = 'telc.admin.session';

const app   = document.getElementById('app');
const nav   = document.getElementById('nav');
const btnOut= document.getElementById('out');
const elToast = document.getElementById('toast');

let session = null;
let tab = 'home';

/* ============ أدوات ============ */
const esc = s => String(s ?? '').replace(/[&<>"]/g,
  c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));

function toast(m, ms = 2600){
  elToast.textContent = m; elToast.hidden = false;
  clearTimeout(toast._t); toast._t = setTimeout(() => elToast.hidden = true, ms);
}
const dtf = new Intl.DateTimeFormat('de-DE',
  { day:'2-digit', month:'2-digit', year:'numeric' });
const fmtDate = s => s ? dtf.format(new Date(s)) : '—';
const fmtDT   = s => s ? new Date(s).toLocaleString('de-DE') : '—';

/* Der Code wird gespeichert wie er ist (B14827519366), aber gelesen und
   weitergegeben in Gruppen: B1 4827 5193 66. Nur Anzeige — beim Einlösen
   räumt code_norm() Leerzeichen und Bindestriche ohnehin weg.
   Alte Codes (B1-7K2M-9XQP) haben ihre Bindestriche schon und bleiben. */
const fmtCode = c => {
  const raw = String(c ?? '');
  if (!/^[A-Z0-9]+$/.test(raw)) return raw;
  return (raw.slice(0, 2) + ' ' + raw.slice(2).replace(/(.{4})/g, '$1 ')).trim();
};

/* ============ الاتصال ============ */
function storeSession(s){
  session = s;
  try { s ? localStorage.setItem(SKEY, JSON.stringify(s))
          : localStorage.removeItem(SKEY); } catch {}
}
function loadSession(){
  try { session = JSON.parse(localStorage.getItem(SKEY) || 'null'); } catch {}
  return session;
}

async function signIn(email, password){
  const r = await fetch(`${BASE}/auth/v1/token?grant_type=password`, {
    method:'POST', headers:{ apikey:KEY, 'content-type':'application/json' },
    body: JSON.stringify({ email, password })
  });
  const j = await r.json().catch(() => ({}));
  if (!r.ok) throw new Error(j.error_description || j.msg || 'Anmeldung fehlgeschlagen');
  storeSession(j);
  return j;
}
async function refresh(){
  if (!session?.refresh_token) return null;
  const r = await fetch(`${BASE}/auth/v1/token?grant_type=refresh_token`, {
    method:'POST', headers:{ apikey:KEY, 'content-type':'application/json' },
    body: JSON.stringify({ refresh_token: session.refresh_token })
  });
  if (!r.ok){ storeSession(null); return null; }
  storeSession(await r.json());
  return session;
}

async function api(path, opts = {}, retry = true){
  if (!session) throw new Error('no_session');
  const r = await fetch(`${BASE}/rest/v1/${path}`, {
    ...opts,
    headers:{ apikey:KEY, authorization:`Bearer ${session.access_token}`,
              'content-type':'application/json', ...(opts.headers || {}) }
  });
  if (r.status === 401 && retry){
    if (await refresh()) return api(path, opts, false);
    throw new Error('no_session');
  }
  const j = await r.json().catch(() => null);
  if (!r.ok) throw new Error(j?.message || j?.hint || `Fehler ${r.status}`);
  return j;
}
const rpc = (fn, args) =>
  api(`rpc/${fn}`, { method:'POST', body: JSON.stringify(args || {}) });

/* رفع ملف لـStorage بجلسة الأدمن نفسها.
   ما بده مفتاح service_role: سياسة 0015 بتسمح الكتابة لـis_admin() وبالدلوين
   بس. x-upsert بيخلّي الرفع التاني بيستبدل بدل ما يفشل بـ409. */
async function upload(bucket, path, file, retry = true){
  if (!session) throw new Error('no_session');
  const r = await fetch(`${BASE}/storage/v1/object/${bucket}/${path}`, {
    method: 'POST',
    headers: { apikey: KEY, authorization: `Bearer ${session.access_token}`,
               'x-upsert': 'true',
               'content-type': file.type || 'application/octet-stream' },
    body: file
  });
  if (r.status === 401 && retry){
    if (await refresh()) return upload(bucket, path, file, false);
    throw new Error('no_session');
  }
  if (!r.ok){
    const j = await r.json().catch(() => null);
    throw new Error(j?.message || j?.error || `Upload fehlgeschlagen (${r.status})`);
  }
  return true;
}

/* نلفّ كل إجراء: بيوقف الزرّ، بيعرض الخطأ، وبيعيد الرسم لما يخلص */
async function act(btn, fn, okMsg){
  const old = btn && btn.textContent;
  if (btn){ btn.disabled = true; btn.textContent = '…'; }
  try {
    const r = await fn();
    if (okMsg) toast(okMsg);
    return r;
  } catch (e){
    toast(e.message === 'no_session' ? 'Sitzung abgelaufen — bitte neu anmelden'
                                     : `Fehler: ${e.message}`, 4000);
    if (e.message === 'no_session') return void screenLogin();
    throw e;
  } finally {
    if (btn){ btn.disabled = false; btn.textContent = old; }
  }
}

/* ============ الدخول ============ */
function screenLogin(err){
  nav.hidden = true; btnOut.hidden = true;
  app.innerHTML = `
    <div class="login card">
      <h1>Anmelden</h1>
      <p class="sub">Administrator-Konto</p>
      <label style="font-size:13px;color:var(--muted)">E-Mail
        <input id="mail" type="email" autocomplete="username" style="margin-top:4px"></label>
      <label style="font-size:13px;color:var(--muted);display:block;margin-top:10px">Passwort
        <input id="pw" type="password" autocomplete="current-password" style="margin-top:4px"></label>
      ${err ? `<p class="err">${esc(err)}</p>` : ''}
      <button class="btn" id="go" style="width:100%;margin-top:14px">Anmelden</button>
    </div>`;
  const go = document.getElementById('go');
  const submit = async () => {
    const m = document.getElementById('mail').value.trim();
    const p = document.getElementById('pw').value;
    if (!m || !p) return;
    go.disabled = true; go.textContent = '…';
    try { await signIn(m, p); await start(); }
    catch (e){ screenLogin(e.message); }
  };
  go.onclick = submit;
  document.getElementById('pw').onkeydown = e => { if (e.key === 'Enter') submit(); };
  document.getElementById('mail').focus();
}

/* ============ الأقسام ============ */
async function screenHome(){
  app.innerHTML = '<div class="empty">Lädt …</div>';
  const [o, act] = await Promise.all([
    rpc('admin_overview'),
    rpc('admin_redeem_activity').catch(() => null)
  ]);
  const stat = (n, label, cls = '') =>
    `<div class="stat ${cls}"><b>${n}</b><span>${esc(label)}</span></div>`;
  app.innerHTML = `
    <h1>Übersicht</h1>
    <p class="sub">Stand: ${fmtDT(new Date().toISOString())}</p>
    <div class="stats">
      ${stat(o.users, 'Nutzer')}
      ${stat(o.active_subs, 'aktive Abos')}
      ${stat(o.expiring_7d, 'laufen in 7 Tagen ab', o.expiring_7d > 0 ? 'warn' : '')}
      ${stat(o.expired, 'abgelaufen / gesperrt')}
      ${stat(o.codes_unused, 'freie Codes', o.codes_unused < 3 ? 'warn' : '')}
      ${stat(o.attempts_7d, 'Prüfungen (7 Tage)')}
      ${stat(o.tests_published, 'Tests online')}
    </div>
    ${act ? `<h2>Code-Eingaben</h2>
    <p class="sub" style="margin-bottom:10px">Viele Fehlversuche heißt entweder
      vertippt — oder jemand probiert Codes durch. Nach
      ${act.limits.max_failed} Fehlversuchen in ${act.limits.window_minutes}
      Minuten wird die Eingabe gesperrt.</p>
    <div class="stats">
      <div class="stat"><b>${act.ok_24h}</b><span>eingelöst (24 h)</span></div>
      <div class="stat ${act.failed_1h > 5 ? 'warn' : ''}">
        <b>${act.failed_1h}</b><span>Fehlversuche (1 h)</span></div>
      <div class="stat ${act.failed_24h > 20 ? 'warn' : ''}">
        <b>${act.failed_24h}</b><span>Fehlversuche (24 h)</span></div>
      ${act.blocked ? `<div class="stat warn"><b>${act.blocked}</b>
        <span>gerade gesperrt</span></div>` : ''}
    </div>` : ''}

    <h2>Prüfungen</h2>
    <div class="card"><div class="wrap"><table>
      <tr><th>Anbieter</th><th>Stufe</th><th>Titel</th><th>Status</th></tr>
      ${(o.levels || []).map(l => `<tr>
        <td>${esc(l.provider || '—')}</td>
        <td class="mono">${esc(l.stufe || l.id)}</td><td>${esc(l.title)}</td>
        <td><span class="pill ${l.published ? 'ok' : ''}">${l.published ? 'online' : 'versteckt'}</span></td>
      </tr>`).join('') || '<tr><td colspan="4" class="empty">Keine Prüfungen</td></tr>'}
    </table></div></div>`;
}

let userSearch = '';
async function screenUsers(){
  app.innerHTML = '<div class="empty">Lädt …</div>';
  const rows = await rpc('admin_users', { p_search: userSearch || null });

  const line = u => {
    /* Ein Nutzer kann mehrere Abos haben — ein Code öffnet genau eine
       Stufe, wer A1 und B1 will, löst zwei Codes ein. Jede Zeile der
       drei Spalten Abo/Stufen/Aktion gehört zum selben Abo. */
    const subs = u.subs || [];
    const cell = (html) => subs.length
      ? subs.map(html).join('') : '<span style="color:var(--muted)">—</span>';

    return `<tr data-u="${esc(u.id)}">
      <td>
        <b>${esc(u.name || 'ohne Namen')}</b>
        ${u.note ? `<div style="color:var(--muted);font-size:13px">${esc(u.note)}</div>` : ''}
        ${(u.codes || []).map(c =>
          `<div class="mono" style="color:var(--muted);font-size:12px">${esc(fmtCode(c.code))}</div>`
        ).join('')}
      </td>
      <td>${subs.length ? subs.map(s => {
        const live = s.status === 'active' && new Date(s.current_period_end) > new Date();
        const cls  = live ? (s.days_left <= 7 ? 'warn' : 'ok') : 'bad';
        const txt  = live ? `${s.days_left} Tage`
                   : (s.status === 'revoked' ? 'gesperrt' : 'abgelaufen');
        return `<div class="subrow"><span class="pill ${cls}">${esc(txt)}</span>
          <span style="color:var(--muted);font-size:12px;margin-inline-start:6px"
            >bis ${fmtDate(s.current_period_end)}</span></div>`;
      }).join('') : '<span class="pill">kein Abo</span>'}</td>
      <td>${cell(s => `<div class="subrow mono">${esc((s.levels || []).join(', '))}</div>`)}</td>
      <td>${u.devices}</td>
      <td>${u.attempts}${u.best_pct != null ? ` · best ${u.best_pct}%` : ''}</td>
      <td>${fmtDate(u.last_seen_at || u.created_at)}</td>
      <td style="white-space:nowrap">
        ${subs.map(s => `<div class="subrow">
          <button class="btn sm grey" data-shift="30"  data-sub="${esc(s.id)}">+30</button>
          <button class="btn sm grey" data-shift="-30" data-sub="${esc(s.id)}">−30</button>
        </div>`).join('')}
        <button class="btn sm grey" data-more="${esc(u.id)}">…</button>
      </td></tr>`;
  };

  app.innerHTML = `
    <h1>Nutzer</h1>
    <p class="sub">${rows.length} Einträge. Suche nach Name, Notiz oder Code.</p>
    <div class="card">
      <div class="row">
        <label style="flex:3">Suche
          <input id="q" value="${esc(userSearch)}" placeholder="Name, Notiz oder Code"></label>
        <button class="btn" id="find">Suchen</button>
        ${userSearch ? '<button class="btn grey" id="clr">Zurücksetzen</button>' : ''}
      </div>
    </div>
    <div class="card"><div class="wrap"><table>
      <tr><th>Nutzer</th><th>Abo</th><th>Stufen</th><th>Geräte</th>
          <th>Prüfungen</th><th>zuletzt</th><th></th></tr>
      ${rows.map(line).join('') || '<tr><td colspan="7" class="empty">Keine Nutzer</td></tr>'}
    </table></div></div>`;

  const q = document.getElementById('q');
  const find = () => { userSearch = q.value.trim(); screenUsers(); };
  document.getElementById('find').onclick = find;
  q.onkeydown = e => { if (e.key === 'Enter') find(); };
  const clr = document.getElementById('clr');
  if (clr) clr.onclick = () => { userSearch = ''; screenUsers(); };

  app.querySelectorAll('[data-shift]').forEach(b => b.onclick = async () => {
    await act(b, () => rpc('admin_shift_subscription',
      { p_sub_id: b.dataset.sub, p_days: Number(b.dataset.shift) }),
      'Abo angepasst');
    screenUsers();
  });
  app.querySelectorAll('[data-more]').forEach(b => b.onclick = () =>
    userDialog(rows.find(u => u.id === b.dataset.more)));
}

/* تفاصيل مستخدم: كل الإجراءات الباقية */
function userDialog(u){
  if (!u) return;
  const subs = u.subs || [];
  const back = document.createElement('div');
  back.style.cssText = 'position:fixed;inset:0;background:rgba(0,0,0,.45);' +
    'display:flex;align-items:center;justify-content:center;padding:16px;z-index:40';

  /* Ein Block pro Abo. Die Knöpfe tragen die Abo-ID, damit +30 auf B1
     nicht versehentlich das A1-Abo verlängert. */
  const aboBlock = (s, i) => `
    <h2>Abo ${esc((s.levels || []).join(', ') || '—')}</h2>
    <p class="sub" style="margin-bottom:8px">
      ${esc(s.status)} · läuft bis ${fmtDate(s.current_period_end)}
      ${s.code ? ` · Code <span class="mono">${esc(fmtCode(s.code))}</span>` : ''}</p>
    <div class="row">
      <label>Enddatum
        <input id="d_end${i}" type="date"
               value="${new Date(s.current_period_end).toISOString().slice(0,10)}"></label>
      <button class="btn sm" data-end="${esc(s.id)}" data-i="${i}">Setzen</button>
    </div>
    <div class="row" style="margin-top:10px">
      ${[7, 30, 90, -7, -30].map(d =>
        `<button class="btn sm grey" data-d="${d}" data-sub="${esc(s.id)}"
          >${d > 0 ? '+' : '−'}${Math.abs(d)}</button>`).join('')}
    </div>
    <div class="row" style="margin-top:10px">
      ${s.status === 'active'
        ? `<button class="btn sm danger" data-st="revoked" data-sub="${esc(s.id)}"
            >Abo sperren</button>`
        : `<button class="btn sm" data-st="active" data-sub="${esc(s.id)}"
            >Abo entsperren</button>`}
    </div>`;

  back.innerHTML = `
    <div class="card" style="max-width:460px;width:100%;margin:0;max-height:90vh;overflow:auto">
      <h2 style="margin-top:0">${esc(u.name || 'Nutzer ohne Namen')}</h2>
      <p class="sub" style="margin-bottom:12px">
        ${u.attempts} Prüfungen · ${u.mistakes} offene Fehler · ${u.devices} Geräte<br>
        angelegt ${fmtDate(u.created_at)}
      </p>

      <label style="font-size:13px;color:var(--muted)">Name
        <input id="d_name" value="${esc(u.name || '')}" style="margin-top:4px"></label>
      <label style="font-size:13px;color:var(--muted);display:block;margin-top:8px">Notiz
        <input id="d_note" value="${esc(u.note || '')}"
               placeholder="z. B. WhatsApp-Nummer, bezahlt am …" style="margin-top:4px"></label>
      <button class="btn sm" id="d_save" style="margin-top:10px">Speichern</button>

      <h2>Eingelöste Codes</h2>
      ${(u.codes || []).length ? `<div class="wrap"><table>
        <tr><th>Code</th><th>Stufe</th><th>eingelöst</th></tr>
        ${u.codes.map(c => `<tr>
          <td class="mono">${esc(fmtCode(c.code))}</td>
          <td class="mono">${esc((c.levels || []).join(', '))}</td>
          <td>${fmtDate(c.at)}</td></tr>`).join('')}
      </table></div>` : '<p class="sub">Noch keinen Code eingelöst.</p>'}

      ${subs.length ? subs.map(aboBlock).join('')
                    : '<h2>Abo</h2><p class="sub">Kein Abo vorhanden.</p>'}

      <h2>Geräte</h2>
      <p class="sub" style="margin-bottom:8px">${u.devices} registriert.
        Zurücksetzen, wenn der Nutzer sein Gerät gewechselt hat.</p>
      <button class="btn sm grey" id="d_dev">Geräte zurücksetzen</button>

      <div style="margin-top:18px;text-align:right">
        <button class="btn grey" id="d_close">Schließen</button>
      </div>
    </div>`;
  document.body.appendChild(back);
  const close = () => { back.remove(); screenUsers(); };
  back.onclick = e => { if (e.target === back) close(); };
  back.querySelector('#d_close').onclick = close;

  const $ = id => back.querySelector('#' + id);
  $('d_save').onclick = e => act(e.target, () => rpc('admin_set_profile', {
    p_user_id: u.id, p_name: $('d_name').value.trim() || null,
    p_note: $('d_note').value.trim() || null }), 'Gespeichert');

  $('d_dev').onclick = e => act(e.target,
    () => rpc('admin_reset_devices', { p_user_id: u.id }), 'Geräte zurückgesetzt')
    .then(close);

  back.querySelectorAll('[data-d]').forEach(b => b.onclick = () =>
    act(b, () => rpc('admin_shift_subscription',
      { p_sub_id: b.dataset.sub, p_days: Number(b.dataset.d) }), 'Abo angepasst').then(close));

  back.querySelectorAll('[data-end]').forEach(b => b.onclick = () =>
    act(b, () => rpc('admin_set_period_end', {
      p_sub_id: b.dataset.end,
      p_end: new Date($('d_end' + b.dataset.i).value + 'T12:00:00Z').toISOString() }),
      'Enddatum gesetzt').then(close));

  back.querySelectorAll('[data-st]').forEach(b => b.onclick = () =>
    act(b, () => rpc('admin_set_subscription_status',
      { p_sub_id: b.dataset.sub, p_status: b.dataset.st }),
      b.dataset.st === 'revoked' ? 'Abo gesperrt' : 'Abo entsperrt').then(close));
}

let codeLevel = '';

async function screenCodes(){
  app.innerHTML = '<div class="empty">Lädt …</div>';
  const [codes, content] = await Promise.all([
    rpc('admin_codes'),
    rpc('admin_content')
  ]);
  // wie viele Tests jede Stufe wirklich freischaltet — versteckte zählen nicht
  const levels = (content.levels || []).map(l => ({
    ...l,
    live: (content.tests || []).filter(t => t.level_id === l.id && t.published).length
  }));
  /* الافتراضي: أول امتحان إله محتوى منشور. بلاه بيوقع الاختيار على أول
     صف بالترتيب — وهاد ممكن يكون مستوى فاضي لسا ما انبنى، فبيطلعلك
     تحذير «ما فيه امتحانات» بلا سبب واضح أول ما تفتحي الصفحة. */
  if (!codeLevel || !levels.some(l => l.id === codeLevel))
    codeLevel = (levels.find(l => l.live > 0) || levels[0] || {}).id || '';

  const state = c => c.revoked_at        ? ['bad', 'gesperrt']
                   : c.uses >= c.max_uses ? ['', 'aufgebraucht']
                   : c.uses > 0           ? ['warn', `${c.uses}/${c.max_uses} benutzt`]
                   :                        ['ok', `${c.max_uses}× frei`];
  app.innerHTML = `
    <h1>Zugangscodes</h1>
    <p class="sub">Erzeugen, ausdrucken, weitergeben. Ein Code wird einmal
      eingelöst und bindet sich dann an dieses Konto.</p>

    <div class="card">
      <div class="row">
        <label>Anzahl<input id="c_n" type="number" value="5" min="1" max="200"></label>
        ${pickerHTML('c_lvl', levels, codeLevel, {
          extra: l => `data-live="${l.live}" data-pub="${l.published ? 1 : 0}"` })}
        <label>Art<select id="c_kind">
          <option value="full" selected>Vollzugang</option>
          <option value="demo">Demo</option>
        </select></label>
        <label id="c_days_l">Tage<select id="c_days">
          <option value="30" selected>30</option><option value="90">90</option>
          <option value="180">180</option><option value="365">365</option>
        </select></label>
        <label id="c_hours_l" hidden>Stunden<input id="c_hours" type="number"
          value="24" min="1" max="720"></label>
        <label>Aktivierungen<input id="c_uses" type="number" value="2"
          min="1" max="10" title="Wie oft der Code eingelöst werden kann"></label>
        <label style="flex:2">Notiz<input id="c_note" placeholder="z. B. Kurs März"></label>
        <button class="btn" id="c_go">Erzeugen</button>
      </div>

      <!-- Nur für Demo: welche Tests der Code öffnet. Ohne Auswahl öffnet
           er die ganze Stufe, und das ist dann kein Demo mehr. -->
      <div class="row" id="c_tests_row" hidden style="margin-top:10px">
        <label style="flex:1">Tests im Demo
          <select id="c_tests" multiple size="4"></select></label>
        <p class="sub" style="flex:1;align-self:flex-end;margin:0">
          Mehrere mit Strg/Cmd anklicken. Korrektur und Lösungen sind dabei —
          nur die anderen Modelltests bleiben zu.</p>
      </div>

      <p class="sub" id="c_hint" style="margin:10px 0 0"></p>
      <div id="c_out"></div>
    </div>

    <div class="card"><div class="wrap"><table>
      <tr><th>Code</th><th>Status</th><th>Stufen</th><th>Gültig</th><th>Umfang</th>
          <th>Aktivierungen</th><th>Notiz</th><th>erstellt</th><th></th></tr>
      ${codes.map(c => { const [cls, txt] = state(c); return `<tr>
        <td class="mono"><b>${esc(fmtCode(c.code))}</b></td>
        <td><span class="pill ${cls}">${txt}</span></td>
        <td>${esc((c.levels || []).join(', '))}</td>
        <td>${c.duration_days ? c.duration_days + ' Tage' : ''}${
          c.duration_days && c.duration_hours ? ' + ' : ''}${
          c.duration_hours ? c.duration_hours + ' Std' : ''}</td>
        <td>${(c.test_slugs || []).length
          ? `<span class="pill warn">Demo</span> <span class="mono"
               style="font-size:12px">${esc(c.test_slugs.join(', '))}</span>`
          : 'ganze Stufe'}</td>
        <td>${c.uses} / ${c.max_uses}
          ${(c.redeemers || []).length ? `<div style="color:var(--muted);font-size:12px">
            ${c.redeemers.map(x => esc(x.name || 'ohne Namen') + ' · ' + fmtDate(x.at)).join('<br>')}
          </div>` : ''}</td>
        <td>${esc(c.note || '—')}</td><td>${fmtDate(c.created_at)}</td>
        <td style="white-space:nowrap">
          ${!c.revoked_at && c.uses >= c.max_uses
            ? `<button class="btn sm grey" data-more1="${esc(c.id)}"
                 title="Eine weitere Aktivierung freigeben">+1</button>` : ''}
          ${!c.revoked_at && c.uses === 0
            ? `<button class="btn sm danger" data-rev="${esc(c.id)}">sperren</button>` : ''}
        </td>
      </tr>`; }).join('') || '<tr><td colspan="9" class="empty">Noch keine Codes</td></tr>'}
    </table></div></div>`;

  /* Vor dem Erzeugen sichtbar machen, was der Code öffnet — eine Stufe,
     nicht alles, und nur ihre veröffentlichten Tests. */
  const $c = id => document.getElementById(id);
  const sel = $c('c_lvl'), hint = $c('c_hint'), kind = $c('c_kind'), tsel = $c('c_tests');

  /* Die Testliste hängt an der Stufe: ein Demo-Code für B1 darf keinen
     A1-Test anbieten. Nur veröffentlichte — ein verstecktes sieht der
     Kurs ohnehin nicht, und der Code sähe leer aus. */
  const testsOf = lvl => (content.tests || [])
    .filter(t => t.level_id === lvl && t.published);

  const fillTests = () => {
    const list = testsOf(sel.value);
    tsel.innerHTML = list.map((t, i) =>
      `<option value="${esc(t.slug)}"${i === 0 ? ' selected' : ''}>${
        esc(t.title)} <span>(${esc(t.slug)})</span></option>`).join('')
      || '<option value="" disabled>— keine veröffentlichten Tests —</option>';
  };

  const isDemo = () => kind.value === 'demo';
  const picked = () => [...tsel.selectedOptions].map(o => o.value).filter(Boolean);

  const showHint = () => {
    $c('c_days_l').hidden   = isDemo();
    $c('c_hours_l').hidden  = !isDemo();
    $c('c_tests_row').hidden = !isDemo();

    const o = sel.selectedOptions[0];
    if (!o || !o.value){ hint.textContent = ''; return; }
    const live = Number(o.dataset.live), pub = o.dataset.pub === '1';
    const uses = $c('c_uses').value;
    const geraete = `<b>${esc(uses)} Gerät${uses === '1' ? '' : 'en'}</b>`;

    if (!pub || !live){
      hint.innerHTML = `<span style="color:var(--warn)">Diese Stufe hat gerade
        ${live ? 'keine veröffentlichten' : 'keine'} Tests — der Code
        funktioniert, der Kurs sieht aber nichts.</span>`;
      return;
    }
    if (isDemo()){
      const n = picked().length;
      hint.innerHTML = n
        ? `Öffnet <b>${n} Test${n === 1 ? '' : 's'}</b> der Stufe
           <b>${esc(o.textContent)}</b> für <b>${esc($c('c_hours').value)} Stunden</b>,
           einlösbar auf ${geraete}. Mit Korrektur und Lösungen.
           Die anderen ${live - n} Test${live - n === 1 ? '' : 's'} bleiben zu.`
        : `<span style="color:var(--warn)">Kein Test ausgewählt — bitte
           mindestens einen anklicken.</span>`;
    } else {
      hint.innerHTML = `Öffnet <b>${live} Test${live === 1 ? '' : 's'}</b> der Stufe
        <b>${esc(o.textContent)}</b> für <b>${esc($c('c_days').value)} Tage</b>,
        einlösbar auf ${geraete}.
        Andere Stufen bleiben zu — dafür braucht es einen zweiten Code.`;
    }
  };

  wireNewLevel(sel, id => { if (id) codeLevel = id; screenCodes(); });
  // تبديل المؤسسة بيغيّر قائمة الدرجات، وتبديل الدرجة بيغيّر قائمة
  // الامتحانات وسطر «شو بيفتح»
  wirePicker('c_lvl', levels, id => { codeLevel = id; fillTests(); showHint(); },
             { extra: l => `data-live="${l.live}" data-pub="${l.published ? 1 : 0}"` });
  kind.onchange    = showHint;
  tsel.onchange    = showHint;
  $c('c_days').onchange  = showHint;
  $c('c_hours').oninput  = showHint;
  $c('c_uses').oninput   = showHint;
  fillTests(); showHint();

  document.getElementById('c_go').onclick = async e => {
    if (!sel.value) return toast('Zuerst eine Stufe anlegen (Inhalte → Stufen)');
    if (isDemo() && !picked().length)
      return toast('Beim Demo mindestens einen Test auswählen');
    const made = await act(e.target, () => rpc('admin_create_codes', {
      p_count: Number($c('c_n').value),
      p_levels: [sel.value],
      // Demo zählt in Stunden, nicht in Tagen — 0 Tage + 24 Stunden
      p_days:  isDemo() ? 0 : Number($c('c_days').value),
      p_hours: isDemo() ? Number($c('c_hours').value) : 0,
      p_tests: isDemo() ? picked() : null,
      p_max_devices: Number($c('c_uses').value),
      p_note: $c('c_note').value.trim() || null,
      p_max_uses: Number($c('c_uses').value)
    }), 'Codes erzeugt');
    if (!made) return;
    document.getElementById('c_out').innerHTML =
      `<h2>Neu erzeugt</h2><div class="codes">
         ${made.map(c => `<div class="mono">${esc(fmtCode(c))}</div>`).join('')}</div>
       <p class="sub" style="margin:8px 0 0">Genau so weitergeben. Beim Einlösen
          sind Leerzeichen, Bindestriche und Groß-/Kleinschreibung egal.</p>
       <button class="btn sm grey" id="c_copy" style="margin-top:10px">Kopieren</button>`;
    document.getElementById('c_copy').onclick = () => {
      navigator.clipboard?.writeText(made.map(fmtCode).join('\n'))
        .then(() => toast('Kopiert')).catch(() => toast('Kopieren nicht möglich'));
    };
  };
  app.querySelectorAll('[data-rev]').forEach(b => b.onclick = async () => {
    await act(b, () => rpc('admin_revoke_code', { p_code_id: b.dataset.rev }), 'Code gesperrt');
    screenCodes();
  });
  // Gerät verloren, Browser gelöscht: eine Aktivierung nachlegen
  app.querySelectorAll('[data-more1]').forEach(b => b.onclick = async () => {
    await act(b, () => rpc('admin_add_code_use',
      { p_code_id: b.dataset.more1, p_extra: 1 }), 'Eine Aktivierung freigegeben');
    screenCodes();
  });
}

async function screenAudit(){
  app.innerHTML = '<div class="empty">Lädt …</div>';
  const rows = await api('admin_audit_log?select=created_at,action,target_type,' +
                         'target_id,detail&order=created_at.desc&limit=200');
  app.innerHTML = `
    <h1>Protokoll</h1>
    <p class="sub">Jede Änderung an Abos, Codes und Geräten — die letzten 200.</p>
    <div class="card"><div class="wrap"><table>
      <tr><th>Zeit</th><th>Aktion</th><th>Ziel</th><th>Details</th></tr>
      ${rows.map(r => `<tr>
        <td style="white-space:nowrap">${fmtDT(r.created_at)}</td>
        <td class="mono">${esc(r.action)}</td>
        <td class="mono" style="font-size:12px">${esc(r.target_id || '')}</td>
        <td><details><summary>ansehen</summary>
          <pre class="mono" style="font-size:12px;white-space:pre-wrap;margin:6px 0 0">${esc(JSON.stringify(r.detail, null, 1))}</pre>
        </details></td>
      </tr>`).join('') || '<tr><td colspan="4" class="empty">Noch nichts protokolliert</td></tr>'}
    </table></div></div>`;
}


/* ============ الإنشاء: مستويات، امتحانات، مراجع ============ */
let contentCache = null;

let contentLevel = '';

async function screenContent(){
  app.innerHTML = '<div class="empty">Lädt …</div>';
  const c = contentCache = await rpc('admin_content');
  // مرشّح الستوفة بينطبق هون بالعميل: admin_content بترجّع كل شي مرة
  // وحدة، والقوائم صغيرة — نداء تاني لكل تبديل مو مستاهل.
  const tests = (c.tests || []).filter(t => !contentLevel || t.level_id === contentLevel);

  const lvlRow = l => `<tr>
    <td>${l.provider
      ? `<b>${esc(l.provider)}</b>`
      : '<span style="color:var(--warn)">ohne Anbieter</span>'}</td>
    <td class="mono">${esc(l.stufe || '—')}</td>
    <td>${esc(l.title)}
      <div class="mono" style="color:var(--muted);font-size:12px">${esc(l.id)}</div></td>
    <td>${l.tests}</td>
    <td><span class="pill ${l.published ? 'ok' : ''}">${l.published ? 'online' : 'versteckt'}</span></td>
    <td><button class="btn sm grey" data-lvl="${esc(l.id)}"
          data-pub="${l.published ? 0 : 1}" data-title="${esc(l.title)}"
          data-sort="${l.sort}" data-prov="${esc(l.provider || '')}"
          data-stufe="${esc(l.stufe || '')}"
          >${l.published ? 'verstecken' : 'online stellen'}</button></td>
  </tr>`;

  const testRow = t => `<tr>
    <td class="mono">${esc(t.level_id)}</td>
    <td><b>${esc(t.title)}</b>
      <div class="mono" style="color:var(--muted);font-size:12px">${esc(t.slug)}</div></td>
    <td>${t.sections} / ${t.aufgaben}</td>
    <td>${t.answers}</td>
    <td><span class="pill ${t.published ? 'ok' : ''}">${t.published ? 'online' : 'Entwurf'}</span></td>
    <td style="white-space:nowrap">
      <button class="btn sm" data-tedit="${esc(t.id)}"
        title="Im Import-Editor öffnen">bearbeiten</button>
      <button class="btn sm grey" data-tpub="${esc(t.id)}" data-v="${t.published ? 0 : 1}">
        ${t.published ? 'verstecken' : 'online'}</button>
      <button class="btn sm danger" data-tdel="${esc(t.id)}" data-n="${esc(t.title)}">löschen</button>
    </td></tr>`;

  const resRow = r => `<tr>
    <td class="mono">${esc(r.level_id || 'alle')}</td>
    <td>${esc(r.title)}</td>
    <td>${r.length} Zeichen</td>
    <td><span class="pill ${r.published ? 'ok' : ''}">${r.published ? 'online' : 'Entwurf'}</span></td>
    <td style="white-space:nowrap">
      <button class="btn sm grey" data-redit="${esc(r.id)}">bearbeiten</button>
      <button class="btn sm danger" data-rdel="${esc(r.id)}" data-n="${esc(r.title)}">löschen</button>
    </td></tr>`;

  app.innerHTML = `
    <h1>Inhalte</h1>
    <p class="sub">Prüfungen, Modelltests und Lesematerial.</p>

    <h2>Prüfungen</h2>
    <p class="sub">Eine Prüfung ist <b>Anbieter + Stufe</b>: telc·B1 und
      Goethe·B1 sind zwei verschiedene Produkte mit eigenen Modelltests,
      eigenen Codes und eigenem Abo. Ein Code für telc·B1 öffnet Goethe·B1
      nicht.</p>
    <div class="card">
      <div class="row">
        <label>Anbieter<input id="l_prov" list="anbieter" placeholder="telc"></label>
        <datalist id="anbieter">
          ${ANBIETER.map(a => `<option value="${esc(a)}">`).join('')}
        </datalist>
        <label>Stufe<input id="l_stufe" list="stufen" placeholder="B1"
          maxlength="12" style="max-width:110px"></label>
        <datalist id="stufen">
          ${STUFEN.map(x => `<option value="${esc(x)}">`).join('')}
        </datalist>
        <label style="flex:2">Titel <span style="color:var(--muted)">(optional)</span>
          <input id="l_title" placeholder="wird aus Anbieter + Stufe gebildet"></label>
        <label>Reihenfolge<input id="l_sort" type="number" value="0"></label>
        <button class="btn" id="l_go">Anlegen / ändern</button>
      </div>
      <div class="wrap" style="margin-top:12px"><table>
        <tr><th>Anbieter</th><th>Stufe</th><th>Titel</th><th>Tests</th>
            <th>Status</th><th></th></tr>
        ${c.levels.map(lvlRow).join('')
          || '<tr><td colspan="6" class="empty">Noch keine Prüfung</td></tr>'}
      </table></div>
    </div>

    <h2>Modelltests</h2>
    <div class="card">
      <div class="row">
        ${pickerHTML('t_lvl', c.levels, contentLevel, { all: true })}
        <p class="sub" style="flex:2;align-self:flex-end;margin:0">
          <b>bearbeiten</b> öffnet den Test im Import-Editor — dieselbe
          Vorlagensprache wie beim Anlegen. Speichern ersetzt ihn.</p>
      </div>
      <div class="wrap" style="margin-top:12px"><table>
        <tr><th>Stufe</th><th>Test</th><th>Teile / Aufg.</th><th>Lösungen</th><th>Status</th><th></th></tr>
        ${tests.map(testRow).join('')
          || '<tr><td colspan="6" class="empty">Keine Tests in dieser Stufe</td></tr>'}
      </table></div>
    </div>

    <h2>Lesematerial</h2>
    <p class="sub">Kein Modelltest: freie Texte, die im Kurs jederzeit lesbar
      sind — Wortschatzlisten, Grammatik, Prüfungstipps. Ohne Uhr, ohne
      Punkte, ohne Lösung. Wer die Stufe abonniert hat, sieht sie.</p>
    <div class="card">
      <div class="row">
        ${pickerHTML('r_lvl', c.levels, '', { all: true })}
        <label style="flex:2">Titel<input id="r_title" placeholder="z. B. Wortschatz Reisen"></label>
        <label>Reihenfolge<input id="r_sort" type="number" value="0"></label>
      </div>
      <textarea id="r_body" class="paste" style="margin-top:10px;min-height:180px"
        placeholder="Text hier einfügen. Leerzeile trennt Absätze, ## macht eine Überschrift."></textarea>
      <input type="hidden" id="r_id">
      <div class="row" style="margin-top:10px">
        <button class="btn" id="r_save">Speichern &amp; veröffentlichen</button>
        <button class="btn grey" id="r_draft">Als Entwurf speichern</button>
        <button class="btn grey" id="r_new" hidden>Neu</button>
      </div>
      <div class="wrap" style="margin-top:12px"><table>
        <tr><th>Stufe</th><th>Titel</th><th>Länge</th><th>Status</th><th></th></tr>
        ${c.resources.map(resRow).join('') || '<tr><td colspan="5" class="empty">Noch nichts</td></tr>'}
      </table></div>
    </div>`;

  const $ = id => document.getElementById(id);

  wirePicker('t_lvl', c.levels, id => { contentLevel = id; screenContent(); },
             { all: true });

  /* التعديل: القراءة رجوعاً من القاعدة، تحويل لنص القالب، وفتح المحرّر.
     نفس اللغة يلي بتنكتب فيها الامتحانات الجديدة — ما في صيغة تانية
     تتعلّميها، والحفظ بيستبدل الامتحان على نفس الـslug. */
  app.querySelectorAll('[data-tedit]').forEach(b => b.onclick = async () => {
    const t = (c.tests || []).find(x => x.id === b.dataset.tedit);
    const doc = await act(b, () => rpc('admin_test_doc', { p_test_id: b.dataset.tedit }));
    if (!doc) return;
    importState = { id: null, doc: null, raw: '' };
    pendingEdit = { level: t.level_id, slug: t.slug, text: Markup.serialize(doc) };
    show('import');
  });

  $('l_go').onclick = async e => {
    const provider = $('l_prov').value.trim();
    const stufe    = $('l_stufe').value.trim().toUpperCase();
    if (!provider || !stufe)
      return toast('Anbieter und Stufe sind beide nötig');
    // المعرّف والعنوان بيتولّدوا بقاعدة البيانات لما ما ينعطوا
    await act(e.target, () => rpc('admin_upsert_level', {
      p_id: null, p_title: $('l_title').value.trim() || null,
      p_sort: Number($('l_sort').value) || 0, p_published: false,
      p_provider: provider, p_stufe: stufe }), 'Prüfung gespeichert');
    screenContent();
  };
  app.querySelectorAll('[data-lvl]').forEach(b => b.onclick = async () => {
    await act(b, () => rpc('admin_upsert_level', {
      p_id: b.dataset.lvl, p_title: b.dataset.title,
      p_sort: Number(b.dataset.sort), p_published: b.dataset.pub === '1',
      p_provider: b.dataset.prov || null, p_stufe: b.dataset.stufe || null }),
      'Gespeichert');
    screenContent();
  });
  app.querySelectorAll('[data-tpub]').forEach(b => b.onclick = async () => {
    await act(b, () => rpc('admin_set_test_published',
      { p_test_id: b.dataset.tpub, p_published: b.dataset.v === '1' }), 'Gespeichert');
    screenContent();
  });
  app.querySelectorAll('[data-tdel]').forEach(b => b.onclick = async () => {
    if (!confirm(`„${b.dataset.n}“ mit allen Aufgaben und Lösungen löschen?`)) return;
    await act(b, () => rpc('admin_delete_test', { p_test_id: b.dataset.tdel }), 'Gelöscht');
    screenContent();
  });

  const saveRes = pub => async e => {
    const id = $('r_id').value || null;
    if (!$('r_title').value.trim()) return toast('Titel fehlt');
    await act(e.target, () => rpc('admin_save_resource', {
      p_id: id, p_level_id: $('r_lvl').value || null,
      p_title: $('r_title').value.trim(), p_body: $('r_body').value,
      p_published: pub, p_sort: Number($('r_sort').value) || 0 }), 'Gespeichert');
    screenContent();
  };
  $('r_save').onclick  = saveRes(true);
  $('r_draft').onclick = saveRes(false);
  app.querySelectorAll('[data-rdel]').forEach(b => b.onclick = async () => {
    if (!confirm(`„${b.dataset.n}“ löschen?`)) return;
    await act(b, () => rpc('admin_delete_resource', { p_id: b.dataset.rdel }), 'Gelöscht');
    screenContent();
  });
  app.querySelectorAll('[data-redit]').forEach(b => b.onclick = async () => {
    const rows = await api(`resources?select=id,level_id,title,body,sort&id=eq.${b.dataset.redit}`);
    const r = rows[0]; if (!r) return;
    $('r_id').value = r.id; $('r_title').value = r.title || '';
    $('r_body').value = r.body || ''; $('r_lvl').value = r.level_id || '';
    $('r_sort').value = r.sort || 0;
    $('r_new').hidden = false;
    $('r_new').onclick = () => screenContent();
    $('r_title').scrollIntoView({ behavior:'smooth', block:'center' });
  });
}

/* ============ الاستماع ============
   ثلث الامتحان. بدون ملفات صوت هالقسم مراجعة مو تدريب. */
/* منتقي الستوفة بيعرض يلي موجود بس، فالمستخدم يلي بده A1 وما عنده
   بيوقف. الخيار الأخير بيفتح سؤالين وبيعمل الستوفة على طول، بلا ما
   يترك الشاشة يلي هو فيها. */
/* ============ المؤسسة + الدرجة ============ */
/* «A1» لحالها مو منتج: في A1 من telc وA1 من Goethe وA1 من ÖSD، وكل
   وحدة امتحان مختلف. فصف المستوى الواحد بقاعدة البيانات = (مؤسسة،
   درجة)، والاشتراك والكود معلّقين عليه متل ما كانوا. */
const STUFEN    = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
const ANBIETER  = ['telc', 'Goethe', 'ÖSD', 'TestDaF', 'DTZ'];

/* اسم للعرض: «telc · B1». المستويات القديمة ممكن تكون بلا مؤسسة —
   منبيّن عنوانها متل ما هو بدل ما نخترع وحدة. */
const lvlName = l => l.provider && l.stufe
  ? `${l.provider} · ${l.stufe}` : (l.title || l.id);

/* منتقي الامتحان: **منتقيين** — مؤسسة، ثم درجة.
   جرّبت قائمة وحدة مجمّعة بـoptgroup: بتخفي المؤسسة. الصندوق المقفول
   بيعرض «B1» بس، والمؤسسة ما بتبيّن إلا لما تفتحيه — وهي نص القرار.

   idBase هو معرّف منتقي الدرجة (يلي قيمته = معرّف المستوى)، ومنتقي
   المؤسسة بياخد نفس الاسم + «_prov».  */
const NO_PROV = 'ohne Anbieter';
const provOf  = l => l.provider || NO_PROV;

/* خيارات منتقي الدرجة. مركزيّة بالقصد: الرسم الأول وإعادة الملء بعد
   تبديل المؤسسة لازم يتطابقوا، وإلا بتختلف الخيارات بين الحالتين.

   لما المؤسسة «الكل»، بتتعرض كل المستويات باسم «telc · B1» — وإلا
   القائمة بتطلع فاضية وما بتقدري تقفزي لواحد مباشرة. */
function stufeOptions(levels, curProv, selected, withAll, extra){
  const list = curProv ? levels.filter(l => provOf(l) === curProv) : levels;
  const label = l => curProv ? (l.stufe || l.title)
                             : `${provOf(l)} · ${l.stufe || l.title}`;
  return (withAll && !curProv ? '<option value="">alle</option>' : '')
    + list.map(l => `<option value="${esc(l.id)}"${
        l.id === selected ? ' selected' : ''} ${extra(l)}>${esc(label(l))}${
        l.published ? '' : ' (versteckt)'}</option>`).join('');
}

function pickerHTML(idBase, levels, selected, opts = {}){
  const withAll = !!opts.all;
  const extra   = opts.extra || (() => '');
  const provs   = [...new Set(levels.map(provOf))];
  const cur     = levels.find(l => l.id === selected);
  // بلا اختيار: «الكل» إذا مسموح، وإلا أول مؤسسة
  const curProv = cur ? provOf(cur) : (withAll ? '' : (provs[0] || ''));

  return `
    <label>${esc(opts.label || 'Anbieter')}<select id="${idBase}_prov">
      ${withAll ? `<option value=""${curProv ? '' : ' selected'}>alle</option>` : ''}
      ${provs.map(pr => `<option value="${esc(pr)}"${
        pr === curProv ? ' selected' : ''}>${esc(pr)}</option>`).join('')}
    </select></label>
    <label>Stufe<select id="${idBase}">
      ${stufeOptions(levels, curProv, selected, withAll, extra)}
    </select></label>`;
}

/* تبديل المؤسسة بيعيد ملء الدرجات وبينده onChange بالمستوى الجديد.
   بلا هالربط، منتقي الدرجة بيضل على درجات المؤسسة القديمة. */
function wirePicker(idBase, levels, onChange, opts = {}){
  const withAll = !!opts.all;
  const extra   = opts.extra || (() => '');
  const selP = document.getElementById(idBase + '_prov');
  const selS = document.getElementById(idBase);
  if (!selP || !selS) return;

  selP.onchange = () => {
    selS.innerHTML = stufeOptions(levels, selP.value, null, withAll, extra);
    onChange(selS.value);
  };
  selS.addEventListener('change', () => onChange(selS.value));
}

const NEW_LEVEL = '__neu__';
const newLevelOption = '<option value="' + NEW_LEVEL + '">+ neue Stufe anlegen …</option>';

async function askNewLevel(){
  const provider = (prompt(
    `Anbieter der Prüfung?\n(${ANBIETER.join(', ')} … oder ein anderer)`) || '').trim();
  if (!provider) return null;
  const stufe = (prompt(
    `Stufe?\n(${STUFEN.join(', ')})`, 'B1') || '').trim().toUpperCase();
  if (!stufe) return null;
  try {
    // مخفية أول ما تنعمل: ما في محتوى فيها بعد، ونشرها فاضية بيوصّل
    // للطالب مستوى بلا امتحانات. المعرّف بيتولّد بقاعدة البيانات.
    const r = await rpc('admin_upsert_level', {
      p_id: null, p_title: null, p_sort: 0, p_published: false,
      p_provider: provider, p_stufe: stufe });
    toast(`„${provider} · ${stufe}" angelegt (noch versteckt)`);
    return r.id;
  } catch (e){
    toast(e.message === 'provider_and_stufe_required'
      ? 'Anbieter und Stufe sind beide nötig'
      : `Fehler: ${e.message}`, 4000);
    return null;
  }
}

/* بيربط منتقي بالخيار: لما ينختار، بيسأل وبيعيد رسم الشاشة */
function wireNewLevel(sel, redraw){
  if (!sel) return;
  sel.insertAdjacentHTML('beforeend', newLevelOption);
  const prev = sel.value;
  sel.addEventListener('change', async () => {
    if (sel.value !== NEW_LEVEL) return;
    sel.value = prev;
    const id = await askNewLevel();
    redraw(id);
  });
}

/* ============ الملفات: صور وصوت ============ */
/* جدول الملفات بينرسم بمكانين — شاشة «Dateien» لكل الامتحانات، وصندوق
   أسفل الاستيراد للامتحان يلي عم تشتغلي عليه. نسختين من هالمنطق معناها
   إن الرفع بيتصلّح بمكان وبيضل مكسور بالتاني، فالرسم والربط مشتركين. */

function assetBlock(title, list, bucket, hint){
  return `
    <h2>${title}</h2>
    <div class="card">
      <p class="sub" style="margin-top:0">${hint}</p>
      ${list.length ? `<div class="wrap"><table>
        <tr><th>Test</th><th>Teil</th><th>Dateiname</th>
            ${bucket === 'exam-audio' ? '<th>Wdh.</th>' : ''}
            <th>Status</th><th></th></tr>
        ${list.map(r => `<tr>
          <td>${esc(r.test_title)}
            <div class="mono" style="color:var(--muted);font-size:12px">${esc(r.slug)}</div></td>
          <td class="mono">${esc(r.section)}</td>
          <td>${bucket === 'exam-audio'
            ? `<input class="mono" data-name="${esc(r.section_id)}"
                 value="${esc(r.path)}" style="min-width:170px;font-size:12px">`
            : `<span class="mono" style="font-size:12px">${esc(r.path)}</span>`}</td>
          ${bucket === 'exam-audio'
            ? `<td><input data-plays="${esc(r.section_id)}" type="number" min="1" max="5"
                 value="${r.plays}" style="width:64px"></td>` : ''}
          <td><span class="pill ${r.uploaded ? 'ok' : r.assigned ? 'warn' : ''}">${
            r.uploaded ? 'da' : r.assigned ? 'fehlt' : 'offen'}</span></td>
          <td style="white-space:nowrap">
            <input type="file" hidden
                   accept="${bucket === 'exam-audio' ? 'audio/*' : 'image/*'}"
                   data-file="${esc(r.section_id)}" data-bucket="${bucket}"
                   data-path="${esc(r.path)}">
            <button class="btn sm ${r.uploaded ? 'grey' : ''}"
                    data-pick="${esc(r.section_id)}">${
              r.uploaded ? 'ersetzen' : 'hochladen'}</button>
            ${bucket === 'exam-audio' && r.assigned
              ? `<button class="btn sm grey" data-unlink="${esc(r.section_id)}"
                   title="Verknüpfung lösen">trennen</button>` : ''}
          </td></tr>`).join('')}
      </table></div>` : '<p class="empty">Nichts nötig</p>'}
    </div>`;
}

function wireAssets(root, refresh){
  root.querySelectorAll('[data-pick]').forEach(b => b.onclick = () =>
    root.querySelector(`[data-file="${b.dataset.pick}"]`).click());

  root.querySelectorAll('[data-file]').forEach(inp => inp.onchange = async () => {
    const file = inp.files && inp.files[0];
    if (!file) return;
    const id  = inp.dataset.file;
    const btn = root.querySelector(`[data-pick="${id}"]`);
    // اسم الملف بالدلو هو يلي بالحقل، مو اسم الملف عالجهاز — لازم يطابق
    // يلي بـconfig حرف بحرف وإلا الطالب ما بيشوفه
    const nameEl = root.querySelector(`[data-name="${id}"]`);
    const path = (nameEl ? nameEl.value.trim() : inp.dataset.path);
    if (!path) return toast('Zuerst einen Dateinamen eintragen');
    try {
      await act(btn, async () => {
        // للصوت: نربط المسار بالقسم أول، وإلا بيوصل الملف للدلو وما حدا
        // بيعرف إنه إله
        if (inp.dataset.bucket === 'exam-audio'){
          const plays = Number(root.querySelector(`[data-plays="${id}"]`).value) || 1;
          await rpc('admin_set_section_audio',
                    { p_section_id: id, p_path: path, p_plays: plays });
        }
        await upload(inp.dataset.bucket, path, file);
      }, 'Hochgeladen');
    } catch { /* act أصلاً بيعرض الخطأ */ }
    refresh();
  });

  root.querySelectorAll('[data-unlink]').forEach(b => b.onclick = async () => {
    await act(b, () => rpc('admin_set_section_audio',
      { p_section_id: b.dataset.unlink, p_path: null, p_plays: 1 }), 'Getrennt');
    refresh();
  });
}

/* نداء لدالة لسا مو موجودة بالقاعدة. بيصير لما تنرفع نسخة جديدة من
   اللوحة قبل ما ينشغل setup.sql — والرسالة العامة «Fehler beim Laden»
   ما بتقول شو لازم تعملي. */
const isStale = e => /schema cache|does not exist|admin_assets|admin_test_doc/i
  .test(e && e.message || '');
const STALE_MSG = '⚠ Die Datenbank ist noch nicht aktualisiert — bitte '
  + '<code>supabase/setup.sql</code> im SQL-Editor ausführen. Ohne sie fehlen '
  + 'Datei-Upload, Demo-Codes und Anbieter.';

/* ★ نسخة المخطّط.
   اللوحة بتنرفع لـCloudflare فوراً، والقاعدة ما بتتحدّث إلا بالإيد —
   فبينفتح فرق: واجهة جديدة بتنادي دوال لسا مو موجودة. وقتها كل ميزة
   بتفشل بصمت بطريقتها، وولا وحدة بتقول السبب. الرقم بيخلّي اللوحة تقوله.

   لما يتضاف ترحيل: يزيد الرقم هون وبـ0019_version.sql. */
const SCHEMA_MIN = 21;
let schemaHave = null;      // null = لسا ما انفحص

async function checkSchema(){
  try { schemaHave = await rpc('schema_version'); }
  catch { schemaHave = 0; }   // الدالة نفسها ناقصة = قاعدة قديمة جداً
  return schemaHave;
}

/* شريط بيطلع فوق كل شاشة لما القاعدة تكون ورا. مو toast: الـtoast
   بيروح بعد ثانيتين، وهاد لازم يضل لحد ما ينحلّ. */
function schemaBanner(){
  if (schemaHave == null || schemaHave >= SCHEMA_MIN) return '';
  return `<div class="stale">
    <b>Die Datenbank ist ${SCHEMA_MIN - schemaHave} Migration${
      SCHEMA_MIN - schemaHave === 1 ? '' : 'en'} zurück</b>
    (Stand ${schemaHave}, gebraucht ${SCHEMA_MIN}).
    <br>Öffnen Sie <code>supabase/setup.sql</code> aus dem Repository,
    kopieren Sie alles und führen Sie es im <b>SQL Editor</b> aus.
    Die Datei ist gefahrlos wiederholbar — Nutzer, Codes und Abos bleiben.
    <br><span class="sub">Bis dahin fehlen: gesperrte Modelltests in der
    Demo, Datei-Upload, Demo-Codes, Anbieter und das Bearbeiten von Tests.</span>
  </div>`;
}

const IMG_HINT = 'Die Anzeigenseite aus der PDF, als Bild. Der Dateiname steht '
  + 'im Test unter <code>Bild:</code> — er wird beim Hochladen übernommen, egal '
  + 'wie die Datei auf Ihrem Rechner heißt.';
const AUD_HINT = 'Die Aufnahme zum Abschnitt. Wie oft sie abgespielt werden darf, '
  + 'steht im Test unter <code>Wiedergaben:</code>.';

let assetLevel = '';

async function screenAssets(){
  app.innerHTML = '<div class="empty">Lädt …</div>';
  let rows, content;
  try {
    [rows, content] = await Promise.all([
      rpc('admin_assets', { p_level_id: assetLevel || null }),
      rpc('admin_content')
    ]);
  } catch (e){
    if (!isStale(e)) throw e;
    // نفس الرسالة يلي بصفحة الاستيراد: «Fehler beim Laden» العامة ما
    // بتقول للمستخدم شو لازم يعمل
    app.innerHTML = `<h1>Dateien</h1><p class="sub">${STALE_MSG}</p>`;
    return;
  }

  const fehlt = rows.filter(r => !r.uploaded).length;

  app.innerHTML = `
    <h1>Dateien</h1>
    <p class="sub">Bilder der Anzeigen und die Hörtexte. Ohne sie fehlt dem
      Kurs ein Teil der Prüfung — Leseverstehen 3 bleibt leer, Hörverstehen
      lässt sich nur nachlesen.</p>

    <div class="stats">
      <div class="stat ${fehlt ? 'warn' : 'ok'}"><b>${fehlt}</b><span>fehlen</span></div>
      <div class="stat"><b>${rows.length - fehlt}</b><span>hochgeladen</span></div>
    </div>

    <div class="card"><div class="row">
      ${pickerHTML('as_lvl', content.levels || [], assetLevel, { all: true })}
    </div></div>

    ${assetBlock('Bilder',   rows.filter(r => r.kind === 'image'), 'exam-images', IMG_HINT)}
    ${assetBlock('Hörtexte', rows.filter(r => r.kind === 'audio'), 'exam-audio',  AUD_HINT)}`;

  wirePicker('as_lvl', content.levels || [], id => { assetLevel = id; screenAssets(); },
             { all: true });
  wireAssets(app, screenAssets);
}

/* ============ الاستيراد ============ */
/* القوالب بـadmin/vorlagen.js، مولّدة من docs/vorlage/*.txt.
   المختصر تحت للعين بس؛ الكامل بالزرّين. */
const SAMPLE = VORLAGE_BEISPIEL.split('\n').filter(l => !l.startsWith('//'))
  .join('\n').split('### Teil: lv2')[0].trim();

let importState = { id: null, doc: null, raw: '' };
/* لما تضغطي «bearbeiten» بالإنهالته، منخزّن الامتحان هون ومنقفز لشاشة
   الاستيراد — هي يلي بترسم المحرّر، فما بينفع نملا الحقول قبلها. */
let pendingEdit = null;
/* بعد النشر: الصفحة بتنعاد ترسم، وهاد بيضيّع الاسم — منمرّره تا يفتح
   صندوق الملفات على الامتحان يلي لسا انتشر */
let pendingFiles = null;
let importLevel = '';

async function screenImport(){
  app.innerHTML = '<div class="empty">Lädt …</div>';
  const c = contentCache = await rpc('admin_content');

  /* امتحان جاي للتعديل: لازم المنتقي يتبنى مؤسسته **قبل** الرسم.
     المنتقي حقلين، وحقل الدرجة بيعرض درجات المؤسسة المختارة بس — فتعيين
     القيمة بعد الرسم بيفشل بصمت لما يكون الامتحان من مؤسسة تانية. */
  if (pendingEdit)  importLevel = pendingEdit.level;
  if (pendingFiles) importLevel = pendingFiles.level;

  app.innerHTML = `
    <h1>Import</h1>
    <p class="sub">Prüfungstext einfügen, prüfen, dann veröffentlichen.
      Nichts geht online, bevor Sie die Vorschau gesehen haben.</p>

    <div class="card">
      <div class="row">
        ${pickerHTML('i_lvl', c.levels, importLevel)}
        <label style="flex:2">Kennung des Tests
          <input id="i_slug" placeholder="modell-a2-01"></label>
        <button class="btn grey" id="i_sample">Beispiel einfügen</button>
        <button class="btn grey" id="i_leer">Leere Vorlage</button>
      </div>

      <textarea id="i_text" class="paste" style="margin-top:10px"
        placeholder="Hier den Prüfungstext einfügen …"></textarea>

      <div class="row" style="margin-top:10px">
        <button class="btn" id="i_parse">Prüfen</button>
        <button class="btn grey" id="i_clear">Leeren</button>
      </div>

      <div id="i_result"></div>

      <details class="help">
        <summary>Format — kurz erklärt</summary>
        <pre>${esc(SAMPLE)}</pre>
        <p class="sub" style="margin:8px 0 0">
          <code>#</code> Testname · <code>## Block:</code> Prüfungsteil mit Zeit ·
          <code>### Teil:</code> Abschnitt · <code>[1]</code> Aufgabe ·
          <code>A)</code> Antwortmöglichkeit · <code>Lösung:</code> richtige Antwort.<br>
          Bei <b>truefalse</b>: <code>Lösung: richtig</code> oder <code>falsch</code>.
          Bei Lesetexten: <code>Text:</code> und dann die Absätze, <code>**fett**</code> für Überschriften.
          Alles, was das Format nicht kennt, kann als <code>Extra:</code> mit JSON angehängt werden.
          Zeilen mit <code>//</code> sind Kommentare und werden ignoriert.<br>
          <b>Beispiel einfügen</b> lädt eine vollständige B1-Prüfung mit allen fünf
          Formaten, Bild und Hörtext. <b>Leere Vorlage</b> lädt dasselbe Gerüst mit
          allen 61 Aufgaben zum Ausfüllen — jede noch offene Stelle
          <code>&lt;…&gt;</code> wird beim Prüfen gemeldet.
        </p>
      </details>
    </div>

    <div id="i_files"></div>

    <h2>Frühere Importe</h2>
    <div class="card"><div class="wrap"><table>
      <tr><th>Titel</th><th>Stufe</th><th>Status</th><th>Größe</th><th>Datum</th><th></th></tr>
      ${c.imports.map(i => `<tr>
        <td>${esc(i.title || '—')}</td><td class="mono">${esc(i.level_id || '')}</td>
        <td><span class="pill ${i.status === 'applied' ? 'ok' : ''}">${esc(i.status)}</span></td>
        <td>${i.raw_length} Zeichen</td><td>${fmtDate(i.created_at)}</td>
        <td style="white-space:nowrap">
          <button class="btn sm grey" data-iload="${esc(i.id)}">laden</button>
          <button class="btn sm danger" data-idel="${esc(i.id)}">löschen</button>
        </td></tr>`).join('') || '<tr><td colspan="6" class="empty">Noch keine Importe</td></tr>'}
    </table></div></div>`;

  const $ = id => document.getElementById(id);

  /* ملفات هالامتحان بالذات، تحت المحرّر مباشرة. الملفات بتخصّ امتحان
     محدّد، فمنطقي تكون معه — مو بتبويب تاني لازم تدوّري فيه على اسمه
     بين كل الامتحانات. بتظهر بس لما الامتحان يكون موجود بالقاعدة. */
  async function loadFiles(){
    const box  = $('i_files');
    if (!box) return;
    const slug = $('i_slug').value.trim().toLowerCase();
    const lvl  = $('i_lvl').value;

    // القسم بيضل ظاهر دايماً. أول نسخة كانت تفرّغه لما ما يكون في اسم،
    // فالمستخدم ما بيشوف ولا إشارة إنه في رفع ملفات أصلاً — وبيسأل وين هو.
    const note = t => { box.innerHTML =
      `<h2>Bilder und Hörtexte</h2><p class="sub">${t}</p>`; };

    if (!slug || !lvl)
      return note('Erst eine Kennung eintragen und den Test veröffentlichen — '
                + 'danach stehen seine Bilder und Hörtexte hier, zum Hochladen.');

    if (!(c.tests || []).some(t => t.slug === slug && t.level_id === lvl))
      return note(`„${esc(slug)}" ist noch nicht veröffentlicht. `
                + 'Nach dem Veröffentlichen erscheinen hier seine Bilder und '
                + 'Hörtexte, zum Hochladen.');

    let rows;
    try {
      rows = (await rpc('admin_assets', { p_level_id: lvl }))
        .filter(r => r.slug === slug);
    } catch (e){
      // النداء بيفشل لو قاعدة البيانات لسا ما انحدّثت. بلا هالفحص
      // بينهار الوعد بصمت والصندوق بيضل فاضي بلا سبب ظاهر.
      return note(isStale(e) ? STALE_MSG : `Fehler: ${esc(e.message)}`);
    }

    if (!rows.length)
      return note(`„${esc(slug)}" braucht weder Bilder noch Hörtexte.`);

    const fehlt = rows.filter(r => !r.uploaded).length;
    box.innerHTML = `
      <h2>Bilder und Hörtexte von „${esc(slug)}"</h2>
      <div class="stats">
        <div class="stat ${fehlt ? 'warn' : 'ok'}"><b>${fehlt}</b><span>fehlen</span></div>
        <div class="stat"><b>${rows.length - fehlt}</b><span>hochgeladen</span></div>
      </div>
      ${assetBlock('Bilder',   rows.filter(r => r.kind === 'image'),
                   'exam-images', IMG_HINT)}
      ${assetBlock('Hörtexte', rows.filter(r => r.kind === 'audio'),
                   'exam-audio',  AUD_HINT)}`;
    wireAssets(box, loadFiles);
  }

  const fill = txt => {
    $('i_text').value = txt; $('i_text').scrollTop = 0;
    runParse(txt);
  };

  wireNewLevel($('i_lvl'), id => { if (id) importLevel = id; screenImport(); });
  wirePicker('i_lvl', c.levels, id => { importLevel = id; loadFiles(); });
  $('i_slug').addEventListener('change', loadFiles);
  if (pendingFiles){ $('i_slug').value = pendingFiles.slug; pendingFiles = null; }
  loadFiles();

  // امتحان جاي للتعديل: الستوفة والاسم لازم يكونوا نفسهن، وإلا الحفظ
  // بيعمل امتحان تاني بدل ما يستبدل هاد.
  if (pendingEdit){
    const { level, slug, text } = pendingEdit;
    pendingEdit = null;
    $('i_slug').value = slug;
    fill(text);
    toast(`„${slug}" geladen — Speichern ersetzt den Test`);
  }
  // المثال معبّى وبيمرق بلا تحذير — بيبيّن الشكل الصح.
  $('i_sample').onclick = () => fill(VORLAGE_BEISPIEL);
  // القالب الفاضي فيه كل الـ٦١ سؤال وكل خاناته <…>. المحلّل بينبّه على
  // كل خانة باقية، فبتعرفي إذا الذكاء الاصطناعي نسي شي قبل النشر.
  $('i_leer').onclick   = () => fill(VORLAGE_LEER);
  $('i_clear').onclick  = () => { $('i_text').value = ''; $('i_result').innerHTML = '';
                                  importState = { id:null, doc:null, raw:'' }; };
  $('i_parse').onclick  = () => runParse($('i_text').value);

  app.querySelectorAll('[data-iload]').forEach(b => b.onclick = async () => {
    const rows = await api(`imports?select=id,level_id,raw_text&id=eq.${b.dataset.iload}`);
    const r = rows[0]; if (!r) return;
    importState.id = r.id;
    $('i_lvl').value = r.level_id || '';
    $('i_text').value = r.raw_text || '';
    runParse(r.raw_text || '');
    $('i_text').scrollIntoView({ behavior:'smooth', block:'center' });
  });
  app.querySelectorAll('[data-idel]').forEach(b => b.onclick = async () => {
    await act(b, () => rpc('admin_delete_import', { p_id: b.dataset.idel }), 'Gelöscht');
    screenImport();
  });
}

/* التحليل + المعاينة. الاعتماد ما بينفتح إلا لما التحليل ينجح. */
function runParse(raw){
  const box = document.getElementById('i_result');
  if (!raw.trim()){ box.innerHTML = ''; return; }

  const { test, warnings, counts } = Markup.parse(raw);
  importState.raw = raw;
  importState.doc = test;

  // ما إله حل = مشكلة تمنع النشر (إلا التعبير الكتابي)
  const fatal = warnings.filter(w =>
    /keine Aufgaben|unbekannten Teil|doppelt|Kein Titel|Keine Teile|kein Format|unbekanntes Format/
      .test(w));
  const ok = fatal.length === 0 && counts.items > 0;

  const preview = test.sections.map(s => `
    <h4>${esc(s.id)} · ${esc(s.format)} · ${s.items.length} Aufgaben
      ${s.pointsPerItem != null ? `· ${s.pointsPerItem} P./Aufgabe` : ''}</h4>
    ${s.items.slice(0, 4).map(it => `<div class="it">
       <b>${esc(it.id)}</b> ${esc(String(it.text || '').slice(0, 90))}
       ${it.answer != null ? `<span class="ans">→ ${esc(it.answer)}</span>`
         : (s.format === 'writing' ? '' : '<span class="no">→ keine Lösung</span>')}
     </div>`).join('')}
    ${s.items.length > 4 ? `<div class="it" style="color:var(--muted)">
       … ${s.items.length - 4} weitere</div>` : ''}`).join('');

  box.innerHTML = `
    <div class="stats" style="margin-top:14px">
      <div class="stat"><b>${counts.blocks}</b><span>Prüfungsteile</span></div>
      <div class="stat"><b>${counts.sections}</b><span>Abschnitte</span></div>
      <div class="stat"><b>${counts.items}</b><span>Aufgaben</span></div>
      <div class="stat ${counts.answers < counts.items - counts.sections ? 'warn' : ''}">
        <b>${counts.answers}</b><span>Lösungen</span></div>
    </div>
    ${warnings.length ? `<ul class="warns ${fatal.length ? 'bad' : ''}">
      ${warnings.slice(0, 12).map(w => `<li>${esc(w)}</li>`).join('')}
      ${warnings.length > 12 ? `<li>… ${warnings.length - 12} weitere</li>` : ''}
    </ul>` : ''}
    <div class="preview">${preview || '<div class="empty">Nichts erkannt</div>'}</div>
    <div class="row" style="margin-top:12px">
      <button class="btn grey" id="i_save">Als Entwurf sichern</button>
      <button class="btn" id="i_apply" ${ok ? '' : 'disabled'}>
        ${ok ? 'Veröffentlichen' : 'Erst Fehler beheben'}</button>
    </div>`;

  document.getElementById('i_save').onclick = e => saveImport(e.target, 'parsed');
  const ap = document.getElementById('i_apply');
  if (ok) ap.onclick = async e => {
    const slug = document.getElementById('i_slug').value.trim().toLowerCase();
    if (!/^[a-z0-9][a-z0-9_-]{0,63}$/.test(slug))
      return toast('Kennung fehlt oder ist ungültig (z. B. modell-a2-01)');
    await saveImport(e.target, 'parsed');
    const r = await act(e.target, () => rpc('admin_apply_import', {
      p_import_id: importState.id,
      p_level_id: document.getElementById('i_lvl').value,
      p_slug: slug, p_publish: true }));
    if (r && r.ok){
      toast(`${r.sections} Abschnitte, ${r.items} Aufgaben, ${r.answers} Lösungen`, 5000);
      importState = { id:null, doc:null, raw:'' };
      // ما منعيد رسم الصفحة كاملة: الامتحان لسا بالمحرّر، وصندوق
      // الملفات لازم يظهر فوراً — هون بالضبط لازم ترفعي الصور والصوت
      pendingFiles = { level: document.getElementById('i_lvl').value, slug };
      screenImport();
    }
  };
}

async function saveImport(btn, status){
  const r = await act(btn, () => rpc('admin_save_import', {
    p_id: importState.id,
    p_level_id: document.getElementById('i_lvl').value || null,
    p_raw: importState.raw, p_parsed: importState.doc, p_status: status }),
    status === 'parsed' ? 'Entwurf gesichert' : null);
  if (r && r.id) importState.id = r.id;
  return r;
}

/* ============ التشغيل ============ */
const TABS = { home: screenHome, users: screenUsers, codes: screenCodes,
               content: screenContent, assets: screenAssets,
               import: screenImport, audit: screenAudit };

async function show(name){
  tab = name;
  nav.querySelectorAll('button').forEach(b =>
    b.classList.toggle('on', b.dataset.tab === name));
  try {
    await TABS[name]();
    // الشريط بينحقن بعد الرسم تا كل شاشة تعرضه بلا ما تتذكّره
    const b = schemaBanner();
    if (b) app.insertAdjacentHTML('afterbegin', b);
  }
  catch (e){
    if (e.message === 'no_session') return screenLogin('Sitzung abgelaufen.');
    app.innerHTML = `<div class="empty">Fehler beim Laden.<br>${esc(e.message)}</div>`;
  }
}

async function start(){
  // Der Guard sitzt in der Datenbank: admin_overview wirft für Nicht-Admins.
  await checkSchema();
  try { await rpc('admin_overview'); }
  catch (e){
    storeSession(null);
    return screenLogin(/privilege|not_admin/i.test(e.message)
      ? 'Dieses Konto ist kein Administrator.' : e.message);
  }
  nav.hidden = false; btnOut.hidden = false;
  show(tab);
}

nav.querySelectorAll('button').forEach(b => b.onclick = () => show(b.dataset.tab));
btnOut.onclick = () => { storeSession(null); screenLogin(); };

if (!BASE || !KEY || BASE.includes('YOUR-PROJECT')){
  app.innerHTML = '<div class="empty">Bitte zuerst <code>assets/config.js</code> ausfüllen.</div>';
} else {
  loadSession();
  session ? start() : screenLogin();
}
