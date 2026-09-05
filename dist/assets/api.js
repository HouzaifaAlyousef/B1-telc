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

  /* الاشتراكات السارية — بيتفحصوا عند كل إقلاع.
     كل كود بيعمل اشتراك لمستواه، فالطالب يلي اشترى A1 وبعدين B1 بيصير
     عنده اتنين. لازم نجمعهن كلهن: جلب واحد بس كان بيخفي المستوى التاني
     عن الواجهة رغم إن قاعدة البيانات بتسمح فيه. */
  async function subscription(){
    const rows = await rest(
      'subscriptions?select=levels,status,current_period_end' +
      '&status=eq.active&order=current_period_end.desc');
    const now = Date.now();
    const live = (rows || []).filter(s => new Date(s.current_period_end).getTime() > now);
    if (!live.length) return null;

    // متى بينتهي كل مستوى — تا نقدر نقول «A1 باقيله ٣ أيام»
    const until = {};
    live.forEach(s => (s.levels || []).forEach(l => {
      if (!until[l] || new Date(s.current_period_end) > new Date(until[l]))
        until[l] = s.current_period_end;
    }));
    return {
      levels: Object.keys(until),
      until,
      status: 'active',
      current_period_end: live[0].current_period_end   // الأبعد
    };
  }

  /* ---------- المحتوى ---------- */
  async function levels(){
    return rest('levels?select=id,title,sort&order=sort&published=is.true');
  }

  /* المستويات يلي اشتراكه بيغطّيها فعلاً، مرتّبة ومسمّاة */
  async function myLevels(sub){
    if (!sub || !sub.levels || !sub.levels.length) return [];
    const all = await levels();
    const mine = all.filter(l => sub.levels.includes(l.id));
    // مستوى بالاشتراك بس مو منشور بعد: منعرضه باسمه الخام
    sub.levels.forEach(id => {
      if (!mine.some(l => l.id === id)) mine.push({ id, title: id.toUpperCase() });
    });
    return mine;
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
  const signCache = new Map();

  async function signed(bucket, path){
    if (!path) return null;
    if (path.startsWith('data:') || path.startsWith('http')) return path;
    const ck = bucket + '/' + path;
    const hit = signCache.get(ck);
    if (hit && hit.until > Date.now()) return hit.url;

    await ensureSession();
    if (!session) return null;
    const r = await fetch(`${BASE}/storage/v1/object/sign/${bucket}/${path}`, {
      method: 'POST',
      headers: { apikey: KEY, authorization: `Bearer ${session.access_token}`,
                 'content-type': 'application/json' },
      body: JSON.stringify({ expiresIn: 3600 })
    });
    if (!r.ok) return null;
    const j = await r.json().catch(() => null);
    if (!j || !j.signedURL) return null;
    const url = BASE + '/storage/v1' + j.signedURL.replace(/^\/?(storage\/v1)?/, '/');
    signCache.set(ck, { url, until: Date.now() + 3000000 });   // أقصر من الصلاحية
    return url;
  }

  const imageUrl = p => signed('exam-images', p);
  /* الصوت متل الصور: محتوى امتحان، دلو خاص، رابط موقّع بينتهي */
  const audioUrl = p => signed('exam-audio', p);

  /* ---------- تصحيح التعبير الكتابي ----------
     نداء لـEdge Function، مو لقاعدة البيانات: هي يلي بتحكي مع Claude
     وبتحمل المفتاح. بتاخد وقت (نصف دقيقة أحياناً). */
  async function correctWriting(attemptId){
    await ensureSession();
    if (!session) throw new Error('no_session');
    const r = await fetch(`${BASE}/functions/v1/correct-writing`, {
      method: 'POST',
      headers: { apikey: KEY, authorization: `Bearer ${session.access_token}`,
                 'content-type': 'application/json' },
      body: JSON.stringify({ attempt_id: attemptId })
    });
    return r.json().catch(() => ({ ok: false, error: 'bad_response' }));
  }

  /* تصحيح سابق لنفس المحاولة — تا ما ندفع مرتين على نفس النص */
  async function writingFeedback(attemptId){
    const rows = await rest(
      'writing_feedback?select=id,status,points,max_points,grades,errors,' +
      'summary,corrected,word_count,created_at' +
      `&attempt_id=eq.${encodeURIComponent(attemptId)}` +
      '&status=eq.done&order=created_at.desc&limit=1');
    return rows && rows[0] || null;
  }

  /* ---------- التصحيح ---------- */
  const submitAttempt = (testUuid, blockId, answers) =>
    rpc('submit_attempt', { p_test_id: testUuid, p_block_id: blockId, p_answers: answers });

  const submitDrill = answers => rpc('submit_drill', { p_answers: answers });

  /* أسئلة مستحقّة للمراجعة اليوم، مع سياق قسمها — بدونه ما بتنحلّ.
     المتقن (صندوق > ٥) وغير المستحقّ ما بينجابوا. */
  async function mistakes(){
    const now = new Date().toISOString();
    return rest(
      'mistakes?select=item_id,wrong_count,box,due_at,' +
      'items(id,item_id,text,options,points,meta,' +
      'sections(section_id,title,format,config,test_id,tests(slug,title)))' +
      `&due_at=lte.${encodeURIComponent(now)}&box=lte.5` +
      '&order=due_at.asc&limit=60');
  }

  /* أرقام المراجعة للشاشة الرئيسية — نداء واحد بدل جلب كل الصفوف */
  const reviewSummary = () => rpc('review_summary');

  async function attempts(testUuid){
    return rest(`attempts?select=id,block_id,points,max_points,pct,answers,submitted_at` +
                `&test_id=eq.${encodeURIComponent(testUuid)}` +
                `&order=submitted_at.desc`);
  }

  return { configured, deviceId, loadSession, ensureSession, signInAnonymously,
           redeem, subscription, levels, myLevels, index, test, resources, imageUrl, audioUrl,
           submitAttempt, submitDrill, mistakes, reviewSummary, attempts,
           correctWriting, writingFeedback,
           signOut: () => storeSession(null),
           hasSession: () => !!session };
})();
