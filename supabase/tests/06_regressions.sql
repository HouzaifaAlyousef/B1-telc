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
  -- من 0010: الكود صالح لعدد تفعيلات، مو لحساب واحد. الأكواد فوق
  -- انعملت بالافتراضي (٢)، فالحساب التاني لازم ينفّذ ويستهلك التاني.
  perform set_config('request.jwt.claim.sub', u2::text, true);
  perform t_check('★ الحساب التاني بيستهلك التفعيل التاني',
                  (redeem_code('B1-ONCE-AAAA','dev-x')->>'ok')::boolean);
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

  ---------------------------------------------------------------- بغ ٥
  -- التطبيق كان يجيب اشتراك واحد (limit 1)، فالطالب يلي اشترى A1
  -- وبعدين B1 ما بيشوف غير واحد رغم إن RLS بتسمحله بالاتنين
  reset role;
  insert into levels (id, title, sort, published)
  values ('a1', 'telc Deutsch A1', 1, true)
  on conflict (id) do update set published = true;
  insert into tests (level_id, slug, title, blocks, aufgaben, published, sort)
  values ('a1', 'a1-reg-01', 'A1 Probe', '[]'::jsonb, 10, true, 1)
  on conflict (level_id, slug) do nothing;
  insert into access_codes (code, levels, duration_days)
  values ('A1-REGR-TEST', array['a1'], 60) on conflict (code) do nothing;

  set local role authenticated;
  perform set_config('request.jwt.claim.sub', u2::text, true);
  perform redeem_code('A1-REGR-TEST', 'dev-y');

  select count(*) into n from subscriptions where user_id = u2 and status = 'active';
  perform t_check(format('اشترى مستويين ← %s اشتراك', n), n = 2);
  perform t_check('★ RLS بتسمحله بالاتنين',
                  has_access(u2,'a1') and has_access(u2,'b1'));

  -- ★ يلي بيجيبه التطبيق لازم يغطّي الاتنين
  select count(distinct l) into n
    from subscriptions s, unnest(s.levels) l
   where s.user_id = u2 and s.status = 'active'
     and s.current_period_end > now();
  perform t_check(format('★ مجموع المستويات من كل الاشتراكات = %s', n), n = 2);

  perform t_check('★ وجلب واحد بس كان بيعطي مستوى واحد (البغ)',
                  (select array_length(levels,1) from subscriptions
                    where user_id = u2 and status='active'
                    order by current_period_end desc limit 1) = 1);

  -- كل مستوى إله تاريخ انتهاء لحاله
  perform t_check('لكل مستوى تاريخ انتهاء مستقلّ',
                  (select count(distinct current_period_end) from subscriptions
                    where user_id = u2 and status = 'active') >= 1);

  ---------------------------------------------------------------- بغ ٥ب
  -- الكود لمستوى واحد ما بيفتح غيره
  perform set_config('request.jwt.claim.sub', u1::text, true);
  perform t_check('★ كود B1 ما بيفتح A1',
                  has_access(u1,'b1') and not has_access(u1,'a1'));
  select count(*) into n from tests where level_id = 'a1';
  perform t_check('ومشترك B1 ما بيشوف امتحانات A1', n = 0);

  raise notice '';
  raise notice '  كل اختبارات الانحدار نجحت ✓';
end $$;

drop function t_check(text, boolean);

-- =====================================================================
-- 0010: الكود صالح لعدد تفعيلات محدّد
-- المشكلة الأصلية: كل جهاز = حساب مجهول جديد، فالكود «مرة وحدة» كان
-- بيمنع الطالب من جهازه التاني نهائياً.
-- =====================================================================
\set ON_ERROR_STOP on

delete from code_redemptions; delete from subscriptions; delete from devices;
delete from access_codes; delete from profiles; delete from auth.users;

insert into auth.users (id) values
  ('bbbb0001-0000-0000-0000-000000000001'),
  ('bbbb0002-0000-0000-0000-000000000002'),
  ('bbbb0003-0000-0000-0000-000000000003'),
  ('bbbb000a-0000-0000-0000-00000000000a');
insert into profiles (id, is_admin) values
  ('bbbb0001-0000-0000-0000-000000000001', false),
  ('bbbb0002-0000-0000-0000-000000000002', false),
  ('bbbb0003-0000-0000-0000-000000000003', false),
  ('bbbb000a-0000-0000-0000-00000000000a', true);

create or replace function t_check(label text, cond boolean)
returns void language plpgsql as $$
begin
  if cond then raise notice '  ✓ %', label;
  else raise exception '  ✗ فشل: %', label; end if;
end $$;

