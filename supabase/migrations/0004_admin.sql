-- =====================================================================
-- 0004_admin — إجراءات لوحة التحكّم
--
-- ليش دوال بدل كتابة مباشرة عالجداول؟ سجلّ التدقيق. لو اللوحة كتبت
-- على subscriptions رأساً، أي إجراء ممكن يصير بلا أثر. هون كل دالة
-- بتكتب سطر بـadmin_audit_log بنفس المعاملة — ما في طريق يتخطّاه.
--
-- القراءة بتضل مباشرة عبر PostgREST: سياسة admin_all بتسمح فيها،
-- والقراءة ما بدها تدقيق.
-- =====================================================================

-- تسجيل إجراء — بتنندعى من كل دالة تحت
create or replace function admin_log(
  p_action text, p_type text, p_id text, p_detail jsonb default '{}'
) returns void
language sql security definer set search_path = public as $$
  insert into admin_audit_log (admin_id, action, target_type, target_id, detail)
  values (auth.uid(), p_action, p_type, p_id, p_detail);
$$;

-- حارس: كل دالة بتبلّش فيه
create or replace function admin_guard() returns void
language plpgsql security definer set search_path = public as $$
begin
  if not is_admin() then
    raise exception 'not_admin' using errcode = 'insufficient_privilege';
  end if;
end $$;

-- ---------------------------------------------------------------------
-- توليد أكواد وصول
-- الحروف بلا 0/O/1/I/L — تا ما ينقرا الكود غلط عالتلفون
-- ---------------------------------------------------------------------
create or replace function admin_create_codes(
  p_count       int,
  p_levels      text[],
  p_days        int,
  p_max_devices int  default 2,
  p_note        text default null
) returns setof text
language plpgsql security definer set search_path = public as $$
declare
  alphabet text := '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
  prefix   text := upper(coalesce(p_levels[1], 'XX'));
  v_code   text;      -- مو 'code': بينلخبط مع access_codes.code جوّا الاستعلام
  i        int;
  j        int;
begin
  perform admin_guard();
  if p_count < 1 or p_count > 200 then
    raise exception 'count_out_of_range';
  end if;
  if p_days < 1 then raise exception 'days_out_of_range'; end if;

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

    insert into access_codes (code, levels, duration_days, max_devices, note, created_by)
    values (v_code, p_levels, p_days, p_max_devices, p_note, auth.uid());

    perform admin_log('code.create', 'access_code', v_code,
      jsonb_build_object('levels', p_levels, 'days', p_days,
                         'max_devices', p_max_devices, 'note', p_note));
    return next v_code;
  end loop;
end $$;

-- ---------------------------------------------------------------------
-- تمديد أو تقصير اشتراك — الطلب الأساسي من اللوحة
-- p_days موجب بيمدّد، سالب بيقصّر
-- ---------------------------------------------------------------------
create or replace function admin_shift_subscription(p_sub_id uuid, p_days int)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_old timestamptz; v_new timestamptz;
begin
  perform admin_guard();

  select current_period_end into v_old from subscriptions where id = p_sub_id;
  if not found then raise exception 'subscription_not_found'; end if;

  -- التقصير ما بيرجّع الاشتراك لقبل هلق: بيوقف عند اللحظة الحالية
  v_new := greatest(v_old + make_interval(days => p_days), now());

  update subscriptions
     set current_period_end = v_new,
         status = case when v_new > now() then 'active' else status end,
         updated_at = now()
   where id = p_sub_id;

  perform admin_log(
    case when p_days >= 0 then 'sub.extend' else 'sub.shorten' end,
    'subscription', p_sub_id::text,
    jsonb_build_object('days', p_days, 'from', v_old, 'to', v_new));

  return jsonb_build_object('ok', true, 'current_period_end', v_new);
end $$;

-- تاريخ انتهاء محدّد بدل عدد أيام
create or replace function admin_set_period_end(p_sub_id uuid, p_end timestamptz)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_old timestamptz;
begin
  perform admin_guard();
  select current_period_end into v_old from subscriptions where id = p_sub_id;
  if not found then raise exception 'subscription_not_found'; end if;

  update subscriptions
     set current_period_end = p_end,
         status = case when p_end > now() then 'active' else status end,
         updated_at = now()
   where id = p_sub_id;

  perform admin_log('sub.set_end', 'subscription', p_sub_id::text,
    jsonb_build_object('from', v_old, 'to', p_end));
  return jsonb_build_object('ok', true, 'current_period_end', p_end);
end $$;

-- إلغاء / إعادة تفعيل
create or replace function admin_set_subscription_status(p_sub_id uuid, p_status text)
returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  if p_status not in ('active', 'revoked', 'expired') then
    raise exception 'bad_status';
  end if;
  update subscriptions set status = p_status, updated_at = now() where id = p_sub_id;
  if not found then raise exception 'subscription_not_found'; end if;

  perform admin_log('sub.status', 'subscription', p_sub_id::text,
                    jsonb_build_object('status', p_status));
  return jsonb_build_object('ok', true, 'status', p_status);
end $$;

-- ---------------------------------------------------------------------
-- الأجهزة — لما يضيع جهاز الطالب أو ينبدّل
-- ---------------------------------------------------------------------
create or replace function admin_reset_devices(p_user_id uuid)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare n int;
begin
  perform admin_guard();
  delete from devices where user_id = p_user_id;
  get diagnostics n = row_count;
  perform admin_log('devices.reset', 'profile', p_user_id::text,
                    jsonb_build_object('removed', n));
  return jsonb_build_object('ok', true, 'removed', n);
