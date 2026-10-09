-- صيغة الكود الجديدة: حرفين + عشرة أرقام، ومدخل متسامح
\set ON_ERROR_STOP on
\pset pager off

delete from mistakes; delete from attempts; delete from code_redemptions;
delete from devices; delete from subscriptions; delete from access_codes;
delete from redeem_attempts;
delete from admin_audit_log;
delete from tests  where level_id like 'goethe%';
delete from levels where id       like 'goethe%';

insert into auth.users (id) values
  ('cccccccc-0000-0000-0000-000000000001'),   -- أدمن
  ('cccccccc-0000-0000-0000-000000000002'),   -- طالب: كود جديد
  ('cccccccc-0000-0000-0000-000000000003'),   -- طالب: كود قديم بشرطات
  ('cccccccc-0000-0000-0000-000000000004')    -- طالب: كود Goethe
on conflict do nothing;
insert into profiles (id, is_admin, display_name) values
  ('cccccccc-0000-0000-0000-000000000001', true,  'FMT-Admin'),
  ('cccccccc-0000-0000-0000-000000000002', false, 'FMT-Neu'),
  ('cccccccc-0000-0000-0000-000000000003', false, 'FMT-Alt'),
  ('cccccccc-0000-0000-0000-000000000004', false, 'FMT-Goethe')
on conflict (id) do update
  set is_admin = excluded.is_admin, display_name = excluded.display_name;

create or replace function t_check(label text, cond boolean)
returns void language plpgsql as $$
begin
  if cond then raise notice '  ✓ %', label;
  else raise exception '  ✗ فشل: %', label;
  end if;
end $$;

do $$
declare
  adm   uuid := 'cccccccc-0000-0000-0000-000000000001';
  s_new uuid := 'cccccccc-0000-0000-0000-000000000002';
  s_old uuid := 'cccccccc-0000-0000-0000-000000000003';
  s_goe uuid := 'cccccccc-0000-0000-0000-000000000004';
  codes text[];
  gcode text[];
  r     jsonb;
  n     int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', adm::text, true);

  ------------------------------------------------------------ ١ التطبيع
  perform t_check('التطبيع بيشيل الشرطات والمسافات وبيكبّر الحروف',
                  code_norm('b1 4827 5193 66') = 'B14827519366'
                  and code_norm('B1-4827-5193-66') = 'B14827519366'
                  and code_norm('  B14827519366 ') = 'B14827519366');
  perform t_check('والفاضي بيضل فاضي', code_norm(null) = '' and code_norm('  ') = '');

  ------------------------------------------------------------ ٢ التوليد
  select array_agg(c) into codes
    from admin_create_codes(5, array['b1'], 30, 2, 'صيغة جديدة') c;
  perform t_check(format('الصيغة: حرفين ثم ١٠ أرقام (%s)', codes[1]),
                  codes[1] ~ '^B1[0-9]{10}$');
  perform t_check('كل الخمسة بنفس الشكل',
                  (select bool_and(c ~ '^B1[0-9]{10}$') from unnest(codes) c));
  perform t_check('وما في شرطة ولا حرف ملتبس بالأرقام',
                  codes[1] !~ '[-OIL]');
  perform t_check('الأكواد كلها مختلفة',
                  (select count(distinct c) from unnest(codes) c) = 5);

  -------------------------------------------- ٣ ★ البادئة من الدرجة مو من المعرّف
  -- كانت upper(p_levels[1])، وبعد ترحيل المؤسسات صار المعرّف
  -- «goethe-b1» — يعني الكود كان بيطلع «GOETHE-B1…».
  perform admin_upsert_level(null, null, 0, true, 'Goethe', 'B1');
  select array_agg(c) into gcode
    from admin_create_codes(1, array['goethe-b1'], 30, 2, 'Goethe') c;
  perform t_check(format('★ بادئة Goethe·B1 هي الدرجة (%s)', gcode[1]),
                  gcode[1] ~ '^B1[0-9]{10}$');

  ------------------------------------------------------ ٤ التفعيل متسامح
  perform set_config('request.jwt.claim.sub', s_new::text, true);
  r := redeem_code(codes[1], 'fmt-dev-1');
  perform t_check('الكود الجديد بينفّذ متل ما هو', (r->>'ok')::boolean);

  perform set_config('request.jwt.claim.sub', s_goe::text, true);
  r := redeem_code(
         substr(gcode[1],1,2) || ' ' || substr(gcode[1],3,4) || ' '
         || substr(gcode[1],7,4) || ' ' || substr(gcode[1],11,2),
         'fmt-dev-2');
  perform t_check('★ وبينفّذ مكتوب مجموعات بمسافات', (r->>'ok')::boolean);

  ------------------------------------------------- ٥ ★ الأكواد القديمة لسا شغالة
  perform set_config('request.jwt.claim.sub', adm::text, true);
  insert into access_codes (code, levels, duration_days, max_devices, max_uses)
  values ('B1-7K2M-9XQP', array['b1'], 30, 2, 2);

  perform set_config('request.jwt.claim.sub', s_old::text, true);
  r := redeem_code('B1-7K2M-9XQP', 'fmt-dev-3');
  perform t_check('★ كود بالصيغة القديمة لسا بينفّذ', (r->>'ok')::boolean);

  ------------------------------------------------ ٦ حروف صغيرة وبلا شرطات
  -- نفس الحساب بيعيد الإدخال: بيرجّع already بلا ما يستهلك تفعيل.
  r := redeem_code('  b17k2m9xqp ', 'fmt-dev-3');
  perform t_check('★ ونفسه بحروف صغيرة وبلا شرطات بينعرف',
                  (r->>'ok')::boolean and (r->>'already')::boolean);

  ---------------------------------------------------------- ٧ الغلط بيضل غلط
  r := redeem_code('B1 0000 0000 00', 'fmt-dev-4');
  perform t_check('كود مو موجود بيرفض',
                  not (r->>'ok')::boolean and r->>'error' = 'invalid_code');
  r := redeem_code('---', 'fmt-dev-5');
  perform t_check('★ ومدخل كله شرطات ما بيطابق ولا كود',
                  not (r->>'ok')::boolean and r->>'error' = 'invalid_code');

  -------------------------------------------------- ٨ ★ بحث اللوحة بالمجموعات
  perform set_config('request.jwt.claim.sub', adm::text, true);
  r := admin_users(substr(codes[1],1,2) || ' ' || substr(codes[1],3,4) || ' '
                   || substr(codes[1],7,4) || ' ' || substr(codes[1],11,2));
  perform t_check('★ البحث بكود ملصوق مجموعات بيلاقي صاحبه',
                  jsonb_array_length(r) = 1
                  and r->0->>'name' = 'FMT-Neu');

  r := admin_users('b17k2m9xqp');
  perform t_check('★ والقديم بلا شرطات كمان',
                  jsonb_array_length(r) = 1 and r->0->>'name' = 'FMT-Alt');

  select jsonb_array_length(admin_users('FMT-')) into n;
  perform t_check(format('والبحث بالاسم ما تأثر (%s)', n), n = 3);

  raise notice '';
  raise notice '  كل اختبارات صيغة الكود نجحت ✓';
end $$;

drop function t_check(text, boolean);