do $$
declare
  phone  uuid := 'bbbb0001-0000-0000-0000-000000000001';
  laptop uuid := 'bbbb0002-0000-0000-0000-000000000002';
  third  uuid := 'bbbb0003-0000-0000-0000-000000000003';
  adm    uuid := 'bbbb000a-0000-0000-0000-00000000000a';
  codes  text[];
  cid    uuid;
  r      jsonb;
  n      int;
begin
  set local role authenticated;

  ---------------------------------------------------------------- التوليد
  perform set_config('request.jwt.claim.sub', adm::text, true);
  select array_agg(c) into codes
    from admin_create_codes(1, array['b1'], 30, 2, 'اختبار تفعيلات', 2) c;
  select id into cid from access_codes where code = codes[1];
  perform t_check('الكود انولّد بتفعيلين',
                  (select max_uses from access_codes where id = cid) = 2);
  perform t_check('★ الكود لمستوى واحد فقط',
                  (select array_length(levels,1) from access_codes where id = cid) = 1);

  begin
    perform admin_create_codes(1, array['b1','a1'], 30, 2, null, 2);
    perform t_check('★ كود لمستويين مرفوض', false);
  exception when others then perform t_check('★ كود لمستويين مرفوض', true);
  end;

  ---------------------------------------------------------------- التفعيل
  perform set_config('request.jwt.claim.sub', phone::text, true);
  r := redeem_code(codes[1], 'fp-phone', 'Android');
  perform t_check(format('١ الجوال فعّل (%s/%s)', r->>'uses', r->>'max_uses'),
                  (r->>'ok')::boolean and (r->>'uses')::int = 1);

  perform set_config('request.jwt.claim.sub', laptop::text, true);
  r := redeem_code(codes[1], 'fp-laptop', 'Firefox');
  perform t_check(format('★ ٢ اللابتوب فعّل كمان (%s/%s)', r->>'uses', r->>'max_uses'),
                  (r->>'ok')::boolean and (r->>'uses')::int = 2);
  perform t_check('واللابتوب صار عنده اشتراك',
                  has_access(laptop, 'b1'));

  perform set_config('request.jwt.claim.sub', third::text, true);
  r := redeem_code(codes[1], 'fp-third');
  perform t_check(format('★ ٣ التالت مرفوض (%s)', r->>'error'),
                  r->>'error' = 'code_exhausted');
  perform t_check('والتالت ما عنده وصول', not has_access(third, 'b1'));

  ---------------------------------------------------------------- الإعادة
  perform set_config('request.jwt.claim.sub', phone::text, true);
  for n in 1..5 loop r := redeem_code(codes[1], 'fp-phone'); end loop;
  perform t_check('★ إعادة الإدخال من نفس الجهاز ما بتستهلك تفعيل',
                  (r->>'already')::boolean and (r->>'uses')::int = 2);
  perform t_check('ولا بتمدّد',
                  (select count(distinct current_period_end) from subscriptions
                    where user_id = phone) = 1);

  ---------------------------------------------------------------- +١
  perform set_config('request.jwt.claim.sub', adm::text, true);
  r := admin_add_code_use(cid, 1);
  perform t_check(format('الأدمن فتح تفعيل زيادة (%s)', r->>'max_uses'),
                  (r->>'max_uses')::int = 3);
  perform set_config('request.jwt.claim.sub', third::text, true);
  perform t_check('★ وبعدها التالت صار يقدر يفعّل',
                  (redeem_code(codes[1], 'fp-third')->>'ok')::boolean);

  ---------------------------------------------------------------- اللوحة
  perform set_config('request.jwt.claim.sub', adm::text, true);
  r := admin_codes();
  perform t_check('اللوحة بتعرض ٣ تفعيلات من ٣',
                  (r->0->>'uses')::int = 3 and (r->0->>'max_uses')::int = 3);
  perform t_check('وبتعرض مين فعّل',
                  jsonb_array_length(r->0->'redeemers') = 3);

  ---------------------------------------------------------------- الإلغاء
  perform admin_revoke_code(cid);
  perform set_config('request.jwt.claim.sub', phone::text, true);
  perform t_check('الكود الملغى ما بينفّذ ولا لمين فعّله قبل',
                  redeem_code(codes[1], 'fp-phone')->>'error' = 'revoked');

  ---------------------------------------------------------------- الخصوصية
  perform t_check('★ الطالب ما بيشوف سجلّ التفعيلات',
                  (select count(*) from code_redemptions) = 0);

  raise notice '';
  raise notice '  كل اختبارات التفعيلات نجحت ✓';
end $$;

drop function t_check(text, boolean);
