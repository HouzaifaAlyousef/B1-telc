-- =====================================================================
-- 0011_rate_limit — حدّ محاولات على تنفيذ الكود
--
-- الأكواد هي كل آلية الوصول، وما كان في شي يوقف التخمين المتكرّر.
-- فضاء الأكواد ٣١⁸ ≈ ٨×١٠¹¹ فالتخمين الأعمى مو عملي، بس بلا حد:
--   · سكربت بسيط بيقدر يدق آلاف المحاولات بالدقيقة
--   · وكل محاولة استعلام على قاعدة البيانات — يعني تكلفة كمان
--
-- الحد على مستويين، والاتنين قابلين للتجاوز من مهاجم مصمّم (بيعمل
-- حساب جديد وبيمسح البصمة). هدفهن يوقفوا الدق الآلي من عميل واحد،
-- مو يمنعوا هجوم موزّع — هاد شغل حدود Supabase نفسها.
-- =====================================================================

create table if not exists redeem_attempts (
  id          bigserial primary key,
  user_id     uuid references profiles(id) on delete cascade,
  fingerprint text,
  success     boolean not null,
  created_at  timestamptz not null default now()
);
-- المحاولات القديمة ما بتنقرا؛ الفهرس على النافذة الحديثة
create index if not exists redeem_attempts_user_idx
  on redeem_attempts (user_id, created_at desc);
create index if not exists redeem_attempts_fp_idx
  on redeem_attempts (fingerprint, created_at desc);

alter table redeem_attempts enable row level security;
grant select on redeem_attempts to authenticated;
drop policy if exists admin_attempts on redeem_attempts;
create policy admin_attempts on redeem_attempts for all to authenticated
  using (is_admin()) with check (is_admin());
-- الطالب ما بيشوف ولا صف: ما إله سياسة قراءة

-- الحدود بمكان واحد تا تنغيّر بسهولة
create or replace function redeem_limits()
returns jsonb language sql immutable as $$
  select jsonb_build_object(
    'window_minutes', 15,
    'max_failed',     8);     -- محاولات فاشلة بالنافذة قبل القفل
$$;

-- ---------------------------------------------------------------------
-- هل هالمحاولة مقفولة؟ بيرجّع عدد الثواني للفتح، أو 0 إذا مسموح
-- ---------------------------------------------------------------------
create or replace function redeem_blocked_for(p_fingerprint text)
returns int
language plpgsql stable security definer set search_path = public as $$
declare
  v_user  uuid := auth.uid();
  v_lim   jsonb := redeem_limits();
  v_win   interval := make_interval(mins => (v_lim->>'window_minutes')::int);
  v_max   int := (v_lim->>'max_failed')::int;
  v_last  timestamptz;
  v_count int;
begin
  -- الحساب الحالي
  select count(*), max(created_at) into v_count, v_last
    from redeem_attempts
   where not success and created_at > now() - v_win
     and (user_id = v_user
          or (p_fingerprint is not null and fingerprint = p_fingerprint));

  if v_count >= v_max then
    return greatest(1, ceil(extract(epoch from (v_last + v_win - now())))::int);
  end if;
  return 0;
end $$;

-- ---------------------------------------------------------------------
-- التنفيذ، مع تسجيل كل محاولة
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
      'uses', code_uses(v_code.id), 'max_uses', v_code.max_uses);
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
    'uses', v_used + 1, 'max_uses', v_code.max_uses);
end $$;

-- ---------------------------------------------------------------------
-- تنظيف: المحاولات أقدم من يوم ما إلها لزوم
-- بتنندعى من admin_overview تا تصير بلا وظيفة مجدولة
-- ---------------------------------------------------------------------
create or replace function redeem_attempts_prune()
returns int
language plpgsql security definer set search_path = public as $$
declare n int;
begin
  delete from redeem_attempts where created_at < now() - interval '1 day';
  get diagnostics n = row_count;
  return n;
end $$;

-- ---------------------------------------------------------------------
-- للوحة: محاولات فاشلة أخيرة — علامة على حدا عم يجرّب
-- ---------------------------------------------------------------------
create or replace function admin_redeem_activity()
returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  perform admin_guard();
  perform redeem_attempts_prune();
  select jsonb_build_object(
    'failed_1h',  (select count(*) from redeem_attempts
                    where not success and created_at > now() - interval '1 hour'),
    'failed_24h', (select count(*) from redeem_attempts
                    where not success and created_at > now() - interval '24 hours'),
    'ok_24h',     (select count(*) from redeem_attempts
                    where success and created_at > now() - interval '24 hours'),
    'blocked',    (select count(distinct coalesce(fingerprint, user_id::text))
                     from redeem_attempts a
                    where not success
                      and created_at > now() - make_interval(
                            mins => (redeem_limits()->>'window_minutes')::int)
                    group by coalesce(fingerprint, user_id::text)
                   having count(*) >= (redeem_limits()->>'max_failed')::int
                    limit 1),
    'limits',     redeem_limits()
  ) into r;
  return r;
end $$;

revoke all on function redeem_blocked_for(text)   from public;
revoke all on function redeem_attempts_prune()    from public, authenticated;
revoke all on function admin_redeem_activity()    from public;
grant execute on function redeem_blocked_for(text) to authenticated;
grant execute on function admin_redeem_activity()  to authenticated;
