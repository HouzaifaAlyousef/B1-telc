-- طلب الوصول الكامل: الحدّ الحقيقي هو bot_admins، مو الزرّ بتلغرام
\set ON_ERROR_STOP on
\pset pager off

delete from access_requests;
delete from bot_admins;
delete from telegram_users;
delete from mistakes; delete from attempts; delete from code_redemptions;
delete from devices; delete from subscriptions; delete from access_codes;
delete from tests  where level_id like 'req-%';
delete from levels where id       like 'req-%';

create or replace function t_check(label text, cond boolean)
returns void language plpgsql as $$
begin
  if cond then raise notice '  ✓ %', label;
  else raise exception '  ✗ فشل: %', label;
  end if;
end $$;

insert into levels (id, title, sort, published, provider, stufe)
values ('req-b1', 'ReqTest B1', 0, true, 'reqtest', 'B1');
insert into tests (level_id, slug, title, blocks, aufgaben, published, sort)
values ('req-b1', 'm1', 'ERSTER', '[]'::jsonb, 5, true, 1),
       ('req-b1', 'm2', 'ZWEITER', '[]'::jsonb, 5, true, 2);

do $$
declare
  tg_stud bigint := 900001;      -- الطالب
  tg_boss bigint := 900002;      -- إنت
  tg_liar bigint := 900003;      -- حدا بدّه يوافق على حاله
  r jsonb; r2 jsonb; c access_codes%rowtype; n int; req uuid;
