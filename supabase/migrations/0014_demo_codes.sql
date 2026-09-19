-- =====================================================================
-- 0014_demo_codes — كود تجريبي: ساعات بدل أيام، وامتحان واحد بدل مستوى
--
-- الكود لليوم بيفتح **كل** امتحانات المستوى لعدد **أيام**. الكود
-- التجريبي بده الاتنين أضيق: امتحان واحد (مع تصحيحه) لأربع وعشرين ساعة.
--
-- عمودين جداد:
--   duration_hours — بينضاف لـduration_days. تجريبي = ٠ يوم + ٢٤ ساعة.
--   test_slugs     — null يعني كل امتحانات المستوى (السلوك القديم)،
--                    ومصفوفة يعني هدول بس.
--
-- ★ الحدّ لازم ينطبق بكل مكان بينقرا منه محتوى، مو بواجهة العرض بس:
--   الامتحانات، الأقسام، الأسئلة، التصحيح، تصحيح الكتابة، والملفات
--   بـStorage. أي مكان ينُسى بيصير ثغرة: صاحب كود تجريبي بيوصل
--   لمحتوى مدفوع.
-- =====================================================================

alter table access_codes  add column if not exists duration_hours int not null default 0;
alter table access_codes  add column if not exists test_slugs text[];
alter table subscriptions add column if not exists test_slugs text[];

comment on column access_codes.test_slugs  is 'null = كل امتحانات المستوى';
comment on column subscriptions.test_slugs is 'null = كل امتحانات المستوى';

-- ---------------------------------------------------------------------
-- الصلاحية على مستوى الامتحان
--
-- ما بتقرا من tests بالقصد: بتنندعى من سياسة على tests نفسها، والقراءة
-- من نفس الجدول بتخلّي المنطق أصعب تتبّعاً. المستوى والاسم بينمرّروا
-- من الصف يلي عم تتفحص.
-- ---------------------------------------------------------------------
create or replace function has_test_access(p_user uuid, p_level text, p_slug text)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from subscriptions s
     where s.user_id = p_user
       and s.status = 'active'
       and s.current_period_end > now()
       and p_level = any(s.levels)
       and (s.test_slugs is null or p_slug = any(s.test_slugs))
  );
$$;
revoke all on function has_test_access(uuid, text, text) from public;
grant execute on function has_test_access(uuid, text, text) to authenticated;

-- ---------------------------------------------------------------------
-- السياسات: نفس الشكل القديم، بس بتمرّر الاسم كمان
-- ---------------------------------------------------------------------
drop policy if exists tests_entitled on tests;
create policy tests_entitled on tests for select to authenticated
  using (published and (is_free or has_test_access(auth.uid(), level_id, slug)));

drop policy if exists sections_entitled on sections;
create policy sections_entitled on sections for select to authenticated
  using (exists (
    select 1 from tests t
    where t.id = sections.test_id
      and t.published
      and (t.is_free or has_test_access(auth.uid(), t.level_id, t.slug))));

drop policy if exists items_entitled on items;
create policy items_entitled on items for select to authenticated
  using (exists (
    select 1 from sections s join tests t on t.id = s.test_id
    where s.id = items.section_id
      and t.published
      and (t.is_free or has_test_access(auth.uid(), t.level_id, t.slug))));

-- الملفات كمان: صورة امتحان مدفوع ما بتوصل لصاحب كود تجريبي
create or replace function storage_asset_allowed(p_bucket text, p_name text)
returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from sections s
      join tests t on t.id = s.test_id
     where s.config->>(case when p_bucket = 'exam-audio' then 'audio'
                            else 'bankImage' end) = p_name
       and has_test_access(auth.uid(), t.level_id, t.slug)
  );
$$;

