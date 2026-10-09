-- =====================================================================
-- 0021_code_format — كود أسهل بالكتابة: حرفين ثم عشرة أرقام
--
-- القديم: B1-7K2M-9XQP — أبجدية بـ٣١ حرف مع شرطات. آمن، بس الطالب لازم
-- يبدّل لوحة المفاتيح، ويميّز حروف متشابهة، ويكتب الشرطات بمكانها. وأكتر
-- ناسنا بيستلموا الكود عبر واتساب وبيكتبوه على الموبايل.
--
-- الجديد: B1 4827 5193 66 — الحرفان درجة الامتحان، والباقي أرقام.
-- بينحفظ بلا فواصل (B14827519366)، وبينقبل بأي شكل: مسافات، شرطات،
-- حروف صغيرة.
--
-- ★ ليش عشرة أرقام مو ستة أو تمانية:
--     ٦ أرقام   → مليون احتمال    → مهاجم بيلاقي كود بساعتين
--     ٨ أرقام   → ١٠⁸            → بأسبوع
--     ١٠ أرقام  → ١٠¹⁰           → بسنتين ونص
--   (الحساب: ٥٠٠ كود ساري، ألف محاولة بالساعة من مهاجم بيدوّر هويته.)
--   حدّ المحاولات بـ0011 بيبطّئ الدق، بس ما بيوقف مهاجم موزّع — الطول هو
--   يلي بيوقفه. والطول نفسه ما زاد: ١٢ خانة متل القديم، بس أرقام.
--
-- وخلل انصلح معه: البادئة كانت `upper(p_levels[1])`، وهاد معرّف المستوى
-- — يلي صار `goethe-b1` بعد ترحيل المؤسسات. يعني كود Goethe كان بيطلع
-- «GOETHE-B1-7K2M-9XQP». صارت البادئة الدرجة (B1) من صف المستوى.
-- =====================================================================

-- ---------------------------------------------------------------------
-- التطبيع: الشكل يلي بينقارن فيه. الشرطات والمسافات والحالة ما بتفرق.
-- بيخلّي أكواد الصيغة القديمة تشتغل متل ما هي.
-- ---------------------------------------------------------------------
create or replace function code_norm(p text)
returns text language sql immutable as $$
  select regexp_replace(upper(coalesce(p, '')), '[^A-Z0-9]', '', 'g');
$$;
grant execute on function code_norm(text) to authenticated, anon;

-- الفهرس على الشكل المطبّع: البحث صار عليه، مو على العمود الخام
create index if not exists access_codes_norm_idx on access_codes (code_norm(code));

-- ---------------------------------------------------------------------
-- التوليد
-- ---------------------------------------------------------------------
create or replace function admin_create_codes(
  p_count       int,
  p_levels      text[],
  p_days        int,
  p_max_devices int  default 2,      -- محفوظ للتوافق؛ صار max_uses هو الحاكم
  p_note        text default null,
  p_max_uses    int  default 2,
  p_hours       int  default 0,
  p_tests       text[] default null
) returns setof text
language plpgsql security definer set search_path = public as $$
declare
  prefix text;
  v_code text;
  i      int;
  j      int;
begin
  perform admin_guard();
  if p_count < 1 or p_count > 200 then raise exception 'count_out_of_range'; end if;
  if p_days < 0 or p_hours < 0 or (p_days = 0 and p_hours = 0) then
    raise exception 'duration_out_of_range';
  end if;
  if p_tests is not null and array_length(p_tests, 1) is null then
    raise exception 'tests_empty';
  end if;
  if p_max_uses < 1 or p_max_uses > 10 then raise exception 'uses_out_of_range'; end if;
  if array_length(p_levels, 1) is distinct from 1 then
    raise exception 'exactly_one_level';        -- كود واحد = مستوى واحد
  end if;

  -- الحرفان = درجة الامتحان (B1). الاحتياط للمستويات القديمة يلي لسا
  -- بلا stufe: أول حرفين أبجديين من المعرّف.
  select upper(coalesce(nullif(regexp_replace(l.stufe, '[^A-Za-z0-9]', '', 'g'), ''),
                        substr(regexp_replace(l.id, '[^A-Za-z0-9]', '', 'g'), 1, 2),
                        'XX'))
    into prefix
    from levels l where l.id = p_levels[1];
  prefix := substr(coalesce(prefix, 'XX') || 'XX', 1, 2);

  for i in 1..p_count loop
    loop
      v_code := prefix;
      for j in 1..10 loop
        v_code := v_code || floor(random() * 10)::int::text;
      end loop;
      exit when not exists (select 1 from access_codes a
                             where code_norm(a.code) = v_code);
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

