-- =====================================================================
-- 0006_review — تكرار متباعد فوق جدول الأخطاء
--
-- الأخطاء كانت بتنجمع وبس تنعدّ. هون بتصير جدول مراجعة: كل سؤال إله
-- صندوق (Leitner) وموعد استحقاق. جاوبت صح ← بيصعد صندوق وبيبعد موعده.
-- غلطت ← بيرجع للصندوق الأول وبيستحق فوراً.
--
-- الفواصل: ١، ٣، ٧، ١٦، ٣٥ يوم. بعد الصندوق الخامس بينحسب متقن وبيطلع
-- من التدوير — بلا ما ينحذف، تا يضل التاريخ موجود للتحليلات.
-- =====================================================================

alter table mistakes add column if not exists box         int not null default 1;
alter table mistakes add column if not exists due_at      timestamptz not null default now();
alter table mistakes add column if not exists right_count int not null default 0;

create index if not exists mistakes_due_idx on mistakes (user_id, due_at);

-- فاصل الصندوق بالأيام
create or replace function review_interval(p_box int)
returns interval language sql immutable as $$
  select (array['1 day','3 days','7 days','16 days','35 days']::interval[])
         [least(greatest(p_box, 1), 5)];
$$;

comment on column mistakes.box is
  'صندوق Leitner ١..٥؛ ٦ فما فوق = متقن، بيطلع من التدوير';

-- ---------------------------------------------------------------------
-- التصحيح: الخطأ بيرجّع السؤال لأول صندوق
-- (نفس submit_attempt بـ0003، بس تحديث الأخطاء صار يضبط الصندوق والموعد)
-- ---------------------------------------------------------------------
create or replace function submit_attempt(
  p_test_id  uuid,
  p_block_id text,
  p_answers  jsonb
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user       uuid := auth.uid();
  v_level      text;
  v_parts      text[];
  v_attempt_id uuid;
  v_points     numeric := 0;
  v_max        numeric := 0;
  v_results    jsonb   := '[]';
  r            record;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  select level_id into v_level from tests where id = p_test_id and published;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'test_not_found');
  end if;

  if not (exists (select 1 from tests where id = p_test_id and is_free)
          or has_access(v_user, v_level)) then
    return jsonb_build_object('ok', false, 'error', 'not_entitled');
  end if;

  select array(select jsonb_array_elements_text(b->'parts'))
    into v_parts
    from tests t, jsonb_array_elements(t.blocks) b
   where t.id = p_test_id and b->>'id' = p_block_id;

  if v_parts is null or array_length(v_parts, 1) is null then
    return jsonb_build_object('ok', false, 'error', 'block_not_found');
  end if;

  insert into attempts (user_id, test_id, block_id, answers, submitted_at)
  values (v_user, p_test_id, p_block_id, p_answers, now())
  returning id into v_attempt_id;

  for r in
    select i.id, i.item_id, i.points, s.section_id, s.format,
           ia.answer, ia.explanation,
           p_answers ->> i.id::text as given
      from items i
      join sections s on s.id = i.section_id
      left join item_answers ia on ia.item_id = i.id
     where s.test_id = p_test_id
       and s.section_id = any(v_parts)
       and s.format <> 'writing'
       and ia.answer is not null
     order by s.sort, i.sort
  loop
    v_max := v_max + r.points;
    if r.given is not null and r.given = r.answer then
      v_points := v_points + r.points;
    else
      -- غلط بالامتحان = رجوع لأول صندوق، مستحق فوراً
      insert into mistakes (user_id, item_id, box, due_at)
      values (v_user, r.id, 1, now())
      on conflict (user_id, item_id)
        do update set wrong_count = mistakes.wrong_count + 1,
                      box = 1, due_at = now(), last_seen_at = now();
    end if;

    v_results := v_results || jsonb_build_object(
      'id',          r.id,
      'section',     r.section_id,
      'item',        r.item_id,
      'given',       r.given,
      'answer',      r.answer,
      'explanation', r.explanation,
      'correct',     (r.given is not null and r.given = r.answer));
  end loop;

  update attempts
     set points = v_points, max_points = v_max,
         pct = case when v_max > 0 then round(100 * v_points / v_max, 1) else null end
   where id = v_attempt_id;

  return jsonb_build_object(
    'ok', true, 'attempt_id', v_attempt_id,
    'points', v_points, 'max_points', v_max,
    'pct', case when v_max > 0 then round(100 * v_points / v_max, 1) else null end,
    'results', v_results);
end $$;

-- ---------------------------------------------------------------------
-- المراجعة: صح ← الصندوق الجاي، غلط ← الأول
-- ---------------------------------------------------------------------
create or replace function submit_drill(p_answers jsonb)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_user    uuid := auth.uid();
  v_right   int  := 0;
  v_total   int  := 0;
  v_master  int  := 0;
  v_results jsonb := '[]';
  v_box     int;
  r         record;
begin
  if v_user is null then
    return jsonb_build_object('ok', false, 'error', 'not_authenticated');
  end if;

  for r in
    select i.id, i.item_id, s.section_id, t.slug, t.level_id,
           ia.answer, ia.explanation, m.box,
           p_answers ->> i.id::text as given
      from items i
      join item_answers ia on ia.item_id = i.id
      join sections s on s.id = i.section_id
      join tests   t on t.id = s.test_id
      join mistakes m on m.item_id = i.id and m.user_id = v_user
     where i.id::text in (select jsonb_object_keys(p_answers))
       and (t.is_free or has_access(v_user, t.level_id))
  loop
    v_total := v_total + 1;
    if r.given is not null and r.given = r.answer then
      v_right := v_right + 1;
      v_box := r.box + 1;
      if v_box > 5 then v_master := v_master + 1; end if;
      update mistakes
         set box = v_box,
             right_count = right_count + 1,
             -- المتقن بيتأجّل بعيد بدل ما ينحذف: التاريخ بيضل للتحليلات
             due_at = now() + case when v_box > 5 then interval '365 days'
                                   else review_interval(v_box) end,
             last_seen_at = now()
       where user_id = v_user and item_id = r.id;
    else
      update mistakes
         set box = 1, wrong_count = wrong_count + 1,
             due_at = now(), last_seen_at = now()
       where user_id = v_user and item_id = r.id;
    end if;

    v_results := v_results || jsonb_build_object(
      'id', r.id, 'item', r.item_id, 'section', r.section_id, 'test', r.slug,
      'given', r.given, 'answer', r.answer, 'explanation', r.explanation,
      'correct', (r.given is not null and r.given = r.answer));
  end loop;

  return jsonb_build_object(
    'ok', true, 'right', v_right, 'total', v_total, 'mastered', v_master,
    'pct', case when v_total > 0 then round(100.0 * v_right / v_total, 1) else null end,
    'results', v_results);
end $$;

-- ---------------------------------------------------------------------
-- ملخّص المراجعة للشاشة الرئيسية — نداء واحد بدل جلب كل الصفوف
-- ---------------------------------------------------------------------
create or replace function review_summary()
returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_user uuid := auth.uid();
begin
  if v_user is null then return jsonb_build_object('due', 0, 'total', 0); end if;
  return (select jsonb_build_object(
    'due',      count(*) filter (where due_at <= now() and box <= 5),
    'total',    count(*) filter (where box <= 5),
    'mastered', count(*) filter (where box > 5),
    'next_due', min(due_at) filter (where due_at > now() and box <= 5))
    from mistakes where user_id = v_user);
end $$;

revoke all on function review_summary() from public;
grant execute on function review_summary() to authenticated;
