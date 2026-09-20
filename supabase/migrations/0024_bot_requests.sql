-- =====================================================================
-- 0024_bot_requests — طلب وصول كامل من البوت، بموافقتك
--
-- التجريبي بيوزّع حاله. الوصول الكامل لأ: الطالب بيطلب، وإنت بتوافق أو
-- بترفض من قناة خاصة، وقرارك هو يلي بيعمل الكود.
--
-- ★ الحدّ هون، مو بالبوت.
--   bot_decide_request بترفض أي حدا مو موجود بـbot_admins. حتى لو طالب
--   عرف رقم الطلب وزوّر ضغطة زرّ، القاعدة بترفضه. الزرّ بالبوت راحة،
--   مو حماية.
--
-- ★ طلب معلّق واحد لكل حساب (فهرس فريد جزئي).
--   بلاه، ضغطتين متتاليتين بيعملوا طلبين وبتوصلك نسختين وبتوافق
--   مرّتين — وبيطلع كودين.
-- =====================================================================

-- ---------------------------------------------------------------------
-- مولّد الأكواد — مصدر واحد
--
-- كان مكرّر بمطرحين (admin_create_codes وbot_demo_code) بنفس الحلقة
-- بالضبط. نسختين معناها إنّ تغيير الشكل بينطبّق على وحدة وبتنسى
-- التانية، وبتطلع أكواد بشكلين. هون وحدة وبس.
-- ---------------------------------------------------------------------
create or replace function new_access_code(p_level_id text)
returns text
language plpgsql security definer set search_path = public as $$
declare prefix text; v_code text; j int;
begin
  -- الحرفان = درجة الامتحان (B1). الاحتياط للمستويات القديمة يلي لسا
  -- بلا stufe: أول حرفين أبجديين من المعرّف.
  select upper(coalesce(nullif(regexp_replace(l.stufe, '[^A-Za-z0-9]', '', 'g'), ''),
                        substr(regexp_replace(l.id, '[^A-Za-z0-9]', '', 'g'), 1, 2),
                        'XX'))
    into prefix from levels l where l.id = p_level_id;
  prefix := substr(coalesce(prefix, 'XX') || 'XX', 1, 2);

  loop
    v_code := prefix;
    for j in 1..10 loop v_code := v_code || floor(random() * 10)::int::text; end loop;
    exit when not exists (select 1 from access_codes a where code_norm(a.code) = v_code);
  end loop;
  return v_code;
end $$;
revoke all on function new_access_code(text) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- مين بيقدر يوافق
-- ---------------------------------------------------------------------
create table if not exists bot_admins (
  telegram_id bigint primary key,
  label       text,
  added_at    timestamptz not null default now()
);
-- ما في سياسة: الجدول للـservice_role بس. بلا هالسطر بيضل مفتوح لأي
-- حدا معه مفتاح anon — وهاد جدول بيقرّر مين بيوافق على الوصول الكامل.
alter table bot_admins enable row level security;

create or replace function bot_is_admin(p_telegram_id bigint)
returns boolean
language sql security definer set search_path = public stable as $$
  select exists (select 1 from bot_admins where telegram_id = p_telegram_id);
$$;
revoke all on function bot_is_admin(bigint) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- الطلبات
-- ---------------------------------------------------------------------
create table if not exists access_requests (
  id          uuid primary key default gen_random_uuid(),
  telegram_id bigint not null references telegram_users(telegram_id) on delete cascade,
  level_id    text references levels(id) on delete set null,
  months      int not null check (months >= 1 and months <= 12),
  status      text not null default 'pending'
              check (status in ('pending', 'approved', 'rejected')),
  code_id     uuid references access_codes(id) on delete set null,
  reason      text,
  created_at  timestamptz not null default now(),
  decided_at  timestamptz,
  decided_by  bigint
);
create unique index if not exists access_requests_one_pending
  on access_requests (telegram_id) where status = 'pending';
create index if not exists access_requests_pending_idx
  on access_requests (created_at) where status = 'pending';
alter table access_requests enable row level security;

