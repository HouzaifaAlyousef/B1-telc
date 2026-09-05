-- =====================================================================
-- telc Training — التركيب الكامل بملف واحد
-- مولّد من supabase/migrations/ — لا تعدّليه، عدّلي الترحيلات.
-- =====================================================================

-- ═══════════════════════════════════════════════
-- 0001_init.sql
-- ═══════════════════════════════════════════════
-- =====================================================================
-- 0001_init — الأساس: مستخدمين، أكواد وصول، اشتراكات، محتوى متعدّد المستويات
--
-- مبدأ التصميم المركزي: مفاتيح الحلول بجدول منفصل (item_answers) وما إله
-- ولا سياسة SELECT للعميل. الوصول الوحيد إله عبر دالة SECURITY DEFINER
-- بتصحّح بالسيرفر. هيك «الحماية الكاملة» بتصير خاصية بقاعدة البيانات
-- مو شي بنتذكّره بكل استعلام.
-- =====================================================================

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------
-- المستويات
-- ---------------------------------------------------------------------
create table if not exists levels (
  id          text primary key,              -- 'a1','a2','b1','b2','c1'
  title       text not null,                 -- 'telc Deutsch B1'
  sort        int  not null default 0,
  published   boolean not null default false
);

-- ---------------------------------------------------------------------
-- المستخدمون
-- الحساب بينعمل بتسجيل دخول مجهول (anonymous) لما ينفدّ كود الوصول.
-- ما في إيميل ولا كلمة سر — الكود هو نقطة الدخول الوحيدة.
-- ---------------------------------------------------------------------
create table if not exists profiles (
  id            uuid primary key references auth.users on delete cascade,
  display_name  text,                        -- بتحطّيه إنتي من اللوحة
  note          text,                        -- «أحمد - واتساب 0176...»
  is_admin      boolean not null default false,
  created_at    timestamptz not null default now(),
  last_seen_at  timestamptz
);

-- ---------------------------------------------------------------------
-- أكواد الوصول — بتولّديها من اللوحة وبتعطيها للمستخدم
-- ---------------------------------------------------------------------
create table if not exists access_codes (
  id             uuid primary key default gen_random_uuid(),
  code           text unique not null,       -- 'B1-7K2M-9XQP'
  levels         text[] not null,            -- شو بيفتحله: {'b1'} أو {'a1','a2'}
  duration_days  int  not null,              -- ٣٠، ٩٠، ٣٦٥...
  max_devices    int  not null default 2,    -- الدفاع الأساسي ضد مشاركة الكود
  note           text,                       -- لمين هالكود ومتى دفع
  -- مراجع تأليف: حذف حساب أدمن ما لازم يحبس ولا يمحي التاريخ
  created_by     uuid references profiles(id) on delete set null,
  created_at     timestamptz not null default now(),
  redeemed_at    timestamptz,
  redeemed_by    uuid references profiles(id) on delete set null,
  revoked_at     timestamptz
);
create index if not exists access_codes_redeemed_by_idx on access_codes (redeemed_by);

-- ---------------------------------------------------------------------
-- الاشتراكات — هي مصدر الحقيقة لـ«هل هالمستخدم مسموحله»
-- ---------------------------------------------------------------------
create table if not exists subscriptions (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid not null references profiles(id) on delete cascade,
  levels              text[] not null,
  status              text not null default 'active',   -- active|expired|revoked
  current_period_end  timestamptz not null,             -- بتمدّديها أو بتقصّريها من اللوحة
  source              text not null default 'manual',   -- manual | stripe (لاحقاً)
  access_code_id      uuid references access_codes(id) on delete set null,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);
create index if not exists subscriptions_user_id_idx on subscriptions (user_id);

-- الدالة يلي كل شي بيتعلّق فيها: هل الاشتراك ساري لهالمستوى؟
create or replace function has_access(p_user uuid, p_level text)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from subscriptions
    where user_id = p_user
      and status = 'active'
      and current_period_end > now()
      and p_level = any(levels)
  );
$$;

-- ---------------------------------------------------------------------
-- الأجهزة — سقف عدد الأجهزة هو يلي بيمنع مشاركة الكود
-- ---------------------------------------------------------------------
create table if not exists devices (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references profiles(id) on delete cascade,
  fingerprint  text not null,
  user_agent   text,
  first_seen   timestamptz not null default now(),
  last_seen    timestamptz not null default now(),
  unique (user_id, fingerprint)
);

-- ---------------------------------------------------------------------
-- المحتوى: امتحان ← أقسام ← أسئلة
-- ---------------------------------------------------------------------
create table if not exists tests (
  id         uuid primary key default gen_random_uuid(),
  level_id   text not null references levels(id),
  slug       text not null,                  -- 'modell-01'
  title      text not null,                  -- 'PETRA'
  subtitle   text,
  blocks     jsonb not null default '[]',    -- الكتل المؤقّتة (نفس شكل modell-XX.json)
  aufgaben   int not null default 0,         -- عدد الأسئلة، للعرض بالقائمة
  is_free    boolean not null default false, -- عيّنة مجانية للتجربة
  published  boolean not null default false,
  sort       int not null default 0,
  created_at timestamptz not null default now(),
  unique (level_id, slug)
);

create table if not exists sections (
  id           uuid primary key default gen_random_uuid(),
  test_id      uuid not null references tests(id) on delete cascade,
  section_id   text not null,                -- 'lv1','sb2','hv3','sa'
  "group"      text,
  title        text,
  minutes      int,
  instruction  text,
  format       text not null,                -- matching|mc|wordbank|truefalse|writing
  config       jsonb not null default '{}',  -- bank, passages, bankImage, bankTitle
  sort         int not null default 0,
  unique (test_id, section_id)
);

create table if not exists items (
  id          uuid primary key default gen_random_uuid(),
  section_id  uuid not null references sections(id) on delete cascade,
  item_id     text not null,                 -- '1','2',... رقم السؤال بالامتحان
  text        text,
  options     jsonb,                         -- خيارات mc — بدون تعليم الصح
  points      numeric not null default 1,
  meta        jsonb,                         -- خاص بـwriting: minWords والنقاط المطلوبة
  sort        int not null default 0,
  unique (section_id, item_id)
);

-- ★ الجدول الحسّاس: هون بس مفاتيح الحلول، ومحدا بيقرا منه من العميل
create table if not exists item_answers (
  item_id     uuid primary key references items(id) on delete cascade,
  answer      text not null,
  explanation text                           -- شرح اختياري بينعرض بعد التسليم
);

-- ---------------------------------------------------------------------
-- المراجع — النقطة ٤: نصوص بتلصقيها من اللوحة والمستخدم بيقراها أي وقت
-- ---------------------------------------------------------------------
create table if not exists resources (
  id         uuid primary key default gen_random_uuid(),
  level_id   text references levels(id),     -- null = بتنعرض لكل المستويات
  title      text not null,
  kind       text not null default 'text',   -- text | pdf
  body       text,                           -- النص الملصوق (markdown)
  file_path  text,                           -- مسار بـSupabase Storage لو PDF
  published  boolean not null default false,
  sort       int not null default 0,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- الاستيراد — بتلصقي نص الامتحان الخام، وبينتحوّل لأسئلة بعد مراجعتك
-- ---------------------------------------------------------------------
create table if not exists imports (
  id          uuid primary key default gen_random_uuid(),
  level_id    text references levels(id),
  raw_text    text not null,                 -- يلي لصقتيه
  parsed      jsonb,                         -- ناتج التحليل — بتراجعيه قبل الاعتماد
  status      text not null default 'draft', -- draft|parsed|needs_review|applied|failed
  error       text,
  test_id     uuid references tests(id) on delete set null,  -- بينتعبّى بعد الاعتماد
  created_by  uuid references profiles(id) on delete set null,
  created_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- تقدّم المستخدم
-- ---------------------------------------------------------------------
create table if not exists attempts (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references profiles(id) on delete cascade,
  test_id       uuid not null references tests(id) on delete cascade,
  block_id      text not null,
  started_at    timestamptz not null default now(),
  submitted_at  timestamptz,
  answers       jsonb not null default '{}',
  points        numeric,
  max_points    numeric,
  pct           numeric
);
create index if not exists attempts_user_id_test_id_idx on attempts (user_id, test_id);

create table if not exists mistakes (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references profiles(id) on delete cascade,
  item_id      uuid not null references items(id) on delete cascade,
  wrong_count  int not null default 1,
  last_seen_at timestamptz not null default now(),
  unique (user_id, item_id)
);

create table if not exists admin_audit_log (
  id          uuid primary key default gen_random_uuid(),
  admin_id    uuid references profiles(id) on delete set null,
  action      text not null,                 -- 'code.create','sub.extend','sub.revoke'
  target_type text,
  target_id   text,
  detail      jsonb,
  created_at  timestamptz not null default now()
);

-- ═══════════════════════════════════════════════
-- 0002_rls.sql
-- ═══════════════════════════════════════════════
-- =====================================================================
-- 0002_rls — سياسات الوصول
--
-- القاعدة: كل جدول عليه RLS. الافتراضي «ممنوع»، وكل سماح مكتوب صراحةً.
-- item_answers ما إله ولا سياسة قراءة — مقصود. محدا بيوصله من العميل
-- مهما عمل، ولا حتى بتوكن صالح. التصحيح بس عبر submit_attempt().
-- =====================================================================

alter table levels          enable row level security;
alter table profiles        enable row level security;
alter table access_codes    enable row level security;
alter table subscriptions   enable row level security;
alter table devices         enable row level security;
alter table tests           enable row level security;
alter table sections        enable row level security;
alter table items           enable row level security;
alter table item_answers    enable row level security;   -- ★ بلا سياسات نهائياً
alter table resources       enable row level security;
alter table imports         enable row level security;
alter table attempts        enable row level security;
alter table mistakes        enable row level security;
alter table admin_audit_log enable row level security;

-- مساعدة: هل المستخدم الحالي أدمن؟
create or replace function is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select is_admin from profiles where id = auth.uid()), false);
$$;

