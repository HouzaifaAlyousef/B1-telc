-- اختبار لوحة التحكّم: الإجراءات، سجلّ التدقيق، ومنع غير الأدمن
\set ON_ERROR_STOP on
\pset pager off

delete from admin_audit_log; delete from mistakes; delete from attempts;
delete from devices; delete from subscriptions; delete from access_codes;
delete from profiles; delete from auth.users;

insert into auth.users (id) values
  ('aaaaaaaa-0000-0000-0000-000000000001'),   -- أدمن
  ('bbbbbbbb-0000-0000-0000-000000000002');   -- طالب
insert into profiles (id, is_admin, display_name) values
  ('aaaaaaaa-0000-0000-0000-000000000001', true,  'Admin'),
  ('bbbbbbbb-0000-0000-0000-000000000002', false, null);

create or replace function t_check(label text, cond boolean)
returns void language plpgsql as $$
begin
  if cond then raise notice '  ✓ %', label;
  else raise exception '  ✗ فشل: %', label;
  end if;
end $$;

do $$
declare
  adm   uuid := 'aaaaaaaa-0000-0000-0000-000000000001';
  stud  uuid := 'bbbbbbbb-0000-0000-0000-000000000002';
  codes text[];
  sub   uuid;
  res   jsonb;
  ov    jsonb;
  n     int;
  d1    timestamptz;
  d2    timestamptz;
