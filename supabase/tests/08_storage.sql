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
insert into auth.users (id) values ('dddddddd-0000-0000-0000-00000000000a')
  on conflict do nothing;
insert into profiles (id, is_admin) values
  ('dddddddd-0000-0000-0000-00000000000a', true)
  on conflict (id) do update set is_admin = true;
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
   where t.level_id = 'b1' and s.format = 'truefalse'
   order by t.sort, s.sort limit 1;
  update sections set config = config || '{"audio":"m01-hv1.mp3"}'::jsonb
   where id = v_sec;
  insert into storage.objects (bucket_id, name) values ('exam-audio', 'm01-hv1.mp3');

  -- قسم استماع تاني إله مسار بس بلا ملف: تا يكون في «ناقص» تنفحصه
  select s.id into v_sec from sections s join tests t on t.id = s.test_id
   where t.level_id = 'b1' and s.format = 'truefalse'
     and not (s.config ? 'audio')
   order by t.sort, s.sort limit 1;
  update sections set config = config || '{"audio":"m01-hv2.mp3"}'::jsonb
   where id = v_sec;

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
  res   jsonb;
  adm   uuid := 'dddddddd-0000-0000-0000-00000000000a';
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

  ------------------------------------------------------------ الأدمن
  -- الأدمن ما إله اشتراك، فسياسة القراءة المبنية على الاشتراك كانت
  -- بتخفي عنه كل شي — يعني لوحته ما بتعرف شو مرفوع وشو ناقص.
  perform set_config('request.jwt.claim.sub', adm::text, true);
  select count(*) into n from storage.objects;
  perform t_check(format('★ الأدمن بيشوف كل الملفات (%s) بلا اشتراك', n), n = 3);

  insert into storage.objects (bucket_id, name) values ('exam-images','img/neu.jpg');
  select count(*) into n from storage.objects where name = 'img/neu.jpg';
  perform t_check('★ الأدمن بيقدر يرفع', n = 1);

  delete from storage.objects where name = 'img/neu.jpg';
  select count(*) into n from storage.objects where name = 'img/neu.jpg';
  perform t_check('★ والأدمن بيقدر يمسح', n = 0);

  -- ودلو تالت؟ السياسة محصورة بالاتنين
  begin
    insert into storage.objects (bucket_id, name) values ('anderer','x.jpg');
    perform t_check('★ الأدمن ممنوع يكتب بدلو تاني', false);
  exception when insufficient_privilege or foreign_key_violation then
    perform t_check('★ الأدمن ممنوع يكتب بدلو تاني', true);
  end;

  -- ولائحة اللوحة بتقول شو ناقص
  res := admin_assets('b1');
  perform t_check(format('admin_assets بترجّع %s ملف مطلوب',
                         jsonb_array_length(res)),
                  jsonb_array_length(res) >= 2);
  -- تصفية الستوفة لازم تشيل الصور كمان، مو الصوت بس: and بتربط أقوى من
  -- or، فبلا قوس خارجي بالـwhere صور المستويات التانية بتضل ظاهرة.
  perform t_check('★ تصفية الستوفة بتشيل كل شي مو من هالستوفة',
    (select count(*) from jsonb_array_elements(admin_assets('a1')) e) = 0
    and jsonb_array_length(admin_assets('b1')) > 0);

  perform t_check('أقسام الاستماع بلا ملف ظاهرة مع اسم مقترح',
    exists (select 1 from jsonb_array_elements(admin_assets(null)) e
             where e->>'kind' = 'audio' and not (e->>'assigned')::boolean
               and e->>'path' like '%.mp3'));

  perform t_check('★ وبتميّز المرفوع عن الناقص',
    exists (select 1 from jsonb_array_elements(res) e where (e->>'uploaded')::boolean)
    and exists (select 1 from jsonb_array_elements(res) e
                 where not (e->>'uploaded')::boolean));

  raise notice '';
  raise notice '  كل اختبارات التخزين نجحت ✓';
end $$;

-- ★ ترجيع: هالملف بيعدّل config لأقسام البذور تا يبني حالته. اختبارات
-- المتصفّح بتصدّر تجهيزتها من نفس القاعدة، فأي تعديل بيضل هون بيوصلها.
-- (هيك بالضبط انكسر اختبار مشغّل الصوت: قسم تاني إله audio ← مشغّلين
-- بالصفحة ← المنتقي الصارم بيفشل على عنصرين.)
update sections set config = config - 'audio' - 'audioPlays'
 where config->>'audio' in ('m01-hv1.mp3', 'm01-hv2.mp3');

drop function t_check(text, boolean);