-- ---------------------------------------------------------------------
-- الطالب بيطلب
-- ---------------------------------------------------------------------
create or replace function bot_request_access(
  p_telegram_id bigint,
  p_months      int
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_u telegram_users%rowtype; v_r access_requests%rowtype; v_lvl levels%rowtype;
begin
  if p_months is null or p_months < 1 or p_months > 12 then
    raise exception 'months_out_of_range';
  end if;

  -- لازم يكون أخد تجريبي: هيك منعرف مستواه ولغته وشات آي دي تبعه
  select * into v_u from telegram_users where telegram_id = p_telegram_id;
  if not found then raise exception 'no_demo_yet'; end if;

  -- طلب معلّق موجود: منرجّعه متل ما هو بدل ما نعمل تاني
  select * into v_r from access_requests
   where telegram_id = p_telegram_id and status = 'pending';
  if found then
    select * into v_lvl from levels where id = v_r.level_id;
    return jsonb_build_object('ok', true, 'again', true, 'request_id', v_r.id,
      'months', v_r.months, 'username', v_u.username, 'lang', v_u.lang,
      'level_id', v_r.level_id, 'stufe', v_lvl.stufe, 'provider', v_lvl.provider);
  end if;

  insert into access_requests (telegram_id, level_id, months)
  values (p_telegram_id, v_u.level_id, p_months)
  returning * into v_r;

  select * into v_lvl from levels where id = v_r.level_id;
  return jsonb_build_object('ok', true, 'again', false, 'request_id', v_r.id,
    'months', v_r.months, 'username', v_u.username, 'lang', v_u.lang,
    'level_id', v_r.level_id, 'stufe', v_lvl.stufe, 'provider', v_lvl.provider);
end $$;
revoke all on function bot_request_access(bigint, int)
  from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- إنت بتقرّر
-- ---------------------------------------------------------------------
create or replace function bot_decide_request(
  p_admin_telegram_id bigint,
  p_request_id        uuid,
  p_approve           boolean,
  p_reason            text default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_r access_requests%rowtype; v_u telegram_users%rowtype;
        v_code text; v_id uuid;
begin
  -- ★ هون الحدّ. زرّ بتلغرام أي حدا بيقدر يزوّره؛ هالسطر يلي بيمنع.
  if not bot_is_admin(p_admin_telegram_id) then
    raise exception 'not_bot_admin';
  end if;

  -- قفل الصفّ: ضغطتين بنفس اللحظة من أدمنين ما بيعملوا كودين
  select * into v_r from access_requests where id = p_request_id for update;
  if not found then raise exception 'request_not_found'; end if;
  if v_r.status <> 'pending' then
    return jsonb_build_object('ok', false, 'already', v_r.status);
  end if;

  select * into v_u from telegram_users where telegram_id = v_r.telegram_id;

  if p_approve then
    if v_r.level_id is null then raise exception 'level_gone'; end if;
    v_code := new_access_code(v_r.level_id);
    -- test_slugs = null معناها كل امتحانات المستوى، مو امتحان واحد
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

  return jsonb_build_object('ok', true,
    'status',  case when p_approve then 'approved' else 'rejected' end,
    'code',    v_code,
    'months',  v_r.months,
    'reason',  left(p_reason, 64),
    'chat_id', v_u.chat_id,
    'lang',    v_u.lang,
    'username', v_u.username);
end $$;
revoke all on function bot_decide_request(bigint, uuid, boolean, text)
  from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- والقديمين كمان بيستعملوا نفس المولّد
-- ---------------------------------------------------------------------
create or replace function admin_create_codes(
  p_count       int,
  p_levels      text[],
  p_days        int,
  p_max_devices int  default 2,
  p_note        text default null,
  p_max_uses    int  default 2,
  p_hours       int  default 0,
  p_tests       text[] default null
) returns setof text
language plpgsql security definer set search_path = public as $$
declare v_code text; i int;
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
    raise exception 'exactly_one_level';
  end if;

  for i in 1..p_count loop
    v_code := new_access_code(p_levels[1]);
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

create or replace function bot_demo_code(
  p_telegram_id bigint,
  p_chat_id     bigint,
  p_username    text,
  p_lang        text,
  p_level_id    text
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_row  telegram_users%rowtype;
  v_code access_codes%rowtype;
  v_slug text;
  v_test text;
  v_lvl  levels%rowtype;
  v_new  text;
begin
  if p_telegram_id is null or p_chat_id is null then
    raise exception 'telegram_id_required';
  end if;

  -- ★ رجع مرة تانية: نفس الكود، مو كود جديد
  select * into v_row from telegram_users where telegram_id = p_telegram_id;
  if found and v_row.code_id is not null then
    select * into v_code from access_codes where id = v_row.code_id;
    if found then
      select t.title into v_test from tests t
       where t.level_id = v_code.levels[1] and t.slug = v_code.test_slugs[1];
      select * into v_lvl from levels where id = v_code.levels[1];
      return jsonb_build_object(
        'ok', true, 'again', true, 'code', v_code.code,
        'level_id', v_lvl.id, 'provider', v_lvl.provider, 'stufe', v_lvl.stufe,
        'test', v_test, 'hours', v_code.duration_hours,
        'used', code_uses(v_code.id), 'max_uses', v_code.max_uses);
    end if;
  end if;

  select * into v_lvl from levels where id = p_level_id and published;
  if not found then raise exception 'level_not_found'; end if;

  -- أول امتحان منشور بالمستوى — هو يلي بينفتح بالتجريبي
  select t.slug, t.title into v_slug, v_test
    from tests t where t.level_id = v_lvl.id and t.published
   order by t.sort, t.slug limit 1;
  if v_slug is null then raise exception 'no_published_test'; end if;

  v_new := new_access_code(v_lvl.id);

  -- ★ القيم مثبّتة: تجريبي وبس. ما في معامل بيوصل لهون من برّا.
  insert into access_codes (code, levels, duration_days, duration_hours,
                            test_slugs, max_devices, max_uses, note)
  values (v_new, array[v_lvl.id], 0, 24, array[v_slug], 1, 1,
          'telegram:' || p_telegram_id)
  returning * into v_code;

  insert into telegram_users (telegram_id, chat_id, username, lang, level_id, code_id)
  values (p_telegram_id, p_chat_id, left(p_username, 64), left(p_lang, 8),
          v_lvl.id, v_code.id)
  on conflict (telegram_id) do update
    set chat_id = excluded.chat_id, username = excluded.username,
        lang = excluded.lang, level_id = excluded.level_id,
        code_id = excluded.code_id;

  return jsonb_build_object(
    'ok', true, 'again', false, 'code', v_new,
    'level_id', v_lvl.id, 'provider', v_lvl.provider, 'stufe', v_lvl.stufe,
    'test', v_test, 'hours', 24, 'used', 0, 'max_uses', 1);
end $$;

revoke all on function bot_demo_code(bigint,bigint,text,text,text)
  from public, anon, authenticated;

-- نسخة السكيما: اللوحة بتقارنها وبتحذّر لو القاعدة متأخّرة
create or replace function schema_version()
returns int language sql immutable as $$ select 24 $$;
grant execute on function schema_version() to authenticated, anon;
