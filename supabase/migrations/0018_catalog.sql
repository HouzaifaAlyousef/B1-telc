-- =====================================================================
-- 0018_catalog — الامتحانات المقفولة تنشاف، بس ما تنفتح
--
-- صاحب الكود التجريبي ما بيشوف إلا امتحانه الواحد — لا بيعرف إنه في
-- غيره، ولا ليش يشتري. سياسة RLS بتخفي الصفوف كلياً، وهاد صح للمحتوى
-- بس غلط للتسويق.
--
-- الحل: دالة بترجّع **بيانات وصفية فقط** لامتحانات المستوى:
-- العنوان وعدد الأسئلة والدقائق. ولا قسم، ولا سؤال، ولا حل — هدول
-- بيضلّوا محكومين بـRLS متل ما هنّي.
--
-- ★ الشرط: لازم يكون عنده اشتراك ساري بهالمستوى (بأي نطاق). يلي ما
--   عنده ولا اشتراك ما بيشوف ولا عنوان — ما منعطي كتالوج مجاني لكل
--   من دقّ الباب.
-- =====================================================================

create or replace function level_catalog(p_level_id text)
returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare
  v_user uuid := auth.uid();
  r jsonb;
begin
  if v_user is null then return '[]'::jsonb; end if;

  -- اشتراك ساري بهالمستوى، مهما كان نطاقه
  if not exists (select 1 from subscriptions s
                  where s.user_id = v_user and s.status = 'active'
                    and s.current_period_end > now()
                    and p_level_id = any(s.levels)) then
    return '[]'::jsonb;
  end if;

  select coalesce(jsonb_agg(x order by sort), '[]') into r
  from (
    select t.sort, jsonb_build_object(
      'id',       t.slug,
      'title',    t.title,
      'subtitle', t.subtitle,
      'aufgaben', t.aufgaben,
      -- الدقائق من الكتل: رقم وصفي، مو محتوى
      'minutes',  coalesce((select sum((b->>'minutes')::int)
                              from jsonb_array_elements(t.blocks) b), 0),
      -- مفتوح إذا مجاني أو داخل نطاق اشتراكه
      'open',     t.is_free or has_test_access(v_user, t.level_id, t.slug)
    ) as x
      from tests t
     where t.level_id = p_level_id and t.published
  ) q;
  return r;
end $$;

revoke all on function level_catalog(text) from public;
grant execute on function level_catalog(text) to authenticated;