-- ---------------------------------------------------------------------
-- التصحيح: نفس الحدّ بالسيرفر. الجسم منسوخ حرفياً من 0003 ما عدا
-- سطر الصلاحية — منطق التصحيح والنقاط ما انلمس.
-- ---------------------------------------------------------------------
create or replace function submit_attempt(
  p_test_id  uuid,
  p_block_id text,
  p_answers  jsonb
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user       uuid := auth.uid();
  v_level      text;
  v_slug       text;
  v_parts      text[];
  v_attempt_id uuid;
  v_points     numeric := 0;
  v_max        numeric := 0;
  v_results    jsonb   := '[]';
  r            record;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  select level_id, slug into v_level, v_slug
    from tests where id = p_test_id and published;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'test_not_found');
  end if;

  if not (exists (select 1 from tests where id = p_test_id and is_free)
          or has_test_access(v_user, v_level, v_slug)) then
    return jsonb_build_object('ok', false, 'error', 'not_entitled');
  end if;

  select array(select jsonb_array_elements_text(b->'parts'))
    into v_parts
    from tests t, jsonb_array_elements(t.blocks) b
   where t.id = p_test_id and b->>'id' = p_block_id;

  if v_parts is null or array_length(v_parts, 1) is null then
    return jsonb_build_object('ok', false, 'error', 'block_not_found');
  end if;

  insert into attempts (user_id, test_id, block_id, answers, submitted_at)
  values (v_user, p_test_id, p_block_id, p_answers, now())
  returning id into v_attempt_id;

  for r in
    select i.id, i.item_id, i.points, s.section_id, s.format,
           ia.answer, ia.explanation,
           p_answers ->> i.id::text as given
      from items i
      join sections s on s.id = i.section_id
      left join item_answers ia on ia.item_id = i.id
     where s.test_id = p_test_id
       and s.section_id = any(v_parts)
       and s.format <> 'writing'
       and ia.answer is not null
     order by s.sort, i.sort
  loop
    v_max := v_max + r.points;
    if r.given is not null and r.given = r.answer then
      v_points := v_points + r.points;
    else
      -- غلط بالامتحان = رجوع لأول صندوق، مستحق فوراً
      insert into mistakes (user_id, item_id, box, due_at)
      values (v_user, r.id, 1, now())
      on conflict (user_id, item_id)
        do update set wrong_count = mistakes.wrong_count + 1,
                      box = 1, due_at = now(), last_seen_at = now();
    end if;

    v_results := v_results || jsonb_build_object(
      'id',          r.id,
      'section',     r.section_id,
      'item',        r.item_id,
      'given',       r.given,
      'answer',      r.answer,
      'explanation', r.explanation,
      'correct',     (r.given is not null and r.given = r.answer));
  end loop;

  update attempts
     set points = v_points, max_points = v_max,
         pct = case when v_max > 0 then round(100 * v_points / v_max, 1) else null end
   where id = v_attempt_id;

  return jsonb_build_object(
    'ok', true, 'attempt_id', v_attempt_id,
    'points', v_points, 'max_points', v_max,
    'pct', case when v_max > 0 then round(100 * v_points / v_max, 1) else null end,
    'results', v_results);
end $$;

-- المراجعة المتباعدة: نفس الحدّ
create or replace function submit_drill(p_answers jsonb)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user    uuid := auth.uid();
  v_right   int  := 0;
  v_total   int  := 0;
  v_master  int  := 0;
  v_results jsonb := '[]';
  v_box     int;
  r         record;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  for r in
    select i.id, i.item_id, s.section_id, t.slug, t.level_id,
           ia.answer, ia.explanation, m.box,
           p_answers ->> i.id::text as given
      from items i
      join item_answers ia on ia.item_id = i.id
      join sections s on s.id = i.section_id
      join tests   t on t.id = s.test_id
      join mistakes m on m.item_id = i.id and m.user_id = v_user
     where i.id::text in (select jsonb_object_keys(p_answers))
       and (t.is_free or has_test_access(v_user, t.level_id, t.slug))
  loop
    v_total := v_total + 1;
    if r.given is not null and r.given = r.answer then
      v_right := v_right + 1;
      v_box := r.box + 1;
      if v_box > 5 then v_master := v_master + 1; end if;
      update mistakes
         set box = v_box,
             right_count = right_count + 1,
             -- المتقن بيتأجّل بعيد بدل ما ينحذف: التاريخ بيضل للتحليلات
             due_at = now() + case when v_box > 5 then interval '365 days'
                                   else review_interval(v_box) end,
             last_seen_at = now()
       where user_id = v_user and item_id = r.id;
    else
      update mistakes
         set box = 1, wrong_count = wrong_count + 1,
             due_at = now(), last_seen_at = now()
       where user_id = v_user and item_id = r.id;
    end if;

    v_results := v_results || jsonb_build_object(
      'id', r.id, 'item', r.item_id, 'section', r.section_id, 'test', r.slug,
      'given', r.given, 'answer', r.answer, 'explanation', r.explanation,
      'correct', (r.given is not null and r.given = r.answer));
  end loop;

  return jsonb_build_object(
    'ok', true, 'right', v_right, 'total', v_total, 'mastered', v_master,
    'pct', case when v_total > 0 then round(100.0 * v_right / v_total, 1) else null end,
    'results', v_results);
