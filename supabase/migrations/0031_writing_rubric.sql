-- =====================================================================
-- 0031_writing_rubric — التصحيح الآلي كان بيعطي صفر لكل مستوى غير B1
--
-- ★ عطبين منفصلين، والاتنين صامتين:
--
-- ١) النقاط. writing_finish بيترجم حرف التقييم (A/B/C/D) لنقاط من
--    جدول `grades` المخزّن مع القسم. وبس telc B1 عنده هالجدول — ÖSD
--    وGoethe وtelc B2 وDTZ كلهن فاضيين. النتيجة: coalesce(null,0)،
--    يعني **صفر نقطة مهما كتب الطالب**. ما بيرمي خطأ، بس بيكذب.
--
-- ٢) أي قسم ينصحّح. الاستعلام كان `limit 1` بلا ترتيب — وبلوك الكتابة
--    بـÖSD وGoethe فيه قسمين (استمارة ورسالة). يعني ممكن يصحّح
--    الاستمارة بدل الرسالة، وبشكل عشوائي بين تشغيلة وتانية.
--
-- الحلّ: معيار افتراضي مشترك. مو معايير المؤسسة الرسمية — تلك بتنكتب
-- بالمحتوى لما تتوفّر — بس معيار عام صريح ومتناسب مع نقاط القسم، أحسن
-- بكتير من صفر صامت.
-- =====================================================================

create or replace function writing_default_rubric(p_max numeric)
returns jsonb
language sql immutable as $$
  -- تلات معايير، كل واحد بياخد تلت النقاط. A كامل · B ٦٠٪ · C ٣٠٪ · D صفر.
  select jsonb_build_object(
    'criteria', jsonb_build_array(
      jsonb_build_object('title', 'Aufgabenerfüllung',
        'hint', 'Sind alle Leitpunkte inhaltlich bearbeitet und angemessen ausgeführt?'),
      jsonb_build_object('title', 'Kommunikative Gestaltung',
        'hint', 'Passen Anrede, Aufbau, Verknüpfung der Sätze und Gruß zur Textsorte?'),
      jsonb_build_object('title', 'Formale Richtigkeit',
        'hint', 'Wie korrekt sind Grammatik, Wortschatz und Rechtschreibung?')),
    'grades', jsonb_build_array(
      jsonb_build_object('key', 'A', 'points', round(p_max / 3, 2)),
      jsonb_build_object('key', 'B', 'points', round(p_max / 3 * 0.6, 2)),
      jsonb_build_object('key', 'C', 'points', round(p_max / 3 * 0.3, 2)),
      jsonb_build_object('key', 'D', 'points', 0)),
    'generic', true);
$$;
grant execute on function writing_default_rubric(numeric) to authenticated;

