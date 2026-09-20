-- =====================================================================
-- 0026_reject_text — سبب رفض بخطّ إيدك، ولغة بتتحدّث
--
-- ★ مشكلتين طلعوا بالاستعمال:
--
--   ١. الأسباب الأربعة الجاهزة ما بتكفي. أحياناً بدّك تكتب للطالب شي
--      خاص فيه. العمود كان ٦٤ حرف — بيكفي لمفتاح، مو لجملة.
--
--   ٢. لغة الطالب كانت بتنحفظ وقت التجريبي وبس. مين أخد التجريبي
--      بالعربي وبعدين طلب الوصول بالألماني، كان بياخد الردّ بالعربي.
--      اللغة لازم تتحدّث مع كل خطوة بيختارها الطالب.
-- =====================================================================

alter table access_requests
  alter column reason type varchar(300);

drop function if exists bot_request_access(bigint, int);

create or replace function bot_request_access(
  p_telegram_id bigint,
  p_months      int,
  p_lang        text default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_u telegram_users%rowtype; v_r access_requests%rowtype; v_lvl levels%rowtype;
        v_lang text;
begin
  if p_months is null or p_months < 1 or p_months > 12 then
    raise exception 'months_out_of_range';
  end if;

  select * into v_u from telegram_users where telegram_id = p_telegram_id;
  if not found then raise exception 'no_demo_yet'; end if;

  -- ★ آخر لغة اختارها هي لغته. الردّ بيوصله فيها حتى لو أخد التجريبي بغيرها.
  --
  -- متغيّر لحاله مو v_u.lang := …: Postgres بيقبل الإسناد لحقل جوّا
  -- %rowtype، بس المحلّل السكوني (pglast بالـCI) ما بيقدر يحلّ نوع
  -- الصفّ بلا قاعدة فبيرفضه. ومنّا شغلة تستاهل نضعّف الفحص لأجلها.
  v_lang := nullif(trim(coalesce(p_lang, '')), '');
  if v_lang is null then
    v_lang := v_u.lang;
  elsif v_lang is distinct from v_u.lang then
    v_lang := left(v_lang, 8);
    update telegram_users set lang = v_lang where telegram_id = p_telegram_id;
  end if;

  select * into v_r from access_requests
   where telegram_id = p_telegram_id and status = 'pending';
  if found then
    select * into v_lvl from levels where id = v_r.level_id;
    return jsonb_build_object('ok', true, 'again', true, 'request_id', v_r.id,
      'months', v_r.months, 'username', v_u.username, 'lang', v_lang,
      'level_id', v_r.level_id, 'stufe', v_lvl.stufe, 'provider', v_lvl.provider);
  end if;

  insert into access_requests (telegram_id, level_id, months)
  values (p_telegram_id, v_u.level_id, p_months)
  returning * into v_r;

  select * into v_lvl from levels where id = v_r.level_id;
  return jsonb_build_object('ok', true, 'again', false, 'request_id', v_r.id,
    'months', v_r.months, 'username', v_u.username, 'lang', v_lang,
    'level_id', v_r.level_id, 'stufe', v_lvl.stufe, 'provider', v_lvl.provider);
end $$;
revoke all on function bot_request_access(bigint, int, text)
  from public, anon, authenticated;

-- السبب الحرّ بيوصل كامل، مو مقصوص على ٦٤
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

  select * into v_u from telegram_users where telegram_id = v_r.telegram_id;

  if p_approve then
    if v_r.level_id is null then raise exception 'level_gone'; end if;
    v_code := new_access_code(v_r.level_id);
    insert into access_codes (code, levels, duration_days, duration_hours,
                              test_slugs, max_devices, max_uses, note)
    values (v_code, array[v_r.level_id], v_r.months * 30, 0,
            null, 2, 1, 'telegram-full:' || v_r.telegram_id)
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
returns int language sql immutable as $$ select 26 $$;
grant execute on function schema_version() to authenticated, anon;
