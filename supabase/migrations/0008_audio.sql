-- =====================================================================
-- 0008_audio — صوت الاستماع (Hörverstehen)
--
-- ثلث كل امتحان telc استماع، والـPDF الأصلي ما فيه صوت — فالقسم كان
-- بيعرض النص مع الحل للمراجعة بس. هون بينفتح الطريق للصوت الحقيقي.
--
-- الصوت محتوى امتحان متل الأسئلة: دلو **خاص** ورابط موقّع بينتهي.
-- المسار بينحفظ بـsections.config.audio، وعدد مرات التشغيل بـaudioPlays
-- (telc بيشغّل بعض الأجزاء مرة وبعضها مرتين).
-- =====================================================================

create or replace function admin_set_section_audio(
  p_section_id uuid,
  p_path       text,          -- مسار الملف بالدلو، أو null لشيله
  p_plays      int default 1  -- كم مرة مسموح يسمعه
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_cfg jsonb;
begin
  perform admin_guard();
  if p_plays < 1 or p_plays > 5 then raise exception 'plays_out_of_range'; end if;

  select config into v_cfg from sections where id = p_section_id;
  if v_cfg is null then raise exception 'section_not_found'; end if;

  update sections
     set config = case
           when p_path is null then (config - 'audio' - 'audioPlays')
           else config || jsonb_build_object('audio', p_path, 'audioPlays', p_plays)
         end
   where id = p_section_id;

  perform admin_log('section.audio', 'section', p_section_id::text,
                    jsonb_build_object('path', p_path, 'plays', p_plays));
  return jsonb_build_object('ok', true, 'path', p_path, 'plays', p_plays);
end $$;

-- أقسام الاستماع مع حالة صوتها — للوحة
create or replace function admin_audio_status(p_level_id text default null)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  perform admin_guard();
  select coalesce(jsonb_agg(x order by x->>'test', x->>'section'), '[]') into r
  from (
    select jsonb_build_object(
      'section_id', s.id, 'section', s.section_id, 'title', s.title,
      'test', t.slug, 'test_title', t.title, 'level', t.level_id,
      'items', (select count(*) from items i where i.section_id = s.id),
      'audio', s.config->>'audio',
      'plays', coalesce((s.config->>'audioPlays')::int, 1)) as x
      from sections s join tests t on t.id = s.test_id
     where s."group" ilike '%Hörverstehen%'
       and (p_level_id is null or t.level_id = p_level_id)
  ) q;
  return r;
end $$;

revoke all on function admin_set_section_audio(uuid,text,int) from public;
revoke all on function admin_audio_status(text)               from public;
grant execute on function admin_set_section_audio(uuid,text,int) to authenticated;
grant execute on function admin_audio_status(text)               to authenticated;
