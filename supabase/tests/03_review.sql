-- تكرار متباعد: الصناديق، الفواصل، الاستحقاق، الإتقان
\set ON_ERROR_STOP on
\pset pager off

delete from admin_audit_log; delete from mistakes; delete from attempts;
delete from imports; delete from resources;
delete from tests where level_id <> 'b1'; delete from levels where id <> 'b1';
delete from devices; delete from subscriptions; delete from access_codes;
delete from profiles; delete from auth.users;

insert into auth.users (id) values ('cccccccc-0000-0000-0000-000000000003');
insert into profiles (id) values ('cccccccc-0000-0000-0000-000000000003');
insert into subscriptions (user_id, levels, current_period_end)
values ('cccccccc-0000-0000-0000-000000000003', array['b1'], now() + interval '30 days');

create or replace function t_check(label text, cond boolean)
returns void language plpgsql as $$
begin
  if cond then raise notice '  ✓ %', label;
  else raise exception '  ✗ فشل: %', label; end if;
end $$;

do $$
declare
  u    uuid := 'cccccccc-0000-0000-0000-000000000003';
  tid  uuid;
  got  jsonb;
  res  jsonb;
  sum  jsonb;
  one  uuid;
  n    int;
  d    timestamptz;
begin
  select id into tid from tests where slug = 'modell-01';
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', u::text, true);

  ---------------------------------------------------------------- ١
  -- امتحان كل إجاباته غلط → كل الأسئلة بالصندوق ١ ومستحقّة
  reset role;
  select jsonb_object_agg(i.id::text, 'ZZZ') into got
    from items i join item_answers ia on ia.item_id = i.id
    join sections s on s.id = i.section_id
   where s.test_id = tid and s.section_id in ('lv1','lv2','lv3','sb1','sb2');
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', u::text, true);

  res := submit_attempt(tid, 'block-lv-sb', got);
  perform t_check('امتحان فاشل ← أخطاء انسجّلت', (res->>'pct')::numeric = 0);

  select count(*) into n from mistakes where user_id = u;
  perform t_check(format('%s سؤال بالمراجعة', n), n = 40);
  perform t_check('كلهن بالصندوق ١',
                  (select count(*) from mistakes where user_id = u and box = 1) = 40);

  sum := review_summary();
  perform t_check(format('الملخّص: %s مستحقّ من %s', sum->>'due', sum->>'total'),
                  (sum->>'due')::int = 40 and (sum->>'total')::int = 40);

  ---------------------------------------------------------------- ٢
  -- مراجعة صحيحة → الصندوق ٢ والموعد بعد ٣ أيام
  reset role;
  select jsonb_object_agg(m.item_id::text, ia.answer) into got
    from mistakes m join item_answers ia on ia.item_id = m.item_id
   where m.user_id = u;
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', u::text, true);

  res := submit_drill(got);
  perform t_check('مراجعة كلها صح', (res->>'pct')::numeric = 100);
  perform t_check('كلهن صعدوا للصندوق ٢',
                  (select count(*) from mistakes where user_id = u and box = 2) = 40);
  select due_at into d from mistakes where user_id = u limit 1;
  perform t_check(format('الموعد الجاي بعد ٣ أيام (%s)', d::date),
                  d::date = (now() + interval '3 days')::date);

  sum := review_summary();
  perform t_check('ما بقي شي مستحقّ اليوم', (sum->>'due')::int = 0);
  perform t_check('بس المجموع لسا ٤٠', (sum->>'total')::int = 40);

  ---------------------------------------------------------------- ٣
  -- غلطة واحدة بالمراجعة ترجّع سؤالها للصندوق ١
  select item_id into one from mistakes where user_id = u limit 1;
  update mistakes set due_at = now() - interval '1 hour' where user_id = u;

  res := submit_drill(jsonb_build_object(one::text, 'FALSCH'));
  perform t_check('جواب غلط بالمراجعة', (res->>'right')::int = 0);
  perform t_check('السؤال رجع للصندوق ١',
                  (select box from mistakes where user_id = u and item_id = one) = 1);
  perform t_check('عدّاد الأخطاء زاد',
                  (select wrong_count from mistakes where user_id = u and item_id = one) = 2);

  ---------------------------------------------------------------- ٤
  -- التصعيد لحتى الإتقان
  reset role;
  select jsonb_object_agg(m.item_id::text, ia.answer) into got
    from mistakes m join item_answers ia on ia.item_id = m.item_id
   where m.user_id = u and m.item_id = one;
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', u::text, true);

  for n in 1..5 loop
    update mistakes set due_at = now() - interval '1 hour'
     where user_id = u and item_id = one;
    res := submit_drill(got);
  end loop;
  perform t_check(format('بعد ٥ إجابات صحيحة صار بالصندوق %s',
                         (select box from mistakes where user_id = u and item_id = one)),
                  (select box from mistakes where user_id = u and item_id = one) = 6);
  perform t_check('آخر مراجعة أعلنت الإتقان', (res->>'mastered')::int = 1);

  sum := review_summary();
  perform t_check(format('الملخّص بيعدّ %s متقن', sum->>'mastered'),
                  (sum->>'mastered')::int = 1);
  perform t_check('المتقن طلع من المجموع النشط', (sum->>'total')::int = 39);

  ---------------------------------------------------------------- ٥
  -- الفواصل نفسها
  perform t_check('فواصل الصناديق ١،٣،٧،١٦،٣٥',
    review_interval(1) = interval '1 day'  and review_interval(2) = interval '3 days' and
    review_interval(3) = interval '7 days' and review_interval(4) = interval '16 days' and
    review_interval(5) = interval '35 days');
  perform t_check('صندوق برّا المدى بينحصر', review_interval(99) = interval '35 days');

  ---------------------------------------------------------------- ٦
  -- غلطة بالامتحان بترجّع حتى المتقن للصندوق ١
  reset role;
  select jsonb_object_agg(i.id::text, 'ZZZ') into got
    from items i where i.id = one;
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', u::text, true);
  res := submit_attempt(tid, 'block-lv-sb', got);
  perform t_check('★ الغلط بامتحان جديد بيرجّع المتقن للصندوق ١',
                  (select box from mistakes where user_id = u and item_id = one) = 1
                  and (select due_at from mistakes where user_id = u and item_id = one)
                      <= now() + interval '1 minute');

  raise notice '';
  raise notice '  كل اختبارات المراجعة نجحت ✓';
end $$;

drop function t_check(text, boolean);