end $$;

-- تصحيح الكتابة: نفس الحدّ
create or replace function writing_start(p_attempt_id uuid)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user  uuid := auth.uid();
  a       attempts%rowtype;
  v_slug     text;
  v_level text;
  v_sec   record;
  v_text  text;
  v_q     jsonb;
  v_id    uuid;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  select * into a from attempts where id = p_attempt_id and user_id = v_user;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'attempt_not_found');
  end if;

  select level_id, slug into v_level, v_slug from tests where id = a.test_id;
  if not has_test_access(v_user, v_level, v_slug) then
    return jsonb_build_object('ok', false, 'error', 'not_entitled');
  end if;

  select s.id, s.section_id, s.instruction, s.config into v_sec
    from sections s
   where s.test_id = a.test_id and s.format = 'writing'
     and s.section_id in (
       select jsonb_array_elements_text(b->'parts')
         from tests t, jsonb_array_elements(t.blocks) b
        where t.id = a.test_id and b->>'id' = a.block_id)
   limit 1;
  if v_sec.id is null then
    return jsonb_build_object('ok', false, 'error', 'not_a_writing_block');
  end if;

  select a.answers ->> i.id::text into v_text
    from items i where i.section_id = v_sec.id order by i.sort limit 1;

  if coalesce(trim(v_text), '') = '' then
    return jsonb_build_object('ok', false, 'error', 'empty_text');
  end if;

  v_q := writing_quota_state();
  if (v_q->>'used')::int >= (v_q->>'quota')::int then
    return jsonb_build_object('ok', false, 'error', 'quota_exceeded',
                              'used', v_q->'used', 'quota', v_q->'quota');
  end if;

  insert into writing_feedback (attempt_id, user_id, section_id, text, word_count,
                                max_points, status)
  values (p_attempt_id, v_user, v_sec.id, v_text,
          array_length(regexp_split_to_array(trim(v_text), '\s+'), 1),
          coalesce((v_sec.config->>'maxPoints')::numeric, 45), 'pending')
  returning id into v_id;

  return jsonb_build_object(
    'ok', true,
    'feedback_id', v_id,
    'text', v_text,
    'instruction', v_sec.instruction,
    'task',      v_sec.config->'brief',
    'points',    (select i.meta->'points' from items i
                   where i.section_id = v_sec.id order by i.sort limit 1),
    'min_words', (select (i.meta->>'minWords')::int from items i
                   where i.section_id = v_sec.id order by i.sort limit 1),
    'criteria',  v_sec.config->'criteria',
    'grades',    v_sec.config->'grades',
    'factor',    coalesce((v_sec.config->>'factor')::numeric, 1),
    'max_points',coalesce((v_sec.config->>'maxPoints')::numeric, 45),
    'level',     v_level,
    'used', v_q->'used', 'quota', v_q->'quota');
