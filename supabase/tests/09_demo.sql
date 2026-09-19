-- الكود التجريبي: امتحان واحد، ٢٤ ساعة، عدد تفعيلات محدّد
-- الأهم: الحدّ لازم يمسك بكل مكان بينقرا محتوى، مو بالعرض بس
\set ON_ERROR_STOP on
\pset pager off

delete from mistakes; delete from attempts;
delete from storage.objects; delete from storage.buckets;
delete from devices; delete from code_redemptions;
delete from subscriptions; delete from access_codes;
delete from profiles where id <> 'aaaaaaaa-0000-0000-0000-000000000001';
delete from auth.users where id not in (
  select id from profiles union select 'aaaaaaaa-0000-0000-0000-000000000001'::uuid);

insert into auth.users (id) values
  ('eeeeeeee-0000-0000-0000-000000000001'),   -- أدمن
  ('eeeeeeee-0000-0000-0000-000000000002'),   -- تجريبي
  ('eeeeeeee-0000-0000-0000-000000000003')    -- مشترك كامل
on conflict do nothing;
insert into profiles (id, is_admin) values
  ('eeeeeeee-0000-0000-0000-000000000001', true),
  ('eeeeeeee-0000-0000-0000-000000000002', false),
  ('eeeeeeee-0000-0000-0000-000000000003', false)
on conflict (id) do update set is_admin = excluded.is_admin;

insert into storage.buckets (id, name, public)
values ('exam-images','exam-images',false), ('exam-audio','exam-audio',false)
on conflict (id) do nothing;
insert into storage.objects (bucket_id, name)
select 'exam-images', config->>'bankImage' from sections where config ? 'bankImage';

create or replace function t_check(label text, cond boolean)
returns void language plpgsql as $$
begin
  if cond then raise notice '  ✓ %', label;
  else raise exception '  ✗ فشل: %', label;
  end if;
end $$;

do $$
declare
  adm   uuid := 'eeeeeeee-0000-0000-0000-000000000001';
  demo  uuid := 'eeeeeeee-0000-0000-0000-000000000002';
  full_ uuid := 'eeeeeeee-0000-0000-0000-000000000003';
  t1    text;                 -- أول امتحان (التجريبي)
  t2    text;                 -- امتحان تاني (مدفوع)
  id1   uuid;
  id2   uuid;
  codes text[];
  res   jsonb;
  n     int;
  n_b1  int;                  -- كم امتحان بالمستوى فعلاً — قبل أي دور
  ends  timestamptz;
