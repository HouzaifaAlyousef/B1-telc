-- =====================================================================
-- 0025_group_admin — المجموعة كلها بتوافق، مو أشخاص بأسمائهن
--
-- كان لازم كل واحد بيوافق ينتسجّل برقمه. بمجموعة بيدخلها ويطلع منها
-- ناس، هاد بيصير قايمة تانية لازم تتزامن بالإيد — ومين نسي يتشال
-- بيضل موافق.
--
-- ★ العضوية بالمجموعة هي الصلاحية.
--   بطاقة الطلب ما بتوصل إلا لمجموعتك، ومين مو فيها ما بيشوف الزرّ
--   أصلاً. وcb.message.chat.id تلغرام بيحطّه مو المستخدم، فما بينزوّر.
--   (التحويل بيضيّع الأزرار، فما في طريق يوصل الزرّ لبرّا المجموعة.)
--
-- bot_admins صار بيقبل النوعين: رقم شخص (موجب) أو رقم مجموعة (سالب).
-- الموافقة بتمرق لو **أي** واحد فيهن مسجّل.
-- =====================================================================

comment on table bot_admins is
  'مين بيوافق على طلبات الوصول: رقم شخص (موجب) أو رقم مجموعة (سالب)';

drop function if exists bot_decide_request(bigint, uuid, boolean, text);

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
  -- ★ هون الحدّ: الشخص مسجّل، أو الضغطة جاية من مجموعة مسجّلة.
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
       set status = 'rejected', reason = left(p_reason, 64), decided_at = now(),
           decided_by = p_admin_telegram_id
     where id = p_request_id;
  end if;

  -- decided_by بيضل الشخص مو المجموعة: بدنا نعرف مين قرّر فعلاً
  return jsonb_build_object('ok', true,
    'status',  case when p_approve then 'approved' else 'rejected' end,
    'code',    v_code,
    'months',  v_r.months,
    'reason',  left(p_reason, 64),
    'chat_id', v_u.chat_id,
    'lang',    v_u.lang,
    'username', v_u.username);
end $$;
revoke all on function bot_decide_request(bigint, uuid, boolean, text, bigint)
  from public, anon, authenticated;

create or replace function schema_version()
returns int language sql immutable as $$ select 25 $$;
grant execute on function schema_version() to authenticated, anon;
