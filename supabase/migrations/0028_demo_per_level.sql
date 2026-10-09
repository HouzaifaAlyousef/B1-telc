-- =====================================================================
-- 0028_demo_per_level — تجريبي لكل مستوى، مو تجريبي واحد للأبد
--
-- كان: telegram_users.code_id عمود واحد، فحساب واحد = كود واحد للأبد.
-- يعني مين جرّب B1 وبعدين بدّه يجرّب B2 بياخد «أخدت نسختك من قبل»
-- ومعه كود B1 — وهو ما شاف B2 بحياته. هاد بيقفل باب مبيعات مفتوح.
--
-- صار: جدول (telegram_id, level_id) — تجريبي واحد **لكل مستوى**.
--
-- ★ شو تغيّر بحدود الأمان؟ مين بدّه يجمّع أكواد كان بياخد واحد، صار
--   بياخد بعدد المستويات المنشورة. وكل واحد فيهن لسا: ٢٤ ساعة،
--   امتحان واحد، تفعيل واحد، مستوى مختلف. يعني ما ربح ولا امتحان
--   زيادة عن يلي بدّه يجرّبه فعلاً.
--
-- ★ والرجعة لنفس المستوى لسا بتعطي **نفس** الكود مو كود جديد.
-- =====================================================================

create table if not exists telegram_demos (
  telegram_id bigint not null
              references telegram_users(telegram_id) on delete cascade,
  level_id    text   not null references levels(id) on delete cascade,
  code_id     uuid   references access_codes(id) on delete set null,
  created_at  timestamptz not null default now(),
  primary key (telegram_id, level_id)
);
alter table telegram_demos enable row level security;   -- service_role بس

-- يلي أخدوا تجريبي قبل هالترحيل: كودهم بينتقل لمستواه
insert into telegram_demos (telegram_id, level_id, code_id)
select telegram_id, level_id, code_id
  from telegram_users
 where code_id is not null and level_id is not null
on conflict (telegram_id, level_id) do nothing;

create or replace function bot_demo_code(
  p_telegram_id bigint,
  p_chat_id     bigint,
  p_username    text,
  p_lang        text,
  p_level_id    text
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_d    telegram_demos%rowtype;
  v_code access_codes%rowtype;
  v_slug text;
  v_test text;
  v_lvl  levels%rowtype;
  v_new  text;
begin
  if p_telegram_id is null or p_chat_id is null then
    raise exception 'telegram_id_required';
  end if;

  select * into v_lvl from levels where id = p_level_id and published;
  if not found then raise exception 'level_not_found'; end if;

  -- هوّيته بتنحدّث دايماً: آخر لغة وآخر مستوى اختارهن
  insert into telegram_users (telegram_id, chat_id, username, lang, level_id)
  values (p_telegram_id, p_chat_id, left(p_username, 64), left(p_lang, 8), v_lvl.id)
  on conflict (telegram_id) do update
    set chat_id = excluded.chat_id, username = excluded.username,
        lang = excluded.lang, level_id = excluded.level_id;

  -- ★ رجع لنفس المستوى: نفس الكود، مو كود جديد
  select * into v_d from telegram_demos
   where telegram_id = p_telegram_id and level_id = v_lvl.id;
  if found and v_d.code_id is not null then
    select * into v_code from access_codes where id = v_d.code_id;
    if found then
      select t.title into v_test from tests t
       where t.level_id = v_code.levels[1] and t.slug = v_code.test_slugs[1];
      return jsonb_build_object(
        'ok', true, 'again', true, 'code', v_code.code,
        'level_id', v_lvl.id, 'provider', v_lvl.provider, 'stufe', v_lvl.stufe,
        'test', v_test, 'hours', v_code.duration_hours,
        'used', code_uses(v_code.id), 'max_uses', v_code.max_uses);
    end if;
  end if;

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

  insert into telegram_demos (telegram_id, level_id, code_id)
  values (p_telegram_id, v_lvl.id, v_code.id)
  on conflict (telegram_id, level_id) do update set code_id = excluded.code_id;

  -- العمود القديم بيضل يحمل الأخير: bot_request_access بتاخد منه
  -- المستوى يلي الطالب عم يطلب وصول كامل إله
  update telegram_users set code_id = v_code.id where telegram_id = p_telegram_id;

  return jsonb_build_object(
    'ok', true, 'again', false, 'code', v_new,
    'level_id', v_lvl.id, 'provider', v_lvl.provider, 'stufe', v_lvl.stufe,
    'test', v_test, 'hours', 24, 'used', 0, 'max_uses', 1);
end $$;
revoke all on function bot_demo_code(bigint,bigint,text,text,text)
  from public, anon, authenticated;

create or replace function schema_version()
returns int language sql immutable as $$ select 28 $$;
grant execute on function schema_version() to authenticated, anon;
