-- سياسة التخزين: الصور والصوت محتوى امتحان، بينوصلهن المشترك بمستواهن بس
\set ON_ERROR_STOP on
\pset pager off

delete from storage.objects; delete from storage.buckets;
delete from devices; delete from subscriptions; delete from access_codes;
delete from profiles where id in (
  'dddddddd-0000-0000-0000-000000000001',
  'dddddddd-0000-0000-0000-000000000002',
  'dddddddd-0000-0000-0000-000000000003');
delete from auth.users where id in (
  'dddddddd-0000-0000-0000-000000000001',
  'dddddddd-0000-0000-0000-000000000002',
  'dddddddd-0000-0000-0000-000000000003');

insert into auth.users (id) values
  ('dddddddd-0000-0000-0000-000000000001'),   -- مشترك b1
  ('dddddddd-0000-0000-0000-000000000002'),   -- مشترك a1 بس
  ('dddddddd-0000-0000-0000-000000000003');   -- بلا اشتراك
insert into profiles (id) values
  ('dddddddd-0000-0000-0000-000000000001'),
  ('dddddddd-0000-0000-0000-000000000002'),
  ('dddddddd-0000-0000-0000-000000000003');

insert into levels (id, title, published) values ('a1','telc A1',true)
  on conflict (id) do nothing;
insert into subscriptions (user_id, levels, current_period_end) values
  ('dddddddd-0000-0000-0000-000000000001', array['b1'], now() + interval '30 days'),
  ('dddddddd-0000-0000-0000-000000000002', array['a1'], now() + interval '30 days');

-- الدلاء والملفات: صورة وصوت مربوطين بأقسام b1 حقيقية، وملف يتيم
insert into storage.buckets (id, name, public)
values ('exam-images','exam-images',false), ('exam-audio','exam-audio',false)
on conflict (id) do nothing;

do $seed$
declare v_img text; v_sec uuid;
begin
  -- قسم b1 حقيقي إله صورة
  select s.config->>'bankImage' into v_img from sections s
    join tests t on t.id = s.test_id
   where t.level_id = 'b1' and s.config ? 'bankImage' limit 1;
  insert into storage.objects (bucket_id, name) values ('exam-images', v_img);

  -- ونربط صوت بقسم استماع b1 تا نفحص الدلو التاني كمان
  select s.id into v_sec from sections s join tests t on t.id = s.test_id
   where t.level_id = 'b1' and s.format = 'truefalse' limit 1;
  update sections set config = config || '{"audio":"m01-hv1.mp3"}'::jsonb
   where id = v_sec;
  insert into storage.objects (bucket_id, name) values ('exam-audio', 'm01-hv1.mp3');

  -- ملف ما إله قسم بيشير إله
  insert into storage.objects (bucket_id, name) values ('exam-images', 'img/waise.jpg');
end $seed$;

create or replace function t_check(label text, cond boolean)
returns void language plpgsql as $$
begin
  if cond then raise notice '  ✓ %', label;
  else raise exception '  ✗ فشل: %', label;
  end if;
end $$;

do $$
declare
  b1u   uuid := 'dddddddd-0000-0000-0000-000000000001';
  a1u   uuid := 'dddddddd-0000-0000-0000-000000000002';
  nou   uuid := 'dddddddd-0000-0000-0000-000000000003';
  v_img text;
  n     int;
begin
  -- اسم الملف بينقرا قبل ما نلبس دور authenticated: بعدها السياسة
  -- بتحكم، وبلا مستخدم محدّد بترجّع صفر صفوف
  select name into v_img from storage.objects
   where bucket_id='exam-images' and name <> 'img/waise.jpg';
  set local role authenticated;

  -- المشترك بـb1 بيشوف صورة b1 وصوتها
  perform set_config('request.jwt.claim.sub', b1u::text, true);
  select count(*) into n from storage.objects where bucket_id='exam-images'
     and name = v_img;
  perform t_check(format('مشترك b1 بيشوف صورة b1 (%s)', v_img), n = 1);
  select count(*) into n from storage.objects where bucket_id='exam-audio';
  perform t_check('ومعها ملف الصوت', n = 1);

  -- ★ الملف اليتيم ما بينقرا ولا من مشترك
  select count(*) into n from storage.objects where name = 'img/waise.jpg';
  perform t_check('★ ملف ما إله قسم ما بينقرا حتى من مشترك', n = 0);

  -- ★ مشترك a1 ما بيشوف ملفات b1
  perform set_config('request.jwt.claim.sub', a1u::text, true);
  select count(*) into n from storage.objects;
  perform t_check('★ مشترك a1 ما بيشوف ولا ملف من b1', n = 0);

  -- ★ بلا اشتراك: ولا شي
  perform set_config('request.jwt.claim.sub', nou::text, true);
  select count(*) into n from storage.objects;
  perform t_check('★ بلا اشتراك ما بيشوف ولا ملف', n = 0);

  -- ★ الاشتراك المنتهي بيقفل الملفات فوراً
  perform set_config('request.jwt.claim.sub', b1u::text, true);
  set local role postgres;
  update subscriptions set current_period_end = now() - interval '1 day'
   where user_id = b1u;
  set local role authenticated;
  select count(*) into n from storage.objects;
  perform t_check('★ انتهاء الاشتراك بيقفل الصور والصوت', n = 0);

  -- ★ الطالب ما بيقدر يرفع ولا يمسح: ما في سياسة كتابة إطلاقاً
  set local role postgres;
  update subscriptions set current_period_end = now() + interval '30 days'
   where user_id = b1u;
  set local role authenticated;
  begin
    insert into storage.objects (bucket_id, name) values ('exam-images','img/hack.jpg');
    perform t_check('★ الطالب ممنوع يرفع ملف', false);
  exception when insufficient_privilege then
    perform t_check('★ الطالب ممنوع يرفع ملف', true);
  end;

  -- المسح ما بيرمي استثناء: السياسة بتخفي الصفوف فبيمسح صفر. فالفحص
  -- على الحالة الفعلية بعدين، مو على غياب الخطأ.
  delete from storage.objects where name = v_img;
  set local role postgres;
  select count(*) into n from storage.objects where name = v_img;
  perform t_check('★ الطالب ممنوع يمسح ملف (لسا موجود)', n = 1);
  select count(*) into n from storage.objects where name = 'img/hack.jpg';
  perform t_check('★ وما انرفع ولا ملف جديد', n = 0);

  raise notice '';
  raise notice '  كل اختبارات التخزين نجحت ✓';
end $$;

drop function t_check(text, boolean);