revoke all on function admin_create_codes(int,text[],int,int,text,int,int,text[]) from public;
grant execute on function admin_create_codes(int,text[],int,int,text,int,int,text[])
  to authenticated;

-- ---------------------------------------------------------------------
-- التفعيل: البحث صار بالشكل المطبّع على الطرفين
--
-- بلاها، أي كود جديد ينكتب «B1 4827 5193 66» بمسافات بيرجع invalid_code،
-- وأي كود قديم ينكتب بلا شرطات كمان. الجسم منقول متل ما هو من 0014،
-- ما تغيّر غير سطر البحث.
--
-- ما في خطر التباس: الأكواد القديمة بتطلع ١٠ خانات بعد التطبيع والجديدة
-- ١٢، والمولّد بيفحص التصادم على الشكل المطبّع.
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
-- بحث المستخدمين: نفس القصة — الأدمن بينسخ الكود من الجدول مجموعات،
-- وبيلصقه بالبحث. بلا تطبيع ما بيلاقي حدا. الجسم منقول من 0012،
-- ما تغيّر غير شرط البحث على الكود.
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
      'devices',  (select count(*) from devices  d where d.user_id = p.id),
      'attempts', (select count(*) from attempts a where a.user_id = p.id),
      'best_pct', (select max(pct)  from attempts a where a.user_id = p.id),
      'mistakes', (select count(*) from mistakes m where m.user_id = p.id),

      -- كل الاشتراكات، الأطول أولاً. كل واحد إله id لحاله تا تقدري
      -- تمدّديه أو توقفيه من اللوحة بلا ما تأثري على التاني.
      'subs', (select coalesce(jsonb_agg(jsonb_build_object(
                 'id', s.id, 'levels', s.levels, 'status', s.status,
                 'current_period_end', s.current_period_end,
                 'days_left', greatest(0, ceil(extract(epoch from
                               (s.current_period_end - now())) / 86400))::int,
                 'source', s.source,
                 'code', (select ac.code from access_codes ac
                           where ac.id = s.access_code_id))
                 order by s.current_period_end desc), '[]')
               from subscriptions s where s.user_id = p.id),

      -- ★ كل كود فعّله هالحساب — من سجلّ التفعيلات
      'codes', (select coalesce(jsonb_agg(jsonb_build_object(
                  'code', ac.code, 'levels', ac.levels, 'at', cr.created_at)
                  order by cr.created_at desc), '[]')
                from code_redemptions cr
                join access_codes ac on ac.id = cr.code_id
                where cr.user_id = p.id)
    ) as x
    from profiles p
    where not p.is_admin
      and (p_search is null or p_search = ''
           or p.display_name ilike '%' || p_search || '%'
           or p.note ilike '%' || p_search || '%'
           -- البحث كمان لازم يمرق على السجلّ، مو على أول مفعّل
           or exists (select 1 from code_redemptions cr
                        join access_codes ac on ac.id = cr.code_id
                       where cr.user_id = p.id
                         and (ac.code ilike '%' || p_search || '%'
                              -- ★ الكود بينلصق مجموعات: «B1 4827 5193 66»
                              or (code_norm(p_search) <> ''
                                  and code_norm(ac.code)
                                      like '%' || code_norm(p_search) || '%'))))
  ) t;
  return r;
end $$;
