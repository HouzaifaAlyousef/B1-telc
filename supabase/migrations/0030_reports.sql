-- =====================================================================
-- 0030_reports — «بلّغ عن مشكلة» من جوّا الامتحان
--
-- الطالب هو الوحيد يلي بيشوف الغلط: جواب مفتاحه خطأ، صورة ناقصة، سؤال
-- مكرّر. قبل هلق ما كان إله ولا طريق يوصّلنا الخبر — لا إيميل ولا نموذج،
-- وكل واحد لاقى غلط سكت عنه وضل الغلط.
--
-- التبليغ بينكتب من جوّا الامتحان، فبيجي معه سياقه: أي امتحان، أي
-- مستوى، أي مؤسسة، ومين كتبه. بلا هالسياق التبليغ بلا فايدة — «في سؤال
-- غلط» ما بتنحلّ.
--
-- ★ الأمان: النص نص، مو كود.
--   · الإدخال بيمرق من دالة واحدة بوسيط — ما في تركيب SQL بالنص أبداً،
--     فما في حقن مهما كتب.
--   · الجدول مقفول بـRLS بلا ولا سياسة: الطالب ما بيقدر يقرا تبليغاته
--     ولا تبليغات غيره، ولا يعدّل ولا يمسح. الكتابة بالدالة، والقراءة
--     بدالة الأدمن.
--   · طول النص محدود، وحروف التحكّم بتنشال عند الإدخال — تبليغ فيه
--     ٥٠٠ سطر فاضي أو بايت صفري بيخرّب الجدول وبيتعب العين.
--   · العرض بالواجهة بيهرب دايماً (esc) — والاختبار بيحقن حمولة حقيقية
--     وبيتأكّد إنها ما اشتغلت.
--   · حدّ معدّل: التبليغ مجهول ومجاني، يعني سلاح إغراق جاهز لو تركناه.
-- =====================================================================

create table if not exists reports (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references profiles(id) on delete cascade,
  test_id    uuid references tests(id)  on delete set null,
  level_id   text references levels(id) on delete set null,
  -- ★ نسخة نصّية من الاسم وقت التبليغ.
  -- الامتحان ممكن ينمسح أو ينعاد استيراده بـuuid جديد، والتبليغ وقتها
  -- بيصير «مشكلة بامتحان — مجهول». الاسم المحفوظ بيضل يقول عن شو الحكي.
  test_label text,
  body       text not null,
  lang       text,
  status     text not null default 'new' check (status in ('new', 'done')),
  created_at timestamptz not null default now(),
  handled_at timestamptz,
  handled_by uuid references profiles(id) on delete set null
);
create index if not exists reports_new_idx  on reports (created_at desc) where status = 'new';
create index if not exists reports_user_idx on reports (user_id, created_at desc);

alter table reports enable row level security;

-- ★ طبقتين، وكل وحدة بتوقف شي تانية ما بتوقفه — متل redeem_attempts:
--   · GRANT: قراءة بس. ما في insert ولا update ولا delete لحدا من برّا،
--     فما حدا بيقدر يكتب تبليغ باسم غيره ولا يتخطّى الطول وحدّ المعدّل.
--     الكتابة بتصير جوّا report_problem لا غير.
--   · RLS: الأدمن بيشوف، والطالب ما إله سياسة — يعني صفر صفوف، حتى
--     تبليغاته هو. ما في سبب يقراهن، وفي سبب ما يقراهن: نصوص ناس تانيين.
grant select on reports to authenticated;
drop policy if exists admin_reports on reports;
create policy admin_reports on reports for all to authenticated
  using (is_admin()) with check (is_admin());

-- ---------------------------------------------------------------------
-- الحدود بمكان واحد
-- ---------------------------------------------------------------------
create or replace function report_limits()
returns jsonb language sql immutable as $$
  select jsonb_build_object(
    'min_chars',      10,
    'max_chars',      2000,
    'window_minutes', 60,
    'max_per_window', 5);
$$;
grant execute on function report_limits() to authenticated, anon;

