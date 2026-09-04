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
create table levels (
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
create table profiles (
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
create table access_codes (
  id             uuid primary key default gen_random_uuid(),
  code           text unique not null,       -- 'B1-7K2M-9XQP'
  levels         text[] not null,            -- شو بيفتحله: {'b1'} أو {'a1','a2'}
  duration_days  int  not null,              -- ٣٠، ٩٠، ٣٦٥...
  max_devices    int  not null default 2,    -- الدفاع الأساسي ضد مشاركة الكود
  note           text,                       -- لمين هالكود ومتى دفع
  created_by     uuid references profiles(id),
  created_at     timestamptz not null default now(),
  redeemed_at    timestamptz,
  redeemed_by    uuid references profiles(id),
  revoked_at     timestamptz
);
create index on access_codes (redeemed_by);

-- ---------------------------------------------------------------------
-- الاشتراكات — هي مصدر الحقيقة لـ«هل هالمستخدم مسموحله»
-- ---------------------------------------------------------------------
create table subscriptions (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid not null references profiles(id) on delete cascade,
  levels              text[] not null,
  status              text not null default 'active',   -- active|expired|revoked
  current_period_end  timestamptz not null,             -- بتمدّديها أو بتقصّريها من اللوحة
  source              text not null default 'manual',   -- manual | stripe (لاحقاً)
  access_code_id      uuid references access_codes(id),
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);
create index on subscriptions (user_id);

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
create table devices (
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
create table tests (
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

create table sections (
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

create table items (
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
create table item_answers (
  item_id     uuid primary key references items(id) on delete cascade,
  answer      text not null,
  explanation text                           -- شرح اختياري بينعرض بعد التسليم
);

-- ---------------------------------------------------------------------
-- المراجع — النقطة ٤: نصوص بتلصقيها من اللوحة والمستخدم بيقراها أي وقت
-- ---------------------------------------------------------------------
create table resources (
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
create table imports (
  id          uuid primary key default gen_random_uuid(),
  level_id    text references levels(id),
  raw_text    text not null,                 -- يلي لصقتيه
  parsed      jsonb,                         -- ناتج التحليل — بتراجعيه قبل الاعتماد
  status      text not null default 'draft', -- draft|parsed|needs_review|applied|failed
  error       text,
  test_id     uuid references tests(id),     -- بينتعبّى بعد الاعتماد
  created_by  uuid references profiles(id),
  created_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- تقدّم المستخدم
-- ---------------------------------------------------------------------
create table attempts (
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
create index on attempts (user_id, test_id);

create table mistakes (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references profiles(id) on delete cascade,
  item_id      uuid not null references items(id) on delete cascade,
  wrong_count  int not null default 1,
  last_seen_at timestamptz not null default now(),
  unique (user_id, item_id)
);

create table admin_audit_log (
  id          uuid primary key default gen_random_uuid(),
  admin_id    uuid references profiles(id),
  action      text not null,                 -- 'code.create','sub.extend','sub.revoke'
  target_type text,
  target_id   text,
  detail      jsonb,
  created_at  timestamptz not null default now()
);