begin
  raise notice '';
  raise notice '── طلب الوصول الكامل ──';

  -- ★ بلا تجريبي ما في طلب: منعرف مستواه ولغته من جدول التجريبي
  begin
    perform bot_request_access(tg_stud, 3);
    perform t_check('★ طلب بلا تجريبي مرفوض', false);
  exception when others then
    perform t_check('★ طلب بلا تجريبي مرفوض (' || SQLERRM || ')',
                    SQLERRM like '%no_demo_yet%');
  end;

  -- الطالب بياخد تجريبي أوّلاً
  r := bot_demo_code(tg_stud, tg_stud, 'moutasem', 'ar', 'req-b1');
  perform t_check('التجريبي انعطى', (r->>'ok')::boolean);
  select * into c from access_codes where code = r->>'code';
  perform t_check('★ التجريبي امتحان واحد بس', array_length(c.test_slugs, 1) = 1);
  perform t_check('★ ومدّته ٢٤ ساعة', c.duration_hours = 24 and c.duration_days = 0);

  -- الطلب
  r := bot_request_access(tg_stud, 3);
  req := (r->>'request_id')::uuid;
  perform t_check('الطلب انسجّل', (r->>'ok')::boolean and (r->>'months')::int = 3);
  perform t_check('وما هو مكرّر', not (r->>'again')::boolean);

  -- ★ ضغطتين متتاليتين ما بيعملوا طلبين
  r2 := bot_request_access(tg_stud, 1);
  perform t_check('★ الضغطة التانية بترجّع نفس الطلب مو طلب جديد',
                  (r2->>'again')::boolean and (r2->>'request_id')::uuid = req);
  select count(*) into n from access_requests where telegram_id = tg_stud;
  perform t_check('★ وبالجدول طلب واحد بس (' || n || ')', n = 1);
  perform t_check('★ والمدّة ضلّت ٣ مو ١', (r2->>'months')::int = 3);

  -- ★★ هون الحدّ: مين مو بـbot_admins ما بيوافق ولو عرف رقم الطلب
  begin
    perform bot_decide_request(tg_liar, req, true, null);
    perform t_check('★★ غريب وافق على الطلب — ثغرة!', false);
  exception when others then
    perform t_check('★★ مين مو أدمن ما بيقدر يوافق (' || SQLERRM || ')',
                    SQLERRM like '%not_bot_admin%');
  end;
  select count(*) into n from access_codes where note like 'telegram-full:%';
  perform t_check('★★ وما انعمل ولا كود', n = 0);
  perform t_check('★★ والطلب لسا معلّق',
    (select status from access_requests where id = req) = 'pending');

  -- إنت أدمن
  insert into bot_admins (telegram_id, label) values (tg_boss, 'أنا');
  r := bot_decide_request(tg_boss, req, true, null);
  perform t_check('الأدمن وافق', (r->>'ok')::boolean and r->>'status' = 'approved');

  select * into c from access_codes where code = r->>'code';
  perform t_check('★ الكود الكامل ٣ شهور (' || c.duration_days || ' يوم)',
                  c.duration_days = 90);
  perform t_check('★ وبيفتح كل امتحانات المستوى مو واحد', c.test_slugs is null);
  perform t_check('★ وبادئته من الدرجة', c.code like 'B1%');
  perform t_check('وانربط بالطلب',
    (select code_id from access_requests where id = req) = c.id);

  -- ★ موافقة تانية على نفس الطلب ما بتعمل كود تاني
  r2 := bot_decide_request(tg_boss, req, true, null);
  perform t_check('★ الموافقة التانية ما بتشتغل', not (r2->>'ok')::boolean
                  and r2->>'already' = 'approved');
  select count(*) into n from access_codes where note like 'telegram-full:%';
  perform t_check('★ وضلّ كود واحد (' || n || ')', n = 1);

  -- الرفض بسبب
  perform bot_demo_code(900009, 900009, 'zweiter', 'de', 'req-b1');
  r := bot_request_access(900009, 1);
  req := (r->>'request_id')::uuid;
  r := bot_decide_request(tg_boss, req, false, 'soon');
  perform t_check('الرفض اشتغل', r->>'status' = 'rejected' and r->>'reason' = 'soon');
  perform t_check('والسبب انحفظ',
    (select reason from access_requests where id = req) = 'soon');
  perform t_check('★ ورفض ما بيعمل كود',
    (select count(*) from access_codes where note like 'telegram-full:%') = 1);

  -- ★ بعد ما ينرفض بيقدر يطلب من جديد
  r := bot_request_access(900009, 2);
  perform t_check('★ بعد الرفض بيقدر يطلب مرّة تانية',
                  (r->>'ok')::boolean and not (r->>'again')::boolean);

  -- مدّة برّا المدى
  begin
    perform bot_request_access(tg_stud, 99);
    perform t_check('مدّة ٩٩ شهر مرفوضة', false);
  exception when others then
    perform t_check('مدّة برّا المدى مرفوضة', SQLERRM like '%months_out_of_range%');
  end;

  -- ── المجموعة بدل الأشخاص ──
  delete from bot_admins;
  insert into bot_admins (telegram_id, label) values (-1009999, 'المجموعة');

  perform bot_demo_code(900077, 900077, 'dritter', 'ar', 'req-b1');
  r := bot_request_access(900077, 2);
  req := (r->>'request_id')::uuid;

  -- ★ نفس الشخص، بس الضغطة جوّا المجموعة المسجّلة
  begin
    perform bot_decide_request(tg_liar, req, true, null, null);
    perform t_check('★★ برّا المجموعة مرفوض', false);
  exception when others then
    perform t_check('★★ نفس الشخص برّا المجموعة مرفوض', SQLERRM like '%not_bot_admin%');
  end;

  r := bot_decide_request(tg_liar, req, true, null, -1009999);
  perform t_check('★★ وجوّا المجموعة بيمرق — العضوية هي الصلاحية',
                  (r->>'ok')::boolean and r->>'status' = 'approved');
  perform t_check('★ ومين قرّر انسجّل شخص مو مجموعة',
    (select decided_by from access_requests where id = req) = tg_liar);

  -- ★ مجموعة تانية مو مسجّلة ما بتشتغل
  perform bot_demo_code(900078, 900078, 'vierter', 'ar', 'req-b1');
  req := (bot_request_access(900078, 1)->>'request_id')::uuid;
  begin
    perform bot_decide_request(tg_liar, req, true, null, -1000001);
    perform t_check('★★ مجموعة مو مسجّلة مرفوضة', false);
  exception when others then
    perform t_check('★★ مجموعة تانية مو مسجّلة مرفوضة', SQLERRM like '%not_bot_admin%');
  end;

  raise notice '';
  raise notice '  كل اختبارات طلبات الوصول نجحت ✓';
end $$;
