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
    execute format(
      'create policy admin_all on %I for all to authenticated
         using (is_admin()) with check (is_admin())', t);
  end loop;
end $$;

-- ---------------------------------------------------------------------
-- المستخدم العادي
-- ---------------------------------------------------------------------

-- ملفه الشخصي
create policy own_profile on profiles for select to authenticated
  using (id = auth.uid());

-- اشتراكه — بيشوفه بس، ما بيعدّله (التمديد من اللوحة فقط)
create policy own_subs on subscriptions for select to authenticated
  using (user_id = auth.uid());

-- أجهزته
create policy own_devices on devices for select to authenticated
  using (user_id = auth.uid());

-- المستويات المنشورة مكشوفة للكل (لعرض قائمة «شو في»)
create policy levels_public on levels for select to authenticated
  using (published);

-- الامتحانات: المنشور، وبس إذا مجاني أو عنده اشتراك ساري بهالمستوى
create policy tests_entitled on tests for select to authenticated
  using (published and (is_free or has_access(auth.uid(), level_id)));

-- الأقسام والأسئلة: بتتبع صلاحية الامتحان
create policy sections_entitled on sections for select to authenticated
  using (exists (
    select 1 from tests t
    where t.id = sections.test_id
      and t.published
      and (t.is_free or has_access(auth.uid(), t.level_id))));

create policy items_entitled on items for select to authenticated
  using (exists (
    select 1 from sections s join tests t on t.id = s.test_id
    where s.id = items.section_id
      and t.published
      and (t.is_free or has_access(auth.uid(), t.level_id))));

-- ★ item_answers: ما في ولا سياسة. مقفول تماماً على العميل.

-- المراجع: المنشور لمستوى عنده اشتراك فيه (أو العام)
create policy resources_entitled on resources for select to authenticated
  using (published and (level_id is null or has_access(auth.uid(), level_id)));

-- محاولاته: بيقرا وبينشئ تبعه بس. التعديل ممنوع — النتيجة بتنكتب من
-- submit_attempt() لحتى ما يقدر يكتب علامته بإيده.
create policy own_attempts_read on attempts for select to authenticated
  using (user_id = auth.uid());
create policy own_attempts_insert on attempts for insert to authenticated
  with check (user_id = auth.uid() and points is null);

-- أخطاؤه
create policy own_mistakes on mistakes for select to authenticated
  using (user_id = auth.uid());
