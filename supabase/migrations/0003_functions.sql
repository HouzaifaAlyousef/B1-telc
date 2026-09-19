-- =====================================================================
-- 0003_functions — المنطق يلي لازم يصير بالسيرفر
--
-- دالتين بس بيحملوا كل الوزن:
--   redeem_code()    — الكود ← اشتراك + جهاز مسجّل
--   submit_attempt() — الإجابات ← علامة محسوبة بالسيرفر
-- =====================================================================

-- ---------------------------------------------------------------------
-- تنفيذ كود الوصول
-- بينندعى بعد تسجيل دخول مجهول، فـauth.uid() موجود.
-- ---------------------------------------------------------------------
create or replace function redeem_code(
  p_code        text,
  p_fingerprint text,
  p_user_agent  text default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user uuid := auth.uid();
  v_code access_codes%rowtype;
  v_sub  subscriptions%rowtype;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  select * into v_code from access_codes
   where upper(code) = upper(trim(p_code))
   for update;

  if not found then
    return jsonb_build_object('ok', false, 'error', 'invalid_code');
  end if;
  if v_code.revoked_at is not null then
    return jsonb_build_object('ok', false, 'error', 'revoked');
  end if;
  -- الكود بينفّذ مرة وحدة. المستخدم بعدها بيدخل بجلسته، مو بالكود.
  if v_code.redeemed_at is not null and v_code.redeemed_by <> v_user then
    return jsonb_build_object('ok', false, 'error', 'already_used');
  end if;

  insert into profiles (id) values (v_user) on conflict (id) do nothing;

  -- اشتراك ساري لنفس المستويات؟ مدّده. غير هيك اعمل جديد.
  select * into v_sub from subscriptions
   where user_id = v_user and status = 'active' and levels @> v_code.levels
   order by current_period_end desc limit 1;

  if found then
    update subscriptions
       set current_period_end = greatest(current_period_end, now())
                                + make_interval(days => v_code.duration_days),
           updated_at = now()
     where id = v_sub.id
     returning * into v_sub;
  else
    insert into subscriptions (user_id, levels, current_period_end, access_code_id)
    values (v_user, v_code.levels,
            now() + make_interval(days => v_code.duration_days), v_code.id)
    returning * into v_sub;
  end if;

  update access_codes
     set redeemed_at = coalesce(redeemed_at, now()), redeemed_by = v_user
   where id = v_code.id;

  perform register_device(p_fingerprint, p_user_agent);

  return jsonb_build_object(
    'ok', true,
    'levels', v_sub.levels,
    'expires_at', v_sub.current_period_end);
end $$;

-- ---------------------------------------------------------------------
-- تسجيل الجهاز — هون بينفرض سقف الأجهزة (الدفاع ضد مشاركة الكود)
-- ---------------------------------------------------------------------
create or replace function register_device(
  p_fingerprint text,
  p_user_agent  text default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user  uuid := auth.uid();
  v_count int;
  v_max   int;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  -- الجهاز معروف؟ حدّث آخر ظهور وخلص.
  update devices set last_seen = now()
   where user_id = v_user and fingerprint = p_fingerprint;
  if found then
    return jsonb_build_object('ok', true, 'known', true);
  end if;

  select coalesce(max(ac.max_devices), 2) into v_max
    from subscriptions s left join access_codes ac on ac.id = s.access_code_id
   where s.user_id = v_user and s.status = 'active';

  select count(*) into v_count from devices where user_id = v_user;

  if v_count >= v_max then
    return jsonb_build_object('ok', false, 'error', 'device_limit',
                              'max', v_max, 'current', v_count);
  end if;

  insert into devices (user_id, fingerprint, user_agent)
  values (v_user, p_fingerprint, p_user_agent)
  on conflict (user_id, fingerprint) do nothing;

  return jsonb_build_object('ok', true, 'known', false);
end $$;

-- ---------------------------------------------------------------------
-- ★ التصحيح — القلب النابض للحماية الكاملة
-- الإجابات بتوصل، العلامة بترجع. مفاتيح الحلول ما بتغادر السيرفر
-- إلا بعد ما تنكتب المحاولة.
-- ---------------------------------------------------------------------
create or replace function submit_attempt(
  p_test_id  uuid,
  p_block_id text,
  p_answers  jsonb          -- { "<uuid السؤال>": "<جواب المستخدم>" }
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user       uuid := auth.uid();
  v_level      text;
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

  select level_id into v_level from tests where id = p_test_id and published;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'test_not_found');
  end if;

  -- إعادة فحص الصلاحية بالسيرفر — ما منثق بالعميل
  if not (exists (select 1 from tests where id = p_test_id and is_free)
          or has_access(v_user, v_level)) then
    return jsonb_build_object('ok', false, 'error', 'not_entitled');
  end if;

  -- أقسام هالكتلة من tests.blocks
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

  -- التصحيح: أقسام التعبير الكتابي ما إلها مفتاح حل، فبتنستثنى
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
      insert into mistakes (user_id, item_id)
      values (v_user, r.id)
      on conflict (user_id, item_id)
        do update set wrong_count = mistakes.wrong_count + 1,
                      last_seen_at = now();
    end if;

    v_results := v_results || jsonb_build_object(
      'id',          r.id,
      'section',     r.section_id,
      'item',        r.item_id,
      'given',       r.given,
      'answer',      r.answer,          -- ← بينكشف هون بس، بعد التسليم
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

revoke all on function redeem_code(text,text,text)      from public;
revoke all on function submit_attempt(uuid,text,jsonb)  from public;
revoke all on function register_device(text,text)       from public;
grant execute on function redeem_code(text,text,text)     to authenticated;
grant execute on function submit_attempt(uuid,text,jsonb) to authenticated;
grant execute on function register_device(text,text)      to authenticated;

-- ---------------------------------------------------------------------
-- تصحيح جولة «تكرار الأخطاء»
-- بتختلف عن submit_attempt لأنها بتجمع أسئلة من امتحانات وأقسام مختلفة،
-- فما إلها امتحان ولا كتلة واحدة. ما بتنكتب كمحاولة — هي تمرين مو امتحان.
-- ---------------------------------------------------------------------
create or replace function submit_drill(p_answers jsonb)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user    uuid := auth.uid();
  v_right   int  := 0;
  v_total   int  := 0;
  v_results jsonb := '[]';
  r         record;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  for r in
    select i.id, i.item_id, s.section_id, t.slug, t.level_id,
           ia.answer, ia.explanation,
           p_answers ->> i.id::text as given
      from items i
      join item_answers ia on ia.item_id = i.id
      join sections s on s.id = i.section_id
      join tests   t on t.id = s.test_id
     where i.id::text in (select jsonb_object_keys(p_answers))
       -- نفس فحص الصلاحية: ما بينفع يتدرّب على مستوى مو مشترك فيه
       and (t.is_free or has_access(v_user, t.level_id))
  loop
    v_total := v_total + 1;
    if r.given is not null and r.given = r.answer then
      v_right := v_right + 1;
      -- جاوب صح ← بيطلع من قائمة الأخطاء
      delete from mistakes where user_id = v_user and item_id = r.id;
    else
      insert into mistakes (user_id, item_id) values (v_user, r.id)
      on conflict (user_id, item_id)
        do update set wrong_count = mistakes.wrong_count + 1,
                      last_seen_at = now();
    end if;

    v_results := v_results || jsonb_build_object(
      'id', r.id, 'item', r.item_id, 'section', r.section_id, 'test', r.slug,
      'given', r.given, 'answer', r.answer, 'explanation', r.explanation,
      'correct', (r.given is not null and r.given = r.answer));
  end loop;

  return jsonb_build_object(
    'ok', true, 'right', v_right, 'total', v_total,
    'pct', case when v_total > 0 then round(100.0 * v_right / v_total, 1) else null end,
    'results', v_results);
end $$;

revoke all on function submit_drill(jsonb) from public;
grant execute on function submit_drill(jsonb) to authenticated;
