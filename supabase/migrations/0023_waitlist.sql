-- =====================================================================
-- 0023_waitlist — قائمة انتظار بحدّ من اللوحة
--
-- سببين:
--
-- ١. الحمل. كل شي عنّا على الخطط المجانية، وأول ما يوصل الصوت رح
--    يصير خروج البيانات هو السقف الحقيقي (وقت استماع طويل × كل طالب).
--    والأغلى منه هو تصحيح الكتابة: كل تصحيح بيكلّف مصاري فعلية، وكل
--    مشترك إله حصّة عشرين تصحيح. بلا سقف، فاتورة الشهر مفتوحة.
--
-- ٢. الطلب المرئي. الطالب يلي بيشوف «إنت رقم ٤٧» بيفهم إنّ في ناس
--    غيره — وهاد بيشتغل لصالحنا أكتر من أي إعلان.
--
-- الحدّ رقمين، والاتنين بينتحكم فيهن من اللوحة، وصفر = بلا حدّ:
--   max_active       أقصى عدد مشتركين فعّالين بنفس الوقت
--   max_new_per_day  أقصى عدد مستخدمين جداد باليوم
--
-- ★ الكود ما بينستهلك لما الطالب ينحطّ بالانتظار.
--   لو استهلكناه، يلي دفع بيخسر كوده لأنه إجا بوقت زحمة. بيضل ساري،
--   ولما يجي دوره بينفّذ عادي.
-- =====================================================================

-- صفّ واحد بس: الحدود. المفتاح المنطقي بيمنع صفّ تاني.
create table if not exists app_limits (
  only_row        boolean primary key default true check (only_row),
  max_active      int not null default 0 check (max_active >= 0),
  max_new_per_day int not null default 0 check (max_new_per_day >= 0),
  updated_at      timestamptz not null default now(),
  updated_by      uuid references profiles(id) on delete set null
);
insert into app_limits (only_row) values (true) on conflict do nothing;
alter table app_limits enable row level security;   -- الوصول عبر الدوال بس

-- ★ الترتيب بـseq مو بـcreated_at.
-- now() هو وقت **بداية المعاملة**، فتنتين بنفس المعاملة بياخدوا نفس
-- الطابع بالضبط — والاتنين بيطلعوا «رقم ١». وحتى بمعاملتين، تصادم
-- بنفس الميلي ثانية بيعطي نفس النتيجة. المتسلسلة ما بتتصادم.
create table if not exists waitlist (
  user_id    uuid primary key references profiles(id) on delete cascade,
  seq        bigserial not null unique,
  code_id    uuid references access_codes(id) on delete set null,
  created_at timestamptz not null default now(),
  invited_at timestamptz
);
create index if not exists waitlist_order_idx on waitlist (seq);
alter table waitlist enable row level security;

-- ---------------------------------------------------------------------
-- الطاقة الحالية
-- ---------------------------------------------------------------------
create or replace function capacity()
returns jsonb
language sql security definer set search_path = public stable as $$
  select jsonb_build_object(
    'max_active',      l.max_active,
    'max_new_per_day', l.max_new_per_day,
    'active', (select count(distinct s.user_id) from subscriptions s
                where s.status = 'active' and s.current_period_end > now()),
    -- «جديد اليوم» = حساب أول تفعيل إله صار اليوم، مو كل تفعيل:
    -- مشترك بيضيف مستوى تاني مو مستخدم جديد
    'today',  (select count(*) from (
                 select cr.user_id from code_redemptions cr
                  group by cr.user_id
                 having min(cr.created_at) >= date_trunc('day', now())) q),
    'waiting', (select count(*) from waitlist)
  ) from app_limits l;
$$;
grant execute on function capacity() to authenticated, anon;

-- هل في مطرح لمستخدم جديد؟ (الموجود عنده اشتراك فعّال ما بياخد مطرح جديد)
create or replace function capacity_full(p_user uuid)
returns boolean
language plpgsql security definer set search_path = public stable as $$
declare c jsonb; begin
  -- مين عنده اشتراك فعّال هو أصلاً جوّا: تمديد أو مستوى تاني ما بينتظر
  if exists (select 1 from subscriptions s
              where s.user_id = p_user and s.status = 'active'
                and s.current_period_end > now()) then
    return false;
  end if;
  c := capacity();
  if (c->>'max_active')::int > 0
     and (c->>'active')::int >= (c->>'max_active')::int then return true; end if;
  if (c->>'max_new_per_day')::int > 0
     and (c->>'today')::int >= (c->>'max_new_per_day')::int then return true; end if;
  return false;
end $$;