begin
  select count(*) into n_b1 from tests where level_id = 'b1';
  select slug, id into t1, id1 from tests where level_id='b1' order by sort limit 1;
  select slug, id into t2, id2 from tests where level_id='b1' and slug <> t1 order by sort limit 1;

  set local role authenticated;
  perform set_config('request.jwt.claim.sub', adm::text, true);

  ---------------------------------------------------------------- التوليد
  select array_agg(c) into codes from admin_create_codes(
    1, array['b1'], 0, 3, 'Demo', 3, 24, array[t1]) c;
  perform t_check(format('كود تجريبي انولّد (%s)', codes[1]), codes[1] is not null);

  -- مدّة صفر = كود ميّت من ساعة ولادته، لازم ينرفض
  begin
    perform admin_create_codes(1, array['b1'], 0, 2, null, 2, 0, null);
    perform t_check('٠ يوم + ٠ ساعة مرفوض', false);
  exception when others then
    perform t_check('٠ يوم + ٠ ساعة مرفوض', sqlerrm = 'duration_out_of_range');
  end;

  -- مصفوفة امتحانات فاضية = كود ما بيفتح شي
  begin
    perform admin_create_codes(1, array['b1'], 1, 2, null, 2, 0, array[]::text[]);
    perform t_check('قائمة امتحانات فاضية مرفوضة', false);
  exception when others then
    perform t_check('قائمة امتحانات فاضية مرفوضة', sqlerrm = 'tests_empty');
  end;

  ---------------------------------------------------------------- التفعيل
  perform set_config('request.jwt.claim.sub', demo::text, true);
  res := redeem_code(codes[1], 'demo-dev-1');
  perform t_check('التجريبي فعّل الكود', (res->>'ok')::boolean);
  perform t_check(format('وبيفتح امتحان واحد بس (%s)', res->'tests'->>0),
                  jsonb_array_length(res->'tests') = 1 and res->'tests'->>0 = t1);

  select current_period_end into ends from subscriptions where user_id = demo;
  perform t_check(format('★ بينتهي بعد ٢٤ ساعة (%s)', ends::date),
                  ends between now() + interval '23 hours' and now() + interval '25 hours');

  ---------------------------------------------------------- الحدّ بالقراءة
  perform t_check('بيشوف امتحانه', (select count(*) from tests where slug = t1) = 1);
  perform t_check('★ ما بيشوف باقي امتحانات المستوى',
                  (select count(*) from tests where level_id = 'b1') = 1);
  perform t_check('★ ولا أقسام الامتحان التاني',
                  (select count(*) from sections where test_id = id2) = 0);
  perform t_check('★ ولا أسئلته',
                  (select count(*) from items i join sections s on s.id = i.section_id
                    where s.test_id = id2) = 0);
  select count(*) into n from sections where test_id = id1;
  perform t_check(format('بس أقسام امتحانه ظاهرة (%s)', n), n = 9);

  ---------------------------------------------------------- الحدّ بالتصحيح
  res := submit_attempt(id2, 'block-lv-sb', '{}'::jsonb);
  perform t_check('★ ما بيقدر يصحّح الامتحان التاني',
                  res->>'error' = 'test_not_found' or res->>'error' = 'not_entitled');
  res := submit_attempt(id1, 'block-lv-sb', '{}'::jsonb);
  perform t_check('بس بيقدر يصحّح امتحانه', (res->>'ok')::boolean);

  --------------------------------------------------- الكتالوج (للتسويق)
  -- صاحب التجريبي لازم يشوف إنه في امتحانات تانية — بعنوانها بس.
  res := level_catalog('b1');
  perform t_check(format('الكتالوج بيرجّع كل امتحانات المستوى (%s من %s)',
                         jsonb_array_length(res), n_b1),
                  jsonb_array_length(res) = n_b1 and n_b1 > 0);
  perform t_check('★ واحد مفتوح والباقي مقفول',
    (select count(*) from jsonb_array_elements(res) e
      where (e->>'open')::boolean) = 1);
  perform t_check('★ الكتالوج ما بيحوي أقسام ولا أسئلة ولا حلول',
    not (res::text ~* '(sections|items|answer|"loesung")'));

  -- بلا اشتراك: ولا عنوان. ما منعطي كتالوج مجاني لكل من دقّ الباب.
  set local role postgres;
  update subscriptions set status = 'revoked' where user_id = demo;
  set local role authenticated;
  perform t_check('★ بلا اشتراك ساري ما في كتالوج',
                  jsonb_array_length(level_catalog('b1')) = 0);
  set local role postgres;
  update subscriptions set status = 'active' where user_id = demo;
  set local role authenticated;

  ------------------------------------------------------------ الحدّ بالملفات
  perform t_check('★ ما بيشوف إلا صورة امتحانه',
                  (select count(*) from storage.objects) <= 1);

  --------------------------------------------------------- المشترك الكامل
  perform set_config('request.jwt.claim.sub', adm::text, true);
  select array_agg(c) into codes from admin_create_codes(
    1, array['b1'], 30, 2, 'Voll', 2) c;
  perform set_config('request.jwt.claim.sub', full_::text, true);
  perform redeem_code(codes[1], 'full-dev-1');
  perform t_check(format('المشترك الكامل بيشوف كل الامتحانات (%s)',
                         (select count(*) from tests where level_id = 'b1')),
                  (select count(*) from tests where level_id = 'b1') = n_b1);

  ------------------------------------------- تجريبي + كامل ما بينمزجوا
  perform set_config('request.jwt.claim.sub', adm::text, true);
  select array_agg(c) into codes from admin_create_codes(
    1, array['b1'], 0, 2, 'Demo2', 2, 24, array[t1]) c;
  perform set_config('request.jwt.claim.sub', full_::text, true);
  perform redeem_code(codes[1], 'full-dev-1');
  select count(*) into n from subscriptions where user_id = full_;
  perform t_check(format('★ كود تجريبي ما بيمدّد الاشتراك الكامل (%s اشتراك)', n), n = 2);
  perform t_check('والكامل لسا ٣٠ يوم',
    (select current_period_end > now() + interval '29 days'
       from subscriptions where user_id = full_ and test_slugs is null));

  ------------------------------------------------------ انتهاء التجريبي
  set local role postgres;
  update subscriptions set current_period_end = now() - interval '1 minute'
   where user_id = demo;
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', demo::text, true);
  perform t_check('★ بعد ٢٤ ساعة ما بيشوف ولا امتحان',
                  (select count(*) from tests) = 0);

  raise notice '';
  raise notice '  كل اختبارات الكود التجريبي نجحت ✓';
end $$;

drop function t_check(text, boolean);
