/* ============================================================
   طبقة البيانات — كل ما بيمرق بين التطبيق وSupabase بيمرق من هون.
   التطبيق ما بيعرف شي عن HTTP ولا عن أسماء الجداول.

   نقطتين مهمّتين:
   · مفاتيح الحلول ما بتوصل هون أبداً. التصحيح نداء لـsubmit_attempt
     وبيرجع النتيجة جاهزة مع الحلول — بعد التسليم.
   · الأسئلة بتنعاد تركيبها بنفس شكل modell-XX.json القديم، فبقيّة
     التطبيق ما لازم تتغيّر. الفرق الوحيد: it.id صار uuid وit.num
     صار رقم السؤال المعروض.
   ============================================================ */
'use strict';

const API = (() => {
  const cfg = window.TELC_CONFIG || {};
  const BASE = (cfg.supabaseUrl || '').replace(/\/+$/, '');
  const KEY  = cfg.supabaseAnonKey || '';
  const SESSION_KEY = 'telc.session';
  const DEVICE_KEY  = 'telc.device';

  let session = null;   // { access_token, refresh_token, expires_at, user }

  const configured = () => !!BASE && !!KEY && !BASE.includes('YOUR-PROJECT');

  /* ---------- بصمة الجهاز ----------
     مو للتعريف الأمني — بس تتعرّف الأجهزة عن بعضها تا ينفرض السقف. */
  function deviceId(){
    let d = null;
    try { d = localStorage.getItem(DEVICE_KEY); } catch {}
    if (!d){
      d = (crypto.randomUUID ? crypto.randomUUID()
                             : String(Date.now()) + Math.random().toString(36).slice(2));
      try { localStorage.setItem(DEVICE_KEY, d); } catch {}
    }
    return d;
  }

  /* ---------- الجلسة ---------- */
  function loadSession(){
    try { session = JSON.parse(localStorage.getItem(SESSION_KEY) || 'null'); }
    catch { session = null; }
    return session;
  }
  function storeSession(s){
    session = s;
    try {
      if (s) localStorage.setItem(SESSION_KEY, JSON.stringify(s));
      else   localStorage.removeItem(SESSION_KEY);
    } catch {}
  }
  const expired = () => !session || !session.expires_at
                     || session.expires_at * 1000 < Date.now() + 60000;

  async function auth(path, body){
    const r = await fetch(`${BASE}/auth/v1/${path}`, {
      method: 'POST',
      headers: { apikey: KEY, 'content-type': 'application/json' },
      body: JSON.stringify(body || {})
    });
    const j = await r.json().catch(() => ({}));
    if (!r.ok) throw new Error(j.error_description || j.msg || j.error || `auth ${r.status}`);
    return j;
  }

  async function signInAnonymously(){
    const j = await auth('signup', {});          // مستخدم مجهول: حساب حقيقي بلا إيميل
    storeSession(j);
    return j;
  }
  async function refresh(){
    if (!session || !session.refresh_token) return null;
    try {
      const j = await auth('token?grant_type=refresh_token',
                           { refresh_token: session.refresh_token });
      storeSession(j);
      return j;
    } catch { storeSession(null); return null; }
  }
  async function ensureSession(){
    if (!session) loadSession();
    if (session && expired()) await refresh();
    return session;
  }

  /* ---------- نداءات البيانات ---------- */
  async function rest(path, opts = {}){
    await ensureSession();
    if (!session) throw new Error('no_session');
    const r = await fetch(`${BASE}/rest/v1/${path}`, {
      ...opts,
      headers: {
        apikey: KEY,
        authorization: `Bearer ${session.access_token}`,
        'content-type': 'application/json',
        ...(opts.headers || {})
      }
    });
    if (r.status === 401){                       // التوكن مات بالنص
      await refresh();
      if (!session) throw new Error('no_session');
      return rest(path, opts);
    }
    const j = await r.json().catch(() => null);
    if (!r.ok) throw new Error((j && (j.message || j.hint)) || `rest ${r.status}`);
    return j;
  }
  const rpc = (fn, args) =>
    rest(`rpc/${fn}`, { method: 'POST', body: JSON.stringify(args || {}) });

  /* ---------- الدخول بالكود ---------- */
  async function redeem(code){
    if (!configured()) return { ok: false, error: 'not_configured' };
    await ensureSession();
    if (!session) await signInAnonymously();
    return rpc('redeem_code', {
      p_code: code,
      p_fingerprint: deviceId(),
      p_user_agent: navigator.userAgent.slice(0, 200)
    });
  }

  /* الاشتراك الساري — بيتفحص عند كل إقلاع */
  async function subscription(){
    const rows = await rest(
      'subscriptions?select=levels,status,current_period_end' +
      '&status=eq.active&order=current_period_end.desc&limit=1');
    const s = rows && rows[0];
    if (!s || new Date(s.current_period_end) < new Date()) return null;
    return s;
  }

  /* ---------- المحتوى ---------- */
  async function levels(){
    return rest('levels?select=id,title,sort&order=sort&published=is.true');
  }

  async function index(levelId){
    const rows = await rest(
      `tests?select=id,slug,title,subtitle,blocks,aufgaben,level_id,is_free` +
      `&level_id=eq.${encodeURIComponent(levelId)}&order=sort`);
    return {
      modelle: rows.map(t => ({
        id: t.slug, uuid: t.id, title: t.title, subtitle: t.subtitle,
        blocks: t.blocks || [],
        aufgaben: t.aufgaben || 0,
        minutes: (t.blocks || []).reduce((a, b) => a + (b.minutes || 0), 0)
      }))
    };
  }

  /* امتحان كامل بشكل modell-XX.json القديم — بدون أي حل */
  async function test(slug, levelId){
    const rows = await rest(
      `tests?select=id,slug,title,subtitle,blocks,` +
      `sections(id,section_id,group,title,minutes,instruction,format,config,sort,` +
      `items(id,item_id,text,options,points,meta,sort))` +
      `&slug=eq.${encodeURIComponent(slug)}` +
      `&level_id=eq.${encodeURIComponent(levelId)}&limit=1`);
    const t = rows && rows[0];
    if (!t) return null;

    const sections = (t.sections || [])
      .sort((a, b) => a.sort - b.sort)
      .map(s => {
        const cfg = s.config || {};
        const items = (s.items || []).sort((a, b) => a.sort - b.sort).map(it => ({
          id: it.id,               // uuid — هو مفتاح الإجابة عند التسليم
          num: it.item_id,         // الرقم المعروض للطالب
          text: it.text,
          ...(it.options ? { options: it.options } : {}),
          ...(it.meta || {})       // writing: minWords والنقاط المطلوبة
        }));
        return {
          id: s.section_id, group: s.group, title: s.title,
          minutes: s.minutes, instruction: s.instruction,
          format: s.format, items, ...cfg
        };
      });

    return { id: t.slug, uuid: t.id, title: t.title,
             subtitle: t.subtitle, blocks: t.blocks || [], sections };
  }

  async function resources(levelId){
    const q = levelId ? `&or=(level_id.is.null,level_id.eq.${encodeURIComponent(levelId)})` : '';
    return rest(`resources?select=id,title,kind,body,file_path,level_id&order=sort${q}`);
  }

  /* ---------- الصور ----------
     صور إعلانات Leseverstehen 3 هي محتوى امتحان متل الأسئلة، فبتنحفظ بدلو
     Storage خاص وبتنجاب برابط موقّع بينتهي. ما بينفع تكون عامة. */
  const BUCKET = 'exam-images';
  const signCache = new Map();

  async function imageUrl(path){
    if (!path) return null;
    if (path.startsWith('data:') || path.startsWith('http')) return path;
    const hit = signCache.get(path);
    if (hit && hit.until > Date.now()) return hit.url;

    await ensureSession();
    if (!session) return null;
    const r = await fetch(`${BASE}/storage/v1/object/sign/${BUCKET}/${path}`, {
      method: 'POST',
      headers: { apikey: KEY, authorization: `Bearer ${session.access_token}`,
                 'content-type': 'application/json' },
      body: JSON.stringify({ expiresIn: 3600 })
    });
    if (!r.ok) return null;
    const j = await r.json().catch(() => null);
    if (!j || !j.signedURL) return null;
    const url = BASE + '/storage/v1' + j.signedURL.replace(/^\/?(storage\/v1)?/, '/');
    signCache.set(path, { url, until: Date.now() + 3000000 });   // أقصر من الصلاحية
    return url;
  }

  /* ---------- التصحيح ---------- */
  const submitAttempt = (testUuid, blockId, answers) =>
    rpc('submit_attempt', { p_test_id: testUuid, p_block_id: blockId, p_answers: answers });

  const submitDrill = answers => rpc('submit_drill', { p_answers: answers });

  /* أسئلة أخطأ فيها سابقاً، مع سياق قسمها — بدونه ما بتنحلّ */
  async function mistakes(){
    return rest(
      'mistakes?select=item_id,wrong_count,' +
      'items(id,item_id,text,options,points,meta,' +
      'sections(section_id,title,format,config,test_id,tests(slug,title)))' +
      '&order=last_seen_at.desc&limit=200');
  }

  async function attempts(testUuid){
    return rest(`attempts?select=id,block_id,points,max_points,pct,answers,submitted_at` +
                `&test_id=eq.${encodeURIComponent(testUuid)}` +
                `&order=submitted_at.desc`);
  }

  return { configured, deviceId, loadSession, ensureSession, signInAnonymously,
           redeem, subscription, levels, index, test, resources, imageUrl,
           submitAttempt, submitDrill, mistakes, attempts,
           signOut: () => storeSession(null),
           hasSession: () => !!session };
})();
