-- قائمة الانتظار: الحدّ بيشتغل، والكود ما بينضيع
\set ON_ERROR_STOP on
\pset pager off

delete from waitlist;
delete from mistakes; delete from attempts; delete from code_redemptions;
delete from devices; delete from subscriptions; delete from access_codes;
delete from redeem_attempts;
update app_limits set max_active = 0, max_new_per_day = 0;

insert into auth.users (id) values
  ('eeee0000-0000-0000-0000-000000000001'),   -- أدمن
  ('eeee0000-0000-0000-0000-000000000002'),
  ('eeee0000-0000-0000-0000-000000000003'),
  ('eeee0000-0000-0000-0000-000000000004')
on conflict do nothing;
insert into profiles (id, is_admin, display_name) values
  ('eeee0000-0000-0000-0000-000000000001', true,  'WL-Admin'),
  ('eeee0000-0000-0000-0000-000000000002', false, 'WL-Eins'),
  ('eeee0000-0000-0000-0000-000000000003', false, 'WL-Zwei'),
  ('eeee0000-0000-0000-0000-000000000004', false, 'WL-Drei')
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
  adm uuid := 'eeee0000-0000-0000-0000-000000000001';
  u1  uuid := 'eeee0000-0000-0000-0000-000000000002';
  u2  uuid := 'eeee0000-0000-0000-0000-000000000003';
  u3  uuid := 'eeee0000-0000-0000-0000-000000000004';
  codes text[];
  r   jsonb;
  n   int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', adm::text, true);
  select array_agg(c) into codes
    from admin_create_codes(4, array['b1'], 30, 2, 'انتظار', 2) c;

  ------------------------------------------------------- ١ بلا حدّ
  perform t_check('الافتراضي بلا حدّ',
    (capacity()->>'max_active')::int = 0 and (capacity()->>'max_new_per_day')::int = 0);

  perform set_config('request.jwt.claim.sub', u1::text, true);
  r := redeem_code(codes[1], 'wl-1');
  perform t_check('بلا حدّ: التفعيل بيمرق', (r->>'ok')::boolean);

  ------------------------------------------------- ٢ حدّ المشتركين الفعّالين
  perform set_config('request.jwt.claim.sub', adm::text, true);
  r := admin_limits(1, 0);                       -- مطرح واحد، وهو مليان
  perform t_check(format('الحدّ انحفظ (%s فعّال من %s)',
                         r->>'active', r->>'max_active'),
                  (r->>'max_active')::int = 1 and (r->>'active')::int = 1);

  perform set_config('request.jwt.claim.sub', u2::text, true);
  r := redeem_code(codes[2], 'wl-2');
  perform t_check('★ الزحمة بتحطّه بالانتظار مو بتقبله',
                  not (r->>'ok')::boolean and r->>'error' = 'waitlist');
  perform t_check(format('★ وبيقلّه رقمه (%s)', r->>'position'),
                  (r->>'position')::int = 1);

  -- ★ أهم فحص: الكود ما انستهلك
  -- ★ بلا دور: RLS بتخبّي صفوف code_redemptions عن الطالب، فالفحص
  -- بهويّته كان بيمرق حتى لو الكود انستهلك فعلاً.
  reset role;
  perform t_check('★ الكود ما انستهلك — بيضل ساري لصاحبه',
                  code_uses((select id from access_codes where code = codes[2])) = 0);
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', u2::text, true);
  perform t_check('★ وما انفتحله اشتراك',
                  not exists (select 1 from subscriptions where user_id = u2));

  -- الجدول ما إله GRANT للطالب بالقصد: الدوال هي الطريق الوحيد
  begin
    perform 1 from waitlist limit 1;
    perform t_check('★ الطالب ما بيقدر يقرا الطابور مباشرةً', false);
  exception when insufficient_privilege then
    perform t_check('★ الطالب ما بيقدر يقرا الطابور مباشرةً', true);
  end;

  -- ★ ولا انقفل عليه الإدخال: كود صحيح مو محاولة فاشلة
  perform t_check('★ وما انحسبت محاولة فاشلة عليه',
                  redeem_blocked_for('wl-2') = 0);

  -- تالت واحد بياخد الرقم التاني
  perform set_config('request.jwt.claim.sub', u3::text, true);
  r := redeem_code(codes[3], 'wl-3');
  perform t_check(format('★ التالت بياخد الرقم التاني (%s)', r->>'position'),
                  (r->>'position')::int = 2);

  -- الطالب بيسأل عن حالته
  perform set_config('request.jwt.claim.sub', u2::text, true);
  r := waitlist_status();
  perform t_check('★ الطالب بيقدر يشوف دوره بلا ما يعيد الكود',
                  (r->>'waiting')::boolean and (r->>'position')::int = 1
                  and (r->>'total')::int = 2);
  perform t_check('★ وبيعرف إنّ الدور لسا ما إجا', not (r->>'open')::boolean);

  ------------------------------------------------- ٣ فتح مطرح ← بيمرق
  perform set_config('request.jwt.claim.sub', adm::text, true);
  perform admin_limits(5, 0);

  perform set_config('request.jwt.claim.sub', u2::text, true);
  r := waitlist_status();
  perform t_check('★ أول ما يفتح مطرح بيقول إنّ دوره إجا',
                  (r->>'open')::boolean);
  r := redeem_code(codes[2], 'wl-2');
  perform t_check('★ ونفس الكود بينفّذ عادي', (r->>'ok')::boolean);
  r := waitlist_status();
  perform t_check('★ وانشال من الطابور', not (r->>'waiting')::boolean);
  reset role;
  perform t_check('★ والتالت صار رقم واحد', waitlist_position(u3) = 1);
  set local role authenticated;

  --------------------------------------- ٤ الموجود ما بينتظر بالتمديد
  perform set_config('request.jwt.claim.sub', adm::text, true);
  perform admin_limits(2, 0);           -- مليان (u1 وu2)
  perform t_check('الطاقة مليانة',
                  (capacity()->>'active')::int >= 2);
  perform set_config('request.jwt.claim.sub', u1::text, true);
  r := redeem_code(codes[4], 'wl-1');
  perform t_check('★ مشترك موجود بيمدّد بلا ما ينتظر', (r->>'ok')::boolean);

  --------------------------------------------- ٥ حدّ الجداد باليوم
  perform set_config('request.jwt.claim.sub', adm::text, true);
  perform admin_limits(0, 1);           -- بلا حدّ فعّالين، بس واحد جديد باليوم
  select (capacity()->>'today')::int into n;
  -- فعّلوا اليوم: u1 وu2 بس. u1 فعّل مرتين (تمديد) وما انعدّ مرتين،
  -- وu3 ما نجح ولا مرة — فهو مو مستخدم جديد.
  perform t_check(format('★ عدّ الجداد اليوم بيحسب أول تفعيل بس (%s)', n), n = 2);

  perform set_config('request.jwt.claim.sub', u3::text, true);
  r := redeem_code(codes[3], 'wl-3');
  perform t_check('★ تجاوز حدّ اليوم بيحطّه بالانتظار',
                  not (r->>'ok')::boolean and r->>'error' = 'waitlist');

  --------------------------------------------------------- ٦ اللوحة
  perform set_config('request.jwt.claim.sub', adm::text, true);
  r := admin_waitlist();
  perform t_check(format('اللوحة بتشوف الطابور (%s)', jsonb_array_length(r)),
                  jsonb_array_length(r) = 1);
  perform t_check('وفيه الاسم والكود',
                  r->0->>'name' = 'WL-Drei' and r->0->>'code' = codes[3]);

  perform admin_waitlist_invite(u3);
  perform t_check('★ الإدخال اليدوي بيشيله من الطابور',
                  jsonb_array_length(admin_waitlist()) = 0);
  perform t_check('★ بس ما بيفتحله اشتراك — الكود هو الطريق الوحيد',
                  not exists (select 1 from subscriptions where user_id = u3));

  begin
    perform admin_limits(-1, 0);
    perform t_check('حدّ سالب مرفوض', false);
  exception when others then
    perform t_check('حدّ سالب مرفوض', sqlerrm = 'limit_negative');
  end;

  ------------------------------------------------- ٧ الطالب ممنوع
  perform set_config('request.jwt.claim.sub', u1::text, true);
  begin
    perform admin_limits(999, 0);
    perform t_check('★ الطالب ما بيقدر يرفع الحدّ', false);
  exception when others then
    perform t_check('★ الطالب ما بيقدر يرفع الحدّ', true);
  end;
  begin
    perform admin_waitlist();
    perform t_check('★ ولا يشوف الطابور', false);
  exception when others then
    perform t_check('★ ولا يشوف الطابور', true);
  end;

  perform set_config('request.jwt.claim.sub', adm::text, true);
  perform admin_limits(0, 0);           -- منرجّعها بلا حدّ للاختبارات الباقية
  raise notice '';
  raise notice '  كل اختبارات قائمة الانتظار نجحت ✓';
end $$;

drop function t_check(text, boolean);
