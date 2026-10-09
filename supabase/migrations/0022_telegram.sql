-- =====================================================================
-- 0022_telegram — بوت تلغرام بيوزّع أكواد تجريبية لحاله
--
-- المشكلة: كل كود تجريبي لازم الأدمن يفتح اللوحة ويعمله ويبعته بالإيد.
-- وهاد بيوقف عند أول عشر طلبات بالليل.
--
-- الحل: بوت. الطالب بيختار المؤسسة والدرجة، وبياخد كود ورابط فوراً.
--
-- ★ حدّ الصلاحية هون، مو بالبوت.
--   bot_demo_code ما إلها ولا معامل بيغيّر نوع الكود: المدّة ٢٤ ساعة
--   مثبّتة، والتفعيل واحد، والنطاق امتحان واحد — أول امتحان منشور
--   بالمستوى. يعني حتى لو انسرق توكن البوت أو انكسر كوده، أقصى ضرر
--   ممكن هو أكواد تجريبية. ما في طريق يطلع منه وصول كامل.
--
-- ★ حساب تلغرام واحد = تجريبي واحد، للأبد.
--   telegram_id هو المفتاح الأساسي. مين بيرجع بيطلب، بياخد **نفس**
--   كوده مو كود جديد — تا يلي ضيّع الرسالة يلاقيها، وبنفس الوقت ما
--   يقدر يجمّع أكواد. مين بدّه يكرّر بدّه رقم هاتف جديد كل مرة.
-- =====================================================================

create table if not exists telegram_users (
  telegram_id bigint primary key,
  chat_id     bigint not null,
  username    text,
  lang        text,
  level_id    text references levels(id) on delete set null,
  code_id     uuid   references access_codes(id) on delete set null,
  created_at  timestamptz not null default now()
);

-- ما في سياسة قراءة ولا كتابة: الجدول للـservice_role بس (بيتخطّى RLS).
-- بلا هالسطر بيضل مفتوح لأي حدا معه مفتاح anon.
alter table telegram_users enable row level security;

-- ---------------------------------------------------------------------
-- قائمة المستويات للبوت
-- بس يلي منشور وفيه امتحان منشور: عرض مستوى فاضي بيعطي كود ما بيفتح شي
-- ---------------------------------------------------------------------
create or replace function bot_levels()
returns jsonb
language sql security definer set search_path = public stable as $$
  select coalesce(jsonb_agg(jsonb_build_object(
           'id', l.id, 'provider', l.provider, 'stufe', l.stufe, 'title', l.title)
           order by l.provider nulls last, stufe_rank(l.stufe), l.id), '[]')
    from levels l
   where l.published
     and exists (select 1 from tests t where t.level_id = l.id and t.published);
$$;

revoke all on function bot_levels() from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- الكود التجريبي
-- ---------------------------------------------------------------------
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
  j      int;
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

  loop
    v_new := coalesce(nullif(regexp_replace(upper(v_lvl.stufe), '[^A-Z0-9]', '', 'g'), ''), 'XX');
    v_new := substr(v_new || 'XX', 1, 2);
    for j in 1..10 loop v_new := v_new || floor(random() * 10)::int::text; end loop;
    exit when not exists (select 1 from access_codes a where code_norm(a.code) = v_new);
  end loop;

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
