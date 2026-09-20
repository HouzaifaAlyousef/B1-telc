-- =====================================================================
-- 0005_content — إدارة المحتوى من اللوحة: استيراد، مراجع، مستويات
--
-- التحليل بيصير بالمتصفّح (admin/parse.js) ونتيجته بتنحفظ بـimports.parsed.
-- الدالة هون بتاخد الـJSON المراجَع وبتحوّله لصفوف. نفس مبدأ باقي النظام:
-- مفاتيح الحلول بتتفصل عن الأسئلة وبتروح لـitem_answers.
-- =====================================================================

-- ---------------------------------------------------------------------
-- المستويات
-- ---------------------------------------------------------------------
create or replace function admin_upsert_level(
  p_id text, p_title text, p_sort int default 0, p_published boolean default false
) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  if p_id !~ '^[a-z][a-z0-9_]{0,15}$' then raise exception 'bad_level_id'; end if;

  insert into levels (id, title, sort, published)
  values (p_id, p_title, p_sort, p_published)
  on conflict (id) do update
    set title = excluded.title, sort = excluded.sort, published = excluded.published;

  perform admin_log('level.upsert', 'level', p_id,
    jsonb_build_object('title', p_title, 'published', p_published));
  return jsonb_build_object('ok', true, 'id', p_id);
end $$;