end $$;
-- ---------------------------------------------------------------------
-- التفعيل: المدّة صارت أيام + ساعات، والنطاق بينتقل للاشتراك
-- ---------------------------------------------------------------------
create or replace function redeem_code(
  p_code        text,
  p_fingerprint text,
  p_user_agent  text default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user  uuid := auth.uid();
  v_code  access_codes%rowtype;
  v_sub   subscriptions%rowtype;
  v_used  int;
  v_wait  int;
  v_res   jsonb;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  -- ★ الحد أول شي: قبل أي استعلام على الأكواد
  v_wait := redeem_blocked_for(p_fingerprint);
  if v_wait > 0 then
    return jsonb_build_object('ok', false, 'error', 'too_many_attempts',
                              'retry_after', v_wait);
  end if;

  insert into profiles (id) values (v_user) on conflict (id) do nothing;

  select * into v_code from access_codes
   where upper(code) = upper(trim(p_code))
   for update;                                   -- يمنع تفعيلين بنفس اللحظة

  if not found then
    insert into redeem_attempts (user_id, fingerprint, success)
    values (v_user, p_fingerprint, false);
    return jsonb_build_object('ok', false, 'error', 'invalid_code');
  end if;

  if v_code.revoked_at is not null then
    insert into redeem_attempts (user_id, fingerprint, success)
    values (v_user, p_fingerprint, false);
    return jsonb_build_object('ok', false, 'error', 'revoked');
  end if;

  -- نفس الحساب أعاد الإدخال: بنرجّع حالته بلا استهلاك تفعيل وبلا تمديد.
  -- وهاد نجاح، فما بينحسب محاولة فاشلة.
  if exists (select 1 from code_redemptions
              where code_id = v_code.id and user_id = v_user) then
    select * into v_sub from subscriptions
     where user_id = v_user and access_code_id = v_code.id
     order by current_period_end desc limit 1;
    perform register_device(p_fingerprint, p_user_agent);
    insert into redeem_attempts (user_id, fingerprint, success)
    values (v_user, p_fingerprint, true);
    return jsonb_build_object(
      'ok', true, 'already', true,
      'levels', coalesce(v_sub.levels, v_code.levels),
      'expires_at', v_sub.current_period_end,
      'uses', code_uses(v_code.id), 'max_uses', v_code.max_uses,
      'tests', v_sub.test_slugs);
  end if;

  -- حساب جديد: لازم يكون في تفعيل باقي
  v_used := code_uses(v_code.id);
  if v_used >= v_code.max_uses then
    insert into redeem_attempts (user_id, fingerprint, success)
    values (v_user, p_fingerprint, false);
    return jsonb_build_object('ok', false, 'error', 'code_exhausted',
                              'uses', v_used, 'max_uses', v_code.max_uses);
  end if;

  select * into v_sub from subscriptions
   where user_id = v_user and status = 'active' and levels @> v_code.levels
     and test_slugs is not distinct from v_code.test_slugs
   order by current_period_end desc limit 1;

  if found then
    update subscriptions
       set current_period_end = greatest(current_period_end, now())
                                + make_interval(days => v_code.duration_days, hours => v_code.duration_hours),
           access_code_id = coalesce(access_code_id, v_code.id),
           updated_at = now()
     where id = v_sub.id
     returning * into v_sub;
  else
    insert into subscriptions (user_id, levels, current_period_end, access_code_id, test_slugs)
    values (v_user, v_code.levels,
            now() + make_interval(days => v_code.duration_days,
                                  hours => v_code.duration_hours),
            v_code.id, v_code.test_slugs)
    returning * into v_sub;
  end if;

  insert into code_redemptions (code_id, user_id, fingerprint, user_agent)
  values (v_code.id, v_user, p_fingerprint, left(p_user_agent, 200));

  update access_codes
     set redeemed_at = coalesce(redeemed_at, now()),
         redeemed_by = coalesce(redeemed_by, v_user)
   where id = v_code.id;

  perform register_device(p_fingerprint, p_user_agent);

  insert into redeem_attempts (user_id, fingerprint, success)
  values (v_user, p_fingerprint, true);

  return jsonb_build_object(
    'ok', true,
    'levels', v_sub.levels,
    'expires_at', v_sub.current_period_end,
    'uses', v_used + 1, 'max_uses', v_code.max_uses,
    'tests', v_sub.test_slugs);
end $$;

-- ---------------------------------------------------------------------
-- التوليد: ساعات ونطاق امتحانات
-- النسخة القديمة (٦ معاملات) لازم تنشال، وإلا نداء بـ٦ وسائط ملتبس
-- ---------------------------------------------------------------------
drop function if exists admin_create_codes(int, text[], int, int, text, int);

create or replace function admin_create_codes(
  p_count       int,
  p_levels      text[],
  p_days        int,
  p_max_devices int  default 2,      -- محفوظ للتوافق؛ صار max_uses هو الحاكم
  p_note        text default null,
  p_max_uses    int  default 2,
  p_hours       int  default 0,       -- بينضاف للأيام؛ تجريبي = ٠ يوم + ٢٤ ساعة
  p_tests       text[] default null   -- null = كل امتحانات المستوى
) returns setof text
language plpgsql security definer set search_path = public as $$
declare
  alphabet text := '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
  prefix   text := upper(coalesce(p_levels[1], 'XX'));
  v_code   text;
  i        int;
  j        int;
begin
  perform admin_guard();
  if p_count < 1 or p_count > 200 then raise exception 'count_out_of_range'; end if;
  -- صفر يوم مسموح إذا في ساعات؛ بس المجموع لازم يكون موجب
  if p_days < 0 or p_hours < 0 or (p_days = 0 and p_hours = 0) then
    raise exception 'duration_out_of_range';
  end if;
  if p_tests is not null and array_length(p_tests, 1) is null then
    raise exception 'tests_empty';       -- مصفوفة فاضية = ما بيفتح شي
  end if;
  if p_max_uses < 1 or p_max_uses > 10 then raise exception 'uses_out_of_range'; end if;
  if array_length(p_levels, 1) is distinct from 1 then
    raise exception 'exactly_one_level';        -- كود واحد = مستوى واحد
  end if;

  for i in 1..p_count loop
    loop
      v_code := prefix || '-';
      for j in 1..4 loop
        v_code := v_code || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
      end loop;
      v_code := v_code || '-';
      for j in 1..4 loop
        v_code := v_code || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
      end loop;
      exit when not exists (select 1 from access_codes a where a.code = v_code);
    end loop;

    insert into access_codes (code, levels, duration_days, duration_hours,
                              test_slugs, max_devices, max_uses, note, created_by)
    values (v_code, p_levels, p_days, p_hours, p_tests,
            p_max_devices, p_max_uses, p_note, auth.uid());

    perform admin_log('code.create', 'access_code', v_code,
      jsonb_build_object('levels', p_levels, 'days', p_days, 'hours', p_hours,
                         'tests', p_tests, 'max_uses', p_max_uses, 'note', p_note));
    return next v_code;
  end loop;
end $$;
-- ---------------------------------------------------------------------
-- قائمة الأكواد: بتقول المدّة الحقيقية والنطاق
-- ---------------------------------------------------------------------
create or replace function admin_codes()
returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  perform admin_guard();
  select coalesce(jsonb_agg(x order by x->>'created_at' desc), '[]') into r
  from (
    select jsonb_build_object(
      'id', c.id, 'code', c.code, 'levels', c.levels,
      'duration_days', c.duration_days, 'duration_hours', c.duration_hours,
      'test_slugs', c.test_slugs,
      'max_uses', c.max_uses,
      'uses', (select count(*) from code_redemptions cr where cr.code_id = c.id),
      'note', c.note, 'created_at', c.created_at, 'revoked_at', c.revoked_at,
      'redeemers', (select coalesce(jsonb_agg(jsonb_build_object(
                      'name', p.display_name, 'at', cr.created_at) order by cr.created_at), '[]')
                    from code_redemptions cr
                    left join profiles p on p.id = cr.user_id
                   where cr.code_id = c.id)) as x
      from access_codes c
     order by c.created_at desc
     limit 200
  ) q;
  return r;
end $$;

revoke all on function admin_create_codes(int,text[],int,int,text,int,int,text[]) from public;
grant execute on function admin_create_codes(int,text[],int,int,text,int,int,text[])
  to authenticated;
