-- =====================================================================
-- 0029_bot_status — «كودي»، وتنبيه قبل الانتهاء، و«جرّب مستوى تاني»
--
-- تلات ثغرات بنفس اللحظة: الطالب أخد كوده، وبعدين ضيّع الرسالة، أو
-- خلص وقته وهو ما انتبه، أو خلص الامتحان وما بيعرف إنّ في مستوى تاني
-- بيقدر يجرّبه. كلهن بيوصلوا لنفس المكان: سؤال إلك بالخاص، أو زبون راح.
--
-- ★ التنبيه بينبعت مرّة وحدة لكل كود (warned_at بنفس استعلام الكنس مع
--   skip locked) — نفس مبدأ تنبيه الحجز. نداء زيادة ما بيضرّ.
-- =====================================================================

alter table telegram_demos
  add column if not exists warned_at timestamptz;

-- الكنس بيدوّر على يلي قرب ينتهي ولسا ما انتنبّه
create index if not exists telegram_demos_warn_idx
  on telegram_demos (code_id) where warned_at is null;

-- ---------------------------------------------------------------------
-- «كودي»: كل أكواده، وكم باقي لكل واحد
-- ---------------------------------------------------------------------
create or replace function bot_my_codes(p_telegram_id bigint)
returns jsonb
language sql security definer set search_path = public stable as $$
  select coalesce(jsonb_agg(x order by x.ends nulls last), '[]'::jsonb) from (
    -- التجريبي: من جدول التجريبيات
    select jsonb_build_object(
             'code', c.code, 'kind', 'demo',
             'provider', l.provider, 'stufe', l.stufe, 'level_id', l.id,
             'test', (select t.title from tests t
                       where t.level_id = c.levels[1] and t.slug = c.test_slugs[1]),
             'used', code_uses(c.id), 'max_uses', c.max_uses,
             'ends', s.current_period_end,
             'hours', c.duration_hours) x,
           s.current_period_end ends
      from telegram_demos d
      join access_codes c on c.id = d.code_id
      join levels l on l.id = d.level_id
      left join subscriptions s on s.access_code_id = c.id and s.status = 'active'
     where d.telegram_id = p_telegram_id and c.revoked_at is null
    union all
    -- الوصول الكامل: من الطلبات الموافَق عليها
    select jsonb_build_object(
             'code', c.code, 'kind', 'full',
             'provider', l.provider, 'stufe', l.stufe, 'level_id', l.id,
             'test', null,
             'used', code_uses(c.id), 'max_uses', c.max_uses,
             'ends', s.current_period_end,
             'months', r.months) x,
           s.current_period_end ends
      from access_requests r
      join access_codes c on c.id = r.code_id
      join levels l on l.id = r.level_id
      left join subscriptions s on s.access_code_id = c.id and s.status = 'active'
     where r.telegram_id = p_telegram_id and r.status = 'approved'
       and c.revoked_at is null
  ) x;
$$;
revoke all on function bot_my_codes(bigint) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- مستويات ما جرّبها بعد — «جرّب مستوى تاني»
-- ---------------------------------------------------------------------
create or replace function bot_untried_levels(p_telegram_id bigint)
returns jsonb
language sql security definer set search_path = public stable as $$
  select coalesce(jsonb_agg(jsonb_build_object(
           'id', l.id, 'provider', l.provider, 'stufe', l.stufe, 'title', l.title)
           order by l.provider nulls last, stufe_rank(l.stufe), l.id), '[]')
    from levels l
   where l.published
     and exists (select 1 from tests t where t.level_id = l.id and t.published)
     and not exists (select 1 from telegram_demos d
                      where d.telegram_id = p_telegram_id and d.level_id = l.id);
$$;
revoke all on function bot_untried_levels(bigint) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- الكنس: مين تجريبيّه بيخلص خلال ساعة ولسا ما انتنبّه
--
-- ★ شرط الاشتراك مقصود: الكود يلي ما انفعّل أبداً ما إله وقت ينتهي.
--   تنبيه «باقي ساعة» لواحد ما فتح التطبيق أصلاً بيربكه مو بيساعده.
-- ---------------------------------------------------------------------
create or replace function bot_sweep_expiring(p_within interval default '1 hour')
returns jsonb
language sql security definer set search_path = public as $$
  with due as (
    update telegram_demos d set warned_at = now()
     where d.warned_at is null
       and d.code_id in (
             select d2.code_id from telegram_demos d2
               join subscriptions s on s.access_code_id = d2.code_id
                                   and s.status = 'active'
              where d2.warned_at is null
                and s.current_period_end > now()
                and s.current_period_end <= now() + p_within
              for update of d2 skip locked)
    returning d.telegram_id, d.level_id, d.code_id
  )
  select coalesce(jsonb_agg(jsonb_build_object(
           'telegram_id', due.telegram_id, 'chat_id', u.chat_id, 'lang', u.lang,
           'provider', l.provider, 'stufe', l.stufe,
           'ends', s.current_period_end)), '[]'::jsonb)
    from due
    join telegram_users u on u.telegram_id = due.telegram_id
    join levels l on l.id = due.level_id
    join subscriptions s on s.access_code_id = due.code_id and s.status = 'active';
$$;
revoke all on function bot_sweep_expiring(interval) from public, anon, authenticated;

create or replace function schema_version()
returns int language sql immutable as $$ select 29 $$;
grant execute on function schema_version() to authenticated, anon;