-- ---------------------------------------------------------------------
-- المراجع — «الـfeed»: نص بتلصقيه والطالب بيقراه أي وقت
-- ---------------------------------------------------------------------
create or replace function admin_save_resource(
  p_id        uuid,
  p_level_id  text,
  p_title     text,
  p_body      text,
  p_published boolean default false,
  p_sort      int     default 0
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_id uuid;
begin
  perform admin_guard();
  if coalesce(trim(p_title), '') = '' then raise exception 'title_required'; end if;

  if p_id is null then
    insert into resources (level_id, title, body, published, sort, kind)
    values (p_level_id, p_title, p_body, p_published, p_sort, 'text')
    returning id into v_id;
    perform admin_log('resource.create', 'resource', v_id::text,
                      jsonb_build_object('title', p_title));
  else
    update resources
       set level_id = p_level_id, title = p_title, body = p_body,
           published = p_published, sort = p_sort
     where id = p_id
     returning id into v_id;
    if v_id is null then raise exception 'resource_not_found'; end if;
    perform admin_log('resource.update', 'resource', v_id::text,
                      jsonb_build_object('title', p_title, 'published', p_published));
  end if;
  return jsonb_build_object('ok', true, 'id', v_id);
end $$;

create or replace function admin_delete_resource(p_id uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  delete from resources where id = p_id;
  if not found then raise exception 'resource_not_found'; end if;
  perform admin_log('resource.delete', 'resource', p_id::text, '{}');
  return jsonb_build_object('ok', true);
end $$;

-- ---------------------------------------------------------------------
-- الاستيراد: حفظ المسوّدة
-- بينحفظ النص الخام كمان، تا لو التحليل طلع غلط تعيديه بلا ما تعيدي اللصق
-- ---------------------------------------------------------------------
create or replace function admin_save_import(
  p_id uuid, p_level_id text, p_raw text, p_parsed jsonb, p_status text default 'parsed'
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_id uuid;
begin
  perform admin_guard();
  if p_id is null then
    insert into imports (level_id, raw_text, parsed, status, created_by)
    values (p_level_id, p_raw, p_parsed, p_status, auth.uid())
    returning id into v_id;
  else
    update imports set level_id = p_level_id, raw_text = p_raw,
                       parsed = p_parsed, status = p_status
     where id = p_id returning id into v_id;
    if v_id is null then raise exception 'import_not_found'; end if;
  end if;
  perform admin_log('import.save', 'import', v_id::text,
                    jsonb_build_object('status', p_status));
  return jsonb_build_object('ok', true, 'id', v_id);
end $$;

create or replace function admin_delete_import(p_id uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  delete from imports where id = p_id;
  if not found then raise exception 'import_not_found'; end if;
  perform admin_log('import.delete', 'import', p_id::text, '{}');
  return jsonb_build_object('ok', true);
end $$;

-- ---------------------------------------------------------------------
-- ★ الاعتماد: JSON مراجَع ← امتحان كامل بقاعدة البيانات
--
-- بينشتغل بمعاملة وحدة: يا بيمرق كل الامتحان يا ولا شي. وإذا الـslug
-- موجود، بينستبدل محتواه بالكامل (حذف الأقسام بيجرّ الأسئلة والحلول).
-- ---------------------------------------------------------------------
create or replace function admin_apply_import(
  p_import_id uuid,
  p_level_id  text,
  p_slug      text,
  p_publish   boolean default false
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_doc   jsonb;
  v_test  uuid;
  v_sec   uuid;
  v_item  uuid;
  s       jsonb;
  it      jsonb;
  n_sec   int := 0;
  n_item  int := 0;
  n_ans   int := 0;
  i_sec   int := 0;
  i_item  int;
begin
  perform admin_guard();
  if p_slug !~ '^[a-z0-9][a-z0-9_-]{0,63}$' then raise exception 'bad_slug'; end if;

  select parsed into v_doc from imports where id = p_import_id;
  if v_doc is null then raise exception 'import_not_parsed'; end if;
  if not exists (select 1 from levels where id = p_level_id) then
    raise exception 'level_not_found';
  end if;

  insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
  values (p_level_id, p_slug, v_doc->>'title', v_doc->>'subtitle',
          coalesce(v_doc->'blocks', '[]'::jsonb),
          (select count(*)::int from jsonb_array_elements(v_doc->'sections') x,
                  jsonb_array_elements(x->'items')),
          p_publish,
          coalesce((select max(sort) + 1 from tests where level_id = p_level_id), 1))
  on conflict (level_id, slug) do update
    set title = excluded.title, subtitle = excluded.subtitle,
        blocks = excluded.blocks, aufgaben = excluded.aufgaben,
        published = excluded.published
  returning id into v_test;

  -- استبدال كامل: الأقسام القديمة بتنشال ومعها أسئلتها وحلولها
  delete from sections where test_id = v_test;

  for s in select * from jsonb_array_elements(coalesce(v_doc->'sections', '[]'::jsonb))
  loop
    insert into sections (test_id, section_id, "group", title, minutes,
                          instruction, format, config, sort)
    values (v_test, s->>'id', s->>'group', s->>'title',
            (s->>'minutes')::int, s->>'instruction', s->>'format',
            -- كل يلي مو عمود بيروح لـconfig
            (s - 'id' - 'group' - 'title' - 'minutes' - 'instruction'
               - 'format' - 'items'),
            i_sec)
    returning id into v_sec;
    n_sec := n_sec + 1; i_sec := i_sec + 1; i_item := 0;

    for it in select * from jsonb_array_elements(coalesce(s->'items', '[]'::jsonb))
    loop
      insert into items (section_id, item_id, text, options, points, meta, sort)
      values (v_sec, it->>'id', it->>'text',
              case when it ? 'options' then it->'options' end,
              coalesce((s->>'pointsPerItem')::numeric, 1),
              nullif(jsonb_strip_nulls(jsonb_build_object(
                'minWords', it->'minWords',
                'points', case when s->>'format' = 'writing' then it->'points' end)),
                '{}'::jsonb),
              i_item)
      returning id into v_item;
      n_item := n_item + 1; i_item := i_item + 1;

      if it ? 'answer' and it->>'answer' is not null then
        insert into item_answers (item_id, answer, explanation)
        values (v_item, it->>'answer', it->>'explain');
        n_ans := n_ans + 1;
      end if;
    end loop;
  end loop;

  update imports set status = 'applied', test_id = v_test where id = p_import_id;

  perform admin_log('import.apply', 'test', v_test::text,
    jsonb_build_object('level', p_level_id, 'slug', p_slug, 'published', p_publish,
                       'sections', n_sec, 'items', n_item, 'answers', n_ans));

  return jsonb_build_object('ok', true, 'test_id', v_test, 'slug', p_slug,
    'sections', n_sec, 'items', n_item, 'answers', n_ans);
end $$;

-- نشر / إخفاء امتحان
create or replace function admin_set_test_published(p_test_id uuid, p_published boolean)
returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  update tests set published = p_published where id = p_test_id;
  if not found then raise exception 'test_not_found'; end if;
  perform admin_log('test.publish', 'test', p_test_id::text,
                    jsonb_build_object('published', p_published));
  return jsonb_build_object('ok', true);
end $$;

create or replace function admin_delete_test(p_test_id uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  perform admin_guard();
  delete from tests where id = p_test_id;
  if not found then raise exception 'test_not_found'; end if;
  perform admin_log('test.delete', 'test', p_test_id::text, '{}');
  return jsonb_build_object('ok', true);
end $$;

-- قائمة المحتوى للوحة
create or replace function admin_content(p_level_id text default null)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  perform admin_guard();
  select jsonb_build_object(
    'levels', (select coalesce(jsonb_agg(jsonb_build_object(
                 'id', id, 'title', title, 'sort', sort, 'published', published,
                 'tests', (select count(*) from tests t where t.level_id = l.id))
               order by sort), '[]') from levels l),
    'tests', (select coalesce(jsonb_agg(jsonb_build_object(
                'id', t.id, 'slug', t.slug, 'title', t.title, 'level_id', t.level_id,
                'published', t.published, 'is_free', t.is_free, 'aufgaben', t.aufgaben,
                'sections', (select count(*) from sections s where s.test_id = t.id),
                'answers', (select count(*) from item_answers ia
                             join items i on i.id = ia.item_id
                             join sections s on s.id = i.section_id
                            where s.test_id = t.id))
              order by t.level_id, t.sort), '[]')
              from tests t
             where p_level_id is null or t.level_id = p_level_id),
    'resources', (select coalesce(jsonb_agg(jsonb_build_object(
                    'id', id, 'title', title, 'level_id', level_id,
                    'published', published, 'sort', sort,
                    'length', length(coalesce(body, '')))
                  order by sort), '[]') from resources),
    'imports', (select coalesce(jsonb_agg(jsonb_build_object(
                  'id', id, 'level_id', level_id, 'status', status,
                  'created_at', created_at, 'test_id', test_id,
                  'title', parsed->>'title',
                  'raw_length', length(coalesce(raw_text, '')))
                order by created_at desc), '[]') from imports)
  ) into r;
  return r;
end $$;

revoke all on function admin_upsert_level(text,text,int,boolean)      from public;
revoke all on function admin_save_resource(uuid,text,text,text,boolean,int) from public;
revoke all on function admin_delete_resource(uuid)                    from public;
revoke all on function admin_save_import(uuid,text,text,jsonb,text)   from public;
revoke all on function admin_delete_import(uuid)                      from public;
revoke all on function admin_apply_import(uuid,text,text,boolean)     from public;
revoke all on function admin_set_test_published(uuid,boolean)         from public;
revoke all on function admin_delete_test(uuid)                        from public;
revoke all on function admin_content(text)                            from public;

grant execute on function admin_upsert_level(text,text,int,boolean)      to authenticated;
grant execute on function admin_save_resource(uuid,text,text,text,boolean,int) to authenticated;
grant execute on function admin_delete_resource(uuid)                    to authenticated;
grant execute on function admin_save_import(uuid,text,text,jsonb,text)   to authenticated;
grant execute on function admin_delete_import(uuid)                      to authenticated;
grant execute on function admin_apply_import(uuid,text,text,boolean)     to authenticated;
grant execute on function admin_set_test_published(uuid,boolean)         to authenticated;
grant execute on function admin_delete_test(uuid)                        to authenticated;
grant execute on function admin_content(text)                            to authenticated;