begin
  set local role authenticated;

  ---------------------------------------------------------------- ١ الحارس
  perform set_config('request.jwt.claim.sub', stud::text, true);
  begin
    perform admin_create_codes(1, array['b1'], 30, 2, 'محاولة');
    perform t_check('★ الطالب ممنوع من توليد أكواد', false);
  exception when insufficient_privilege then
    perform t_check('★ الطالب ممنوع من توليد أكواد', true);
  end;
  begin
    perform admin_users(null);
    perform t_check('★ الطالب ممنوع من قائمة المستخدمين', false);
  exception when insufficient_privilege then
    perform t_check('★ الطالب ممنوع من قائمة المستخدمين', true);
  end;

  ---------------------------------------------------------------- ٢ توليد أكواد
  perform set_config('request.jwt.claim.sub', adm::text, true);
  select array_agg(c) into codes from admin_create_codes(5, array['b1'], 30, 2, 'دفعة اختبار') c;
  perform t_check(format('توليد ٥ أكواد (طلع %s)', array_length(codes,1)),
                  array_length(codes, 1) = 5);
  perform t_check('صيغة الكود B1-XXXX-XXXX', codes[1] ~ '^B1-[2-9A-HJ-NP-Z]{4}-[2-9A-HJ-NP-Z]{4}$');
  perform t_check('الأكواد كلها مختلفة',
                  (select count(distinct c) from unnest(codes) c) = 5);
  perform t_check('التوليد انسجّل بسجلّ التدقيق',
                  (select count(*) from admin_audit_log where action='code.create') = 5);

  ---------------------------------------------------------------- ٣ الطالب بينفّذ كود
  perform set_config('request.jwt.claim.sub', stud::text, true);
  res := redeem_code(codes[1], 'dev-1', 'agent');
  perform t_check('الطالب نفّذ الكود', (res->>'ok')::boolean);

  ---------------------------------------------------------------- ٤ تمديد وتقصير
  perform set_config('request.jwt.claim.sub', adm::text, true);
  select id, current_period_end into sub, d1 from subscriptions where user_id = stud;

  res := admin_shift_subscription(sub, 30);
  d2  := (res->>'current_period_end')::timestamptz;
  perform t_check(format('التمديد ٣٠ يوم (%s ← %s)', d1::date, d2::date),
                  d2::date = (d1 + interval '30 days')::date);

  res := admin_shift_subscription(sub, -15);
  perform t_check('التقصير ١٥ يوم',
                  (res->>'current_period_end')::timestamptz::date
                  = (d2 - interval '15 days')::date);

  -- التقصير المبالغ فيه ما بيرجّع الاشتراك للماضي
  res := admin_shift_subscription(sub, -9999);
  perform t_check('التقصير الكبير بيوقف عند اليوم، ما بيرجع للماضي',
                  (res->>'current_period_end')::timestamptz <= now() + interval '1 minute'
                  and (res->>'current_period_end')::timestamptz >= now() - interval '1 minute');

  -- ونعيد تمديده تا نكمّل
  perform admin_set_period_end(sub, now() + interval '30 days');
  perform t_check('ضبط تاريخ انتهاء محدّد',
                  (select current_period_end > now() + interval '29 days'
                     from subscriptions where id = sub));

  ---------------------------------------------------------------- ٥ الإلغاء
  perform admin_set_subscription_status(sub, 'revoked');
  perform t_check('الإلغاء شغّال',
                  (select status from subscriptions where id = sub) = 'revoked');
  perform t_check('الملغى ما بيعود يشوف الامتحانات',
                  not has_access(stud, 'b1'));
  perform admin_set_subscription_status(sub, 'active');
  perform t_check('إعادة التفعيل شغّالة', has_access(stud, 'b1'));

  ---------------------------------------------------------------- ٦ الأجهزة
  perform set_config('request.jwt.claim.sub', stud::text, true);
  perform register_device('dev-2');
  perform t_check('الطالب صار عنده جهازين',
                  (select count(*) from devices where user_id = stud) = 2);
  perform set_config('request.jwt.claim.sub', adm::text, true);
  res := admin_reset_devices(stud);
  perform t_check(format('تصفير الأجهزة شال %s', res->>'removed'),
                  (res->>'removed')::int = 2
                  and (select count(*) from devices where user_id = stud) = 0);

  ---------------------------------------------------------------- ٧ تسمية المستخدم
  perform admin_set_profile(stud, 'أحمد', 'واتساب 0176…');
  perform t_check('اسم وملاحظة المستخدم انحفظوا',
                  (select display_name = 'أحمد' from profiles where id = stud));

  ---------------------------------------------------------------- ٨ إلغاء كود
  perform admin_revoke_code((select id from access_codes where code = codes[2]));
  perform set_config('request.jwt.claim.sub', stud::text, true);
  perform t_check('الكود الملغى ما بينفّذ',
                  redeem_code(codes[2], 'dev-x')->>'error' = 'revoked');

  ---------------------------------------------------------------- ٩ اللوحة
  perform set_config('request.jwt.claim.sub', adm::text, true);
  ov := admin_overview();
  perform t_check(format('اللوحة: %s مستخدم، %s اشتراك فعّال، %s كود غير مستعمل',
                         ov->>'users', ov->>'active_subs', ov->>'codes_unused'),
                  (ov->>'users')::int = 1 and (ov->>'active_subs')::int = 1
                  and (ov->>'codes_unused')::int = 3);

  res := admin_users(null);
  perform t_check('قائمة المستخدمين فيها الطالب مع اشتراكه',
                  jsonb_array_length(res) = 1
                  and res->0->>'name' = 'أحمد'
                  and res->0->'sub'->>'status' = 'active');
  perform t_check('البحث بالكود بيلاقي المستخدم',
                  jsonb_array_length(admin_users(codes[1])) = 1);
  perform t_check('البحث بكلمة مو موجودة بيرجّع فاضي',
                  jsonb_array_length(admin_users('zzzznope')) = 0);

  ---------------------------------------------------------------- ١٠ التدقيق
  select count(*) into n from admin_audit_log where admin_id = adm;
  perform t_check(format('★ كل إجراء انسجّل (%s سطر)', n), n >= 12);

  raise notice '';
  raise notice '  كل اختبارات اللوحة نجحت ✓';
end $$;

drop function t_check(text, boolean);
