-- =====================================================================
-- 0010_code_uses — الكود صالح لعدد تفعيلات محدّد
--
-- المشكلة: كل جهاز بياخد حساب مجهول لحاله (ما في إيميل يربطهن). فالكود
-- يلي بينفّذ «مرة وحدة ويرتبط بحساب» كان معناه إن الطالب ما بيقدر
-- يستعمله على جهازه التاني نهائياً — بياخد already_used. وعمود
-- max_devices كان بلا معنى عملياً لأنه بيحدّ أجهزة الحساب الواحد،
-- والحساب أصلاً بيتغيّر مع الجهاز.
--
-- الحل: للكود **عدد تفعيلات** (افتراضي ٢). كل تفعيل على حساب جديد
-- بيستهلك واحد. إعادة الإدخال من نفس الحساب ما بتستهلك — تا يضل
-- النداء آمن للإعادة. لما تخلص التفعيلات، الكود ميّت.
-- =====================================================================

alter table access_codes add column if not exists max_uses int not null default 2;

-- سجلّ التفعيلات: مين فعّل، إمتى، ومن أي جهاز
create table if not exists code_redemptions (
  id          uuid primary key default gen_random_uuid(),
  code_id     uuid not null references access_codes(id) on delete cascade,
  user_id     uuid not null references profiles(id) on delete cascade,
  fingerprint text,
  user_agent  text,
  created_at  timestamptz not null default now(),
  unique (code_id, user_id)
);
create index if not exists code_redemptions_code_idx on code_redemptions (code_id);

alter table code_redemptions enable row level security;
grant select on code_redemptions to authenticated;
-- الأدمن بيقرا كل شي؛ الطالب ما بيشوف ولا صف (ما إله سياسة قراءة خاصة)
drop policy if exists admin_redemptions on code_redemptions;
create policy admin_redemptions on code_redemptions for all to authenticated
  using (is_admin()) with check (is_admin());

-- التفعيلات القديمة (قبل هالترحيل) بتنقل للسجلّ الجديد
insert into code_redemptions (code_id, user_id, created_at)
select id, redeemed_by, redeemed_at from access_codes
 where redeemed_by is not null
on conflict (code_id, user_id) do nothing;

-- كم تفعيل انستهلك
create or replace function code_uses(p_code_id uuid)
returns int language sql stable security definer set search_path = public as $$
  select count(*)::int from code_redemptions where code_id = p_code_id;
$$;

-- ---------------------------------------------------------------------
-- التفعيل
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
  v_used int;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  select * into v_code from access_codes
   where upper(code) = upper(trim(p_code))
   for update;                                   -- يمنع تفعيلين بنفس اللحظة

  if not found then
    return jsonb_build_object('ok', false, 'error', 'invalid_code');
  end if;
  if v_code.revoked_at is not null then
    return jsonb_build_object('ok', false, 'error', 'revoked');
  end if;

  insert into profiles (id) values (v_user) on conflict (id) do nothing;

  -- ★ نفس الحساب أعاد الإدخال: بنرجّع حالته بلا استهلاك تفعيل وبلا تمديد
  if exists (select 1 from code_redemptions
              where code_id = v_code.id and user_id = v_user) then
    select * into v_sub from subscriptions
     where user_id = v_user and access_code_id = v_code.id
     order by current_period_end desc limit 1;
    perform register_device(p_fingerprint, p_user_agent);
    return jsonb_build_object(
      'ok', true, 'already', true,
      'levels', coalesce(v_sub.levels, v_code.levels),
      'expires_at', v_sub.current_period_end,
      'uses', code_uses(v_code.id), 'max_uses', v_code.max_uses);
  end if;

  -- ★ حساب جديد: لازم يكون في تفعيل باقي
  v_used := code_uses(v_code.id);
  if v_used >= v_code.max_uses then
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

  -- أول تفعيل بيعبّي الأعمدة القديمة كمان
  update access_codes
     set redeemed_at = coalesce(redeemed_at, now()),
         redeemed_by = coalesce(redeemed_by, v_user)
   where id = v_code.id;

  perform register_device(p_fingerprint, p_user_agent);

  return jsonb_build_object(
    'ok', true,
    'levels', v_sub.levels,
    'expires_at', v_sub.current_period_end,
    'uses', v_used + 1, 'max_uses', v_code.max_uses);
end $$;

-- ---------------------------------------------------------------------
-- التوليد: عدد التفعيلات صار معامل
-- ---------------------------------------------------------------------
-- النسخة القديمة (٥ معاملات) لازم تنشال: وجودها مع الجديدة بيخلّي أي
-- نداء بـ٥ وسائط ملتبس، لأن السادس عنده قيمة افتراضية.
drop function if exists admin_create_codes(int, text[], int, int, text);

create or replace function admin_create_codes(
  p_count       int,
  p_levels      text[],
  p_days        int,
  p_max_devices int  default 2,      -- محفوظ للتوافق؛ صار max_uses هو الحاكم
  p_note        text default null,
  p_max_uses    int  default 2
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
  if p_days  < 1 then raise exception 'days_out_of_range'; end if;
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

    insert into access_codes (code, levels, duration_days, max_devices, max_uses,
                              note, created_by)
    values (v_code, p_levels, p_days, p_max_devices, p_max_uses, p_note, auth.uid());

    perform admin_log('code.create', 'access_code', v_code,
      jsonb_build_object('levels', p_levels, 'days', p_days,
                         'max_uses', p_max_uses, 'note', p_note));
    return next v_code;
  end loop;
end $$;

-- ---------------------------------------------------------------------
-- قائمة الأكواد للوحة، مع عدّاد التفعيلات
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
      'duration_days', c.duration_days, 'max_uses', c.max_uses,
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

-- إعادة فتح تفعيل: لما الطالب يضيّع جهازه ويحتاج يفعّل من جديد
create or replace function admin_add_code_use(p_code_id uuid, p_extra int default 1)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_new int;
begin
  perform admin_guard();
  if p_extra < 1 or p_extra > 5 then raise exception 'extra_out_of_range'; end if;
  update access_codes set max_uses = least(max_uses + p_extra, 10)
   where id = p_code_id returning max_uses into v_new;
  if v_new is null then raise exception 'code_not_found'; end if;
  perform admin_log('code.add_use', 'access_code', p_code_id::text,
                    jsonb_build_object('extra', p_extra, 'max_uses', v_new));
  return jsonb_build_object('ok', true, 'max_uses', v_new);
end $$;

revoke all on function code_uses(uuid) from public, authenticated;
revoke all on function admin_codes() from public;
revoke all on function admin_add_code_use(uuid,int) from public;
revoke all on function admin_create_codes(int,text[],int,int,text,int) from public;
grant execute on function admin_codes() to authenticated;
grant execute on function admin_add_code_use(uuid,int) to authenticated;
grant execute on function admin_create_codes(int,text[],int,int,text,int) to authenticated;