-- ---------------------------------------------------------------------
-- البداية: قسم واحد محدَّد، ومعيار مضمون
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
  v_id    uuid;
  v_q     jsonb;
  v_max   numeric;
  v_rub   jsonb;
  v_crit  jsonb;
  v_grad  jsonb;
  v_gen   boolean;
  v_words int;
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

  -- ★ القسم المقصود هو النصّ الحرّ، مو أي قسم كتابة بالبلوك.
  --   «الاستمارة» و«التلفون-نوتيتس» كمان format=writing، بس يلي بينصحّح
  --   هو يلي إله حدّ أدنى كلمات — هي علامة الرسالة الحقيقية. وترتيب
  --   ثابت بالآخر تا ما تختلف النتيجة بين تشغيلة وتانية.
  select s.id, s.section_id, s.instruction, s.config,
         (select (i.meta->>'minWords')::int from items i
           where i.section_id = s.id order by i.sort limit 1) as min_words
    into v_sec
    from sections s
   where s.test_id = a.test_id and s.format = 'writing'
     and s.section_id in (
       select jsonb_array_elements_text(b->'parts')
         from tests t, jsonb_array_elements(t.blocks) b
        where t.id = a.test_id and b->>'id' = a.block_id)
   order by ((select (i.meta->>'minWords')::int from items i
               where i.section_id = s.id order by i.sort limit 1) is not null) desc,
            s.sort
   limit 1;
  if v_sec.id is null then
    return jsonb_build_object('ok', false, 'error', 'not_a_writing_block');
  end if;

  select a.answers ->> i.id::text into v_text
    from items i where i.section_id = v_sec.id order by i.sort limit 1;
  if coalesce(trim(v_text), '') = '' then
    return jsonb_build_object('ok', false, 'error', 'empty_text');
  end if;

  -- ★ الحصّة بتنحرق هون، مو بالمتصفّح. «تلفون-نوتيتس» كمان format=writing
  --   وبتطلع خمس كلمات — نداء Gemini عليها بيكلّف من حصّة الطالب وبيرجّع
  --   لا شي. الحدّ منخفض عن قصد: طالب A1 بيكتب بريد من تلات جمل.
  v_words := array_length(regexp_split_to_array(btrim(v_text), '\s+'), 1);
  if v_words < 12 then
    return jsonb_build_object('ok', false, 'error', 'too_short', 'words', v_words);
  end if;

  v_q := writing_quota_state();
  if (v_q->>'left')::int <= 0 then
    return jsonb_build_object('ok', false, 'error', 'quota_exceeded',
                              'used', v_q->'used', 'quota', v_q->'quota');
  end if;

  -- ★ معيار مضمون: تبع المؤسسة إذا مكتوب، وإلا العام المتناسب.
  v_max  := coalesce((v_sec.config->>'maxPoints')::numeric, 45);
  v_rub  := writing_default_rubric(v_max);
  v_gen  := jsonb_array_length(coalesce(v_sec.config->'criteria', '[]')) = 0;
  v_crit := case when v_gen then v_rub->'criteria' else v_sec.config->'criteria' end;
  v_grad := case when jsonb_array_length(coalesce(v_sec.config->'grades', '[]')) > 0
                 then v_sec.config->'grades' else v_rub->'grades' end;

  insert into writing_feedback (attempt_id, user_id, section_id, text, word_count,
                                max_points, status)
  values (p_attempt_id, v_user, v_sec.id, v_text, v_words, v_max, 'pending')
  returning id into v_id;

  return jsonb_build_object(
    'ok', true,
    'feedback_id', v_id,
    'text', v_text,
    'instruction', v_sec.instruction,
    'task',      v_sec.config->'brief',
    'points',    (select i.meta->'points' from items i
                   where i.section_id = v_sec.id order by i.sort limit 1),
    'min_words', v_sec.min_words,
    'criteria',  v_crit,
    'grades',    v_grad,
    -- صريح: هدول معايير عامة، مو معايير المؤسسة الرسمية
    'generic_rubric', v_gen,
    'factor',    coalesce((v_sec.config->>'factor')::numeric, 1),
    'max_points', v_max,
    'level',     v_level,
    -- الامتحان باسمه: النظام كان بيقول «telc Deutsch B1» لكل مستوى
    'exam',      (select coalesce(l.provider || ' ' || l.stufe, l.title, l.id)
                    from levels l where l.id = v_level),
    'used', v_q->'used', 'quota', v_q->'quota');
end $$;

-- ---------------------------------------------------------------------
-- النهاية: نفس المعيار الافتراضي، وإلا النقاط بتضل صفر
-- ---------------------------------------------------------------------
create or replace function writing_finish(
  p_feedback_id uuid,
  p_grades      jsonb,
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
  v_grad   jsonb;
begin
  select * into f from writing_feedback where id = p_feedback_id;
  if not found then raise exception 'feedback_not_found'; end if;
  if f.status <> 'pending' then raise exception 'already_finished'; end if;

  select config into cfg from sections where id = f.section_id;
  v_factor := coalesce((cfg->>'factor')::numeric, 1);

  -- ★ نفس اختيار writing_start بالضبط. لو اختلفوا، الشرح بيجي بمعيار
  --   والنقاط بتنحسب بمعيار تاني — وهاد أسوأ من صفر.
  v_grad := case when jsonb_array_length(coalesce(cfg->'grades', '[]')) > 0
                 then cfg->'grades'
                 else writing_default_rubric(f.max_points)->'grades' end;

  for g in select * from jsonb_array_elements(coalesce(p_grades, '[]'::jsonb))
  loop
    select (x->>'points')::numeric into v_pts
      from jsonb_array_elements(v_grad) x
     where upper(x->>'key') = upper(g->>'key')
     limit 1;
    v_sum := v_sum + coalesce(v_pts, 0);
  end loop;

  update writing_feedback
     set status = 'done', grades = p_grades, errors = p_errors,
         summary = p_summary, corrected = p_corrected, model = p_model,
         points = least(round(v_sum * v_factor, 1), f.max_points),
         completed_at = now()
   where id = p_feedback_id;

  return jsonb_build_object('ok', true,
    'points', least(round(v_sum * v_factor, 1), f.max_points),
    'max_points', f.max_points);
end $$;

create or replace function schema_version()
returns int language sql immutable as $$ select 31 $$;
grant execute on function schema_version() to authenticated, anon;
