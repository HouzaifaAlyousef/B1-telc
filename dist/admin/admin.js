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


/* ============ الإنشاء: مستويات، امتحانات، مراجع ============ */
let contentCache = null;

async function screenContent(){
  app.innerHTML = '<div class="empty">Lädt …</div>';
  const c = contentCache = await rpc('admin_content');

  const lvlRow = l => `<tr>
    <td class="mono">${esc(l.id)}</td>
    <td>${esc(l.title)}</td>
    <td>${l.tests}</td>
    <td><span class="pill ${l.published ? 'ok' : ''}">${l.published ? 'online' : 'versteckt'}</span></td>
    <td><button class="btn sm grey" data-lvl="${esc(l.id)}"
          data-pub="${l.published ? 0 : 1}" data-title="${esc(l.title)}"
          data-sort="${l.sort}">${l.published ? 'verstecken' : 'online stellen'}</button></td>
  </tr>`;

  const testRow = t => `<tr>
    <td class="mono">${esc(t.level_id)}</td>
    <td><b>${esc(t.title)}</b>
      <div class="mono" style="color:var(--muted);font-size:12px">${esc(t.slug)}</div></td>
    <td>${t.sections} / ${t.aufgaben}</td>
    <td>${t.answers}</td>
    <td><span class="pill ${t.published ? 'ok' : ''}">${t.published ? 'online' : 'Entwurf'}</span></td>
    <td style="white-space:nowrap">
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
    <p class="sub">Stufen, Modelltests und Lesematerial.</p>

    <h2>Stufen</h2>
    <div class="card">
      <div class="row">
        <label>Kennung<input id="l_id" placeholder="a2" maxlength="16"></label>
        <label style="flex:2">Titel<input id="l_title" placeholder="telc Deutsch A2"></label>
        <label>Reihenfolge<input id="l_sort" type="number" value="0"></label>
        <button class="btn" id="l_go">Anlegen / ändern</button>
      </div>
      <div class="wrap" style="margin-top:12px"><table>
        <tr><th>Kennung</th><th>Titel</th><th>Tests</th><th>Status</th><th></th></tr>
        ${c.levels.map(lvlRow).join('')}
      </table></div>
    </div>

    <h2>Modelltests</h2>
    <div class="card"><div class="wrap"><table>
      <tr><th>Stufe</th><th>Test</th><th>Teile / Aufg.</th><th>Lösungen</th><th>Status</th><th></th></tr>
      ${c.tests.map(testRow).join('') || '<tr><td colspan="6" class="empty">Noch keine Tests</td></tr>'}
    </table></div></div>

    <h2>Lesematerial</h2>
    <p class="sub">Texte, die im Kurs jederzeit lesbar sind — kein Test, keine Zeit.</p>
    <div class="card">
      <div class="row">
        <label>Stufe<select id="r_lvl">
          <option value="">alle Stufen</option>
          ${c.levels.map(l => `<option value="${esc(l.id)}">${esc(l.title)}</option>`).join('')}
        </select></label>
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

  $('l_go').onclick = async e => {
    const id = $('l_id').value.trim().toLowerCase();
    if (!/^[a-z][a-z0-9_]{0,15}$/.test(id))
      return toast('Kennung: Kleinbuchstaben, z. B. a2');
    await act(e.target, () => rpc('admin_upsert_level', {
      p_id: id, p_title: $('l_title').value.trim() || id.toUpperCase(),
      p_sort: Number($('l_sort').value) || 0, p_published: false }), 'Stufe gespeichert');
    screenContent();
  };
  app.querySelectorAll('[data-lvl]').forEach(b => b.onclick = async () => {
    await act(b, () => rpc('admin_upsert_level', {
      p_id: b.dataset.lvl, p_title: b.dataset.title,
      p_sort: Number(b.dataset.sort), p_published: b.dataset.pub === '1' }), 'Gespeichert');
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

/* ============ الاستيراد ============ */
const SAMPLE = `# PETRA
Untertitel: 61 Aufgaben · 150 Minuten

## Block: block-lv
Titel: Leseverstehen
Minuten: 45
Teile: lv1

### Teil: lv1
Format: matching
Titel: Leseverstehen, Teil 1
Gruppe: Leseverstehen
Punkte: 5
Maximum: 25
Anweisung: Lesen Sie die Texte und die Überschriften.
Auswahl:
A = Bildband: Babys im Garten
B = Ratgeber für junge Eltern
Aufgaben:
[1] Ich möchte, dass Menschen die Welt mit anderen Augen sehen.
Lösung: A
[2] Ein Buch für alle, die gerade Eltern geworden sind.
Lösung: B`;

let importState = { id: null, doc: null, raw: '' };

async function screenImport(){
  app.innerHTML = '<div class="empty">Lädt …</div>';
  const c = contentCache = await rpc('admin_content');

  app.innerHTML = `
    <h1>Import</h1>
    <p class="sub">Prüfungstext einfügen, prüfen, dann veröffentlichen.
      Nichts geht online, bevor Sie die Vorschau gesehen haben.</p>

    <div class="card">
      <div class="row">
        <label>Stufe<select id="i_lvl">
          ${c.levels.map(l => `<option value="${esc(l.id)}">${esc(l.title)}</option>`).join('')
            || '<option value="">— zuerst eine Stufe anlegen —</option>'}
        </select></label>
        <label style="flex:2">Kennung des Tests
          <input id="i_slug" placeholder="modell-a2-01"></label>
        <button class="btn grey" id="i_sample">Beispiel einfügen</button>
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
        </p>
      </details>
    </div>

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
  $('i_sample').onclick = () => { $('i_text').value = SAMPLE; $('i_parse').click(); };
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
  const fatal = warnings.filter(w => /keine Aufgaben|unbekannten Teil|doppelt|Kein Titel|Keine Teile/.test(w));
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
               content: screenContent, import: screenImport, audit: screenAudit };

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
