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
  const o = await rpc('admin_overview');
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
    <h2>Stufen</h2>
    <div class="card"><div class="wrap"><table>
      <tr><th>Stufe</th><th>Titel</th><th>Status</th></tr>
      ${(o.levels || []).map(l => `<tr>
        <td class="mono">${esc(l.id)}</td><td>${esc(l.title)}</td>
        <td><span class="pill ${l.published ? 'ok' : ''}">${l.published ? 'online' : 'versteckt'}</span></td>
      </tr>`).join('') || '<tr><td colspan="3" class="empty">Keine Stufen</td></tr>'}
    </table></div></div>`;
}

let userSearch = '';
async function screenUsers(){
  app.innerHTML = '<div class="empty">Lädt …</div>';
  const rows = await rpc('admin_users', { p_search: userSearch || null });

  const line = u => {
    const s = u.sub;
    const live = s && s.status === 'active' && new Date(s.current_period_end) > new Date();
    const cls  = !s ? '' : live ? (s.days_left <= 7 ? 'warn' : 'ok') : 'bad';
    const txt  = !s ? 'kein Abo'
               : live ? `${s.days_left} Tage` : (s.status === 'revoked' ? 'gesperrt' : 'abgelaufen');
    return `<tr data-u="${esc(u.id)}">
      <td>
        <b>${esc(u.name || 'ohne Namen')}</b>
        ${u.note ? `<div style="color:var(--muted);font-size:13px">${esc(u.note)}</div>` : ''}
        ${u.code ? `<div class="mono" style="color:var(--muted);font-size:12px">${esc(u.code)}</div>` : ''}
      </td>
      <td><span class="pill ${cls}">${esc(txt)}</span>
        ${s ? `<div style="color:var(--muted);font-size:12px;margin-top:3px">
                bis ${fmtDate(s.current_period_end)}</div>` : ''}</td>
      <td>${esc((s && s.levels || []).join(', ') || '—')}</td>
      <td>${u.devices}</td>
      <td>${u.attempts}${u.best_pct != null ? ` · best ${u.best_pct}%` : ''}</td>
      <td>${fmtDate(u.last_seen_at || u.created_at)}</td>
      <td style="white-space:nowrap">
        ${s ? `<button class="btn sm grey" data-shift="30"  data-sub="${esc(s.id)}">+30</button>
               <button class="btn sm grey" data-shift="-30" data-sub="${esc(s.id)}">−30</button>` : ''}
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
  const s = u.sub;
  const back = document.createElement('div');
  back.style.cssText = 'position:fixed;inset:0;background:rgba(0,0,0,.45);' +
    'display:flex;align-items:center;justify-content:center;padding:16px;z-index:40';
  back.innerHTML = `
    <div class="card" style="max-width:460px;width:100%;margin:0;max-height:90vh;overflow:auto">
      <h2 style="margin-top:0">${esc(u.name || 'Nutzer ohne Namen')}</h2>
      <p class="sub" style="margin-bottom:12px">
        ${u.attempts} Prüfungen · ${u.mistakes} offene Fehler · ${u.devices} Geräte<br>
        angelegt ${fmtDate(u.created_at)}${u.code ? ` · Code <span class="mono">${esc(u.code)}</span>` : ''}
      </p>

      <label style="font-size:13px;color:var(--muted)">Name
        <input id="d_name" value="${esc(u.name || '')}" style="margin-top:4px"></label>
      <label style="font-size:13px;color:var(--muted);display:block;margin-top:8px">Notiz
        <input id="d_note" value="${esc(u.note || '')}"
               placeholder="z. B. WhatsApp-Nummer, bezahlt am …" style="margin-top:4px"></label>
      <button class="btn sm" id="d_save" style="margin-top:10px">Speichern</button>

      ${s ? `
      <h2>Abo</h2>
      <p class="sub" style="margin-bottom:8px">
        ${esc(s.status)} · läuft bis ${fmtDate(s.current_period_end)}</p>
      <div class="row">
        <label>Enddatum
          <input id="d_end" type="date"
                 value="${new Date(s.current_period_end).toISOString().slice(0,10)}"></label>
        <button class="btn sm" id="d_end_go">Setzen</button>
      </div>
      <div class="row" style="margin-top:10px">
        <button class="btn sm grey" data-d="7">+7</button>
        <button class="btn sm grey" data-d="30">+30</button>
        <button class="btn sm grey" data-d="90">+90</button>
        <button class="btn sm grey" data-d="-7">−7</button>
        <button class="btn sm grey" data-d="-30">−30</button>
      </div>
      <div class="row" style="margin-top:10px">
        ${s.status === 'active'
          ? '<button class="btn sm danger" id="d_rev">Abo sperren</button>'
          : '<button class="btn sm" id="d_act">Abo entsperren</button>'}
      </div>` : '<h2>Abo</h2><p class="sub">Kein Abo vorhanden.</p>'}

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

  if (s){
    back.querySelectorAll('[data-d]').forEach(b => b.onclick = () =>
      act(b, () => rpc('admin_shift_subscription',
        { p_sub_id: s.id, p_days: Number(b.dataset.d) }), 'Abo angepasst').then(close));
    $('d_end_go').onclick = e => act(e.target, () => rpc('admin_set_period_end',
      { p_sub_id: s.id, p_end: new Date($('d_end').value + 'T12:00:00Z').toISOString() }),
      'Enddatum gesetzt').then(close);
    const rev = $('d_rev'), ac = $('d_act');
    if (rev) rev.onclick = e => act(e.target, () => rpc('admin_set_subscription_status',
      { p_sub_id: s.id, p_status: 'revoked' }), 'Abo gesperrt').then(close);
    if (ac) ac.onclick = e => act(e.target, () => rpc('admin_set_subscription_status',
      { p_sub_id: s.id, p_status: 'active' }), 'Abo entsperrt').then(close);
  }
}

async function screenCodes(){
  app.innerHTML = '<div class="empty">Lädt …</div>';
  const [codes, levels] = await Promise.all([
    api('access_codes?select=id,code,levels,duration_days,max_devices,note,' +
        'created_at,redeemed_at,revoked_at&order=created_at.desc&limit=200'),
    api('levels?select=id,title&order=sort')
  ]);

  const state = c => c.revoked_at ? ['bad', 'gesperrt']
                   : c.redeemed_at ? ['', 'eingelöst']
                   : ['ok', 'frei'];
  app.innerHTML = `
    <h1>Zugangscodes</h1>
    <p class="sub">Erzeugen, ausdrucken, weitergeben. Ein Code wird einmal
      eingelöst und bindet sich dann an dieses Konto.</p>

    <div class="card">
      <div class="row">
        <label>Anzahl<input id="c_n" type="number" value="5" min="1" max="200"></label>
        <label>Stufe<select id="c_lvl">
          ${levels.map(l => `<option value="${esc(l.id)}">${esc(l.title)}</option>`).join('')}
        </select></label>
        <label>Tage<select id="c_days">
          <option value="30" selected>30</option><option value="90">90</option>
          <option value="180">180</option><option value="365">365</option>
        </select></label>
        <label>Geräte<input id="c_dev" type="number" value="2" min="1" max="10"></label>
        <label style="flex:2">Notiz<input id="c_note" placeholder="z. B. Kurs März"></label>
        <button class="btn" id="c_go">Erzeugen</button>
      </div>
      <div id="c_out"></div>
    </div>

    <div class="card"><div class="wrap"><table>
      <tr><th>Code</th><th>Status</th><th>Stufen</th><th>Tage</th>
          <th>Geräte</th><th>Notiz</th><th>erstellt</th><th></th></tr>
      ${codes.map(c => { const [cls, txt] = state(c); return `<tr>
        <td class="mono"><b>${esc(c.code)}</b></td>
        <td><span class="pill ${cls}">${txt}</span></td>
        <td>${esc((c.levels || []).join(', '))}</td>
        <td>${c.duration_days}</td><td>${c.max_devices}</td>
        <td>${esc(c.note || '—')}</td><td>${fmtDate(c.created_at)}</td>
        <td>${!c.revoked_at && !c.redeemed_at
              ? `<button class="btn sm danger" data-rev="${esc(c.id)}">sperren</button>` : ''}</td>
      </tr>`; }).join('') || '<tr><td colspan="8" class="empty">Noch keine Codes</td></tr>'}
    </table></div></div>`;

  document.getElementById('c_go').onclick = async e => {
    const made = await act(e.target, () => rpc('admin_create_codes', {
      p_count: Number(document.getElementById('c_n').value),
      p_levels: [document.getElementById('c_lvl').value],
      p_days: Number(document.getElementById('c_days').value),
      p_max_devices: Number(document.getElementById('c_dev').value),
      p_note: document.getElementById('c_note').value.trim() || null
    }), 'Codes erzeugt');
    if (!made) return;
    document.getElementById('c_out').innerHTML =
      `<h2>Neu erzeugt</h2><div class="codes">
         ${made.map(c => `<div class="mono">${esc(c)}</div>`).join('')}</div>
       <button class="btn sm grey" id="c_copy" style="margin-top:10px">Kopieren</button>`;
    document.getElementById('c_copy').onclick = () => {
      navigator.clipboard?.writeText(made.join('\n'))
        .then(() => toast('Kopiert')).catch(() => toast('Kopieren nicht möglich'));
    };
  };
  app.querySelectorAll('[data-rev]').forEach(b => b.onclick = async () => {
    await act(b, () => rpc('admin_revoke_code', { p_code_id: b.dataset.rev }), 'Code gesperrt');
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

/* ============ التشغيل ============ */
const TABS = { home: screenHome, users: screenUsers, codes: screenCodes, audit: screenAudit };

async function show(name){
  tab = name;
  nav.querySelectorAll('button').forEach(b =>
    b.classList.toggle('on', b.dataset.tab === name));
  try { await TABS[name](); }
  catch (e){
    if (e.message === 'no_session') return screenLogin('Sitzung abgelaufen.');
    app.innerHTML = `<div class="empty">Fehler beim Laden.<br>${esc(e.message)}</div>`;
  }
}

async function start(){
  // Der Guard sitzt in der Datenbank: admin_overview wirft für Nicht-Admins.
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
