-- =====================================================================
-- 0013_storage — دلاء الصور والصوت، وسياسات قراءتها
--
-- الثغرة يلي بيصلحها: التطبيق بيطلب رابط موقّع من Storage باسم حساب
-- الطالب. وSupabase Storage عليه RLS خاص فيه على storage.objects — ما
-- إله علاقة بسياسات الجداول يلي كتبناها. بلا سياسة، كل طلب توقيع
-- بيرجع 403، والدالة بترجّع null، والصورة **ما بتظهر ولا بتعطي خطأ**.
-- يعني Leseverstehen Teil 3 بكل الـ١٦ امتحان بيضل فاضي بلا سبب ظاهر.
--
-- والسياسة مو «كل من فات بيشوف»: الملف بينقرا فقط إذا في قسم بيشير
-- إله، وصاحب الطلب مشترك بمستوى ذاك القسم. يعني صور امتحانات B1 ما
-- بيوصلها مشترك A1، ونفس الشي للصوت.
-- =====================================================================

-- الدلاء: خاصة. الدلو العام بيلغي كل هالكلام — أي حدا معه الرابط بيفوت.
insert into storage.buckets (id, name, public)
values ('exam-images', 'exam-images', false),
       ('exam-audio',  'exam-audio',  false)
on conflict (id) do update set public = false;

-- ---------------------------------------------------------------------
-- مين بيقدر يقرا ملف؟
--
-- الاسم بالدلو لازم يطابق حرفياً يلي محفوظ بـconfig:
--   الصور: config->>'bankImage'  متل 'img/m01-lv3.jpg'
--   الصوت: config->>'audio'      متل 'm01-hv1.mp3'
-- ملف ما إله قسم بيشير إله ما بينقرا — ولا حتى من مشترك.
-- ---------------------------------------------------------------------
create or replace function storage_asset_allowed(p_bucket text, p_name text)
returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from sections s
      join tests t on t.id = s.test_id
     where s.config->>(case when p_bucket = 'exam-audio' then 'audio'
                            else 'bankImage' end) = p_name
       and has_access(auth.uid(), t.level_id)
  );
$$;

revoke all on function storage_asset_allowed(text, text) from public;
grant execute on function storage_asset_allowed(text, text) to authenticated;

drop policy if exists exam_assets_read on storage.objects;
create policy exam_assets_read on storage.objects for select to authenticated
  using (bucket_id in ('exam-images', 'exam-audio')
         and storage_asset_allowed(bucket_id, name));

-- الرفع بيصير بمفتاح service_role، وهو بيتخطّى RLS — فما في سياسة كتابة
-- بالقصد. يعني ولا حساب طالب بيقدر يرفع ولا يمسح ولا يستبدل ملف.
