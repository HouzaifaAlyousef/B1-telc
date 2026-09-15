-- =====================================================================
-- 0016_edit_test — قراءة امتحان منشور رجوعاً لصيغة اللصق
--
-- بعد النشر ما كان في طريقة تعدّلي فيها امتحان: غلطة مطبعية بسؤال
-- بتعني إعادة لصق الامتحان كامل من أوّله — إذا لسا محتفظة بالنص.
--
-- الدالة بترجّع الامتحان بنفس شكل الـJSON يلي بيطلّعه المحلّل، فـ
-- Markup.serialize باللوحة بيحوّله لنص لصق، بتعدّلي عليه، وadmin_apply_
-- import بيستبدل (on conflict على level_id+slug). يعني دورة كاملة
-- بلا صيغة جديدة ولا مسار تاني.
--
-- ★ بترجّع الحلول كمان — ولازم. بلا الحلول، التعديل بيمحيهن: الاستيراد
--   بيبدّل الأقسام كلها، وسؤال بلا Lösung: بينحفظ بلا حل. فهي محصورة
--   بالأدمن متل باقي دوال admin_*.
-- =====================================================================

create or replace function admin_test_doc(p_test_id uuid)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  perform admin_guard();
  select jsonb_build_object(
    'title',    t.title,
    'subtitle', t.subtitle,
    'blocks',   coalesce(t.blocks, '[]'::jsonb),
    'sections', (
      select coalesce(jsonb_agg(sec order by sec_sort), '[]')
      from (
        select s.sort as sec_sort,
               -- config بينفرد على مستوى القسم، متل ما بيطلّعه المحلّل
               coalesce(s.config, '{}'::jsonb) || jsonb_build_object(
                 'id',          s.section_id,
                 'group',       s."group",
                 'title',       s.title,
                 'minutes',     s.minutes,
                 'instruction', s.instruction,
                 'format',      s.format,
                 'items', (
                   select coalesce(jsonb_agg(it order by it_sort), '[]')
                   from (
                     select i.sort as it_sort,
                            jsonb_strip_nulls(jsonb_build_object(
                              'id',       i.item_id,
                              'text',     i.text,
                              'options',  i.options,
                              'minWords', i.meta->'minWords',
                              'points',   i.meta->'points',
                              'answer',   ia.answer,
                              'explain',  ia.explanation)) as it
                       from items i
                       left join item_answers ia on ia.item_id = i.id
                      where i.section_id = s.id
                   ) x
                 )) as sec
          from sections s
         where s.test_id = t.id
      ) y
    ))
    into r
    from tests t
   where t.id = p_test_id;

  if r is null then raise exception 'test_not_found'; end if;
  return r;
end $$;

revoke all on function admin_test_doc(uuid) from public;
grant execute on function admin_test_doc(uuid) to authenticated;
