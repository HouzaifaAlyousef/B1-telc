-- «بلّغ عن مشكلة»: النص بيوصل، والباقي ممنوع
\set ON_ERROR_STOP on
\pset pager off

delete from reports;

insert into auth.users (id) values
  ('cccc0000-0000-0000-0000-000000000001'),   -- أدمن
  ('cccc0000-0000-0000-0000-000000000002'),   -- طالب
  ('cccc0000-0000-0000-0000-000000000003')    -- طالب تاني
on conflict do nothing;
insert into profiles (id, is_admin, display_name) values
  ('cccc0000-0000-0000-0000-000000000001', true,  'RP-Admin'),
  ('cccc0000-0000-0000-0000-000000000002', false, 'RP-Student'),
  ('cccc0000-0000-0000-0000-000000000003', false, 'RP-Andere')
on conflict (id) do update
  set is_admin = excluded.is_admin, display_name = excluded.display_name;

create or replace function t_check(label text, cond boolean)
returns void language plpgsql as $$
begin
  if cond then raise notice '  ✓ %', label;
  else raise exception '  ✗ فشل: %', label;
  end if;
end $$;

-- ★ قراءة الاختبار لازم تتخطّى RLS.
-- الطالب ما بيشوف ولا صف — وهاد المقصود — فلو فحصنا «انحفظ؟» بقراءة
-- عاديّة، الجواب صفر دايماً والاختبار بيفحص السياسة بدل الحفظ.
create or replace function t_rep(p_like text)
returns jsonb language sql security definer set search_path = public stable as $$
  select to_jsonb(r) from reports r where r.body like p_like order by r.id limit 1;
$$;
create or replace function t_rep_count(p_user uuid default null)
returns int language sql security definer set search_path = public stable as $$
  select count(*)::int from reports where p_user is null or user_id = p_user;
$$;

do $$
declare
  adm  uuid := 'cccc0000-0000-0000-0000-000000000001';
  stu  uuid := 'cccc0000-0000-0000-0000-000000000002';
  oth  uuid := 'cccc0000-0000-0000-0000-000000000003';
  tst  uuid;
  tlvl text;
  ttl  text;
  r    jsonb;
  rows jsonb;
  row1 jsonb;
  rep  jsonb;
  n    int;
  s    text;
