-- =====================================================================
-- 0007_writing — تصحيح التعبير الكتابي
--
-- التعبير الكتابي كان تقييم ذاتي: الطالب بيقرا المعايير وبيحكم على حاله.
-- هون بيصير تصحيح حقيقي: الرسالة بتنبعت لـClaude من Edge Function،
-- وبترجع بدرجة لكل معيار وأخطاء مشروحة.
--
-- قاعدتين بالتصميم:
--  ١. النقاط بتنحسب **هون** من مفاتيح الدرجات وجدول grades المخزّن.
--     النموذج بيعطي حرف (A/B/C/D)، والحساب مو عليه.
--  ٢. الكتابة بجدول التغذية الراجعة مسموحة لـservice_role بس. لو
--     كانت مسموحة للطالب، بيقدر يبعت لحاله ٤٥ نقطة.
-- =====================================================================

create table if not exists writing_feedback (
  id           uuid primary key default gen_random_uuid(),
  attempt_id   uuid not null references attempts(id) on delete cascade,
  user_id      uuid not null references profiles(id) on delete cascade,
  section_id   uuid references sections(id) on delete set null,
  text         text not null,                 -- يلي كتبه الطالب
  word_count   int,
  status       text not null default 'pending',  -- pending|done|failed
  grades       jsonb,                         -- [{criterion, key, why}]
  points       numeric,                       -- محسوبة هون مو من النموذج
  max_points   numeric,
  errors       jsonb,                         -- [{type, original, correction, why}]
  summary      text,
  corrected    text,                          -- النص بعد التصحيح
  model        text,
  error        text,                          -- سبب الفشل لو فشل
  created_at   timestamptz not null default now(),
  completed_at timestamptz
);
create index if not exists writing_feedback_user_id_created_at_desc_idx on writing_feedback (user_id, created_at desc);
create index if not exists writing_feedback_attempt_id_idx on writing_feedback (attempt_id);

alter table writing_feedback enable row level security;
grant select on writing_feedback to authenticated;

drop policy if exists own_feedback on writing_feedback;
create policy own_feedback on writing_feedback for select to authenticated
  using (user_id = auth.uid());
drop policy if exists admin_feedback on writing_feedback;
create policy admin_feedback on writing_feedback for all to authenticated
  using (is_admin()) with check (is_admin());

-- حصّة شهرية: التصحيح بيكلّف فلوس حقيقية لكل نداء
alter table subscriptions add column if not exists writing_quota int not null default 20;

-- ---------------------------------------------------------------------
-- بداية التصحيح: فحص الصلاحية والحصّة، وتجهيز كل شي بيحتاجه النموذج
-- بينندعى بهويّة الطالب — فالصلاحية بتنفحص طبيعياً.
-- ---------------------------------------------------------------------
create or replace function writing_start(p_attempt_id uuid)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user  uuid := auth.uid();
  a       attempts%rowtype;
  v_level text;
  v_sec   record;
  v_text  text;
  v_used  int;
  v_quota int;
  v_since timestamptz;
  v_id    uuid;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  select * into a from attempts where id = p_attempt_id and user_id = v_user;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'attempt_not_found');
  end if;

  select level_id into v_level from tests where id = a.test_id;
  if not has_access(v_user, v_level) then
    return jsonb_build_object('ok', false, 'error', 'not_entitled');
  end if;

  -- قسم التعبير الكتابي بهالكتلة
  select s.id, s.section_id, s.instruction, s.config into v_sec
    from sections s
   where s.test_id = a.test_id and s.format = 'writing'
     and s.section_id in (
       select jsonb_array_elements_text(b->'parts')
         from tests t, jsonb_array_elements(t.blocks) b
        where t.id = a.test_id and b->>'id' = a.block_id)
   limit 1;
  if v_sec.id is null then
    return jsonb_build_object('ok', false, 'error', 'not_a_writing_block');
  end if;

  -- نص الطالب: أول (ووحيد) عنصر بالقسم
  select a.answers ->> i.id::text into v_text
    from items i where i.section_id = v_sec.id order by i.sort limit 1;

  if coalesce(trim(v_text), '') = '' then
    return jsonb_build_object('ok', false, 'error', 'empty_text');
  end if;

  -- الحصّة على مدى فترة الاشتراك الحالية
  select greatest(current_period_end - interval '30 days', now() - interval '30 days'),
         writing_quota
    into v_since, v_quota
    from subscriptions
   where user_id = v_user and status = 'active'
   order by current_period_end desc limit 1;

  select count(*) into v_used from writing_feedback
   where user_id = v_user and status <> 'failed' and created_at >= coalesce(v_since, now() - interval '30 days');

  if v_used >= coalesce(v_quota, 20) then
    return jsonb_build_object('ok', false, 'error', 'quota_exceeded',
                              'used', v_used, 'quota', v_quota);
  end if;

  -- صفّ معلّق: الـEdge Function بس بيقدر يكمّله
  insert into writing_feedback (attempt_id, user_id, section_id, text, word_count,
                                max_points, status)
  values (p_attempt_id, v_user, v_sec.id, v_text,
          array_length(regexp_split_to_array(trim(v_text), '\s+'), 1),
          coalesce((v_sec.config->>'maxPoints')::numeric, 45), 'pending')
  returning id into v_id;

  return jsonb_build_object(
    'ok', true,
    'feedback_id', v_id,
    'text', v_text,
    'instruction', v_sec.instruction,
    'task',      v_sec.config->'brief',
    'points',    (select i.meta->'points' from items i
                   where i.section_id = v_sec.id order by i.sort limit 1),
    'min_words', (select (i.meta->>'minWords')::int from items i
                   where i.section_id = v_sec.id order by i.sort limit 1),
    'criteria',  v_sec.config->'criteria',
    'grades',    v_sec.config->'grades',
    'factor',    coalesce((v_sec.config->>'factor')::numeric, 1),
    'max_points',coalesce((v_sec.config->>'maxPoints')::numeric, 45),
    'level',     v_level,
    'used', v_used, 'quota', v_quota);
