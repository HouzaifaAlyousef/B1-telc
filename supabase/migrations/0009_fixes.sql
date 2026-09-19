-- =====================================================================
-- 0009_fixes — بغّين انكشفوا بالفحص العدائي
--
-- ١) الكود كان بينعاد تنفيذه من نفس المستخدم وبيمدّد كل مرة.
--    ١٢ إدخال = سنة مجاناً. الكود صار مرة وحدة فعلاً، والإعادة
--    بترجّع نفس الحالة بلا تمديد (تا يضل آمن لو التطبيق أعاد النداء).
--
-- ٢) نافذة حصّة التصحيح كانت (نهاية الاشتراك − ٣٠ يوم). مع اشتراك
--    سنوي هاد تاريخ **بالمستقبل**، فما كان ينعدّ ولا تصحيح والحصّة
--    ما بتنفرض أبداً — يعني تكلفة API بلا سقف. صارت ٣٠ يوم متدحرجة.
-- =====================================================================

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

  -- ★ الكود بينفّذ مرة وحدة. لو نفس المستخدم أعاد النداء (زرّ مضغوط
  --   مرتين، شبكة أعادت الطلب) منرجّع حالته كما هي — بلا تمديد.
  if v_code.redeemed_at is not null then
    if v_code.redeemed_by <> v_user then
      return jsonb_build_object('ok', false, 'error', 'already_used');
    end if;
    select * into v_sub from subscriptions
     where user_id = v_user and access_code_id = v_code.id
     order by current_period_end desc limit 1;
    perform register_device(p_fingerprint, p_user_agent);
    return jsonb_build_object(
      'ok', true, 'already', true,
      'levels', coalesce(v_sub.levels, v_code.levels),
      'expires_at', v_sub.current_period_end);
  end if;

  insert into profiles (id) values (v_user) on conflict (id) do nothing;

  select * into v_sub from subscriptions
   where user_id = v_user and status = 'active' and levels @> v_code.levels
   order by current_period_end desc limit 1;

  if found then
    update subscriptions
       set current_period_end = greatest(current_period_end, now())
                                + make_interval(days => v_code.duration_days),
           access_code_id = coalesce(access_code_id, v_code.id),
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
     set redeemed_at = now(), redeemed_by = v_user
   where id = v_code.id;

  perform register_device(p_fingerprint, p_user_agent);

  return jsonb_build_object(
    'ok', true,
    'levels', v_sub.levels,
    'expires_at', v_sub.current_period_end);
end $$;

-- ---------------------------------------------------------------------
-- نافذة الحصّة: ٣٠ يوم متدحرجة، ما بتصير بالمستقبل مهما كان الاشتراك
-- ---------------------------------------------------------------------
create or replace function writing_quota_state()
returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user  uuid := auth.uid();
  v_since timestamptz := now() - interval '30 days';
  v_quota int;
  v_used  int;
begin
  if v_user is null then return jsonb_build_object('used', 0, 'quota', 0); end if;
  select writing_quota into v_quota from subscriptions
   where user_id = v_user and status = 'active'
   order by current_period_end desc limit 1;
  v_quota := coalesce(v_quota, 20);
  select count(*) into v_used from writing_feedback
   where user_id = v_user and status <> 'failed' and created_at >= v_since;
  return jsonb_build_object('used', v_used, 'quota', v_quota,
                            'since', v_since, 'left', greatest(0, v_quota - v_used));
end $$;

create or replace function writing_start(p_attempt_id uuid)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user  uuid := auth.uid();
  a       attempts%rowtype;
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

  select level_id into v_level from tests where id = a.test_id;
  if not has_access(v_user, v_level) then
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

revoke all on function writing_quota_state() from public;
grant execute on function writing_quota_state() to authenticated;