-- ---------------------------------------------------------------------
-- الأدمن: صلاحية كاملة على كل شي
-- ---------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array['levels','profiles','access_codes','subscriptions',
                           'devices','tests','sections','items','resources',
                           'imports','attempts','mistakes','admin_audit_log']
  loop
    execute format('drop policy if exists admin_all on %I', t);
    execute format(
      'create policy admin_all on %I for all to authenticated
         using (is_admin()) with check (is_admin())', t);
  end loop;
end $$;

-- ---------------------------------------------------------------------
-- المستخدم العادي
-- ---------------------------------------------------------------------

-- ملفه الشخصي
drop policy if exists own_profile on profiles;
create policy own_profile on profiles for select to authenticated
  using (id = auth.uid());

-- اشتراكه — بيشوفه بس، ما بيعدّله (التمديد من اللوحة فقط)
drop policy if exists own_subs on subscriptions;
create policy own_subs on subscriptions for select to authenticated
  using (user_id = auth.uid());

-- أجهزته
drop policy if exists own_devices on devices;
create policy own_devices on devices for select to authenticated
  using (user_id = auth.uid());

-- المستويات المنشورة مكشوفة للكل (لعرض قائمة «شو في»)
drop policy if exists levels_public on levels;
create policy levels_public on levels for select to authenticated
  using (published);

-- الامتحانات: المنشور، وبس إذا مجاني أو عنده اشتراك ساري بهالمستوى
drop policy if exists tests_entitled on tests;
create policy tests_entitled on tests for select to authenticated
  using (published and (is_free or has_access(auth.uid(), level_id)));

-- الأقسام والأسئلة: بتتبع صلاحية الامتحان
drop policy if exists sections_entitled on sections;
create policy sections_entitled on sections for select to authenticated
  using (exists (
    select 1 from tests t
    where t.id = sections.test_id
      and t.published
      and (t.is_free or has_access(auth.uid(), t.level_id))));

drop policy if exists items_entitled on items;
create policy items_entitled on items for select to authenticated
  using (exists (
    select 1 from sections s join tests t on t.id = s.test_id
    where s.id = items.section_id
      and t.published
      and (t.is_free or has_access(auth.uid(), t.level_id))));

-- ★ item_answers: ما في ولا سياسة. مقفول تماماً على العميل.

-- المراجع: المنشور لمستوى عنده اشتراك فيه (أو العام)
drop policy if exists resources_entitled on resources;
create policy resources_entitled on resources for select to authenticated
  using (published and (level_id is null or has_access(auth.uid(), level_id)));

-- محاولاته: بيقرا وبينشئ تبعه بس. التعديل ممنوع — النتيجة بتنكتب من
-- submit_attempt() لحتى ما يقدر يكتب علامته بإيده.
drop policy if exists own_attempts_read on attempts;
create policy own_attempts_read on attempts for select to authenticated
  using (user_id = auth.uid());
drop policy if exists own_attempts_insert on attempts;
create policy own_attempts_insert on attempts for insert to authenticated
  with check (user_id = auth.uid() and points is null);

-- أخطاؤه
drop policy if exists own_mistakes on mistakes;
create policy own_mistakes on mistakes for select to authenticated
  using (user_id = auth.uid());

-- ---------------------------------------------------------------------
-- الصلاحيات (GRANT) — منفصلة عن RLS ولازمة معها
-- RLS بتحدّد أي صفوف، وGRANT بتحدّد إذا الجدول مسموح أصلاً. الاتنين لازم.
-- item_answers مقصود إنه مو بالقائمة: لا سياسة ولا صلاحية.
-- ---------------------------------------------------------------------
grant usage on schema public to authenticated;

do $$
declare t text;
begin
  foreach t in array array['levels','profiles','access_codes','subscriptions',
                           'devices','tests','sections','items','resources',
                           'imports','attempts','mistakes','admin_audit_log']
  loop
    -- الصلاحية واسعة عمداً؛ RLS فوقها هي يلي بتقرّر مين بيعمل شو.
    execute format('grant select, insert, update, delete on %I to authenticated', t);
  end loop;
end $$;

revoke all on table item_answers from authenticated, anon;

-- ═══════════════════════════════════════════════
-- 0003_functions.sql
-- ═══════════════════════════════════════════════
-- =====================================================================
-- 0003_functions — المنطق يلي لازم يصير بالسيرفر
--
-- دالتين بس بيحملوا كل الوزن:
--   redeem_code()    — الكود ← اشتراك + جهاز مسجّل
--   submit_attempt() — الإجابات ← علامة محسوبة بالسيرفر
-- =====================================================================

-- ---------------------------------------------------------------------
-- تنفيذ كود الوصول
-- بينندعى بعد تسجيل دخول مجهول، فـauth.uid() موجود.
-- ---------------------------------------------------------------------
create or replace function redeem_code(
  p_code        text,
  p_fingerprint text,
  p_user_agent  text default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user uuid := auth.uid();
  v_code access_codes%rowtype;
  v_sub  subscriptions%rowtype;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  select * into v_code from access_codes
   where upper(code) = upper(trim(p_code))
   for update;

  if not found then
    return jsonb_build_object('ok', false, 'error', 'invalid_code');
  end if;
  if v_code.revoked_at is not null then
    return jsonb_build_object('ok', false, 'error', 'revoked');
  end if;
  -- الكود بينفّذ مرة وحدة. المستخدم بعدها بيدخل بجلسته، مو بالكود.
  if v_code.redeemed_at is not null and v_code.redeemed_by <> v_user then
    return jsonb_build_object('ok', false, 'error', 'already_used');
  end if;

  insert into profiles (id) values (v_user) on conflict (id) do nothing;

  -- اشتراك ساري لنفس المستويات؟ مدّده. غير هيك اعمل جديد.
  select * into v_sub from subscriptions
   where user_id = v_user and status = 'active' and levels @> v_code.levels
   order by current_period_end desc limit 1;

  if found then
    update subscriptions
       set current_period_end = greatest(current_period_end, now())
                                + make_interval(days => v_code.duration_days),
           updated_at = now()
     where id = v_sub.id
     returning * into v_sub;
  else
    insert into subscriptions (user_id, levels, current_period_end, access_code_id)
    values (v_user, v_code.levels,
            now() + make_interval(days => v_code.duration_days), v_code.id)
    returning * into v_sub;
  end if;

  update access_codes
     set redeemed_at = coalesce(redeemed_at, now()), redeemed_by = v_user
   where id = v_code.id;

  perform register_device(p_fingerprint, p_user_agent);

  return jsonb_build_object(
    'ok', true,
    'levels', v_sub.levels,
    'expires_at', v_sub.current_period_end);
end $$;

-- ---------------------------------------------------------------------
-- تسجيل الجهاز — هون بينفرض سقف الأجهزة (الدفاع ضد مشاركة الكود)
-- ---------------------------------------------------------------------
create or replace function register_device(
  p_fingerprint text,
  p_user_agent  text default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user  uuid := auth.uid();
  v_count int;
  v_max   int;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  -- الجهاز معروف؟ حدّث آخر ظهور وخلص.
  update devices set last_seen = now()
   where user_id = v_user and fingerprint = p_fingerprint;
  if found then
    return jsonb_build_object('ok', true, 'known', true);
  end if;

  select coalesce(max(ac.max_devices), 2) into v_max
    from subscriptions s left join access_codes ac on ac.id = s.access_code_id
   where s.user_id = v_user and s.status = 'active';

  select count(*) into v_count from devices where user_id = v_user;

  if v_count >= v_max then
    return jsonb_build_object('ok', false, 'error', 'device_limit',
                              'max', v_max, 'current', v_count);
  end if;

  insert into devices (user_id, fingerprint, user_agent)
  values (v_user, p_fingerprint, p_user_agent)
  on conflict (user_id, fingerprint) do nothing;

  return jsonb_build_object('ok', true, 'known', false);
end $$;

-- ---------------------------------------------------------------------
-- ★ التصحيح — القلب النابض للحماية الكاملة
-- الإجابات بتوصل، العلامة بترجع. مفاتيح الحلول ما بتغادر السيرفر
-- إلا بعد ما تنكتب المحاولة.
-- ---------------------------------------------------------------------
create or replace function submit_attempt(
  p_test_id  uuid,
  p_block_id text,
  p_answers  jsonb          -- { "<uuid السؤال>": "<جواب المستخدم>" }
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user       uuid := auth.uid();
  v_level      text;
  v_parts      text[];
  v_attempt_id uuid;
  v_points     numeric := 0;
  v_max        numeric := 0;
  v_results    jsonb   := '[]';
  r            record;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  select level_id into v_level from tests where id = p_test_id and published;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'test_not_found');
  end if;

  -- إعادة فحص الصلاحية بالسيرفر — ما منثق بالعميل
  if not (exists (select 1 from tests where id = p_test_id and is_free)
          or has_access(v_user, v_level)) then
    return jsonb_build_object('ok', false, 'error', 'not_entitled');
  end if;

  -- أقسام هالكتلة من tests.blocks
  select array(select jsonb_array_elements_text(b->'parts'))
    into v_parts
    from tests t, jsonb_array_elements(t.blocks) b
   where t.id = p_test_id and b->>'id' = p_block_id;

  if v_parts is null or array_length(v_parts, 1) is null then
    return jsonb_build_object('ok', false, 'error', 'block_not_found');
  end if;

  insert into attempts (user_id, test_id, block_id, answers, submitted_at)
  values (v_user, p_test_id, p_block_id, p_answers, now())
  returning id into v_attempt_id;

  -- التصحيح: أقسام التعبير الكتابي ما إلها مفتاح حل، فبتنستثنى
  for r in
    select i.id, i.item_id, i.points, s.section_id, s.format,
           ia.answer, ia.explanation,
           p_answers ->> i.id::text as given
      from items i
      join sections s on s.id = i.section_id
      left join item_answers ia on ia.item_id = i.id
     where s.test_id = p_test_id
       and s.section_id = any(v_parts)
       and s.format <> 'writing'
       and ia.answer is not null
     order by s.sort, i.sort
  loop
    v_max := v_max + r.points;
    if r.given is not null and r.given = r.answer then
      v_points := v_points + r.points;
    else
      insert into mistakes (user_id, item_id)
      values (v_user, r.id)
      on conflict (user_id, item_id)
        do update set wrong_count = mistakes.wrong_count + 1,
                      last_seen_at = now();
    end if;

    v_results := v_results || jsonb_build_object(
      'id',          r.id,
      'section',     r.section_id,
      'item',        r.item_id,
      'given',       r.given,
      'answer',      r.answer,          -- ← بينكشف هون بس، بعد التسليم
      'explanation', r.explanation,
      'correct',     (r.given is not null and r.given = r.answer));
  end loop;

  update attempts
     set points = v_points, max_points = v_max,
         pct = case when v_max > 0 then round(100 * v_points / v_max, 1) else null end
   where id = v_attempt_id;

  return jsonb_build_object(
    'ok', true, 'attempt_id', v_attempt_id,
    'points', v_points, 'max_points', v_max,
    'pct', case when v_max > 0 then round(100 * v_points / v_max, 1) else null end,
    'results', v_results);
end $$;

revoke all on function redeem_code(text,text,text)      from public;
revoke all on function submit_attempt(uuid,text,jsonb)  from public;
revoke all on function register_device(text,text)       from public;
grant execute on function redeem_code(text,text,text)     to authenticated;
grant execute on function submit_attempt(uuid,text,jsonb) to authenticated;
grant execute on function register_device(text,text)      to authenticated;

-- ---------------------------------------------------------------------
-- تصحيح جولة «تكرار الأخطاء»
-- بتختلف عن submit_attempt لأنها بتجمع أسئلة من امتحانات وأقسام مختلفة،
-- فما إلها امتحان ولا كتلة واحدة. ما بتنكتب كمحاولة — هي تمرين مو امتحان.
-- ---------------------------------------------------------------------
create or replace function submit_drill(p_answers jsonb)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user    uuid := auth.uid();
  v_right   int  := 0;
  v_total   int  := 0;
  v_results jsonb := '[]';
  r         record;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  for r in
    select i.id, i.item_id, s.section_id, t.slug, t.level_id,
           ia.answer, ia.explanation,
           p_answers ->> i.id::text as given
      from items i
      join item_answers ia on ia.item_id = i.id
      join sections s on s.id = i.section_id
      join tests   t on t.id = s.test_id
     where i.id::text in (select jsonb_object_keys(p_answers))
       -- نفس فحص الصلاحية: ما بينفع يتدرّب على مستوى مو مشترك فيه
       and (t.is_free or has_access(v_user, t.level_id))
  loop
    v_total := v_total + 1;
    if r.given is not null and r.given = r.answer then
      v_right := v_right + 1;
      -- جاوب صح ← بيطلع من قائمة الأخطاء
      delete from mistakes where user_id = v_user and item_id = r.id;
    else
      insert into mistakes (user_id, item_id) values (v_user, r.id)
      on conflict (user_id, item_id)
        do update set wrong_count = mistakes.wrong_count + 1,
                      last_seen_at = now();
    end if;

    v_results := v_results || jsonb_build_object(
      'id', r.id, 'item', r.item_id, 'section', r.section_id, 'test', r.slug,
      'given', r.given, 'answer', r.answer, 'explanation', r.explanation,
      'correct', (r.given is not null and r.given = r.answer));
  end loop;

  return jsonb_build_object(
    'ok', true, 'right', v_right, 'total', v_total,
    'pct', case when v_total > 0 then round(100.0 * v_right / v_total, 1) else null end,
    'results', v_results);
end $$;

revoke all on function submit_drill(jsonb) from public;
grant execute on function submit_drill(jsonb) to authenticated;

-- ═══════════════════════════════════════════════
-- 0004_admin.sql
-- ═══════════════════════════════════════════════
-- =====================================================================
-- 0004_admin — إجراءات لوحة التحكّم
--
-- ليش دوال بدل كتابة مباشرة عالجداول؟ سجلّ التدقيق. لو اللوحة كتبت
-- على subscriptions رأساً، أي إجراء ممكن يصير بلا أثر. هون كل دالة
-- بتكتب سطر بـadmin_audit_log بنفس المعاملة — ما في طريق يتخطّاه.
--
-- القراءة بتضل مباشرة عبر PostgREST: سياسة admin_all بتسمح فيها،
-- والقراءة ما بدها تدقيق.
-- =====================================================================

-- تسجيل إجراء — بتنندعى من كل دالة تحت
create or replace function admin_log(
  p_action text, p_type text, p_id text, p_detail jsonb default '{}'
) returns void
language sql security definer set search_path = public as $$
  insert into admin_audit_log (admin_id, action, target_type, target_id, detail)
  values (auth.uid(), p_action, p_type, p_id, p_detail);
$$;

-- حارس: كل دالة بتبلّش فيه
create or replace function admin_guard() returns void
language plpgsql security definer set search_path = public as $$
begin
  if not is_admin() then
    raise exception 'not_admin' using errcode = 'insufficient_privilege';
  end if;
end $$;

-- ---------------------------------------------------------------------
-- توليد أكواد وصول
-- الحروف بلا 0/O/1/I/L — تا ما ينقرا الكود غلط عالتلفون
-- ---------------------------------------------------------------------
create or replace function admin_create_codes(
  p_count       int,
  p_levels      text[],
  p_days        int,
  p_max_devices int  default 2,
  p_note        text default null
) returns setof text
language plpgsql security definer set search_path = public as $$
declare
  alphabet text := '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
  prefix   text := upper(coalesce(p_levels[1], 'XX'));
  v_code   text;      -- مو 'code': بينلخبط مع access_codes.code جوّا الاستعلام
  i        int;
  j        int;
begin
  perform admin_guard();
  if p_count < 1 or p_count > 200 then
    raise exception 'count_out_of_range';
  end if;
  if p_days < 1 then raise exception 'days_out_of_range'; end if;

  for i in 1..p_count loop
    loop
      v_code := prefix || '-';
      for j in 1..4 loop
        v_code := v_code || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
      end loop;
      v_code := v_code || '-';
      for j in 1..4 loop
        v_code := v_code || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
      end loop;
      exit when not exists (select 1 from access_codes a where a.code = v_code);
    end loop;

    insert into access_codes (code, levels, duration_days, max_devices, note, created_by)
    values (v_code, p_levels, p_days, p_max_devices, p_note, auth.uid());

    perform admin_log('code.create', 'access_code', v_code,
      jsonb_build_object('levels', p_levels, 'days', p_days,
                         'max_devices', p_max_devices, 'note', p_note));
    return next v_code;
  end loop;
end $$;

-- ---------------------------------------------------------------------
-- تمديد أو تقصير اشتراك — الطلب الأساسي من اللوحة
-- p_days موجب بيمدّد، سالب بيقصّر
-- ---------------------------------------------------------------------
create or replace function admin_shift_subscription(p_sub_id uuid, p_days int)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_old timestamptz; v_new timestamptz;
begin
  perform admin_guard();

  select current_period_end into v_old from subscriptions where id = p_sub_id;
  if not found then raise exception 'subscription_not_found'; end if;

  -- التقصير ما بيرجّع الاشتراك لقبل هلق: بيوقف عند اللحظة الحالية
  v_new := greatest(v_old + make_interval(days => p_days), now());

  update subscriptions
     set current_period_end = v_new,
         status = case when v_new > now() then 'active' else status end,
         updated_at = now()
   where id = p_sub_id;

  perform admin_log(
    case when p_days >= 0 then 'sub.extend' else 'sub.shorten' end,
    'subscription', p_sub_id::text,
    jsonb_build_object('days', p_days, 'from', v_old, 'to', v_new));

  return jsonb_build_object('ok', true, 'current_period_end', v_new);
end $$;

-- تاريخ انتهاء محدّد بدل عدد أيام
create or replace function admin_set_period_end(p_sub_id uuid, p_end timestamptz)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_old timestamptz;
begin
  perform admin_guard();
  select current_period_end into v_old from subscriptions where id = p_sub_id;
  if not found then raise exception 'subscription_not_found'; end if;

  update subscriptions
     set current_period_end = p_end,
         status = case when p_end > now() then 'active' else status end,
         updated_at = now()
   where id = p_sub_id;

  perform admin_log('sub.set_end', 'subscription', p_sub_id::text,
    jsonb_build_object('from', v_old, 'to', p_end));
  return jsonb_build_object('ok', true, 'current_period_end', p_end);
end $$;

-- إلغاء / إعادة تفعيل
create or replace function admin_set_subscription_status(p_sub_id uuid, p_status text)
returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  if p_status not in ('active', 'revoked', 'expired') then
    raise exception 'bad_status';
  end if;
  update subscriptions set status = p_status, updated_at = now() where id = p_sub_id;
  if not found then raise exception 'subscription_not_found'; end if;

  perform admin_log('sub.status', 'subscription', p_sub_id::text,
                    jsonb_build_object('status', p_status));
  return jsonb_build_object('ok', true, 'status', p_status);
end $$;

-- ---------------------------------------------------------------------
-- الأجهزة — لما يضيع جهاز الطالب أو ينبدّل
-- ---------------------------------------------------------------------
create or replace function admin_reset_devices(p_user_id uuid)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare n int;
begin
  perform admin_guard();
  delete from devices where user_id = p_user_id;
  get diagnostics n = row_count;
  perform admin_log('devices.reset', 'profile', p_user_id::text,
                    jsonb_build_object('removed', n));
  return jsonb_build_object('ok', true, 'removed', n);
end $$;

-- ---------------------------------------------------------------------
-- سَمِّ المستخدم — هو مجهول بالنظام، فالاسم والملاحظة هنّ الوحيدين
-- يلي بيخلّوكي تعرفي مين هو
-- ---------------------------------------------------------------------
create or replace function admin_set_profile(
  p_user_id uuid, p_name text, p_note text
) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  update profiles set display_name = p_name, note = p_note where id = p_user_id;
  if not found then raise exception 'profile_not_found'; end if;
  perform admin_log('profile.update', 'profile', p_user_id::text,
                    jsonb_build_object('name', p_name, 'note', p_note));
  return jsonb_build_object('ok', true);
end $$;

create or replace function admin_revoke_code(p_code_id uuid)
returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  update access_codes set revoked_at = now()
   where id = p_code_id and revoked_at is null;
  if not found then raise exception 'code_not_found_or_revoked'; end if;
  perform admin_log('code.revoke', 'access_code', p_code_id::text, '{}');
  return jsonb_build_object('ok', true);
end $$;

-- ---------------------------------------------------------------------
-- أرقام الصفحة الرئيسية للوحة
-- ---------------------------------------------------------------------
create or replace function admin_overview() returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  perform admin_guard();
  select jsonb_build_object(
    'users',           (select count(*) from profiles where not is_admin),
    'active_subs',     (select count(*) from subscriptions
                         where status = 'active' and current_period_end > now()),
    'expiring_7d',     (select count(*) from subscriptions
                         where status = 'active'
                           and current_period_end between now() and now() + interval '7 days'),
    'expired',         (select count(*) from subscriptions
                         where status <> 'active' or current_period_end <= now()),
    'codes_unused',    (select count(*) from access_codes
                         where redeemed_at is null and revoked_at is null),
    'attempts_7d',     (select count(*) from attempts
                         where submitted_at > now() - interval '7 days'),
    'tests_published', (select count(*) from tests where published),
    'levels',          (select coalesce(jsonb_agg(jsonb_build_object(
                                 'id', id, 'title', title, 'published', published)
                               order by sort), '[]') from levels)
  ) into r;
  return r;
end $$;

-- ---------------------------------------------------------------------
-- صفّ المستخدمين للوحة — تجميعة وحدة بدل عدة استعلامات
-- ---------------------------------------------------------------------
create or replace function admin_users(p_search text default null)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  perform admin_guard();
  select coalesce(jsonb_agg(x order by x->>'created_at' desc), '[]') into r from (
    select jsonb_build_object(
      'id', p.id,
      'name', p.display_name,
      'note', p.note,
      'created_at', p.created_at,
      'last_seen_at', p.last_seen_at,
      'devices', (select count(*) from devices d where d.user_id = p.id),
      'attempts', (select count(*) from attempts a where a.user_id = p.id),
      'best_pct', (select max(pct) from attempts a where a.user_id = p.id),
      'mistakes', (select count(*) from mistakes m where m.user_id = p.id),
      'sub', (select jsonb_build_object(
                'id', s.id, 'levels', s.levels, 'status', s.status,
                'current_period_end', s.current_period_end,
                'days_left', greatest(0, ceil(extract(epoch from
                              (s.current_period_end - now())) / 86400))::int,
                'source', s.source)
              from subscriptions s where s.user_id = p.id
              order by s.current_period_end desc limit 1),
      'code', (select ac.code from access_codes ac where ac.redeemed_by = p.id
               order by ac.redeemed_at desc limit 1)
    ) as x
    from profiles p
    where not p.is_admin
      and (p_search is null or p_search = ''
           or p.display_name ilike '%' || p_search || '%'
           or p.note ilike '%' || p_search || '%'
           or exists (select 1 from access_codes ac
                       where ac.redeemed_by = p.id and ac.code ilike '%' || p_search || '%'))
  ) t;
  return r;
end $$;

revoke all on function admin_create_codes(int,text[],int,int,text)   from public;
revoke all on function admin_shift_subscription(uuid,int)            from public;
revoke all on function admin_set_period_end(uuid,timestamptz)        from public;
revoke all on function admin_set_subscription_status(uuid,text)      from public;
revoke all on function admin_reset_devices(uuid)                     from public;
revoke all on function admin_set_profile(uuid,text,text)             from public;
revoke all on function admin_revoke_code(uuid)                       from public;
revoke all on function admin_overview()                              from public;
revoke all on function admin_users(text)                             from public;
revoke all on function admin_log(text,text,text,jsonb)               from public, authenticated;
revoke all on function admin_guard()                                 from public, authenticated;

grant execute on function admin_create_codes(int,text[],int,int,text)  to authenticated;
grant execute on function admin_shift_subscription(uuid,int)           to authenticated;
grant execute on function admin_set_period_end(uuid,timestamptz)       to authenticated;
grant execute on function admin_set_subscription_status(uuid,text)     to authenticated;
grant execute on function admin_reset_devices(uuid)                    to authenticated;
grant execute on function admin_set_profile(uuid,text,text)            to authenticated;
grant execute on function admin_revoke_code(uuid)                      to authenticated;
grant execute on function admin_overview()                             to authenticated;
grant execute on function admin_users(text)                            to authenticated;

-- ═══════════════════════════════════════════════
-- 0005_content.sql
-- ═══════════════════════════════════════════════
-- =====================================================================
-- 0005_content — إدارة المحتوى من اللوحة: استيراد، مراجع، مستويات
--
-- التحليل بيصير بالمتصفّح (admin/parse.js) ونتيجته بتنحفظ بـimports.parsed.
-- الدالة هون بتاخد الـJSON المراجَع وبتحوّله لصفوف. نفس مبدأ باقي النظام:
-- مفاتيح الحلول بتتفصل عن الأسئلة وبتروح لـitem_answers.
-- =====================================================================

-- ---------------------------------------------------------------------
-- المستويات
-- ---------------------------------------------------------------------
create or replace function admin_upsert_level(
  p_id text, p_title text, p_sort int default 0, p_published boolean default false
) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  if p_id !~ '^[a-z][a-z0-9_]{0,15}$' then raise exception 'bad_level_id'; end if;

  insert into levels (id, title, sort, published)
  values (p_id, p_title, p_sort, p_published)
  on conflict (id) do update
    set title = excluded.title, sort = excluded.sort, published = excluded.published;

  perform admin_log('level.upsert', 'level', p_id,
    jsonb_build_object('title', p_title, 'published', p_published));
  return jsonb_build_object('ok', true, 'id', p_id);
end $$;

-- ---------------------------------------------------------------------
-- المراجع — «الـfeed»: نص بتلصقيه والطالب بيقراه أي وقت
-- ---------------------------------------------------------------------
create or replace function admin_save_resource(
  p_id        uuid,
  p_level_id  text,
  p_title     text,
  p_body      text,
  p_published boolean default false,
  p_sort      int     default 0
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_id uuid;
begin
  perform admin_guard();
  if coalesce(trim(p_title), '') = '' then raise exception 'title_required'; end if;

  if p_id is null then
    insert into resources (level_id, title, body, published, sort, kind)
    values (p_level_id, p_title, p_body, p_published, p_sort, 'text')
    returning id into v_id;
    perform admin_log('resource.create', 'resource', v_id::text,
                      jsonb_build_object('title', p_title));
  else
    update resources
       set level_id = p_level_id, title = p_title, body = p_body,
           published = p_published, sort = p_sort
     where id = p_id
     returning id into v_id;
    if v_id is null then raise exception 'resource_not_found'; end if;
    perform admin_log('resource.update', 'resource', v_id::text,
                      jsonb_build_object('title', p_title, 'published', p_published));
  end if;
  return jsonb_build_object('ok', true, 'id', v_id);
end $$;

create or replace function admin_delete_resource(p_id uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  delete from resources where id = p_id;
  if not found then raise exception 'resource_not_found'; end if;
  perform admin_log('resource.delete', 'resource', p_id::text, '{}');
  return jsonb_build_object('ok', true);
end $$;

-- ---------------------------------------------------------------------
-- الاستيراد: حفظ المسوّدة
-- بينحفظ النص الخام كمان، تا لو التحليل طلع غلط تعيديه بلا ما تعيدي اللصق
-- ---------------------------------------------------------------------
create or replace function admin_save_import(
  p_id uuid, p_level_id text, p_raw text, p_parsed jsonb, p_status text default 'parsed'
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_id uuid;
begin
  perform admin_guard();
  if p_id is null then
    insert into imports (level_id, raw_text, parsed, status, created_by)
    values (p_level_id, p_raw, p_parsed, p_status, auth.uid())
    returning id into v_id;
  else
    update imports set level_id = p_level_id, raw_text = p_raw,
                       parsed = p_parsed, status = p_status
     where id = p_id returning id into v_id;
    if v_id is null then raise exception 'import_not_found'; end if;
  end if;
  perform admin_log('import.save', 'import', v_id::text,
                    jsonb_build_object('status', p_status));
  return jsonb_build_object('ok', true, 'id', v_id);
end $$;

create or replace function admin_delete_import(p_id uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  delete from imports where id = p_id;
  if not found then raise exception 'import_not_found'; end if;
  perform admin_log('import.delete', 'import', p_id::text, '{}');
  return jsonb_build_object('ok', true);
end $$;

-- ---------------------------------------------------------------------
-- ★ الاعتماد: JSON مراجَع ← امتحان كامل بقاعدة البيانات
--
-- بينشتغل بمعاملة وحدة: يا بيمرق كل الامتحان يا ولا شي. وإذا الـslug
-- موجود، بينستبدل محتواه بالكامل (حذف الأقسام بيجرّ الأسئلة والحلول).
-- ---------------------------------------------------------------------
create or replace function admin_apply_import(
  p_import_id uuid,
  p_level_id  text,
  p_slug      text,
  p_publish   boolean default false
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_doc   jsonb;
  v_test  uuid;
  v_sec   uuid;
  v_item  uuid;
  s       jsonb;
  it      jsonb;
  n_sec   int := 0;
  n_item  int := 0;
  n_ans   int := 0;
  i_sec   int := 0;
  i_item  int;
begin
  perform admin_guard();
  if p_slug !~ '^[a-z0-9][a-z0-9_-]{0,63}$' then raise exception 'bad_slug'; end if;

  select parsed into v_doc from imports where id = p_import_id;
  if v_doc is null then raise exception 'import_not_parsed'; end if;
  if not exists (select 1 from levels where id = p_level_id) then
    raise exception 'level_not_found';
  end if;

  insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
  values (p_level_id, p_slug, v_doc->>'title', v_doc->>'subtitle',
          coalesce(v_doc->'blocks', '[]'::jsonb),
          (select count(*)::int from jsonb_array_elements(v_doc->'sections') x,
                  jsonb_array_elements(x->'items')),
          p_publish,
          coalesce((select max(sort) + 1 from tests where level_id = p_level_id), 1))
  on conflict (level_id, slug) do update
    set title = excluded.title, subtitle = excluded.subtitle,
        blocks = excluded.blocks, aufgaben = excluded.aufgaben,
        published = excluded.published
  returning id into v_test;

  -- استبدال كامل: الأقسام القديمة بتنشال ومعها أسئلتها وحلولها
  delete from sections where test_id = v_test;

  for s in select * from jsonb_array_elements(coalesce(v_doc->'sections', '[]'::jsonb))
  loop
    insert into sections (test_id, section_id, "group", title, minutes,
                          instruction, format, config, sort)
    values (v_test, s->>'id', s->>'group', s->>'title',
            (s->>'minutes')::int, s->>'instruction', s->>'format',
            -- كل يلي مو عمود بيروح لـconfig
            (s - 'id' - 'group' - 'title' - 'minutes' - 'instruction'
               - 'format' - 'items'),
            i_sec)
    returning id into v_sec;
    n_sec := n_sec + 1; i_sec := i_sec + 1; i_item := 0;

    for it in select * from jsonb_array_elements(coalesce(s->'items', '[]'::jsonb))
    loop
      insert into items (section_id, item_id, text, options, points, meta, sort)
      values (v_sec, it->>'id', it->>'text',
              case when it ? 'options' then it->'options' end,
              coalesce((s->>'pointsPerItem')::numeric, 1),
              nullif(jsonb_strip_nulls(jsonb_build_object(
                'minWords', it->'minWords',
                'points', case when s->>'format' = 'writing' then it->'points' end)),
                '{}'::jsonb),
              i_item)
      returning id into v_item;
      n_item := n_item + 1; i_item := i_item + 1;

      if it ? 'answer' and it->>'answer' is not null then
        insert into item_answers (item_id, answer, explanation)
        values (v_item, it->>'answer', it->>'explain');
        n_ans := n_ans + 1;
      end if;
    end loop;
  end loop;

  update imports set status = 'applied', test_id = v_test where id = p_import_id;

  perform admin_log('import.apply', 'test', v_test::text,
    jsonb_build_object('level', p_level_id, 'slug', p_slug, 'published', p_publish,
                       'sections', n_sec, 'items', n_item, 'answers', n_ans));

  return jsonb_build_object('ok', true, 'test_id', v_test, 'slug', p_slug,
    'sections', n_sec, 'items', n_item, 'answers', n_ans);
end $$;

-- نشر / إخفاء امتحان
create or replace function admin_set_test_published(p_test_id uuid, p_published boolean)
returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  update tests set published = p_published where id = p_test_id;
  if not found then raise exception 'test_not_found'; end if;
  perform admin_log('test.publish', 'test', p_test_id::text,
                    jsonb_build_object('published', p_published));
  return jsonb_build_object('ok', true);
end $$;

create or replace function admin_delete_test(p_test_id uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  delete from tests where id = p_test_id;
  if not found then raise exception 'test_not_found'; end if;
  perform admin_log('test.delete', 'test', p_test_id::text, '{}');
  return jsonb_build_object('ok', true);
end $$;

-- قائمة المحتوى للوحة
create or replace function admin_content(p_level_id text default null)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  perform admin_guard();
  select jsonb_build_object(
    'levels', (select coalesce(jsonb_agg(jsonb_build_object(
                 'id', id, 'title', title, 'sort', sort, 'published', published,
                 'tests', (select count(*) from tests t where t.level_id = l.id))
               order by sort), '[]') from levels l),
    'tests', (select coalesce(jsonb_agg(jsonb_build_object(
                'id', t.id, 'slug', t.slug, 'title', t.title, 'level_id', t.level_id,
                'published', t.published, 'is_free', t.is_free, 'aufgaben', t.aufgaben,
                'sections', (select count(*) from sections s where s.test_id = t.id),
                'answers', (select count(*) from item_answers ia
                             join items i on i.id = ia.item_id
                             join sections s on s.id = i.section_id
                            where s.test_id = t.id))
              order by t.level_id, t.sort), '[]')
              from tests t
             where p_level_id is null or t.level_id = p_level_id),
    'resources', (select coalesce(jsonb_agg(jsonb_build_object(
                    'id', id, 'title', title, 'level_id', level_id,
                    'published', published, 'sort', sort,
                    'length', length(coalesce(body, '')))
                  order by sort), '[]') from resources),
    'imports', (select coalesce(jsonb_agg(jsonb_build_object(
                  'id', id, 'level_id', level_id, 'status', status,
                  'created_at', created_at, 'test_id', test_id,
                  'title', parsed->>'title',
                  'raw_length', length(coalesce(raw_text, '')))
                order by created_at desc), '[]') from imports)
  ) into r;
  return r;
end $$;

revoke all on function admin_upsert_level(text,text,int,boolean)      from public;
revoke all on function admin_save_resource(uuid,text,text,text,boolean,int) from public;
revoke all on function admin_delete_resource(uuid)                    from public;
revoke all on function admin_save_import(uuid,text,text,jsonb,text)   from public;
revoke all on function admin_delete_import(uuid)                      from public;
revoke all on function admin_apply_import(uuid,text,text,boolean)     from public;
revoke all on function admin_set_test_published(uuid,boolean)         from public;
revoke all on function admin_delete_test(uuid)                        from public;
revoke all on function admin_content(text)                            from public;

grant execute on function admin_upsert_level(text,text,int,boolean)      to authenticated;
grant execute on function admin_save_resource(uuid,text,text,text,boolean,int) to authenticated;
grant execute on function admin_delete_resource(uuid)                    to authenticated;
grant execute on function admin_save_import(uuid,text,text,jsonb,text)   to authenticated;
grant execute on function admin_delete_import(uuid)                      to authenticated;
grant execute on function admin_apply_import(uuid,text,text,boolean)     to authenticated;
grant execute on function admin_set_test_published(uuid,boolean)         to authenticated;
grant execute on function admin_delete_test(uuid)                        to authenticated;
grant execute on function admin_content(text)                            to authenticated;

-- ═══════════════════════════════════════════════
-- 0006_review.sql
-- ═══════════════════════════════════════════════
-- =====================================================================
-- 0006_review — تكرار متباعد فوق جدول الأخطاء
--
-- الأخطاء كانت بتنجمع وبس تنعدّ. هون بتصير جدول مراجعة: كل سؤال إله
-- صندوق (Leitner) وموعد استحقاق. جاوبت صح ← بيصعد صندوق وبيبعد موعده.
-- غلطت ← بيرجع للصندوق الأول وبيستحق فوراً.
--
-- الفواصل: ١، ٣، ٧، ١٦، ٣٥ يوم. بعد الصندوق الخامس بينحسب متقن وبيطلع
-- من التدوير — بلا ما ينحذف، تا يضل التاريخ موجود للتحليلات.
-- =====================================================================

alter table mistakes add column if not exists box         int not null default 1;
alter table mistakes add column if not exists due_at      timestamptz not null default now();
alter table mistakes add column if not exists right_count int not null default 0;

create index if not exists mistakes_due_idx on mistakes (user_id, due_at);

-- فاصل الصندوق بالأيام
create or replace function review_interval(p_box int)
returns interval language sql immutable as $$
  select (array['1 day','3 days','7 days','16 days','35 days']::interval[])
         [least(greatest(p_box, 1), 5)];
$$;

comment on column mistakes.box is
  'صندوق Leitner ١..٥؛ ٦ فما فوق = متقن، بيطلع من التدوير';

-- ---------------------------------------------------------------------
-- التصحيح: الخطأ بيرجّع السؤال لأول صندوق
-- (نفس submit_attempt بـ0003، بس تحديث الأخطاء صار يضبط الصندوق والموعد)
-- ---------------------------------------------------------------------
create or replace function submit_attempt(
  p_test_id  uuid,
  p_block_id text,
  p_answers  jsonb
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user       uuid := auth.uid();
  v_level      text;
  v_parts      text[];
  v_attempt_id uuid;
  v_points     numeric := 0;
  v_max        numeric := 0;
  v_results    jsonb   := '[]';
  r            record;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  select level_id into v_level from tests where id = p_test_id and published;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'test_not_found');
  end if;

  if not (exists (select 1 from tests where id = p_test_id and is_free)
          or has_access(v_user, v_level)) then
    return jsonb_build_object('ok', false, 'error', 'not_entitled');
  end if;

  select array(select jsonb_array_elements_text(b->'parts'))
    into v_parts
    from tests t, jsonb_array_elements(t.blocks) b
   where t.id = p_test_id and b->>'id' = p_block_id;

  if v_parts is null or array_length(v_parts, 1) is null then
    return jsonb_build_object('ok', false, 'error', 'block_not_found');
  end if;

  insert into attempts (user_id, test_id, block_id, answers, submitted_at)
  values (v_user, p_test_id, p_block_id, p_answers, now())
  returning id into v_attempt_id;

  for r in
    select i.id, i.item_id, i.points, s.section_id, s.format,
           ia.answer, ia.explanation,
           p_answers ->> i.id::text as given
      from items i
      join sections s on s.id = i.section_id
      left join item_answers ia on ia.item_id = i.id
     where s.test_id = p_test_id
       and s.section_id = any(v_parts)
       and s.format <> 'writing'
       and ia.answer is not null
     order by s.sort, i.sort
  loop
    v_max := v_max + r.points;
    if r.given is not null and r.given = r.answer then
      v_points := v_points + r.points;
    else
      -- غلط بالامتحان = رجوع لأول صندوق، مستحق فوراً
      insert into mistakes (user_id, item_id, box, due_at)
      values (v_user, r.id, 1, now())
      on conflict (user_id, item_id)
        do update set wrong_count = mistakes.wrong_count + 1,
                      box = 1, due_at = now(), last_seen_at = now();
    end if;

    v_results := v_results || jsonb_build_object(
      'id',          r.id,
      'section',     r.section_id,
      'item',        r.item_id,
      'given',       r.given,
      'answer',      r.answer,
      'explanation', r.explanation,
      'correct',     (r.given is not null and r.given = r.answer));
  end loop;

  update attempts
     set points = v_points, max_points = v_max,
         pct = case when v_max > 0 then round(100 * v_points / v_max, 1) else null end
   where id = v_attempt_id;

  return jsonb_build_object(
    'ok', true, 'attempt_id', v_attempt_id,
    'points', v_points, 'max_points', v_max,
    'pct', case when v_max > 0 then round(100 * v_points / v_max, 1) else null end,
    'results', v_results);
end $$;

-- ---------------------------------------------------------------------
-- المراجعة: صح ← الصندوق الجاي، غلط ← الأول
-- ---------------------------------------------------------------------
create or replace function submit_drill(p_answers jsonb)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user    uuid := auth.uid();
  v_right   int  := 0;
  v_total   int  := 0;
  v_master  int  := 0;
  v_results jsonb := '[]';
  v_box     int;
  r         record;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  for r in
    select i.id, i.item_id, s.section_id, t.slug, t.level_id,
           ia.answer, ia.explanation, m.box,
           p_answers ->> i.id::text as given
      from items i
      join item_answers ia on ia.item_id = i.id
      join sections s on s.id = i.section_id
      join tests   t on t.id = s.test_id
      join mistakes m on m.item_id = i.id and m.user_id = v_user
     where i.id::text in (select jsonb_object_keys(p_answers))
       and (t.is_free or has_access(v_user, t.level_id))
  loop
    v_total := v_total + 1;
    if r.given is not null and r.given = r.answer then
      v_right := v_right + 1;
      v_box := r.box + 1;
      if v_box > 5 then v_master := v_master + 1; end if;
      update mistakes
         set box = v_box,
             right_count = right_count + 1,
             -- المتقن بيتأجّل بعيد بدل ما ينحذف: التاريخ بيضل للتحليلات
             due_at = now() + case when v_box > 5 then interval '365 days'
                                   else review_interval(v_box) end,
             last_seen_at = now()
       where user_id = v_user and item_id = r.id;
    else
      update mistakes
         set box = 1, wrong_count = wrong_count + 1,
             due_at = now(), last_seen_at = now()
       where user_id = v_user and item_id = r.id;
    end if;

    v_results := v_results || jsonb_build_object(
      'id', r.id, 'item', r.item_id, 'section', r.section_id, 'test', r.slug,
      'given', r.given, 'answer', r.answer, 'explanation', r.explanation,
      'correct', (r.given is not null and r.given = r.answer));
  end loop;

  return jsonb_build_object(
    'ok', true, 'right', v_right, 'total', v_total, 'mastered', v_master,
    'pct', case when v_total > 0 then round(100.0 * v_right / v_total, 1) else null end,
    'results', v_results);
end $$;

-- ---------------------------------------------------------------------
-- ملخّص المراجعة للشاشة الرئيسية — نداء واحد بدل جلب كل الصفوف
-- ---------------------------------------------------------------------
create or replace function review_summary()
returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_user uuid := auth.uid();
begin
  if v_user is null then return jsonb_build_object('due', 0, 'total', 0); end if;
  return (select jsonb_build_object(
    'due',      count(*) filter (where due_at <= now() and box <= 5),
    'total',    count(*) filter (where box <= 5),
    'mastered', count(*) filter (where box > 5),
    'next_due', min(due_at) filter (where due_at > now() and box <= 5))
    from mistakes where user_id = v_user);
end $$;

revoke all on function review_summary() from public;
grant execute on function review_summary() to authenticated;

-- ═══════════════════════════════════════════════
-- 0007_writing.sql
-- ═══════════════════════════════════════════════
-- =====================================================================
-- 0007_writing — تصحيح التعبير الكتابي
--
-- التعبير الكتابي كان تقييم ذاتي: الطالب بيقرا المعايير وبيحكم على حاله.
-- هون بيصير تصحيح حقيقي: الرسالة بتنبعت لـClaude من Edge Function،
-- وبترجع بدرجة لكل معيار وأخطاء مشروحة.
--
-- قاعدتين بالتصميم:
--  ١. النقاط بتنحسب **هون** من مفاتيح الدرجات وجدول grades المخزّن.
--     النموذج بيعطي حرف (A/B/C/D)، والحساب مو عليه.
--  ٢. الكتابة بجدول التغذية الراجعة مسموحة لـservice_role بس. لو
--     كانت مسموحة للطالب، بيقدر يبعت لحاله ٤٥ نقطة.
-- =====================================================================

create table if not exists writing_feedback (
  id           uuid primary key default gen_random_uuid(),
  attempt_id   uuid not null references attempts(id) on delete cascade,
  user_id      uuid not null references profiles(id) on delete cascade,
  section_id   uuid references sections(id) on delete set null,
  text         text not null,                 -- يلي كتبه الطالب
  word_count   int,
  status       text not null default 'pending',  -- pending|done|failed
  grades       jsonb,                         -- [{criterion, key, why}]
  points       numeric,                       -- محسوبة هون مو من النموذج
  max_points   numeric,
  errors       jsonb,                         -- [{type, original, correction, why}]
  summary      text,
  corrected    text,                          -- النص بعد التصحيح
  model        text,
  error        text,                          -- سبب الفشل لو فشل
  created_at   timestamptz not null default now(),
  completed_at timestamptz
);
create index if not exists writing_feedback_user_id_created_at_desc_idx on writing_feedback (user_id, created_at desc);
create index if not exists writing_feedback_attempt_id_idx on writing_feedback (attempt_id);

alter table writing_feedback enable row level security;
grant select on writing_feedback to authenticated;

drop policy if exists own_feedback on writing_feedback;
create policy own_feedback on writing_feedback for select to authenticated
  using (user_id = auth.uid());
drop policy if exists admin_feedback on writing_feedback;
create policy admin_feedback on writing_feedback for all to authenticated
  using (is_admin()) with check (is_admin());

-- حصّة شهرية: التصحيح بيكلّف فلوس حقيقية لكل نداء
alter table subscriptions add column if not exists writing_quota int not null default 20;

-- ---------------------------------------------------------------------
-- بداية التصحيح: فحص الصلاحية والحصّة، وتجهيز كل شي بيحتاجه النموذج
-- بينندعى بهويّة الطالب — فالصلاحية بتنفحص طبيعياً.
-- ---------------------------------------------------------------------
create or replace function writing_start(p_attempt_id uuid)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user  uuid := auth.uid();
  a       attempts%rowtype;
  v_level text;
  v_sec   record;
  v_text  text;
  v_used  int;
  v_quota int;
  v_since timestamptz;
  v_id    uuid;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  select * into a from attempts where id = p_attempt_id and user_id = v_user;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'attempt_not_found');
  end if;

  select level_id into v_level from tests where id = a.test_id;
  if not has_access(v_user, v_level) then
    return jsonb_build_object('ok', false, 'error', 'not_entitled');
  end if;

  -- قسم التعبير الكتابي بهالكتلة
  select s.id, s.section_id, s.instruction, s.config into v_sec
    from sections s
   where s.test_id = a.test_id and s.format = 'writing'
     and s.section_id in (
       select jsonb_array_elements_text(b->'parts')
         from tests t, jsonb_array_elements(t.blocks) b
        where t.id = a.test_id and b->>'id' = a.block_id)
   limit 1;
  if v_sec.id is null then
    return jsonb_build_object('ok', false, 'error', 'not_a_writing_block');
  end if;

  -- نص الطالب: أول (ووحيد) عنصر بالقسم
  select a.answers ->> i.id::text into v_text
    from items i where i.section_id = v_sec.id order by i.sort limit 1;

  if coalesce(trim(v_text), '') = '' then
    return jsonb_build_object('ok', false, 'error', 'empty_text');
  end if;

  -- الحصّة على مدى فترة الاشتراك الحالية
  select greatest(current_period_end - interval '30 days', now() - interval '30 days'),
         writing_quota
    into v_since, v_quota
    from subscriptions
   where user_id = v_user and status = 'active'
   order by current_period_end desc limit 1;

  select count(*) into v_used from writing_feedback
   where user_id = v_user and status <> 'failed' and created_at >= coalesce(v_since, now() - interval '30 days');

  if v_used >= coalesce(v_quota, 20) then
    return jsonb_build_object('ok', false, 'error', 'quota_exceeded',
                              'used', v_used, 'quota', v_quota);
  end if;

  -- صفّ معلّق: الـEdge Function بس بيقدر يكمّله
  insert into writing_feedback (attempt_id, user_id, section_id, text, word_count,
                                max_points, status)
  values (p_attempt_id, v_user, v_sec.id, v_text,
          array_length(regexp_split_to_array(trim(v_text), '\s+'), 1),
          coalesce((v_sec.config->>'maxPoints')::numeric, 45), 'pending')
  returning id into v_id;

  return jsonb_build_object(
    'ok', true,
    'feedback_id', v_id,
    'text', v_text,
    'instruction', v_sec.instruction,
    'task',      v_sec.config->'brief',
    'points',    (select i.meta->'points' from items i
                   where i.section_id = v_sec.id order by i.sort limit 1),
    'min_words', (select (i.meta->>'minWords')::int from items i
                   where i.section_id = v_sec.id order by i.sort limit 1),
    'criteria',  v_sec.config->'criteria',
    'grades',    v_sec.config->'grades',
    'factor',    coalesce((v_sec.config->>'factor')::numeric, 1),
    'max_points',coalesce((v_sec.config->>'maxPoints')::numeric, 45),
    'level',     v_level,
    'used', v_used, 'quota', v_quota);
end $$;

-- ---------------------------------------------------------------------
-- حفظ النتيجة — service_role فقط
-- النقاط بتنحسب هون من مفاتيح الدرجات، النموذج ما بيحسب ولا رقم.
-- ---------------------------------------------------------------------
create or replace function writing_finish(
  p_feedback_id uuid,
  p_grades      jsonb,     -- [{criterion, key, why}]
  p_errors      jsonb,
  p_summary     text,
  p_corrected   text,
  p_model       text
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  f        writing_feedback%rowtype;
  cfg      jsonb;
  v_factor numeric;
  v_sum    numeric := 0;
  g        jsonb;
  v_pts    numeric;
begin
  select * into f from writing_feedback where id = p_feedback_id;
  if not found then raise exception 'feedback_not_found'; end if;
  if f.status <> 'pending' then raise exception 'already_finished'; end if;

  select config into cfg from sections where id = f.section_id;
  v_factor := coalesce((cfg->>'factor')::numeric, 1);

  -- الحرف ← نقاط، من جدول grades المخزّن مع القسم
  for g in select * from jsonb_array_elements(coalesce(p_grades, '[]'::jsonb))
  loop
    select (x->>'points')::numeric into v_pts
      from jsonb_array_elements(coalesce(cfg->'grades', '[]'::jsonb)) x
     where upper(x->>'key') = upper(g->>'key')
     limit 1;
    v_sum := v_sum + coalesce(v_pts, 0);
  end loop;

  update writing_feedback
     set status = 'done', grades = p_grades, errors = p_errors,
         summary = p_summary, corrected = p_corrected, model = p_model,
         points = round(v_sum * v_factor, 1),
         completed_at = now()
   where id = p_feedback_id;

  return jsonb_build_object('ok', true, 'points', round(v_sum * v_factor, 1),
                            'max_points', f.max_points);
end $$;

create or replace function writing_fail(p_feedback_id uuid, p_error text)
returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  update writing_feedback set status = 'failed', error = p_error, completed_at = now()
   where id = p_feedback_id and status = 'pending';
  return jsonb_build_object('ok', true);
end $$;

revoke all on function writing_start(uuid) from public;
grant execute on function writing_start(uuid) to authenticated;
-- ★ finish/fail مو مسموحين للطالب: هيك ما بيقدر يكتب علامته بإيده
revoke all on function writing_finish(uuid,jsonb,jsonb,text,text,text) from public, authenticated;
revoke all on function writing_fail(uuid,text)                        from public, authenticated;

-- ═══════════════════════════════════════════════
-- 0008_audio.sql
-- ═══════════════════════════════════════════════
-- =====================================================================
-- 0008_audio — صوت الاستماع (Hörverstehen)
--
-- ثلث كل امتحان telc استماع، والـPDF الأصلي ما فيه صوت — فالقسم كان
-- بيعرض النص مع الحل للمراجعة بس. هون بينفتح الطريق للصوت الحقيقي.
--
-- الصوت محتوى امتحان متل الأسئلة: دلو **خاص** ورابط موقّع بينتهي.
-- المسار بينحفظ بـsections.config.audio، وعدد مرات التشغيل بـaudioPlays
-- (telc بيشغّل بعض الأجزاء مرة وبعضها مرتين).
-- =====================================================================

create or replace function admin_set_section_audio(
  p_section_id uuid,
  p_path       text,          -- مسار الملف بالدلو، أو null لشيله
  p_plays      int default 1  -- كم مرة مسموح يسمعه
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_cfg jsonb;
begin
  perform admin_guard();
  if p_plays < 1 or p_plays > 5 then raise exception 'plays_out_of_range'; end if;

  select config into v_cfg from sections where id = p_section_id;
  if v_cfg is null then raise exception 'section_not_found'; end if;

  update sections
     set config = case
           when p_path is null then (config - 'audio' - 'audioPlays')
           else config || jsonb_build_object('audio', p_path, 'audioPlays', p_plays)
         end
   where id = p_section_id;

  perform admin_log('section.audio', 'section', p_section_id::text,
                    jsonb_build_object('path', p_path, 'plays', p_plays));
  return jsonb_build_object('ok', true, 'path', p_path, 'plays', p_plays);
end $$;

-- أقسام الاستماع مع حالة صوتها — للوحة
create or replace function admin_audio_status(p_level_id text default null)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  perform admin_guard();
  select coalesce(jsonb_agg(x order by x->>'test', x->>'section'), '[]') into r
  from (
    select jsonb_build_object(
      'section_id', s.id, 'section', s.section_id, 'title', s.title,
      'test', t.slug, 'test_title', t.title, 'level', t.level_id,
      'items', (select count(*) from items i where i.section_id = s.id),
      'audio', s.config->>'audio',
      'plays', coalesce((s.config->>'audioPlays')::int, 1)) as x
      from sections s join tests t on t.id = s.test_id
     where s."group" ilike '%Hörverstehen%'
       and (p_level_id is null or t.level_id = p_level_id)
  ) q;
  return r;
end $$;

revoke all on function admin_set_section_audio(uuid,text,int) from public;
revoke all on function admin_audio_status(text)               from public;
grant execute on function admin_set_section_audio(uuid,text,int) to authenticated;
grant execute on function admin_audio_status(text)               to authenticated;

-- ═══════════════════════════════════════════════
-- 0009_fixes.sql
-- ═══════════════════════════════════════════════
-- =====================================================================
-- 0009_fixes — بغّين انكشفوا بالفحص العدائي
--
-- ١) الكود كان بينعاد تنفيذه من نفس المستخدم وبيمدّد كل مرة.
--    ١٢ إدخال = سنة مجاناً. الكود صار مرة وحدة فعلاً، والإعادة
--    بترجّع نفس الحالة بلا تمديد (تا يضل آمن لو التطبيق أعاد النداء).
--
-- ٢) نافذة حصّة التصحيح كانت (نهاية الاشتراك − ٣٠ يوم). مع اشتراك
--    سنوي هاد تاريخ **بالمستقبل**، فما كان ينعدّ ولا تصحيح والحصّة
--    ما بتنفرض أبداً — يعني تكلفة API بلا سقف. صارت ٣٠ يوم متدحرجة.
-- =====================================================================

create or replace function redeem_code(
  p_code        text,
  p_fingerprint text,
  p_user_agent  text default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user uuid := auth.uid();
  v_code access_codes%rowtype;
  v_sub  subscriptions%rowtype;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  select * into v_code from access_codes
   where upper(code) = upper(trim(p_code))
   for update;

  if not found then
    return jsonb_build_object('ok', false, 'error', 'invalid_code');
  end if;
  if v_code.revoked_at is not null then
    return jsonb_build_object('ok', false, 'error', 'revoked');
  end if;

  -- ★ الكود بينفّذ مرة وحدة. لو نفس المستخدم أعاد النداء (زرّ مضغوط
  --   مرتين، شبكة أعادت الطلب) منرجّع حالته كما هي — بلا تمديد.
  if v_code.redeemed_at is not null then
    if v_code.redeemed_by <> v_user then
      return jsonb_build_object('ok', false, 'error', 'already_used');
    end if;
    select * into v_sub from subscriptions
     where user_id = v_user and access_code_id = v_code.id
     order by current_period_end desc limit 1;
    perform register_device(p_fingerprint, p_user_agent);
    return jsonb_build_object(
      'ok', true, 'already', true,
      'levels', coalesce(v_sub.levels, v_code.levels),
      'expires_at', v_sub.current_period_end);
  end if;

  insert into profiles (id) values (v_user) on conflict (id) do nothing;

  select * into v_sub from subscriptions
   where user_id = v_user and status = 'active' and levels @> v_code.levels
   order by current_period_end desc limit 1;

  if found then
    update subscriptions
       set current_period_end = greatest(current_period_end, now())
                                + make_interval(days => v_code.duration_days),
           access_code_id = coalesce(access_code_id, v_code.id),
           updated_at = now()
     where id = v_sub.id
     returning * into v_sub;
  else
    insert into subscriptions (user_id, levels, current_period_end, access_code_id)
    values (v_user, v_code.levels,
            now() + make_interval(days => v_code.duration_days), v_code.id)
    returning * into v_sub;
  end if;

  update access_codes
     set redeemed_at = now(), redeemed_by = v_user
   where id = v_code.id;

  perform register_device(p_fingerprint, p_user_agent);

  return jsonb_build_object(
    'ok', true,
    'levels', v_sub.levels,
    'expires_at', v_sub.current_period_end);
end $$;

-- ---------------------------------------------------------------------
-- نافذة الحصّة: ٣٠ يوم متدحرجة، ما بتصير بالمستقبل مهما كان الاشتراك
-- ---------------------------------------------------------------------
create or replace function writing_quota_state()
returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user  uuid := auth.uid();
  v_since timestamptz := now() - interval '30 days';
  v_quota int;
  v_used  int;
begin
  if v_user is null then return jsonb_build_object('used', 0, 'quota', 0); end if;
  select writing_quota into v_quota from subscriptions
   where user_id = v_user and status = 'active'
   order by current_period_end desc limit 1;
  v_quota := coalesce(v_quota, 20);
  select count(*) into v_used from writing_feedback
   where user_id = v_user and status <> 'failed' and created_at >= v_since;
  return jsonb_build_object('used', v_used, 'quota', v_quota,
                            'since', v_since, 'left', greatest(0, v_quota - v_used));
end $$;

create or replace function writing_start(p_attempt_id uuid)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user  uuid := auth.uid();
  a       attempts%rowtype;
  v_level text;
  v_sec   record;
  v_text  text;
  v_q     jsonb;
  v_id    uuid;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  select * into a from attempts where id = p_attempt_id and user_id = v_user;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'attempt_not_found');
  end if;

  select level_id into v_level from tests where id = a.test_id;
  if not has_access(v_user, v_level) then
    return jsonb_build_object('ok', false, 'error', 'not_entitled');
  end if;

  select s.id, s.section_id, s.instruction, s.config into v_sec
    from sections s
   where s.test_id = a.test_id and s.format = 'writing'
     and s.section_id in (
       select jsonb_array_elements_text(b->'parts')
         from tests t, jsonb_array_elements(t.blocks) b
        where t.id = a.test_id and b->>'id' = a.block_id)
   limit 1;
  if v_sec.id is null then
    return jsonb_build_object('ok', false, 'error', 'not_a_writing_block');
  end if;

  select a.answers ->> i.id::text into v_text
    from items i where i.section_id = v_sec.id order by i.sort limit 1;

  if coalesce(trim(v_text), '') = '' then
    return jsonb_build_object('ok', false, 'error', 'empty_text');
  end if;

  v_q := writing_quota_state();
  if (v_q->>'used')::int >= (v_q->>'quota')::int then
    return jsonb_build_object('ok', false, 'error', 'quota_exceeded',
                              'used', v_q->'used', 'quota', v_q->'quota');
  end if;

  insert into writing_feedback (attempt_id, user_id, section_id, text, word_count,
                                max_points, status)
  values (p_attempt_id, v_user, v_sec.id, v_text,
          array_length(regexp_split_to_array(trim(v_text), '\s+'), 1),
          coalesce((v_sec.config->>'maxPoints')::numeric, 45), 'pending')
  returning id into v_id;

  return jsonb_build_object(
    'ok', true,
    'feedback_id', v_id,
    'text', v_text,
    'instruction', v_sec.instruction,
    'task',      v_sec.config->'brief',
    'points',    (select i.meta->'points' from items i
                   where i.section_id = v_sec.id order by i.sort limit 1),
    'min_words', (select (i.meta->>'minWords')::int from items i
                   where i.section_id = v_sec.id order by i.sort limit 1),
    'criteria',  v_sec.config->'criteria',
    'grades',    v_sec.config->'grades',
    'factor',    coalesce((v_sec.config->>'factor')::numeric, 1),
    'max_points',coalesce((v_sec.config->>'maxPoints')::numeric, 45),
    'level',     v_level,
    'used', v_q->'used', 'quota', v_q->'quota');
end $$;

revoke all on function writing_quota_state() from public;
grant execute on function writing_quota_state() to authenticated;

-- ═══════════════════════════════════════════════
-- 0010_code_uses.sql
-- ═══════════════════════════════════════════════
-- =====================================================================
-- 0010_code_uses — الكود صالح لعدد تفعيلات محدّد
--
-- المشكلة: كل جهاز بياخد حساب مجهول لحاله (ما في إيميل يربطهن). فالكود
-- يلي بينفّذ «مرة وحدة ويرتبط بحساب» كان معناه إن الطالب ما بيقدر
-- يستعمله على جهازه التاني نهائياً — بياخد already_used. وعمود
-- max_devices كان بلا معنى عملياً لأنه بيحدّ أجهزة الحساب الواحد،
-- والحساب أصلاً بيتغيّر مع الجهاز.
--
-- الحل: للكود **عدد تفعيلات** (افتراضي ٢). كل تفعيل على حساب جديد
-- بيستهلك واحد. إعادة الإدخال من نفس الحساب ما بتستهلك — تا يضل
-- النداء آمن للإعادة. لما تخلص التفعيلات، الكود ميّت.
-- =====================================================================

alter table access_codes add column if not exists max_uses int not null default 2;

-- سجلّ التفعيلات: مين فعّل، إمتى، ومن أي جهاز
create table if not exists code_redemptions (
  id          uuid primary key default gen_random_uuid(),
  code_id     uuid not null references access_codes(id) on delete cascade,
  user_id     uuid not null references profiles(id) on delete cascade,
  fingerprint text,
  user_agent  text,
  created_at  timestamptz not null default now(),
  unique (code_id, user_id)
);
create index if not exists code_redemptions_code_idx on code_redemptions (code_id);

alter table code_redemptions enable row level security;
grant select on code_redemptions to authenticated;
-- الأدمن بيقرا كل شي؛ الطالب ما بيشوف ولا صف (ما إله سياسة قراءة خاصة)
drop policy if exists admin_redemptions on code_redemptions;
create policy admin_redemptions on code_redemptions for all to authenticated
  using (is_admin()) with check (is_admin());

-- التفعيلات القديمة (قبل هالترحيل) بتنقل للسجلّ الجديد
insert into code_redemptions (code_id, user_id, created_at)
select id, redeemed_by, redeemed_at from access_codes
 where redeemed_by is not null
on conflict (code_id, user_id) do nothing;

-- كم تفعيل انستهلك
create or replace function code_uses(p_code_id uuid)
returns int language sql stable security definer set search_path = public as $$
  select count(*)::int from code_redemptions where code_id = p_code_id;
$$;

-- ---------------------------------------------------------------------
-- التفعيل
-- ---------------------------------------------------------------------
create or replace function redeem_code(
  p_code        text,
  p_fingerprint text,
  p_user_agent  text default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user uuid := auth.uid();
  v_code access_codes%rowtype;
  v_sub  subscriptions%rowtype;
  v_used int;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  select * into v_code from access_codes
   where upper(code) = upper(trim(p_code))
   for update;                                   -- يمنع تفعيلين بنفس اللحظة

  if not found then
    return jsonb_build_object('ok', false, 'error', 'invalid_code');
  end if;
  if v_code.revoked_at is not null then
    return jsonb_build_object('ok', false, 'error', 'revoked');
  end if;

  insert into profiles (id) values (v_user) on conflict (id) do nothing;

  -- ★ نفس الحساب أعاد الإدخال: بنرجّع حالته بلا استهلاك تفعيل وبلا تمديد
  if exists (select 1 from code_redemptions
              where code_id = v_code.id and user_id = v_user) then
    select * into v_sub from subscriptions
     where user_id = v_user and access_code_id = v_code.id
     order by current_period_end desc limit 1;
    perform register_device(p_fingerprint, p_user_agent);
    return jsonb_build_object(
      'ok', true, 'already', true,
      'levels', coalesce(v_sub.levels, v_code.levels),
      'expires_at', v_sub.current_period_end,
      'uses', code_uses(v_code.id), 'max_uses', v_code.max_uses);
  end if;

  -- ★ حساب جديد: لازم يكون في تفعيل باقي
  v_used := code_uses(v_code.id);
  if v_used >= v_code.max_uses then
    return jsonb_build_object('ok', false, 'error', 'code_exhausted',
                              'uses', v_used, 'max_uses', v_code.max_uses);
  end if;

  select * into v_sub from subscriptions
   where user_id = v_user and status = 'active' and levels @> v_code.levels
   order by current_period_end desc limit 1;

  if found then
    update subscriptions
       set current_period_end = greatest(current_period_end, now())
                                + make_interval(days => v_code.duration_days),
           access_code_id = coalesce(access_code_id, v_code.id),
           updated_at = now()
     where id = v_sub.id
     returning * into v_sub;
  else
    insert into subscriptions (user_id, levels, current_period_end, access_code_id)
    values (v_user, v_code.levels,
            now() + make_interval(days => v_code.duration_days), v_code.id)
    returning * into v_sub;
  end if;

  insert into code_redemptions (code_id, user_id, fingerprint, user_agent)
  values (v_code.id, v_user, p_fingerprint, left(p_user_agent, 200));

  -- أول تفعيل بيعبّي الأعمدة القديمة كمان
  update access_codes
     set redeemed_at = coalesce(redeemed_at, now()),
         redeemed_by = coalesce(redeemed_by, v_user)
   where id = v_code.id;

  perform register_device(p_fingerprint, p_user_agent);

  return jsonb_build_object(
    'ok', true,
    'levels', v_sub.levels,
    'expires_at', v_sub.current_period_end,
    'uses', v_used + 1, 'max_uses', v_code.max_uses);
end $$;

-- ---------------------------------------------------------------------
-- التوليد: عدد التفعيلات صار معامل
-- ---------------------------------------------------------------------
-- النسخة القديمة (٥ معاملات) لازم تنشال: وجودها مع الجديدة بيخلّي أي
-- نداء بـ٥ وسائط ملتبس، لأن السادس عنده قيمة افتراضية.
drop function if exists admin_create_codes(int, text[], int, int, text);

create or replace function admin_create_codes(
  p_count       int,
  p_levels      text[],
  p_days        int,
  p_max_devices int  default 2,      -- محفوظ للتوافق؛ صار max_uses هو الحاكم
  p_note        text default null,
  p_max_uses    int  default 2
) returns setof text
language plpgsql security definer set search_path = public as $$
declare
  alphabet text := '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
  prefix   text := upper(coalesce(p_levels[1], 'XX'));
  v_code   text;
  i        int;
  j        int;
begin
  perform admin_guard();
  if p_count < 1 or p_count > 200 then raise exception 'count_out_of_range'; end if;
  if p_days  < 1 then raise exception 'days_out_of_range'; end if;
  if p_max_uses < 1 or p_max_uses > 10 then raise exception 'uses_out_of_range'; end if;
  if array_length(p_levels, 1) is distinct from 1 then
    raise exception 'exactly_one_level';        -- كود واحد = مستوى واحد
  end if;

  for i in 1..p_count loop
    loop
      v_code := prefix || '-';
      for j in 1..4 loop
        v_code := v_code || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
      end loop;
      v_code := v_code || '-';
      for j in 1..4 loop
        v_code := v_code || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
      end loop;
      exit when not exists (select 1 from access_codes a where a.code = v_code);
    end loop;

    insert into access_codes (code, levels, duration_days, max_devices, max_uses,
                              note, created_by)
    values (v_code, p_levels, p_days, p_max_devices, p_max_uses, p_note, auth.uid());

    perform admin_log('code.create', 'access_code', v_code,
      jsonb_build_object('levels', p_levels, 'days', p_days,
                         'max_uses', p_max_uses, 'note', p_note));
    return next v_code;
  end loop;
end $$;

-- ---------------------------------------------------------------------
-- قائمة الأكواد للوحة، مع عدّاد التفعيلات
-- ---------------------------------------------------------------------
create or replace function admin_codes()
returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  perform admin_guard();
  select coalesce(jsonb_agg(x order by x->>'created_at' desc), '[]') into r
  from (
    select jsonb_build_object(
      'id', c.id, 'code', c.code, 'levels', c.levels,
      'duration_days', c.duration_days, 'max_uses', c.max_uses,
      'uses', (select count(*) from code_redemptions cr where cr.code_id = c.id),
      'note', c.note, 'created_at', c.created_at, 'revoked_at', c.revoked_at,
      'redeemers', (select coalesce(jsonb_agg(jsonb_build_object(
                      'name', p.display_name, 'at', cr.created_at) order by cr.created_at), '[]')
                    from code_redemptions cr
                    left join profiles p on p.id = cr.user_id
                   where cr.code_id = c.id)) as x
      from access_codes c
     order by c.created_at desc
     limit 200
  ) q;
  return r;
end $$;

-- إعادة فتح تفعيل: لما الطالب يضيّع جهازه ويحتاج يفعّل من جديد
create or replace function admin_add_code_use(p_code_id uuid, p_extra int default 1)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_new int;
begin
  perform admin_guard();
  if p_extra < 1 or p_extra > 5 then raise exception 'extra_out_of_range'; end if;
  update access_codes set max_uses = least(max_uses + p_extra, 10)
   where id = p_code_id returning max_uses into v_new;
  if v_new is null then raise exception 'code_not_found'; end if;
  perform admin_log('code.add_use', 'access_code', p_code_id::text,
                    jsonb_build_object('extra', p_extra, 'max_uses', v_new));
  return jsonb_build_object('ok', true, 'max_uses', v_new);
end $$;

revoke all on function code_uses(uuid) from public, authenticated;
revoke all on function admin_codes() from public;
revoke all on function admin_add_code_use(uuid,int) from public;
revoke all on function admin_create_codes(int,text[],int,int,text,int) from public;
grant execute on function admin_codes() to authenticated;
grant execute on function admin_add_code_use(uuid,int) to authenticated;
grant execute on function admin_create_codes(int,text[],int,int,text,int) to authenticated;

-- ═══════════════════════════════════════════════
-- 0011_rate_limit.sql
-- ═══════════════════════════════════════════════
-- =====================================================================
-- 0011_rate_limit — حدّ محاولات على تنفيذ الكود
--
-- الأكواد هي كل آلية الوصول، وما كان في شي يوقف التخمين المتكرّر.
-- فضاء الأكواد ٣١⁸ ≈ ٨×١٠¹¹ فالتخمين الأعمى مو عملي، بس بلا حد:
--   · سكربت بسيط بيقدر يدق آلاف المحاولات بالدقيقة
--   · وكل محاولة استعلام على قاعدة البيانات — يعني تكلفة كمان
--
-- الحد على مستويين، والاتنين قابلين للتجاوز من مهاجم مصمّم (بيعمل
-- حساب جديد وبيمسح البصمة). هدفهن يوقفوا الدق الآلي من عميل واحد،
-- مو يمنعوا هجوم موزّع — هاد شغل حدود Supabase نفسها.
-- =====================================================================

create table if not exists redeem_attempts (
  id          bigserial primary key,
  user_id     uuid references profiles(id) on delete cascade,
  fingerprint text,
  success     boolean not null,
  created_at  timestamptz not null default now()
);
-- المحاولات القديمة ما بتنقرا؛ الفهرس على النافذة الحديثة
create index if not exists redeem_attempts_user_idx
  on redeem_attempts (user_id, created_at desc);
create index if not exists redeem_attempts_fp_idx
  on redeem_attempts (fingerprint, created_at desc);

alter table redeem_attempts enable row level security;
grant select on redeem_attempts to authenticated;
drop policy if exists admin_attempts on redeem_attempts;
create policy admin_attempts on redeem_attempts for all to authenticated
  using (is_admin()) with check (is_admin());
-- الطالب ما بيشوف ولا صف: ما إله سياسة قراءة

-- الحدود بمكان واحد تا تنغيّر بسهولة
create or replace function redeem_limits()
returns jsonb language sql immutable as $$
  select jsonb_build_object(
    'window_minutes', 15,
    'max_failed',     8);     -- محاولات فاشلة بالنافذة قبل القفل
$$;

-- ---------------------------------------------------------------------
-- هل هالمحاولة مقفولة؟ بيرجّع عدد الثواني للفتح، أو 0 إذا مسموح
-- ---------------------------------------------------------------------
create or replace function redeem_blocked_for(p_fingerprint text)
returns int
language plpgsql stable security definer set search_path = public as $$
declare
  v_user  uuid := auth.uid();
  v_lim   jsonb := redeem_limits();
  v_win   interval := make_interval(mins => (v_lim->>'window_minutes')::int);
  v_max   int := (v_lim->>'max_failed')::int;
  v_last  timestamptz;
  v_count int;
begin
  -- الحساب الحالي
  select count(*), max(created_at) into v_count, v_last
    from redeem_attempts
   where not success and created_at > now() - v_win
     and (user_id = v_user
          or (p_fingerprint is not null and fingerprint = p_fingerprint));

  if v_count >= v_max then
    return greatest(1, ceil(extract(epoch from (v_last + v_win - now())))::int);
  end if;
  return 0;
end $$;

-- ---------------------------------------------------------------------
-- التنفيذ، مع تسجيل كل محاولة
-- ---------------------------------------------------------------------
create or replace function redeem_code(
  p_code        text,
  p_fingerprint text,
  p_user_agent  text default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user  uuid := auth.uid();
  v_code  access_codes%rowtype;
  v_sub   subscriptions%rowtype;
  v_used  int;
  v_wait  int;
  v_res   jsonb;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  -- ★ الحد أول شي: قبل أي استعلام على الأكواد
  v_wait := redeem_blocked_for(p_fingerprint);
  if v_wait > 0 then
    return jsonb_build_object('ok', false, 'error', 'too_many_attempts',
                              'retry_after', v_wait);
  end if;

  insert into profiles (id) values (v_user) on conflict (id) do nothing;

  select * into v_code from access_codes
   where upper(code) = upper(trim(p_code))
   for update;                                   -- يمنع تفعيلين بنفس اللحظة

  if not found then
    insert into redeem_attempts (user_id, fingerprint, success)
    values (v_user, p_fingerprint, false);
    return jsonb_build_object('ok', false, 'error', 'invalid_code');
  end if;

  if v_code.revoked_at is not null then
    insert into redeem_attempts (user_id, fingerprint, success)
    values (v_user, p_fingerprint, false);
    return jsonb_build_object('ok', false, 'error', 'revoked');
  end if;

  -- نفس الحساب أعاد الإدخال: بنرجّع حالته بلا استهلاك تفعيل وبلا تمديد.
  -- وهاد نجاح، فما بينحسب محاولة فاشلة.
  if exists (select 1 from code_redemptions
              where code_id = v_code.id and user_id = v_user) then
    select * into v_sub from subscriptions
     where user_id = v_user and access_code_id = v_code.id
     order by current_period_end desc limit 1;
    perform register_device(p_fingerprint, p_user_agent);
    insert into redeem_attempts (user_id, fingerprint, success)
    values (v_user, p_fingerprint, true);
    return jsonb_build_object(
      'ok', true, 'already', true,
      'levels', coalesce(v_sub.levels, v_code.levels),
      'expires_at', v_sub.current_period_end,
      'uses', code_uses(v_code.id), 'max_uses', v_code.max_uses);
  end if;

  -- حساب جديد: لازم يكون في تفعيل باقي
  v_used := code_uses(v_code.id);
  if v_used >= v_code.max_uses then
    insert into redeem_attempts (user_id, fingerprint, success)
    values (v_user, p_fingerprint, false);
    return jsonb_build_object('ok', false, 'error', 'code_exhausted',
                              'uses', v_used, 'max_uses', v_code.max_uses);
  end if;

  select * into v_sub from subscriptions
   where user_id = v_user and status = 'active' and levels @> v_code.levels
   order by current_period_end desc limit 1;

  if found then
    update subscriptions
       set current_period_end = greatest(current_period_end, now())
                                + make_interval(days => v_code.duration_days),
           access_code_id = coalesce(access_code_id, v_code.id),
           updated_at = now()
     where id = v_sub.id
     returning * into v_sub;
  else
    insert into subscriptions (user_id, levels, current_period_end, access_code_id)
    values (v_user, v_code.levels,
            now() + make_interval(days => v_code.duration_days), v_code.id)
    returning * into v_sub;
  end if;

  insert into code_redemptions (code_id, user_id, fingerprint, user_agent)
  values (v_code.id, v_user, p_fingerprint, left(p_user_agent, 200));

  update access_codes
     set redeemed_at = coalesce(redeemed_at, now()),
         redeemed_by = coalesce(redeemed_by, v_user)
   where id = v_code.id;

  perform register_device(p_fingerprint, p_user_agent);

  insert into redeem_attempts (user_id, fingerprint, success)
  values (v_user, p_fingerprint, true);

  return jsonb_build_object(
    'ok', true,
    'levels', v_sub.levels,
    'expires_at', v_sub.current_period_end,
    'uses', v_used + 1, 'max_uses', v_code.max_uses);
end $$;

-- ---------------------------------------------------------------------
-- تنظيف: المحاولات أقدم من يوم ما إلها لزوم
-- بتنندعى من admin_overview تا تصير بلا وظيفة مجدولة
-- ---------------------------------------------------------------------
create or replace function redeem_attempts_prune()
returns int
language plpgsql security definer set search_path = public as $$
declare n int;
begin
  delete from redeem_attempts where created_at < now() - interval '1 day';
  get diagnostics n = row_count;
  return n;
end $$;

-- ---------------------------------------------------------------------
-- للوحة: محاولات فاشلة أخيرة — علامة على حدا عم يجرّب
-- ---------------------------------------------------------------------
create or replace function admin_redeem_activity()
returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  perform admin_guard();
  perform redeem_attempts_prune();
  select jsonb_build_object(
    'failed_1h',  (select count(*) from redeem_attempts
                    where not success and created_at > now() - interval '1 hour'),
    'failed_24h', (select count(*) from redeem_attempts
                    where not success and created_at > now() - interval '24 hours'),
    'ok_24h',     (select count(*) from redeem_attempts
                    where success and created_at > now() - interval '24 hours'),
    'blocked',    (select count(distinct coalesce(fingerprint, user_id::text))
                     from redeem_attempts a
                    where not success
                      and created_at > now() - make_interval(
                            mins => (redeem_limits()->>'window_minutes')::int)
                    group by coalesce(fingerprint, user_id::text)
                   having count(*) >= (redeem_limits()->>'max_failed')::int
                    limit 1),
    'limits',     redeem_limits()
  ) into r;
  return r;
end $$;

revoke all on function redeem_blocked_for(text)   from public;
revoke all on function redeem_attempts_prune()    from public, authenticated;
revoke all on function admin_redeem_activity()    from public;
grant execute on function redeem_blocked_for(text) to authenticated;
grant execute on function admin_redeem_activity()  to authenticated;
