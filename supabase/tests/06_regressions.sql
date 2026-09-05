-- اختبارات انحدار: كل واحد هون بيقابل بغ انكشف بالفحص العدائي.
-- لو رجع البغ، هالملف بيفشل.
\set ON_ERROR_STOP on
\pset pager off

delete from writing_feedback; delete from admin_audit_log; delete from mistakes;
delete from attempts; delete from imports; delete from resources;
delete from tests where level_id <> 'b1'; delete from levels where id <> 'b1';
delete from devices; delete from subscriptions; delete from access_codes;
delete from profiles; delete from auth.users;

insert into auth.users (id) values
  ('aaaa0001-0000-0000-0000-000000000001'),
  ('aaaa0002-0000-0000-0000-000000000002');
insert into profiles (id) values
  ('aaaa0001-0000-0000-0000-000000000001'),
  ('aaaa0002-0000-0000-0000-000000000002');
insert into access_codes (code, levels, duration_days, max_devices) values
  ('B1-ONCE-AAAA', array['b1'], 30, 2),
  ('B1-OTHR-BBBB', array['b1'], 30, 2);

create or replace function t_check(label text, cond boolean)
returns void language plpgsql as $$
begin
  if cond then raise notice '  ✓ %', label;
  else raise exception '  ✗ انحدار: %', label; end if;
end $$;

do $$
declare
  u1  uuid := 'aaaa0001-0000-0000-0000-000000000001';
  u2  uuid := 'aaaa0002-0000-0000-0000-000000000002';
  r   jsonb; d1 timestamptz; d2 timestamptz;
  tid uuid; sid uuid; iid uuid; aid uuid;
  q   jsonb; n int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', u1::text, true);

  ---------------------------------------------------------------- بغ ١
  -- الكود كان بينعاد تنفيذه من نفس المستخدم وبيمدّد كل مرة
  r  := redeem_code('B1-ONCE-AAAA', 'dev-1');
  d1 := (r->>'expires_at')::timestamptz;
  perform t_check('الكود انفّذ أول مرة', (r->>'ok')::boolean);

  r  := redeem_code('B1-ONCE-AAAA', 'dev-1');
  d2 := (r->>'expires_at')::timestamptz;
  perform t_check('★ إعادة التنفيذ ما مدّدت',  d2 = d1);
  perform t_check('وبترجّع already=true',      (r->>'already')::boolean);
  perform t_check('وبتضل ok (آمنة للإعادة)',   (r->>'ok')::boolean);

  for n in 1..10 loop r := redeem_code('B1-ONCE-AAAA', 'dev-1'); end loop;
  perform t_check('★ عشر إعادات ما زادت ولا يوم',
                  (select current_period_end from subscriptions where user_id = u1) = d1);

  ---------------------------------------------------------------- بغ ١ب
  perform set_config('request.jwt.claim.sub', u2::text, true);
  perform t_check('★ كود غيره مرفوض',
                  redeem_code('B1-ONCE-AAAA','dev-x')->>'error' = 'already_used');
  perform t_check('بس كوده هو بينفّذ',
                  (redeem_code('B1-OTHR-BBBB','dev-y')->>'ok')::boolean);

  ---------------------------------------------------------------- بغ ٢
  -- نافذة الحصّة كانت (نهاية الاشتراك − ٣٠ يوم): مع اشتراك سنوي
  -- بتصير بالمستقبل والحصّة ما بتنفرض أبداً
  reset role;
  select t.id, s.id into tid, sid from tests t join sections s on s.test_id = t.id
   where t.slug = 'modell-01' and s.format = 'writing';
  select id into iid from items where section_id = sid limit 1;
  update subscriptions
     set current_period_end = now() + interval '365 days', writing_quota = 2
   where user_id = u1;
  insert into attempts (user_id, test_id, block_id, answers, submitted_at)
  values (u1, tid, 'block-sa',
          jsonb_build_object(iid::text, 'Liebe Anna, ich komme gern nach Deutschland.'), now())
  returning id into aid;

  set local role authenticated;
  perform set_config('request.jwt.claim.sub', u1::text, true);

  q := writing_quota_state();
  perform t_check(format('★ النافذة بالماضي مو بالمستقبل (%s)', (q->>'since')::timestamptz::date),
                  (q->>'since')::timestamptz < now());

  perform t_check('طلب ١ مقبول', (writing_start(aid)->>'ok')::boolean);
  perform t_check('طلب ٢ مقبول', (writing_start(aid)->>'ok')::boolean);
  perform t_check('★ طلب ٣ مرفوض مع اشتراك سنوي',
                  writing_start(aid)->>'error' = 'quota_exceeded');

  -- والفاشل ما بيستهلك حصّة
  reset role;
  update writing_feedback set status = 'failed' where user_id = u1;
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', u1::text, true);
  perform t_check('التصحيح الفاشل ما بيستهلك حصّة',
                  (writing_quota_state()->>'used')::int = 0);

  raise notice '';
  raise notice '  كل اختبارات الانحدار نجحت ✓';
end $$;

drop function t_check(text, boolean);