end $$;

-- ---------------------------------------------------------------------
-- حفظ النتيجة — service_role فقط
-- النقاط بتنحسب هون من مفاتيح الدرجات، النموذج ما بيحسب ولا رقم.
-- ---------------------------------------------------------------------
create or replace function writing_finish(
  p_feedback_id uuid,
  p_grades      jsonb,     -- [{criterion, key, why}]
  p_errors      jsonb,
  p_summary     text,
  p_corrected   text,
  p_model       text
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  f        writing_feedback%rowtype;
  cfg      jsonb;
  v_factor numeric;
  v_sum    numeric := 0;
  g        jsonb;
  v_pts    numeric;
begin
  select * into f from writing_feedback where id = p_feedback_id;
  if not found then raise exception 'feedback_not_found'; end if;
  if f.status <> 'pending' then raise exception 'already_finished'; end if;

  select config into cfg from sections where id = f.section_id;
  v_factor := coalesce((cfg->>'factor')::numeric, 1);

  -- الحرف ← نقاط، من جدول grades المخزّن مع القسم
  for g in select * from jsonb_array_elements(coalesce(p_grades, '[]'::jsonb))
  loop
    select (x->>'points')::numeric into v_pts
      from jsonb_array_elements(coalesce(cfg->'grades', '[]'::jsonb)) x
     where upper(x->>'key') = upper(g->>'key')
     limit 1;
    v_sum := v_sum + coalesce(v_pts, 0);
  end loop;

  update writing_feedback
     set status = 'done', grades = p_grades, errors = p_errors,
         summary = p_summary, corrected = p_corrected, model = p_model,
         points = round(v_sum * v_factor, 1),
         completed_at = now()
   where id = p_feedback_id;

  return jsonb_build_object('ok', true, 'points', round(v_sum * v_factor, 1),
                            'max_points', f.max_points);
end $$;

create or replace function writing_fail(p_feedback_id uuid, p_error text)
returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  update writing_feedback set status = 'failed', error = p_error, completed_at = now()
   where id = p_feedback_id and status = 'pending';
  return jsonb_build_object('ok', true);
end $$;

revoke all on function writing_start(uuid) from public;
grant execute on function writing_start(uuid) to authenticated;
-- ★ finish/fail مو مسموحين للطالب: هيك ما بيقدر يكتب علامته بإيده
revoke all on function writing_finish(uuid,jsonb,jsonb,text,text,text) from public, authenticated;
revoke all on function writing_fail(uuid,text)                        from public, authenticated;