-- ---------------------------------------------------------------------
-- التبليغ
--
-- بيرجّع {ok:true} أو {ok:false, error:…} — ما بيرمي استثناء إلا لمين
-- مو مسجّل دخول. الواجهة بتترجم الخطأ، فالنص هون رمز مو جملة.
-- ---------------------------------------------------------------------
create or replace function report_problem(
  p_test_id uuid,
  p_text    text,
  p_lang    text default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user  uuid := auth.uid();
  v_lim   jsonb := report_limits();
  v_body  text;
  v_lang  text;
  v_level text;
  v_label text;
  v_n     int;
begin
  if v_user is null then
    raise exception 'not_signed_in' using errcode = 'insufficient_privilege';
  end if;

  -- ★ التنظيف قبل أي شي تاني.
  -- حروف التحكّم (ما عدا سطر جديد وجدولة) بتنشال: ما إلها معنى بنص
  -- مكتوب بالإيد، وبتكسر العرض والتصدير. وأكتر من سطرين فاضيين ورا بعض
  -- بينضغطوا لسطرين — نص مركون بمية سطر فاضي ما بيفيد حدا.
  v_body := regexp_replace(coalesce(p_text, ''), '[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]', '', 'g');
  v_body := regexp_replace(v_body, E'\n{3,}', E'\n\n', 'g');
  v_body := btrim(v_body);

  if length(v_body) < (v_lim->>'min_chars')::int then
    return jsonb_build_object('ok', false, 'error', 'too_short');
  end if;
  -- القص مو الرفض: مين كتب صفحتين ما لازم يخسرهن كلهن
  v_body := left(v_body, (v_lim->>'max_chars')::int);

  -- ★ حدّ المعدّل بيتفحّص بعد فحص الطول.
  -- لو انعكس الترتيب، مين ضغط «إرسال» وهو فاضي خمس مرّات بينقفل ساعة
  -- بسبب خمس محاولات ما انحفظت ولا وحدة منهن.
  select count(*) into v_n from reports
   where user_id = v_user
     and created_at > now() - make_interval(mins => (v_lim->>'window_minutes')::int);
  if v_n >= (v_lim->>'max_per_window')::int then
    return jsonb_build_object('ok', false, 'error', 'too_many');
  end if;

  -- اللغة: قائمة مغلقة. مجهول بيصير null، مو نص المستخدم.
  v_lang := case when p_lang in ('de', 'ar', 'uk') then p_lang end;

  -- السياق بيتقرا من الجدول، مو من العميل: الطالب ما بيقدر يزعم إنه
  -- بيبلّغ عن امتحان تاني.
  select t.level_id,
         coalesce(l.provider || ' · ' || l.stufe, l.title, t.level_id) || ' — ' || t.title
    into v_level, v_label
    from tests t left join levels l on l.id = t.level_id
   where t.id = p_test_id;

  insert into reports (user_id, test_id, level_id, test_label, body, lang)
  values (v_user, p_test_id, v_level, v_label, v_body, v_lang);

  return jsonb_build_object('ok', true);
end $$;
revoke all on function report_problem(uuid, text, text) from public, anon;
grant execute on function report_problem(uuid, text, text) to authenticated;

-- ---------------------------------------------------------------------
-- القراءة: للوحة بس
-- ---------------------------------------------------------------------
create or replace function admin_reports(p_status text default null)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  perform admin_guard();
  select coalesce(jsonb_agg(x order by x->>'created_at' desc), '[]') into r from (
    select jsonb_build_object(
      'id',         rp.id,
      'created_at', rp.created_at,
      'status',     rp.status,
      'body',       rp.body,
      'lang',       rp.lang,
      'user_id',    rp.user_id,
      'name',       p.display_name,
      'test_id',    rp.test_id,
      -- الاسم المحفوظ أولاً: هو يلي كان شايفه الطالب وقت بلّغ
      'test',       coalesce(rp.test_label, t.title),
      'slug',       t.slug,
      'level_id',   rp.level_id,
      'provider',   l.provider,
      'stufe',      l.stufe) as x
    from reports rp
    left join profiles p on p.id = rp.user_id
    left join tests    t on t.id = rp.test_id
    left join levels   l on l.id = rp.level_id
   where p_status is null or rp.status = p_status
   order by rp.created_at desc
   limit 300
  ) q;
  return r;
end $$;
revoke all on function admin_reports(text) from public, anon;
grant execute on function admin_reports(text) to authenticated;

-- ---------------------------------------------------------------------
-- «تمّت معالجته» — وبيرجع لو انضغط بالغلط
-- ---------------------------------------------------------------------
create or replace function admin_report_status(p_id uuid, p_done boolean)
returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  update reports set
    status     = case when p_done then 'done' else 'new' end,
    handled_at = case when p_done then now() end,
    handled_by = case when p_done then auth.uid() end
   where id = p_id;
  if not found then raise exception 'report_not_found'; end if;
  perform admin_log('report_status', 'report', p_id::text,
                    jsonb_build_object('done', p_done));
  return jsonb_build_object('ok', true);
end $$;
revoke all on function admin_report_status(uuid, boolean) from public, anon;
grant execute on function admin_report_status(uuid, boolean) to authenticated;

-- ---------------------------------------------------------------------
-- شاشة البداية بتعدّ التبليغات المفتوحة كمان
-- (منقولة من 0017 — الفرق سطر واحد: reports_open)
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
    'reports_open',    (select count(*) from reports where status = 'new'),
    'levels',          (select coalesce(jsonb_agg(jsonb_build_object(
                                 'id', id, 'title', title, 'published', published,
                                 'provider', provider, 'stufe', stufe)
                               order by coalesce(provider, 'zz'),
                                        stufe_rank(stufe), stufe, sort), '[]')
                        from levels)
  ) into r;
  return r;
end $$;

create or replace function schema_version()
returns int language sql immutable as $$ select 30 $$;
grant execute on function schema_version() to authenticated, anon;
