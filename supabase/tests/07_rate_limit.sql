-- حدّ محاولات تنفيذ الكود: هجوم تخمين حقيقي
\set ON_ERROR_STOP on
\pset pager off

delete from redeem_attempts; delete from code_redemptions;
delete from writing_feedback; delete from admin_audit_log; delete from mistakes;
delete from attempts; delete from imports; delete from resources;
delete from tests where level_id <> 'b1'; delete from levels where id <> 'b1';
delete from devices; delete from subscriptions; delete from access_codes;
delete from profiles; delete from auth.users;

insert into auth.users (id) values
  ('f0000001-0000-0000-0000-000000000001'),
  ('f0000002-0000-0000-0000-000000000002'),
  ('f000000a-0000-0000-0000-00000000000a');
insert into profiles (id, is_admin) values
  ('f0000001-0000-0000-0000-000000000001', false),
  ('f0000002-0000-0000-0000-000000000002', false),
  ('f000000a-0000-0000-0000-00000000000a', true);
insert into access_codes (code, levels, duration_days, max_uses)
values ('B1-GOOD-CODE', array['b1'], 30, 2);

create or replace function t_check(label text, cond boolean)
returns void language plpgsql as $$
begin
  if cond then raise notice '  ✓ %', label;
  else raise exception '  ✗ فشل: %', label; end if;
end $$;

do $$
declare
  att uuid := 'f0000001-0000-0000-0000-000000000001';   -- المهاجم
  vic uuid := 'f0000002-0000-0000-0000-000000000002';   -- طالب عادي
  adm uuid := 'f000000a-0000-0000-0000-00000000000a';
  lim jsonb := redeem_limits();
  r   jsonb;
  n   int;
  i   int;
begin
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', att::text, true);

  ---------------------------------------------------------------- ١
  perform t_check(format('الحد: %s محاولة فاشلة بـ%s دقيقة',
                         lim->>'max_failed', lim->>'window_minutes'),
                  (lim->>'max_failed')::int > 0);
  perform t_check('بالبداية مو مقفول', redeem_blocked_for('fp-att') = 0);

  ---------------------------------------------------------------- ٢ التخمين
  for i in 1..(lim->>'max_failed')::int loop
    r := redeem_code('B1-XXXX-' || lpad(i::text, 4, '0'), 'fp-att');
  end loop;
  perform t_check(format('آخر تخمينة قبل القفل رجّعت %s', r->>'error'),
                  r->>'error' = 'invalid_code');

  r := redeem_code('B1-YYYY-0001', 'fp-att');
  perform t_check(format('★ التخمينة التالية انقفلت (%s)', r->>'error'),
                  r->>'error' = 'too_many_attempts');
  perform t_check(format('وبتقول متى يعيد (%s ثانية)', r->>'retry_after'),
                  (r->>'retry_after')::int between 1 and 60*(lim->>'window_minutes')::int);

  ---------------------------------------------------------------- ٣
  -- ★ حتى الكود الصحيح مرفوض وهو مقفول — ما بينفع يجرّب لحتى يصيب
  r := redeem_code('B1-GOOD-CODE', 'fp-att');
  perform t_check('★ وحتى الكود الصحيح مرفوض وهو مقفول',
                  r->>'error' = 'too_many_attempts');
  perform t_check('وما انعمل اشتراك',
                  (select count(*) from subscriptions where user_id = att) = 0);

  ---------------------------------------------------------------- ٤
  -- ★ القفل ما بيأثر على طالب تاني ببصمة تانية
  perform set_config('request.jwt.claim.sub', vic::text, true);
  perform t_check('★ طالب تاني مو مقفول', redeem_blocked_for('fp-vic') = 0);
  perform t_check('★ وبيقدر ينفّذ كوده عادي',
                  (redeem_code('B1-GOOD-CODE', 'fp-vic')->>'ok')::boolean);

  ---------------------------------------------------------------- ٥
  -- نفس البصمة من حساب جديد لسا مقفولة (مسح الحساب ما بيكفي)
  perform set_config('request.jwt.claim.sub', vic::text, true);
  perform t_check('★ نفس البصمة مقفولة حتى من حساب تاني',
                  redeem_blocked_for('fp-att') > 0);

  ---------------------------------------------------------------- ٦
  -- النجاح ما بينحسب محاولة فاشلة: إعادة الإدخال ما بتقفل الطالب
  for i in 1..20 loop r := redeem_code('B1-GOOD-CODE', 'fp-vic'); end loop;
  perform t_check('★ ٢٠ إعادة ناجحة ما قفلت الطالب',
                  (r->>'ok')::boolean and redeem_blocked_for('fp-vic') = 0);

end $$;

do $$
declare
  att uuid := 'f0000001-0000-0000-0000-000000000001';
  adm uuid := 'f000000a-0000-0000-0000-00000000000a';
  r   jsonb;
begin
  ---------------------------------------------------------------- ٧ النافذة
  -- المحاولات القديمة تطلع من النافذة ← القفل بيفتح لحاله
  update redeem_attempts set created_at = now() - interval '20 minutes'
   where fingerprint = 'fp-att';

  set local role authenticated;
  perform set_config('request.jwt.claim.sub', att::text, true);
  perform t_check('★ بعد ما تمرق النافذة، القفل بيفتح لحاله',
                  redeem_blocked_for('fp-att') = 0);
  perform t_check('وبيقدر ينفّذ',
                  (redeem_code('B1-GOOD-CODE', 'fp-att')->>'ok')::boolean);

  ---------------------------------------------------------------- ٨ اللوحة
  perform set_config('request.jwt.claim.sub', adm::text, true);
  r := admin_redeem_activity();
  perform t_check(format('اللوحة بتعدّ المحاولات (%s فاشلة، %s ناجحة بـ٢٤ ساعة)',
                         r->>'failed_24h', r->>'ok_24h'),
                  (r->>'failed_24h')::int >= 8 and (r->>'ok_24h')::int >= 1);

  ---------------------------------------------------------------- ٩ الخصوصية
  perform set_config('request.jwt.claim.sub', att::text, true);
  perform t_check('★ الطالب ما بيشوف سجلّ المحاولات',
                  (select count(*) from redeem_attempts) = 0);

  raise notice '';
  raise notice '  كل اختبارات حدّ المحاولات نجحت ✓';
end $$;

drop function t_check(text, boolean);