end $$;

-- ---------------------------------------------------------------------
-- سَمِّ المستخدم — هو مجهول بالنظام، فالاسم والملاحظة هنّ الوحيدين
-- يلي بيخلّوكي تعرفي مين هو
-- ---------------------------------------------------------------------
create or replace function admin_set_profile(
  p_user_id uuid, p_name text, p_note text
) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  update profiles set display_name = p_name, note = p_note where id = p_user_id;
  if not found then raise exception 'profile_not_found'; end if;
  perform admin_log('profile.update', 'profile', p_user_id::text,
                    jsonb_build_object('name', p_name, 'note', p_note));
  return jsonb_build_object('ok', true);
end $$;

create or replace function admin_revoke_code(p_code_id uuid)
returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  update access_codes set revoked_at = now()
   where id = p_code_id and revoked_at is null;
  if not found then raise exception 'code_not_found_or_revoked'; end if;
  perform admin_log('code.revoke', 'access_code', p_code_id::text, '{}');
  return jsonb_build_object('ok', true);
end $$;

-- ---------------------------------------------------------------------
-- أرقام الصفحة الرئيسية للوحة
-- ---------------------------------------------------------------------
create or replace function admin_overview() returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  perform admin_guard();
  select jsonb_build_object(
    'users',           (select count(*) from profiles where not is_admin),
    'active_subs',     (select count(*) from subscriptions
                         where status = 'active' and current_period_end > now()),
    'expiring_7d',     (select count(*) from subscriptions
                         where status = 'active'
                           and current_period_end between now() and now() + interval '7 days'),
    'expired',         (select count(*) from subscriptions
                         where status <> 'active' or current_period_end <= now()),
    'codes_unused',    (select count(*) from access_codes
                         where redeemed_at is null and revoked_at is null),
    'attempts_7d',     (select count(*) from attempts
                         where submitted_at > now() - interval '7 days'),
    'tests_published', (select count(*) from tests where published),
    'levels',          (select coalesce(jsonb_agg(jsonb_build_object(
                                 'id', id, 'title', title, 'published', published)
                               order by sort), '[]') from levels)
  ) into r;
  return r;
end $$;

-- ---------------------------------------------------------------------
-- صفّ المستخدمين للوحة — تجميعة وحدة بدل عدة استعلامات
-- ---------------------------------------------------------------------
create or replace function admin_users(p_search text default null)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  perform admin_guard();
  select coalesce(jsonb_agg(x order by x->>'created_at' desc), '[]') into r from (
    select jsonb_build_object(
      'id', p.id,
      'name', p.display_name,
      'note', p.note,
      'created_at', p.created_at,
      'last_seen_at', p.last_seen_at,
      'devices', (select count(*) from devices d where d.user_id = p.id),
      'attempts', (select count(*) from attempts a where a.user_id = p.id),
      'best_pct', (select max(pct) from attempts a where a.user_id = p.id),
      'mistakes', (select count(*) from mistakes m where m.user_id = p.id),
      'sub', (select jsonb_build_object(
                'id', s.id, 'levels', s.levels, 'status', s.status,
                'current_period_end', s.current_period_end,
                'days_left', greatest(0, ceil(extract(epoch from
                              (s.current_period_end - now())) / 86400))::int,
                'source', s.source)
              from subscriptions s where s.user_id = p.id
              order by s.current_period_end desc limit 1),
      'code', (select ac.code from access_codes ac where ac.redeemed_by = p.id
               order by ac.redeemed_at desc limit 1)
    ) as x
    from profiles p
    where not p.is_admin
      and (p_search is null or p_search = ''
           or p.display_name ilike '%' || p_search || '%'
           or p.note ilike '%' || p_search || '%'
           or exists (select 1 from access_codes ac
                       where ac.redeemed_by = p.id and ac.code ilike '%' || p_search || '%'))
  ) t;
  return r;
end $$;

revoke all on function admin_create_codes(int,text[],int,int,text)   from public;
revoke all on function admin_shift_subscription(uuid,int)            from public;
revoke all on function admin_set_period_end(uuid,timestamptz)        from public;
revoke all on function admin_set_subscription_status(uuid,text)      from public;
revoke all on function admin_reset_devices(uuid)                     from public;
revoke all on function admin_set_profile(uuid,text,text)             from public;
revoke all on function admin_revoke_code(uuid)                       from public;
revoke all on function admin_overview()                              from public;
revoke all on function admin_users(text)                             from public;
revoke all on function admin_log(text,text,text,jsonb)               from public, authenticated;
revoke all on function admin_guard()                                 from public, authenticated;

grant execute on function admin_create_codes(int,text[],int,int,text)  to authenticated;
grant execute on function admin_shift_subscription(uuid,int)           to authenticated;
grant execute on function admin_set_period_end(uuid,timestamptz)       to authenticated;
grant execute on function admin_set_subscription_status(uuid,text)     to authenticated;
grant execute on function admin_reset_devices(uuid)                    to authenticated;
grant execute on function admin_set_profile(uuid,text,text)            to authenticated;
grant execute on function admin_revoke_code(uuid)                      to authenticated;
grant execute on function admin_overview()                             to authenticated;
grant execute on function admin_users(text)                            to authenticated;
