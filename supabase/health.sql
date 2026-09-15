-- ═══════════════════════════════════════════════════════════════════
--  فحص جاهزية النشر — للقراءة فقط، ما بيغيّر ولا صفّ.
--  الصقه كامل بـSupabase → SQL Editor واضغط Run.
--
--  ★ محصّن: كل استعلام على شي ممكن يكون ناقص بينفّذ بـEXECUTE جوّا
--    معالج أخطاء. فحص بيموت على المشكلة يلي المفروض يشخّصها بلا فايدة.
--
--  ★ شو ما بيقدر يشوفه: نشر الـEdge Functions، والأسرار، وتسجيل
--    الدخول المجهول. هدول بلوحة سوپابيس مو بالقاعدة — مذكورين بآخر
--    الجدول لتتفقّدهن بالإيد.
-- ═══════════════════════════════════════════════════════════════════
drop table if exists _health;
create temp table _health (ord int, s text, k text, d text);

do $health$
declare v int; t text; n int; m int; k int; begin

  -- ١) نسخة السكيما
  begin
    execute 'select schema_version()' into v;
    insert into _health values (1, case when v >= 30 then '✅' else '❌' end,
      'نسخة السكيما', 'عندك ' || v || ' · لازم 30'
      || case when v < 30 then '  ←  شغّل supabase/setup.sql' else '' end);
  exception when others then
    insert into _health values (1, '❌', 'نسخة السكيما',
      'الدالة مفقودة  ←  شغّل supabase/setup.sql');
  end;

  -- ٢) دوال البوت كلها
  select count(*) into n from pg_proc p join pg_namespace ns on ns.oid = p.pronamespace
   where ns.nspname = 'public' and p.proname in
     ('bot_levels','bot_demo_code','bot_request_access','bot_decide_request',
      'bot_reserve_request','bot_sweep_reservations','bot_my_codes',
      'bot_untried_levels','bot_sweep_expiring','bot_is_admin','bot_set_card');
  insert into _health values (2, case when n = 11 then '✅' else '❌' end,
    'دوال البوت', n || ' من 11'
    || case when n < 11 then '  ←  شغّل supabase/setup.sql' else '' end);

  -- ٣) جداول البوت
  select count(*) into n from (values
    ('telegram_users'),('telegram_demos'),('access_requests'),('bot_admins')) x(t)
   where to_regclass('public.' || x.t) is not null;
  insert into _health values (3, case when n = 4 then '✅' else '❌' end,
    'جداول البوت', n || ' من 4'
    || case when n < 4 then '  ←  شغّل supabase/setup.sql' else '' end);

  -- ٤) مين بيوافق على طلبات الوصول
  if to_regclass('public.bot_admins') is null then
    insert into _health values (4, '❌', 'صلاحية الموافقة', 'الجدول مفقود');
  else
    execute 'select count(*) from bot_admins' into n;
    insert into _health values (4, case when n > 0 then '✅' else '⚠️' end,
      'صلاحية الموافقة',
      case when n = 0
        then 'ما في ولا مسجّل  ←  بلاه ما حدا بيقدر يوافق على طلب'
        else n || ' مسجّل' end);
  end if;

  -- ٥) شو البوت رح يعرض
  if to_regclass('public.levels') is null then
    insert into _health values (5, '❌', 'مستويات البوت', 'الجداول مفقودة');
  else
    execute $q$ select string_agg(l.id, ', ' order by l.id) from levels l
                 where l.published and exists (select 1 from tests t
                        where t.level_id = l.id and t.published) $q$ into t;
    insert into _health values (5, case when t is null then '❌' else '✅' end,
      'مستويات البوت',
      coalesce(t, 'ولا واحد  ←  البوت رح يقول «ما في امتحانات»'));
  end if;

  -- ٦) المحتوى
  if to_regclass('public.tests') is null then
    insert into _health values (6, '❌', 'المحتوى', 'مفقود');
  else
    execute 'select count(*) from tests where published' into n;
    execute $q$ select (select count(*) from items) $q$ into m;
    insert into _health values (6, case when n > 0 then '✅' else '❌' end,
      'المحتوى', n || ' امتحان منشور · ' || m || ' سؤال'
      || case when n = 0 then '  ←  شغّل ملفات supabase/seed/' else '' end);
  end if;

  -- ٧) ★ الصور: المطلوب مقابل المرفوع فعلاً على Storage
  if to_regclass('storage.objects') is null or to_regclass('public.sections') is null then
    insert into _health values (7, '⚠️', 'الصور', 'ما بقدر أفحص (storage مفقود)');
  else
    execute $q$
      select count(*) filter (where o.name is null), count(*)
        from (select distinct s.config->>'bankImage' img from sections s
               where s.config ? 'bankImage') w
        left join storage.objects o
               on o.bucket_id = 'exam-images' and o.name = w.img $q$ into m, n;
    insert into _health values (7,
      case when n = 0 then '✅' when m = 0 then '✅' else '❌' end, 'الصور',
      case when n = 0 then 'ما في امتحان بيطلب صور'
           when m = 0 then (n - m) || ' من ' || n || ' مرفوعة'
           else m || ' من ' || n || ' **ناقصة**  ←  '
                || 'python3 tools/upload_images.py content' end);
  end if;

  -- ٨) ★ الصوت: نفس الفكرة
  if to_regclass('storage.objects') is null then
    insert into _health values (8, '⚠️', 'الصوت', 'ما بقدر أفحص');
  else
    -- ★ رابط خارجي (http) مو ملفّ عنا: التطبيق بيمرّره كما هو
    --   (assets/api.js — signed()) وما إله وجود بالدلو، فعدّه «ناقص»
    --   بيقول كذب. منعدّه لحاله: هو حلّ مؤقّت للتجربة، مو جاهزية.
    execute $q$ select count(*) from (select distinct s.config->>'audio' a
      from sections s where s.config->>'audio' ~* '^https?://') x $q$ into k;
    execute $q$
      select count(*) filter (where o.name is null), count(*)
        from (select distinct s.config->>'audio' aud from sections s
               where s.config ? 'audio'
                 and s.config->>'audio' !~* '^https?://') w
        left join storage.objects o
               on o.bucket_id = 'exam-audio' and o.name = w.aud $q$ into m, n;
    insert into _health values (8,
      case when n = 0 and k = 0 then '⚠️' when m = 0 then '✅' else '❌' end,
      'الصوت',
      case when n = 0 and k = 0 then 'ما في قسم بيطلب صوت  ←  Hörverstehen معطّل'
           when n = 0 then k || ' قسم على روابط خارجية (للتجربة) · ولا ملف مرفوع'
           when m = 0 then n || ' مرفوعة'
           else m || ' من ' || n || ' ناقصة  ←  tools/upload_audio.py' end
      || case when k > 0 and n > 0 then ' · و' || k || ' على روابط خارجية' else '' end);
  end if;

  -- ٩) حساب أدمن
  if to_regclass('public.profiles') is null then
    insert into _health values (9, '❌', 'حساب أدمن', 'مفقود');
  else
    execute 'select count(*) from profiles where is_admin' into n;
    insert into _health values (9, case when n > 0 then '✅' else '⚠️' end,
      'حساب أدمن', n || ' أدمن' || case when n = 0
        then '  ←  بلا أدمن ما فيك تفوت اللوحة' else '' end);
  end if;

  -- ١٠) قائمة الانتظار — صفر معناها بلا حدّ
  if to_regclass('public.app_limits') is null then
    insert into _health values (10, '❌', 'قائمة الانتظار', 'مفقودة');
  else
    execute $q$ select case when (j->>'max_active')::int = 0
                             and (j->>'max_new_per_day')::int = 0
              then 'مطفيّة (بلا حدّ)'
              else 'شغّالة: ' || (j->>'active') || '/' || (j->>'max_active')
                   || ' فعّال · اليوم ' || (j->>'today') || '/'
                   || (j->>'max_new_per_day') || ' · ' || (j->>'waiting')
                   || ' بالطابور' end from (select capacity() j) x $q$ into t;
    insert into _health values (10,
      case when t like 'مطفيّة%' then '✅' else '⚠️' end, 'قائمة الانتظار', t);
  end if;

  -- ١١) ★ التصحيح الآلي: الجدول بيقول إذا اشتغل فعلاً
  if to_regclass('public.writing_feedback') is null then
    insert into _health values (11, '❌', 'التصحيح الآلي', 'الجدول مفقود');
  else
    execute $q$ select count(*) filter (where status = 'done'), count(*)
                  from writing_feedback $q$ into m, n;
    insert into _health values (11, case when m > 0 then '✅' else '⚠️' end,
      'التصحيح الآلي',
      case when m > 0 then m || ' تصحيح تمّ (الدالة شغّالة)'
           when n > 0 then n || ' محاولة وولا وحدة نجحت  ←  فحص GEMINI_API_KEY'
           else 'ما انجرّب بعد  ←  جرّب زرّ Korrektur anfordern' end);
  end if;

  -- ١٢) استعمال البوت
  if to_regclass('public.telegram_demos') is null then
    insert into _health values (12, '⚠️', 'استعمال البوت', 'الجدول مفقود');
  else
    execute 'select count(*) from telegram_demos' into n;
    execute $q$ select count(*) from access_requests where status = 'pending' $q$ into m;
    insert into _health values (12, '✅', 'استعمال البوت',
      n || ' تجريبي انوزّع'
      || case when m > 0 then ' · ⏳ ' || m || ' طلب معلّق مستنّي قرارك' else '' end);
  end if;

  -- ١٣) تبليغات المستخدمين
  -- مو فحص جاهزية: هي بريد وارد. الرقم هون تا تعرف إنّ في شي مستنّيك،
  -- ومطرحه اللوحة ← Meldungen.
  if to_regclass('public.reports') is null then
    insert into _health values (13, '❌', 'تبليغات المستخدمين',
      'الجدول مفقود  ←  شغّل supabase/setup.sql');
  else
    execute $q$ select count(*) filter (where status = 'new'), count(*)
                  from reports $q$ into m, n;
    insert into _health values (13, case when m > 0 then '⏳' else '✅' end,
      'تبليغات المستخدمين',
      case when m > 0 then m || ' تبليغ مفتوح من ' || n || '  ←  اللوحة ← Meldungen'
           when n > 0 then n || ' تبليغ، كلهن معالَجين'
           else 'ولا تبليغ لهلق' end);
  end if;

exception when others then
  insert into _health values (99, '❌', 'الفحص نفسه وقع', SQLERRM);
end $health$;

-- شغلات ما بتنقرا من القاعدة — تفقّدهن بلوحة سوپابيس
insert into _health values
  (90, '👁', 'نشر telegram',        'Edge Functions ← لازم تكون منشورة، Verify JWT **مطفيّة**'),
  (91, '👁', 'نشر correct-writing', 'Edge Functions ← Verify JWT **مفعّلة** (عكس البوت)'),
  (92, '👁', 'الأسرار',             'TELEGRAM_BOT_TOKEN · TELEGRAM_WEBHOOK_SECRET · APP_URL · ADMIN_CHAT_ID · GEMINI_API_KEY'),
  (93, '👁', 'الدخول المجهول',      'Authentication ← Providers ← Allow anonymous sign-ins');

select s as " ", k as "الفحص", d as "التفصيل" from _health order by ord;
