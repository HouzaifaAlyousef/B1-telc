-- =====================================================================
-- 0015_admin_upload — الأدمن بيرفع الصور والصوت من اللوحة
--
-- الرفع كان لازمه مفتاح service_role وسكربت بايثون على جهازك. هاد
-- مفتاح بيتخطّى كل الحماية، فوجوده على الجهاز غلط بيصير خطر، وكل صورة
-- جديدة بتصير مشوار.
--
-- الحل: سياسة كتابة على storage.objects محصورة بـis_admin() وبالدلوين.
-- اللوحة بترفع بجلسة الأدمن نفسها — ولا مفتاح إضافي، ولا سكربت.
-- الطالب ما بيتغيّر شي عنده: ما إله ولا سياسة كتابة.
-- =====================================================================

drop policy if exists exam_assets_write  on storage.objects;
drop policy if exists exam_assets_update on storage.objects;
drop policy if exists exam_assets_delete on storage.objects;

create policy exam_assets_write on storage.objects for insert to authenticated
  with check (bucket_id in ('exam-images', 'exam-audio') and is_admin());

-- الاستبدال (نفس الاسم، ملف أحدث) بيمرق كـupdate عند بعض العملاء
create policy exam_assets_update on storage.objects for update to authenticated
  using (bucket_id in ('exam-images', 'exam-audio') and is_admin())
  with check (bucket_id in ('exam-images', 'exam-audio') and is_admin());

create policy exam_assets_delete on storage.objects for delete to authenticated
  using (bucket_id in ('exam-images', 'exam-audio') and is_admin());

-- ---------------------------------------------------------------------
-- الأدمن لازم يقرا كل الملفات، مو يلي إله اشتراك فيها
--
-- exam_assets_read بتفحص الاشتراك، والأدمن ما إله اشتراك — فكان ما
-- بيشوف ولا ملف بلوحته، ولا بيعرف شو مرفوع وشو ناقص.
-- ---------------------------------------------------------------------
drop policy if exists exam_assets_read on storage.objects;
create policy exam_assets_read on storage.objects for select to authenticated
  using (bucket_id in ('exam-images', 'exam-audio')
         and (is_admin() or storage_asset_allowed(bucket_id, name)));

-- ---------------------------------------------------------------------
-- شو مرفوع وشو ناقص — للوحة
--
-- بترجّع كل قسم بده ملف، مع اسم الملف المتوقّع وهل هو موجود. المقارنة
-- بالاسم الحرفي: ملف مرفوع باسم غير يلي بـconfig ما بيظهر للطالب أبداً،
-- والسياسة كمان ما بتلاقيه — فهاد الفحص بيمسك أشيع غلطة بالرفع.
-- ---------------------------------------------------------------------
create or replace function admin_assets(p_level_id text default null)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  perform admin_guard();
  select coalesce(jsonb_agg(x order by x->>'level_id', x->>'slug', x->>'section'), '[]')
    into r
  from (
    select jsonb_build_object(
      'section_id', s.id,
      'level_id',   t.level_id,
      'slug',       t.slug,
      'test_title', t.title,
      'section',    s.section_id,
      'title',      s.title,
      'kind',       k.kind,
      -- المسار المحفوظ، أو اقتراح لقسم لسا ما إله ملف. الاقتراح بيخلّي
      -- الأسماء منتظمة بلا ما تفكّري فيها، وبيضل قابل للتعديل باللوحة.
      'path',       coalesce(k.path, t.slug || '-' || s.section_id || '.mp3'),
      'assigned',   k.path is not null,
      'plays',      coalesce((s.config->>'audioPlays')::int, 1),
      'uploaded',   k.path is not null and exists (
                      select 1 from storage.objects o
                       where o.bucket_id = k.bucket and o.name = k.path)
    ) as x
    from sections s
    join tests t on t.id = s.test_id
    cross join lateral (values
      ('image', 'exam-images', s.config->>'bankImage'),
      ('audio', 'exam-audio',  s.config->>'audio')
    ) as k(kind, bucket, path)
    -- الصور: بس الأقسام يلي فعلاً بدها صورة (المسار مكتوب بالاستيراد).
    -- الصوت: كل قسم استماع، حتى لو لسا ما إله ملف — وإلا ما في طريقة
    -- تربطي فيها تسجيل بقسم من اللوحة أصلاً.
   where ((k.kind = 'image' and k.path is not null)
          or (k.kind = 'audio' and (k.path is not null or s."group" ilike '%hör%')))
     and (p_level_id is null or t.level_id = p_level_id)
  ) q;
  return r;
end $$;

revoke all on function admin_assets(text) from public;
grant execute on function admin_assets(text) to authenticated;