-- الترتيب بالطابور: ١ = التالي
create or replace function waitlist_position(p_user uuid)
returns int
language sql security definer set search_path = public stable as $$
  select count(*)::int + 1 from waitlist w
   where w.seq < (select seq from waitlist where user_id = p_user);
$$;

-- حالة الطالب — التطبيق بينده عليها ليعرف إذا إجا دوره
create or replace function waitlist_status()
returns jsonb
language plpgsql security definer set search_path = public stable as $$
declare v_user uuid := auth.uid(); begin
  if v_user is null then return jsonb_build_object('waiting', false); end if;
  if not exists (select 1 from waitlist where user_id = v_user) then
    return jsonb_build_object('waiting', false);
  end if;
  return jsonb_build_object(
    'waiting', true,
    'position', waitlist_position(v_user),
    'total',    (select count(*) from waitlist),
    'open',     not capacity_full(v_user));
end $$;
grant execute on function waitlist_status() to authenticated;

-- ---------------------------------------------------------------------
-- التفعيل: بيمرق على الطاقة قبل ما يفتح اشتراك
-- الجسم منقول من 0021، ما تغيّر غير فحص الطاقة ومسح الطابور بالنجاح.
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
   where code_norm(code) = code_norm(p_code)
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

  -- ★ الطاقة: هون بالضبط، بعد ما نتأكد إن الكود صالح وقبل ما نستهلكه.
  -- الكود بيضل ساري — يلي دفع ما بيخسره لأنه إجا بوقت زحمة.
  if capacity_full(v_user) then
    insert into waitlist (user_id, code_id) values (v_user, v_code.id)
      on conflict (user_id) do update set code_id = excluded.code_id;
    -- كود صحيح، فمو محاولة فاشلة: تسجيلها فشل بيقفل عليه الإدخال
    insert into redeem_attempts (user_id, fingerprint, success)
    values (v_user, p_fingerprint, true);
    return jsonb_build_object('ok', false, 'error', 'waitlist',
      'position', waitlist_position(v_user),
      'total',    (select count(*) from waitlist));
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

  delete from waitlist where user_id = v_user;   -- إجا دوره وفات

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
-- اللوحة
-- ---------------------------------------------------------------------
create or replace function admin_limits(
  p_max_active      int default null,
  p_max_new_per_day int default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  if p_max_active is not null or p_max_new_per_day is not null then
    if coalesce(p_max_active, 0) < 0 or coalesce(p_max_new_per_day, 0) < 0 then
      raise exception 'limit_negative';
    end if;
    update app_limits
       set max_active      = coalesce(p_max_active, max_active),
           max_new_per_day = coalesce(p_max_new_per_day, max_new_per_day),
           updated_at = now(), updated_by = auth.uid();
    perform admin_log('limits.set', 'app_limits', 'limits',
      jsonb_build_object('max_active', p_max_active,
                         'max_new_per_day', p_max_new_per_day));
  end if;
  return capacity();
end $$;
revoke all on function admin_limits(int,int) from public, anon;
grant execute on function admin_limits(int,int) to authenticated;

-- الطابور بالترتيب، مع اسم الشخص وكوده
create or replace function admin_waitlist()
returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb; begin
  perform admin_guard();
  select coalesce(jsonb_agg(x order by x->>'created_at'), '[]') into r from (
    select jsonb_build_object(
      'user_id', w.user_id,
      'name',    p.display_name,
      'code',    ac.code,
      'levels',  ac.levels,
      'created_at', w.created_at,
      'invited_at', w.invited_at,
      'position', waitlist_position(w.user_id)) as x
    from waitlist w
    left join profiles p     on p.id = w.user_id
    left join access_codes ac on ac.id = w.code_id
  ) q;
  return r;
end $$;
revoke all on function admin_waitlist() from public, anon;
grant execute on function admin_waitlist() to authenticated;

-- ★ إدخال واحد بالإيد: بيشيله من الطابور بلا ما يفتحله اشتراك.
-- الاشتراك بينفتح لما ينفّذ كوده هو — هيك بيضل التفعيل مرّة وحدة
-- بمكان واحد (redeem_code)، وما منعمل طريق تاني بيتخطّى فحوصه.
create or replace function admin_waitlist_invite(p_user uuid)
returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  update waitlist set invited_at = now() where user_id = p_user;
  if not found then raise exception 'not_waiting'; end if;
  delete from waitlist where user_id = p_user;
  perform admin_log('waitlist.invite', 'profile', p_user::text, '{}'::jsonb);
  return jsonb_build_object('ok', true);
end $$;
revoke all on function admin_waitlist_invite(uuid) from public, anon;
grant execute on function admin_waitlist_invite(uuid) to authenticated;
