-- ═══════════════════════════════════════════════════════════════════
--  فحص جاهزية النشر — للقراءة فقط، ما بيغيّر ولا صفّ.
--  الصقه كامل بـSupabase → SQL Editor واضغط Run.
--
--  ★ محصّن: كل استعلام على شي ممكن يكون ناقص بينفّذ بـEXECUTE جوّا
--    معالج أخطاء. فحص بيموت على المشكلة يلي المفروض يشخّصها بلا فايدة.
-- ═══════════════════════════════════════════════════════════════════
drop table if exists _health;
create temp table _health (ord int, s text, k text, d text);

do $health$
declare v int; t text; n int; begin

  -- ١) نسخة السكيما
  begin
    execute 'select schema_version()' into v;
    insert into _health values (1, case when v >= 23 then '✅' else '❌' end,
      'نسخة السكيما', 'عندك ' || v || ' · لازم 23'
      || case when v < 23 then '  ←  شغّل supabase/setup.sql' else '' end);
  exception when others then
    insert into _health values (1, '❌', 'نسخة السكيما',
      'الدالة مفقودة  ←  شغّل supabase/setup.sql');
  end;

  -- ٢) دوال البوت
  select count(*) into n from pg_proc p join pg_namespace ns on ns.oid = p.pronamespace
   where ns.nspname = 'public' and p.proname in ('bot_levels','bot_demo_code');
  insert into _health values (2, case when n = 2 then '✅' else '❌' end,
    'دوال البوت', n || ' من 2 (bot_levels, bot_demo_code)'
    || case when n < 2 then '  ←  شغّل supabase/setup.sql' else '' end);

  -- ٣) جدول المشتركين من تلغرام
  if to_regclass('public.telegram_users') is null then
    insert into _health values (3, '❌', 'جدول telegram_users',
      'مفقود  ←  شغّل supabase/setup.sql');
  else
    execute 'select count(*) from telegram_users' into n;
    insert into _health values (3, '✅', 'جدول telegram_users', n || ' مستخدم مسجّل');
  end if;

  -- ٤) شو البوت رح يعرض — نفس منطق bot_levels() بلا ما نعتمد عليها
  if to_regclass('public.levels') is null or to_regclass('public.tests') is null then
    insert into _health values (4, '❌', 'مستويات البوت رح يعرضها',
      'جداول المحتوى مفقودة  ←  شغّل supabase/setup.sql');
  else
    execute $q$ select string_agg(l.id, ', ' order by l.id) from levels l
                 where l.published and exists (select 1 from tests t
                        where t.level_id = l.id and t.published) $q$ into t;
    insert into _health values (4, case when t is null then '❌' else '✅' end,
      'مستويات البوت رح يعرضها',
      coalesce(t, 'ولا واحد  ←  البوت رح يقول «ما في امتحانات». '
                  || 'لازم مستوى منشور فيه امتحان منشور'));
  end if;

  -- ٥) المحتوى
  if to_regclass('public.tests') is null then
    insert into _health values (5, '❌', 'المحتوى', 'مفقود  ←  شغّل supabase/setup.sql');
  else
    execute $q$ select (select count(*) from tests where published) || ' امتحان منشور · '
                    || (select count(*) from items) || ' سؤال' $q$ into t;
    -- المهمّ المنشور مو الموجود: امتحان مستورد وغير منشور الطالب ما بيشوفه
    execute 'select count(*) from tests where published' into n;
    insert into _health values (5, case when n > 0 then '✅' else '❌' end, 'المحتوى',
      t || case when n = 0 then '  ←  ما في ولا امتحان منشور. '
                     || 'شغّل supabase/seed/b1.sql أو انشر من اللوحة' else '' end);
  end if;

  -- ٦) حساب أدمن
  if to_regclass('public.profiles') is null then
    insert into _health values (6, '❌', 'حساب أدمن', 'مفقود  ←  شغّل supabase/setup.sql');
  else
    execute 'select count(*) from profiles where is_admin' into n;
    insert into _health values (6, case when n > 0 then '✅' else '⚠️' end,
      'حساب أدمن', n || ' أدمن' || case when n = 0
        then '  ←  بلا أدمن ما فيك تفوت اللوحة' else '' end);
  end if;

  -- ٧) قائمة الانتظار — صفر معناها بلا حدّ
  if to_regclass('public.app_limits') is null then
    insert into _health values (7, '❌', 'قائمة الانتظار', 'مفقودة  ←  شغّل supabase/setup.sql');
  else
    execute $q$ select case when (j->>'max_active')::int = 0
                             and (j->>'max_new_per_day')::int = 0
              then 'مطفيّة (بلا حدّ) — تمام للتجربة'
              else 'شغّالة: ' || (j->>'active') || '/' || (j->>'max_active')
                   || ' فعّال · اليوم ' || (j->>'today') || '/'
                   || (j->>'max_new_per_day') || ' · ' || (j->>'waiting')
                   || ' بالطابور  ←  لو مليانة، الطالب بيروح عالانتظار مو عالامتحان'
              end from (select capacity() j) x $q$ into t;
    insert into _health values (7,
      case when t like 'مطفيّة%' then '✅' else '⚠️' end, 'قائمة الانتظار', t);
  end if;

exception when others then
  insert into _health values (99, '❌', 'الفحص نفسه وقع', SQLERRM);
end $health$;

select s as " ", k as "الفحص", d as "التفصيل" from _health order by ord;