begin
  -- ★ السياق المتوقّع بينقرا قبل تبديل الدور.
  -- بعد `set role authenticated` بتشتغل RLS على جدول الامتحانات كمان،
  -- فقراءة «شو المستوى المضبوط؟» بترجع فاضي — والاختبار بيقارن بفاضي
  -- وبيمرق أو بيفشل لسبب غلط.
  select t.id, t.level_id, t.title into tst, tlvl, ttl
    from tests t order by (t.level_id = 'b1') desc, t.slug limit 1;

  set local role authenticated;

  ------------------------------------------------------- ١ بلا دخول
  perform set_config('request.jwt.claim.sub', '', true);
  begin
    perform report_problem(tst, 'نص طويل كفاية للتبليغ');
    perform t_check('★ بلا تسجيل دخول ممنوع', false);
  exception when insufficient_privilege then
    perform t_check('★ بلا تسجيل دخول ممنوع', true);
  end;

  ------------------------------------------------------- ٢ قصير
  perform set_config('request.jwt.claim.sub', stu::text, true);
  r := report_problem(tst, 'خطأ');
  perform t_check('نص قصير بينرفض', r->>'error' = 'too_short');
  perform t_check('وما انحفظ ولا صف', t_rep_count() = 0);

  ------------------------------------------------------- ٣ تبليغ سليم
  r := report_problem(tst, 'السؤال رقم ٧ جوابه غلط بالتصحيح، تأكّدوا منه.', 'ar');
  perform t_check('التبليغ انقبل', (r->>'ok')::boolean);
  perform t_check('وانحفظ صف واحد', t_rep_count(stu) = 1);

  ------------------------------------------------------- ٤ السياق من الجدول
  rep := t_rep('السؤال%');
  perform t_check(format('المستوى انقرا من جدول الامتحانات (%s)', rep->>'level_id'),
                  rep->>'level_id' = tlvl);
  perform t_check(format('واسم الامتحان انحفظ نصّاً: %s', rep->>'test_label'),
                  rep->>'test_label' like '%' || ttl || '%');
  perform t_check('واللغة انحفظت', rep->>'lang' = 'ar');

  ------------------------------------------------------- ٥ لغة مو من القائمة
  r := report_problem(tst, 'تبليغ تاني للتأكّد من اللغة', '<script>x</script>');
  perform t_check('★ لغة مو من القائمة بتصير فاضية، مو نص المستخدم',
                  t_rep('تبليغ تاني%')->>'lang' is null);

  ------------------------------------------------------- ٦ التنظيف
  r := report_problem(tst,
         E'\x01سطر أول وبايت تحكّم\n\n\n\n\nوخمس أسطر فاضية   ');
  s := t_rep('%وخمس أسطر فاضية')->>'body';
  perform t_check('★ حروف التحكّم انشالت', position(E'\x01' in s) = 0);
  perform t_check('★ الأسطر الفاضية انضغطت', position(E'\n\n\n' in s) = 0);
  perform t_check('والمسافات عالطرف انشالت', s = btrim(s));

  ------------------------------------------------------- ٧ الطول: قصّ مو رفض
  r := report_problem(tst, repeat('ا', 5000));
  perform t_check('نص طويل كتير بينقبل', (r->>'ok')::boolean);
  n := length(t_rep(repeat('ا', 20) || '%')->>'body');
  perform t_check(format('★ وانقصّ عالحدّ (%s حرف)', n),
                  n = (report_limits()->>'max_chars')::int);

  ------------------------------------------------------- ٨ حدّ المعدّل
  -- صار عنده ٤ (٣، ٥، ٦، ٧). الخامس بيمرق والسادس لأ.
  n := t_rep_count(stu);
  perform t_check(format('عنده %s تبليغات لهلق', n), n = 4);
  r := report_problem(tst, 'التبليغ الخامس لازم يمرق');
  perform t_check('الخامس بيمرق', (r->>'ok')::boolean);
  r := report_problem(tst, 'التبليغ السادس لازم ينرفض');
  perform t_check('★ السادس بالساعة بينرفض', r->>'error' = 'too_many');

  -- ★ المحاولة الفاضية ما بتحرق حصّة: الطول بينتفحّص قبل المعدّل
  perform set_config('request.jwt.claim.sub', oth::text, true);
  for i in 1..6 loop r := report_problem(tst, 'x'); end loop;
  r := report_problem(tst, 'أول تبليغ حقيقي بعد ستّ محاولات فاضية');
  perform t_check('★ محاولات قصيرة ما بتحرق الحصّة', (r->>'ok')::boolean);

  ------------------------------------------------------- ٩ الطالب ما بيقرا
  perform set_config('request.jwt.claim.sub', stu::text, true);
  select count(*) into n from reports;
  perform t_check('★ الطالب بيشوف صفر صفوف — حتى تبليغاته هو', n = 0);

  begin
    insert into reports (user_id, body) values (adm, 'تبليغ مزوّر باسم الأدمن');
    perform t_check('★ الطالب ممنوع يكتب مباشرة بالجدول', false);
  exception when insufficient_privilege then
    perform t_check('★ الطالب ممنوع يكتب مباشرة بالجدول', true);
  end;

  begin
    update reports set body = 'معدّل';
    perform t_check('★ وممنوع يعدّل', false);
  exception when insufficient_privilege then
    perform t_check('★ وممنوع يعدّل', true);
  end;

  begin
    perform admin_reports();
    perform t_check('★ الطالب ممنوع من admin_reports', false);
  exception when insufficient_privilege then
    perform t_check('★ الطالب ممنوع من admin_reports', true);
  end;

  ------------------------------------------------------- ١٠ الأدمن بيقرا
  perform set_config('request.jwt.claim.sub', adm::text, true);
  rows := admin_reports();
  perform t_check(format('الأدمن بيشوف %s تبليغ', jsonb_array_length(rows)),
                  jsonb_array_length(rows) = 6);
  row1 := rows->0;
  perform t_check('ومعه اسم صاحبه', (row1->>'name') in ('RP-Student', 'RP-Andere'));
  perform t_check('ومعه الامتحان', (row1->>'test') is not null
                                   and (row1->>'slug') is not null);
  perform t_check('والمؤسسة والدرجة', row1 ? 'provider' and row1 ? 'stufe');

  select count(*) into n from reports;          -- قراءة مباشرة، بسياسة RLS
  perform t_check('★ والقراءة المباشرة بتشتغل للأدمن بس', n = 6);

  ------------------------------------------------------- ١١ معالَج
  r := admin_report_status((row1->>'id')::uuid, true);
  perform t_check('التعليم كمعالَج بيشتغل', (r->>'ok')::boolean);
  perform t_check('والمفتوحة صارت أقل',
                  jsonb_array_length(admin_reports('new')) = 5);
  perform t_check('وانسجّل بالبروتوكول',
    exists (select 1 from admin_audit_log
             where action = 'report_status' and target_id = row1->>'id'));
  perform admin_report_status((row1->>'id')::uuid, false);
  perform t_check('★ وبيرجع لو انضغط بالغلط',
                  jsonb_array_length(admin_reports('new')) = 6);

  ------------------------------------------------------- ١٢ العدّاد بالشاشة
  perform t_check('شاشة البداية بتعدّ المفتوحة',
                  (admin_overview()->>'reports_open')::int = 6);
end $$;

-- ★ الامتحان انمسح: التبليغ بيضل مفهوم
-- هاد سبب وجود test_label. بلاه، كل تبليغ عن امتحان انعاد استيراده
-- بيصير «مشكلة — مجهول»، يعني بلا فايدة بالضبط لما بدّك ياه.
do $$
declare tmp uuid; s text; n int; r jsonb;
begin
  -- امتحان مؤقّت تا ما نمسح شي من البذور
  insert into tests (level_id, slug, title, published)
  select level_id, 'zz-weg-damit', 'Wegwerf-Modell', true from tests limit 1
  returning id into tmp;

  set local role authenticated;
  perform set_config('request.jwt.claim.sub',
                     'cccc0000-0000-0000-0000-000000000003', true);
  r := report_problem(tmp, 'تبليغ عن امتحان رح ينمسح بعد شوي');
  perform t_check('تبليغ على الامتحان المؤقّت', (r->>'ok')::boolean);
  s := t_rep('تبليغ عن امتحان%')->>'test_label';

  reset role;
  delete from tests where id = tmp;

  set local role authenticated;
  perform set_config('request.jwt.claim.sub',
                     'cccc0000-0000-0000-0000-000000000001', true);
  select count(*) into n from reports where test_label = s and test_id is null;
  perform t_check(format('الامتحان انمسح، والتبليغ بقي (%s)', n), n = 1);
  perform t_check('★ والتبليغ ما انمسح معه (on delete set null)',
                  t_rep_count() = 7);
  select x->>'test' into s from jsonb_array_elements(admin_reports()) x
   where (x->>'test_id') is null limit 1;
  perform t_check(format('★ واسمه لسا ظاهر: %s', s),
                  s like '%Wegwerf-Modell%');
end $$;

-- الجدول انفضى تا ما يأثّر على اختبارات تانية
delete from reports;
