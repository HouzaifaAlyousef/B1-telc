-- بوت تلغرام: الحدّ الحقيقي هون — البوت ما بيقدر يعمل غير تجريبي
\set ON_ERROR_STOP on
\pset pager off

delete from telegram_users;
delete from mistakes; delete from attempts; delete from code_redemptions;
delete from devices; delete from subscriptions; delete from access_codes;
delete from tests  where level_id like 'bot-%';
delete from levels where id       like 'bot-%';

insert into auth.users (id) values
  ('dddddddd-0000-0000-0000-000000000001')     -- طالب بيفعّل كود البوت
on conflict do nothing;
insert into profiles (id, is_admin) values
  ('dddddddd-0000-0000-0000-000000000001', false)
on conflict (id) do update set is_admin = excluded.is_admin;

create or replace function t_check(label text, cond boolean)
returns void language plpgsql as $$
begin
  if cond then raise notice '  ✓ %', label;
  else raise exception '  ✗ فشل: %', label;
  end if;
end $$;

do $$
declare
  stud uuid := 'dddddddd-0000-0000-0000-000000000001';
  r    jsonb;
  r2   jsonb;
  c    access_codes%rowtype;
  n    int;
begin
  ------------------------------------------------------------- ١ القائمة
  r := bot_levels();
  perform t_check(format('القائمة فيها b1 (%s مستوى)', jsonb_array_length(r)),
    exists (select 1 from jsonb_array_elements(r) x where x->>'id' = 'b1'));

  -- ★ مستوى بلا امتحان منشور ما لازم ينعرض: بيعطي كود ما بيفتح شي
  insert into levels (id, title, provider, stufe, published)
  values ('bot-empty', 'Leer B2', 'botprov', 'B2', true);
  r := bot_levels();
  perform t_check('★ مستوى بلا امتحان منشور ما بينعرض',
    not exists (select 1 from jsonb_array_elements(r) x where x->>'id' = 'bot-empty'));

  -- ومستوى مو منشور كمان
  insert into levels (id, title, provider, stufe, published)
  values ('bot-hidden', 'Versteckt B2', 'botprov2', 'B2', false);
  insert into tests (level_id, slug, title, blocks, aufgaben, published, sort)
  values ('bot-hidden', 'bot-h-01', 'H1', '[]'::jsonb, 0, true, 1);
  r := bot_levels();
  perform t_check('★ ومستوى مو منشور كمان',
    not exists (select 1 from jsonb_array_elements(r) x where x->>'id' = 'bot-hidden'));

  ---------------------------------------------------------- ٢ الكود التجريبي
  r := bot_demo_code(111222333, 111222333, 'ahmad', 'ar', 'b1');
  perform t_check(format('البوت أعطى كود (%s)', r->>'code'), (r->>'ok')::boolean);
  perform t_check('وما هو تكرار', not (r->>'again')::boolean);
  perform t_check('الصيغة صيغة الأكواد الجديدة', (r->>'code') ~ '^B1[0-9]{10}$');

  select * into c from access_codes where code = r->>'code';
  perform t_check(format('★ ٢٤ ساعة و٠ يوم (%s/%s)', c.duration_days, c.duration_hours),
                  c.duration_days = 0 and c.duration_hours = 24);
  perform t_check(format('★ تفعيل واحد بس (%s)', c.max_uses), c.max_uses = 1);
  perform t_check(format('★ امتحان واحد بس (%s)', array_length(c.test_slugs, 1)),
                  array_length(c.test_slugs, 1) = 1);
  perform t_check('★ وهو أول امتحان منشور بالمستوى',
                  c.test_slugs[1] = (select t.slug from tests t
                                      where t.level_id = 'b1' and t.published
                                      order by t.sort, t.slug limit 1));
  perform t_check('الكود مربوط بحساب تلغرام بالملاحظة',
                  c.note = 'telegram:111222333');

  ------------------------------------- ٣ ★ حساب واحد = تجريبي واحد للأبد
  r2 := bot_demo_code(111222333, 111222333, 'ahmad', 'ar', 'b1');
  perform t_check('★ الطلب التاني بيرجّع نفس الكود مو كود جديد',
                  (r2->>'code') = (r->>'code') and (r2->>'again')::boolean);
  select count(*) into n from access_codes where note = 'telegram:111222333';
  perform t_check(format('★ وما انولّد كود زيادة (%s)', n), n = 1);

  -- ★ وحتى لو طلب مستوى تاني: نفس الكود. هيك ما بيجمّع أكواد.
  insert into levels (id, title, provider, stufe, published)
  values ('bot-b2', 'Bot B2', 'botprov3', 'B2', true);
  insert into tests (level_id, slug, title, blocks, aufgaben, published, sort)
  values ('bot-b2', 'bot-b2-01', 'B2 Modell 1', '[]'::jsonb, 0, true, 1);
  r2 := bot_demo_code(111222333, 111222333, 'ahmad', 'ar', 'bot-b2');
  perform t_check('★ ولا حتى بمستوى تاني بياخد كود جديد',
                  (r2->>'code') = (r->>'code'));
  select count(*) into n from access_codes where note like 'telegram:%';
  perform t_check(format('★ المجموع كود واحد لهالحساب (%s)', n), n = 1);

  -- حساب تاني بياخد كوده هو
  r2 := bot_demo_code(444555666, 444555666, null, 'de', 'b1');
  perform t_check('حساب تاني بياخد كود لحاله',
                  (r2->>'code') <> (r->>'code'));

  --------------------------------------------------- ٤ المستوى المرفوض
  begin
    perform bot_demo_code(777888999, 777888999, null, 'en', 'bot-hidden');
    perform t_check('★ مستوى مو منشور مرفوض', false);
  exception when others then
    perform t_check('★ مستوى مو منشور مرفوض', sqlerrm = 'level_not_found');
  end;

  begin
    perform bot_demo_code(777888999, 777888999, null, 'en', 'bot-empty');
    perform t_check('★ ومستوى بلا امتحان مرفوض', false);
  exception when others then
    perform t_check('★ ومستوى بلا امتحان مرفوض', sqlerrm = 'no_published_test');
  end;

  --------------------------------------- ٥ الكود بيشتغل فعلاً بالتطبيق
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', stud::text, true);
  r2 := redeem_code(r->>'code', 'bot-dev-1');
  perform t_check('كود البوت بينفّذ بالتطبيق', (r2->>'ok')::boolean);

  select count(*) into n from tests;
  perform t_check(format('★ وبيفتح امتحان واحد بس من كل المنشورة (%s)', n), n = 1);

  perform t_check('★ وما بيفتح باقي امتحانات المستوى',
                  not has_test_access(stud, 'b1', 'modell-02'));

  reset role;
  raise notice '';
  raise notice '  كل اختبارات بوت تلغرام نجحت ✓';
end $$;

drop function t_check(text, boolean);
