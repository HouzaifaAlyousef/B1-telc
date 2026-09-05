-- =====================================================================
-- 0012_user_codes — لائحة النتوزر: كل الأكواد وكل الاشتراكات
--
-- مشكلتين بـadmin_users كانوا بيبيّنوا لما يصير في تفعيلات متعدّدة:
--
-- ١) عمود الكود كان بيقرا access_codes.redeemed_by، وهاد بينحط مرة
--    وحدة بس (coalesce(redeemed_by, v_user)) — يعني أول مفعّل. الطالب
--    التاني والتالت يلي فعّلوا نفس الكود كانوا يطلعوا بلا كود إطلاقاً.
--    السجلّ الصحيح موجود بـcode_redemptions من ترحيل 0010.
--
-- ٢) 'sub' كان limit 1، فالطالب يلي عنده A1 وB1 (كودين، متل ما
--    بيلزم) كان يبيّن باشتراك واحد ومستوى واحد — واللوحة ما بتعطيك
--    طريقة تمدّد التاني.
--
-- الاتنين صاروا مصفوفات: subs وcodes.
-- =====================================================================

create or replace function admin_users(p_search text default null)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  perform admin_guard();
  select coalesce(jsonb_agg(x order by x->>'created_at' desc), '[]') into r from (
    select jsonb_build_object(
      'id', p.id,
      'name', p.display_name,
      'note', p.note,
      'created_at', p.created_at,
      'last_seen_at', p.last_seen_at,
      'devices',  (select count(*) from devices  d where d.user_id = p.id),
      'attempts', (select count(*) from attempts a where a.user_id = p.id),
      'best_pct', (select max(pct)  from attempts a where a.user_id = p.id),
      'mistakes', (select count(*) from mistakes m where m.user_id = p.id),

      -- كل الاشتراكات، الأطول أولاً. كل واحد إله id لحاله تا تقدري
      -- تمدّديه أو توقفيه من اللوحة بلا ما تأثري على التاني.
      'subs', (select coalesce(jsonb_agg(jsonb_build_object(
                 'id', s.id, 'levels', s.levels, 'status', s.status,
                 'current_period_end', s.current_period_end,
                 'days_left', greatest(0, ceil(extract(epoch from
                               (s.current_period_end - now())) / 86400))::int,
                 'source', s.source,
                 'code', (select ac.code from access_codes ac
                           where ac.id = s.access_code_id))
                 order by s.current_period_end desc), '[]')
               from subscriptions s where s.user_id = p.id),

      -- ★ كل كود فعّله هالحساب — من سجلّ التفعيلات
      'codes', (select coalesce(jsonb_agg(jsonb_build_object(
                  'code', ac.code, 'levels', ac.levels, 'at', cr.created_at)
                  order by cr.created_at desc), '[]')
                from code_redemptions cr
                join access_codes ac on ac.id = cr.code_id
                where cr.user_id = p.id)
    ) as x
    from profiles p
    where not p.is_admin
      and (p_search is null or p_search = ''
           or p.display_name ilike '%' || p_search || '%'
           or p.note ilike '%' || p_search || '%'
           -- البحث كمان لازم يمرق على السجلّ، مو على أول مفعّل
           or exists (select 1 from code_redemptions cr
                        join access_codes ac on ac.id = cr.code_id
                       where cr.user_id = p.id
                         and ac.code ilike '%' || p_search || '%'))
  ) t;
  return r;
end $$;
