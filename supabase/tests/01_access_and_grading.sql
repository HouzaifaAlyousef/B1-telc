-- اختبار شامل: الصلاحيات + قفل مفاتيح الحلول + التصحيح بالسيرفر + سقف الأجهزة
-- التشغيل: psql -d telc -f supabase/tests/01_access_and_grading.sql
\set ON_ERROR_STOP on
\pset pager off

delete from mistakes; delete from attempts; delete from devices;
delete from subscriptions; delete from access_codes;
delete from profiles; delete from auth.users;

insert into auth.users (id) values
  ('11111111-1111-1111-1111-111111111111'),
  ('22222222-2222-2222-2222-222222222222');
insert into profiles (id) values
  ('11111111-1111-1111-1111-111111111111'),
  ('22222222-2222-2222-2222-222222222222');
insert into access_codes (code, levels, duration_days, max_devices, note)
values ('B1-TEST-0001', array['b1'], 30, 2, 'اختبار آلي');

-- ما بينفع نعرّف دوال جوّا do، فمنستعمل دالة مساعدة بسيطة
create or replace function t_check(label text, cond boolean)
returns void language plpgsql as $$
begin
  if cond then raise notice '  ✓ %', label;
  else raise exception '  ✗ فشل: %', label;
  end if;
end $$;

do $$
declare
  paid uuid := '11111111-1111-1111-1111-111111111111';
  free uuid := '22222222-2222-2222-2222-222222222222';
  tid  uuid;
  n    int;
  res  jsonb;
  got  jsonb := '{}';
  r    record;
begin
  -- معرّف الامتحان بينجاب قبل تقمّص أي مستخدم، لأنه RLS بتحجبه عن غير المشترك
  select id into tid from tests where slug = 'modell-01';

  set local role authenticated;

  ---------------------------------------------------------------- ١
  perform set_config('request.jwt.claim.sub', paid::text, true);
  res := redeem_code('B1-TEST-0001', 'device-aaa', 'agent');
  perform t_check('تنفيذ كود الوصول', (res->>'ok')::boolean);
  perform t_check('الكود فتح مستوى b1', res->'levels' ? 'b1');

  ---------------------------------------------------------------- ٢
  select count(*) into n from tests;
  perform t_check(format('المشترك بيشوف ١٦ امتحان (شاف %s)', n), n = 16);
  select count(*) into n from items;
  perform t_check(format('المشترك بيشوف ٩١٢ سؤال (شاف %s)', n), n = 912);

  ---------------------------------------------------------------- ٣ ★
  begin
    select count(*) into n from item_answers;
    perform t_check('★ مفاتيح الحلول محجوبة', false);
  exception when insufficient_privilege then
    perform t_check('★ مفاتيح الحلول محجوبة تماماً عن العميل', true);
  end;

  ---------------------------------------------------------------- ٤
  perform set_config('request.jwt.claim.sub', free::text, true);
  select count(*) into n from tests;
  perform t_check(format('غير المشترك ما بيشوف امتحانات (شاف %s)', n), n = 0);
  select count(*) into n from items;
  perform t_check(format('غير المشترك ما بيشوف أسئلة (شاف %s)', n), n = 0);

  ---------------------------------------------------------------- ٥
  res := submit_attempt(tid, 'block-lv-sb', '{}'::jsonb);
  perform t_check('غير المشترك ممنوع من التصحيح',
                  res->>'error' = 'not_entitled');

  ---------------------------------------------------------------- ٦
  perform set_config('request.jwt.claim.sub', paid::text, true);
  perform t_check('الجهاز التاني مقبول',
                  (register_device('device-bbb')->>'ok')::boolean);
  perform t_check('الجهاز التالت مرفوض (سقف ٢)',
                  register_device('device-ccc')->>'error' = 'device_limit');

  ---------------------------------------------------------------- ٧ التصحيح
  -- منبني إجابات صح للكتلة الأولى كلها (منقراها كـsuperuser برّا هالجلسة)
  reset role;
  select jsonb_object_agg(i.item_id, ia.answer) into got
    from items i
    join item_answers ia on ia.item_id = i.id
    join sections s on s.id = i.section_id
   where s.test_id = tid and s.section_id in ('lv1','lv2','lv3','sb1','sb2');
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', paid::text, true);

  res := submit_attempt(tid, 'block-lv-sb', got);
  perform t_check('التصحيح رجع ok', (res->>'ok')::boolean);
  perform t_check(format('كل الإجابات صح ← ١٠٠%% (طلع %s%%)', res->>'pct'),
                  (res->>'pct')::numeric = 100);

  -- إجابات كلها غلط
  select jsonb_object_agg(k, 'ZZZ') into got from jsonb_object_keys(got) k;
  res := submit_attempt(tid, 'block-lv-sb', got);
  perform t_check(format('كل الإجابات غلط ← ٠%% (طلع %s%%)', res->>'pct'),
                  (res->>'pct')::numeric = 0);
  perform t_check('الأخطاء انسجّلت للمراجعة',
                  (select count(*) from mistakes) > 0);

  ---------------------------------------------------------------- ٨
  -- العميل ما بيقدر يكتب علامته بإيده
  begin
    insert into attempts (user_id, test_id, block_id, points, max_points, pct)
    values (paid, tid, 'block-lv-sb', 999, 999, 100);
    perform t_check('★ العميل ما بيقدر يزوّر علامته', false);
  exception when insufficient_privilege or check_violation then
    perform t_check('★ العميل ما بيقدر يزوّر علامته', true);
  end;

  raise notice '';
  raise notice '  كل الاختبارات نجحت ✓';
end $$;

drop function t_check(text, boolean);
