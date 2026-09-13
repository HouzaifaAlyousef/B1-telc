-- =====================================================================
-- 0027_reserve — حجز الطلب متل تذكرة
--
-- بمجموعة فيها أكتر من شخص، تنين بيفتحوا نفس الطلب وتنين بيردّوا.
-- الحجز بيحلّها: مين بياخده بيصير إله وحده لمدّة، والباقي بيشوفوا
-- مين ماسكه.
--
-- ★ الحجز بينتهي لحاله بالوقت، مو بمسح صفّ.
--   reserve_until بالماضي = الطلب صار حرّ. ما في مهمّة لازم تشتغل
--   لتحرّره، وما في طلب بيضل محجوز للأبد لأنّ التنبيه ما وصل.
--
-- ★ التنبيه بيتبعت مرّة وحدة (nudged_at)، ومين بيبعته هو أول تحديث
--   بيوصل بعد الانتهاء — أو pg_cron لو ظبّطتها. بالحالتين نفس الدالة.
-- =====================================================================

alter table access_requests
  add column if not exists reserved_by   bigint,
  add column if not exists reserved_name text,
  add column if not exists reserve_until timestamptz,
  add column if not exists nudged_at     timestamptz,
  add column if not exists card_chat     bigint,
  add column if not exists card_msg      bigint;

-- الكنس بيدوّر على المحجوزين المنتهيين بس
create index if not exists access_requests_sweep_idx
  on access_requests (reserve_until)
  where status = 'pending' and reserved_by is not null and nudged_at is null;

-- ---------------------------------------------------------------------
-- وين بطاقة الطلب بالمجموعة — لنعرف شو نعدّل وعلى شو نردّ
-- ---------------------------------------------------------------------
create or replace function bot_set_card(
  p_request_id uuid, p_chat bigint, p_msg bigint
) returns void
language sql security definer set search_path = public as $$
  update access_requests set card_chat = p_chat, card_msg = p_msg
   where id = p_request_id;
$$;
revoke all on function bot_set_card(uuid, bigint, bigint)
  from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- الحجز
-- ---------------------------------------------------------------------
create or replace function bot_reserve_request(
  p_admin_telegram_id bigint,
  p_request_id        uuid,
  p_name              text,
  p_minutes           int    default 15,
  p_chat_id           bigint default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_r access_requests%rowtype;
begin
  if not (bot_is_admin(p_admin_telegram_id)
          or (p_chat_id is not null and bot_is_admin(p_chat_id))) then
    raise exception 'not_bot_admin';
  end if;
  if p_minutes < 1 or p_minutes > 1440 then raise exception 'minutes_out_of_range'; end if;

  select * into v_r from access_requests where id = p_request_id for update;
  if not found then raise exception 'request_not_found'; end if;
  if v_r.status <> 'pending' then
    return jsonb_build_object('ok', false, 'already', v_r.status);
  end if;

  -- محجوز لواحد تاني ولسا ما انتهى: ما بينسرق
  if v_r.reserved_by is not null and v_r.reserved_by <> p_admin_telegram_id
     and v_r.reserve_until > now() then
    return jsonb_build_object('ok', false, 'taken', true,
      'by', v_r.reserved_name, 'until', v_r.reserve_until);
  end if;

  update access_requests
     set reserved_by = p_admin_telegram_id,
         reserved_name = left(p_name, 64),
         reserve_until = now() + make_interval(mins => p_minutes),
         nudged_at = null                     -- حجز جديد = تنبيه جديد
   where id = p_request_id
  returning * into v_r;

  return jsonb_build_object('ok', true, 'by', v_r.reserved_name,
    'until', v_r.reserve_until, 'minutes', p_minutes);
end $$;
revoke all on function bot_reserve_request(bigint, uuid, text, int, bigint)
  from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- الكنس: مين انتهى حجزه ولسا ما قرّر
-- ★ بيعلّم nudged_at بنفس الاستعلام، فتشغيلين بنفس اللحظة ما بيبعتوا
--   تنبيهين — يلي بياخد الصفّ أوّل بياخده وحده.
-- ---------------------------------------------------------------------
create or replace function bot_sweep_reservations()
returns jsonb
language sql security definer set search_path = public as $$
  with due as (
    update access_requests r set nudged_at = now()
     where r.status = 'pending' and r.reserved_by is not null
       and r.nudged_at is null and r.reserve_until <= now()
       and r.id in (select id from access_requests
                     where status = 'pending' and reserved_by is not null
                       and nudged_at is null and reserve_until <= now()
                     for update skip locked)
    returning r.id, r.reserved_by, r.reserved_name, r.card_chat, r.card_msg, r.months
  )
  select coalesce(jsonb_agg(to_jsonb(due)), '[]'::jsonb) from due;
$$;
revoke all on function bot_sweep_reservations()
  from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- القرار: بيحترم الحجز، والكود صار ٣ تفعيلات
-- ---------------------------------------------------------------------
create or replace function bot_decide_request(
  p_admin_telegram_id bigint,
  p_request_id        uuid,
  p_approve           boolean,
  p_reason            text   default null,
  p_chat_id           bigint default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_r access_requests%rowtype; v_u telegram_users%rowtype;
        v_code text; v_id uuid;
begin
  if not (bot_is_admin(p_admin_telegram_id)
          or (p_chat_id is not null and bot_is_admin(p_chat_id))) then
    raise exception 'not_bot_admin';
  end if;

  select * into v_r from access_requests where id = p_request_id for update;
  if not found then raise exception 'request_not_found'; end if;
  if v_r.status <> 'pending' then
    return jsonb_build_object('ok', false, 'already', v_r.status);
  end if;

  -- ★ محجوز لواحد تاني ولسا وقته: هو يلي بيقرّر. بعد ما ينتهي بيصير حرّ.
  if v_r.reserved_by is not null and v_r.reserved_by <> p_admin_telegram_id
     and v_r.reserve_until > now() then
    return jsonb_build_object('ok', false, 'taken', true,
      'by', v_r.reserved_name, 'until', v_r.reserve_until);
  end if;

  select * into v_u from telegram_users where telegram_id = v_r.telegram_id;

  if p_approve then
    if v_r.level_id is null then raise exception 'level_gone'; end if;
    v_code := new_access_code(v_r.level_id);
    -- ٣ تفعيلات: الطالب بيقدر يفتحه على جهاز تاني أو بعد ما يمسح الكاش
    insert into access_codes (code, levels, duration_days, duration_hours,
                              test_slugs, max_devices, max_uses, note)
    values (v_code, array[v_r.level_id], v_r.months * 30, 0,
            null, 2, 3, 'telegram-full:' || v_r.telegram_id)
    returning id into v_id;

    update access_requests
       set status = 'approved', code_id = v_id, decided_at = now(),
           decided_by = p_admin_telegram_id
     where id = p_request_id;
  else
    update access_requests
       set status = 'rejected', reason = left(p_reason, 300), decided_at = now(),
           decided_by = p_admin_telegram_id
     where id = p_request_id;
  end if;

  return jsonb_build_object('ok', true,
    'status',  case when p_approve then 'approved' else 'rejected' end,
    'code',    v_code,
    'months',  v_r.months,
    'reason',  left(p_reason, 300),
    'chat_id', v_u.chat_id,
    'lang',    v_u.lang,
    'username', v_u.username);
end $$;
revoke all on function bot_decide_request(bigint, uuid, boolean, text, bigint)
  from public, anon, authenticated;

create or replace function schema_version()
returns int language sql immutable as $$ select 27 $$;
grant execute on function schema_version() to authenticated, anon;
