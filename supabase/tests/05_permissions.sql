-- تدقيق صلاحيات: شو بيقدر يعمل طالب عادي فعلياً؟
-- الفحص على **الأثر** مو على الاستثناء: UPDATE يلي ما بيطابق ولا صف
-- بيمرق بلا خطأ وبيعدّل صفر — وهاد نجاح مو ثغرة.
\set ON_ERROR_STOP on
\pset pager off

delete from writing_feedback; delete from admin_audit_log; delete from mistakes;
delete from attempts; delete from imports; delete from resources;
delete from tests where level_id <> 'b1'; delete from levels where id <> 'b1';
delete from devices; delete from subscriptions; delete from access_codes;
delete from profiles; delete from auth.users;

insert into auth.users (id) values
  ('99999999-0000-0000-0000-000000000009'),
  ('88888888-0000-0000-0000-000000000008');
insert into profiles (id, is_admin, display_name) values
  ('99999999-0000-0000-0000-000000000009', false, 'Student'),
  ('88888888-0000-0000-0000-000000000008', false, 'Anderer');
insert into subscriptions (user_id, levels, current_period_end) values
  ('99999999-0000-0000-0000-000000000009', array['b1'], now() + interval '30 days'),
  ('88888888-0000-0000-0000-000000000008', array['b1'], now() + interval '30 days');
insert into access_codes (code, levels, duration_days) values ('B1-SECR-ETXX', array['b1'], 30);

create or replace function t_check(label text, cond boolean)
returns void language plpgsql as $$
begin
  if cond then raise notice '  ✓ %', label;
  else raise exception '  ✗ ثغرة: %', label; end if;
end $$;

-- بينفّذ محاولة وبيرجّع الحالة بعدها — المهم الأثر مو الاستثناء
create or replace function attempt(stmt text) returns void
language plpgsql as $$
begin execute stmt;
exception when others then null;         -- الرفض متوقّع، منكمّل
end $$;

do $$
declare
  me    uuid := '99999999-0000-0000-0000-000000000009';
  other uuid := '88888888-0000-0000-0000-000000000008';
  tid   uuid;
  n     int;
begin
  select id into tid from tests where slug = 'modell-01';
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', me::text, true);

  ---- القراءة ----
  perform attempt('select count(*) from item_answers');
  select count(*) into n from pg_class where false;   -- placeholder
  begin
    select count(*) into n from item_answers;
    perform t_check('★ مفاتيح الحلول', false);
  exception when insufficient_privilege then
    perform t_check('★ مفاتيح الحلول محجوبة', true);
  end;

  select count(*) into n from subscriptions where user_id <> me;
  perform t_check('ما بيشوف اشتراكات غيره', n = 0);
  select count(*) into n from profiles where id <> me;
  perform t_check('ما بيشوف ملفات غيره', n = 0);
  select count(*) into n from devices where user_id <> me;
  perform t_check('ما بيشوف أجهزة غيره', n = 0);
  select count(*) into n from attempts where user_id <> me;
  perform t_check('ما بيشوف محاولات غيره', n = 0);
  select count(*) into n from writing_feedback where user_id <> me;
  perform t_check('ما بيشوف تصحيح غيره', n = 0);
  select count(*) into n from access_codes;
  perform t_check('ما بيشوف الأكواد', n = 0);
  select count(*) into n from admin_audit_log;
  perform t_check('ما بيشوف سجلّ التدقيق', n = 0);
  select count(*) into n from imports;
  perform t_check('ما بيشوف المسوّدات', n = 0);

  ---- الكتابة ----
  perform attempt('update attempts set points = 999');
  perform t_check('ما بيقدر يكتب علامة',
                  (select count(*) from attempts where points is not null) = 0);

  perform attempt(format('update subscriptions set current_period_end = now() + interval ''10 years'' where user_id = %L', me));
  perform t_check('ما بيقدر يمدّد اشتراكه',
                  (select current_period_end < now() + interval '60 days'
                     from subscriptions where user_id = me));

  perform attempt(format('update profiles set is_admin = true where id = %L', me));
  perform t_check('★ ما بيقدر يرقّي حاله لأدمن',
                  (select not is_admin from profiles where id = me));

  perform attempt('update tests set published = true, is_free = true');
  perform t_check('ما بيقدر يفتح الامتحانات مجاناً',
                  (select count(*) from tests where is_free) = 0);

  perform attempt('update items set text = ''hacked''');
  perform t_check('ما بيقدر يعدّل الأسئلة',
                  (select count(*) from items where text = 'hacked') = 0);

  perform attempt('delete from tests');
  perform t_check('ما بيقدر يحذف امتحانات',
                  (select count(*) from tests) = 16);

  perform attempt('delete from admin_audit_log');
  perform attempt('insert into admin_audit_log (action) values (''fake'')');
  perform t_check('ما بيقدر يلمس سجلّ التدقيق',
                  (select count(*) from admin_audit_log) = 0);

  perform attempt('insert into access_codes (code, levels, duration_days)
                   values (''HACK-0000-0000'', array[''b1''], 3650)');
  perform t_check('ما بيقدر يولّد كود',
                  (select count(*) from access_codes where code like 'HACK%') = 0);

  perform attempt(format(
    'insert into attempts (user_id, test_id, block_id, points, max_points, pct)
     values (%L, %L, ''block-lv-sb'', 999, 999, 100)', me, tid));
  perform t_check('★ ما بيقدر يدخّل محاولة بعلامة جاهزة',
                  (select count(*) from attempts where points is not null) = 0);

  perform attempt(format(
    'insert into writing_feedback (attempt_id, user_id, text, points)
     select id, %L, ''x'', 45 from attempts limit 1', me));
  perform t_check('ما بيقدر يكتب تصحيح لحاله',
                  (select count(*) from writing_feedback) = 0);

  ---- الدوال الإدارية ----
  -- الدوال الإدارية ممنوحة لـauthenticated، بس admin_guard() جوّاها
  -- بترمي insufficient_privilege لغير الأدمن. المهم النتيجة مو المنحة.
  begin
    perform admin_create_codes(1, array['b1'], 30, 2, null);
    perform t_check('★ admin_create_codes مرفوضة', false);
  exception when insufficient_privilege then
    perform t_check('★ admin_create_codes مرفوضة', true);
  end;
  begin
    perform admin_users(null);
    perform t_check('★ admin_users مرفوضة', false);
  exception when insufficient_privilege then perform t_check('★ admin_users مرفوضة', true);
  end;
  begin
    perform writing_finish(gen_random_uuid(), '[]'::jsonb, '[]'::jsonb, 's', 'c', 'm');
    perform t_check('★ writing_finish مرفوضة', false);
  exception when insufficient_privilege then perform t_check('★ writing_finish مرفوضة', true);
  end;
  begin
    perform admin_log('x','y','z','{}'::jsonb);
    perform t_check('★ admin_log مرفوضة', false);
  exception when insufficient_privilege then perform t_check('★ admin_log مرفوضة', true);
  end;

  raise notice '';
  raise notice '  كل فحوص الصلاحيات نجحت ✓';
end $$;

drop function t_check(text, boolean);
drop function attempt(text);
