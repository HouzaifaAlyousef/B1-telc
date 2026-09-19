-- =====================================================================
-- 0017_provider — المؤسسة الممتحِنة كبُعد تاني
--
-- «A1» لحالها مو منتج: في A1 من telc، وA1 من Goethe، وA1 من ÖSD،
-- وكل وحدة امتحان مختلف بهيكل مختلف. الطالب بيشتري «telc A1»، مو «A1».
--
-- الحل بلا ما ينهدّ شي: بقاعدة البيانات، «المستوى» (levels) هو أصلاً
-- وحدة البيع — عليه معلّق الاشتراك والكود وكل سياسات RLS. فبدل ما
-- نضيف بُعد جنبه ونعقّد كل نداء صلاحية، منخلّي صف المستوى الواحد =
-- (مؤسسة، درجة). عمودين وصفيين، وولا حرف بينتغيّر بمنطق الحماية.
--
--   b1         provider='telc'    stufe='B1'     ← الموجود، ما بينلمس
--   goethe-b1  provider='Goethe'  stufe='B1'     ← منتج تاني تماماً
--
-- المؤسسة نص حرّ بالقصد: كل سنة بتطلع شهادة جديدة، وقائمة مقفلة
-- بقاعدة البيانات معناها ترحيل جديد كل مرة.
-- =====================================================================

alter table levels add column if not exists provider text;
alter table levels add column if not exists stufe    text;

comment on column levels.provider is 'telc, Goethe, ÖSD … — نص حرّ';
comment on column levels.stufe    is 'A1, A2, B1 … — درجة الإطار الأوروبي';

-- ---------------------------------------------------------------------
-- أدوات صغيرة، قبل أي دالة بتستعملها
-- ---------------------------------------------------------------------

-- المعرّف لازم يكون ASCII: Ö بتصير oe مو بتنشال، وإلا «ÖSD» و«SD»
-- بيصيروا نفس المعرّف
create or replace function slug_de(p text)
returns text language sql immutable as $$
  select regexp_replace(
    replace(replace(replace(replace(lower(coalesce(p, '')),
      'ä','ae'), 'ö','oe'), 'ü','ue'), 'ß','ss'),
    '[^a-z0-9]+', '', 'g');
$$;

-- ترتيب الدرجات. الترتيب النصّي بيعطي نفس النتيجة لـA1..C2، بس بينكسر
-- أول ما تجي درجة مثل «DTZ» أو «Start 1» — هدول بيروحوا للآخر.
create or replace function stufe_rank(p text)
returns int language sql immutable as $$
  select coalesce(array_position(
    array['A1','A2','B1','B2','C1','C2'], upper(trim(coalesce(p, '')))), 99);
$$;

grant execute on function slug_de(text), stufe_rank(text) to authenticated, anon;

-- ---------------------------------------------------------------------
-- تعبئة الموجود: بنستنتج من العنوان والمعرّف
--
-- المحتوى الحالي كله telc، بس ما منفترض — منقرا العنوان. يلي ما
-- بينعرف بيضل فاضي، واللوحة بتطالب فيه عند أول تعديل.
-- ---------------------------------------------------------------------
update levels set
  stufe = coalesce(stufe,
            upper((regexp_match(id || ' ' || title, '\m([ABC][12])\M', 'i'))[1])),
  provider = coalesce(provider, case
    when title ilike '%telc%'                        then 'telc'
    when title ilike '%goethe%'                      then 'Goethe'
    when title ilike '%ösd%' or title ilike '%oesd%' then 'ÖSD'
    when title ilike '%testdaf%'                     then 'TestDaF'
    when title ilike '%dtz%'                         then 'DTZ'
  end)
 where provider is null or stufe is null;

-- نفس (مؤسسة، درجة) مرتين = منتجين ما بينفرقوا باللوحة. الفهرس جزئي تا
-- يضل مسموح صف قديم لسا ما انعبّى.
create unique index if not exists levels_provider_stufe_idx
  on levels (provider, stufe) where provider is not null and stufe is not null;

-- ---------------------------------------------------------------------
-- الإنشاء والتعديل
--
-- النسخة القديمة (٤ معاملات) لازم تنشال: وجودها مع الجديدة بيخلّي أي
-- نداء بـ٤ وسائط ملتبس، لأن الخامس والسادس عندهن قيم افتراضية.
-- ---------------------------------------------------------------------
drop function if exists admin_upsert_level(text, text, int, boolean);

create or replace function admin_upsert_level(
  p_id        text,
  p_title     text,
  p_sort      int     default 0,
  p_published boolean default false,
  p_provider  text    default null,
  p_stufe     text    default null
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  v_prov  text := nullif(trim(coalesce(p_provider, '')), '');
  v_stufe text := nullif(upper(trim(coalesce(p_stufe, ''))), '');
  v_id    text := nullif(trim(coalesce(p_id, '')), '');
  v_title text;
begin
  perform admin_guard();

  -- معرّف مولّد: goethe-b1، oesd-a2 … بيوفّر تفكير وبيخلّي الأسماء منتظمة
  if v_id is null then
    if v_prov is null or v_stufe is null then
      raise exception 'provider_and_stufe_required';
    end if;
    v_id := slug_de(v_prov) || '-' || lower(v_stufe);
  end if;

  if v_id !~ '^[a-z][a-z0-9_-]{0,31}$' then raise exception 'bad_level_id'; end if;

  v_title := nullif(trim(coalesce(p_title, '')), '');
  if v_title is null then
    v_title := trim(coalesce(v_prov, '') || ' ' || coalesce(v_stufe, v_id));
  end if;

  insert into levels (id, title, sort, published, provider, stufe)
  values (v_id, v_title, p_sort, p_published, v_prov, v_stufe)
  on conflict (id) do update
    set title = excluded.title, sort = excluded.sort,
        published = excluded.published,
        -- null ما بيمحي قيمة موجودة: نداء ما بيمرّر الأعمدة الجديدة ما
        -- لازم يفرّغها
        provider = coalesce(excluded.provider, levels.provider),
        stufe    = coalesce(excluded.stufe,    levels.stufe);

  perform admin_log('level.upsert', 'level', v_id,
    jsonb_build_object('title', v_title, 'provider', v_prov,
                       'stufe', v_stufe, 'published', p_published));
  return jsonb_build_object('ok', true, 'id', v_id, 'title', v_title,
                            'provider', v_prov, 'stufe', v_stufe);
end $$;

revoke all on function admin_upsert_level(text,text,int,boolean,text,text) from public;
grant execute on function admin_upsert_level(text,text,int,boolean,text,text)
  to authenticated;

-- ---------------------------------------------------------------------
-- اللوحة لازم تشوف المؤسسة والدرجة، وترتيبها لازم يتبعهن
-- ---------------------------------------------------------------------
create or replace function admin_content(p_level_id text default null)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  perform admin_guard();
  select jsonb_build_object(
    'levels', (select coalesce(jsonb_agg(jsonb_build_object(
                 'id', id, 'title', title, 'sort', sort, 'published', published,
                 'provider', provider, 'stufe', stufe,
                 'tests', (select count(*) from tests t where t.level_id = l.id))
               order by coalesce(provider, 'zz'), stufe_rank(stufe), stufe, sort),
               '[]') from levels l),
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
                order by created_at desc), '[]')
                from (select * from imports order by created_at desc limit 30) q)
  ) into r;
  return r;
end $$;

revoke all on function admin_content(text) from public;
grant execute on function admin_content(text) to authenticated;

-- شاشة البداية كمان: المؤسسة والدرجة، ومرتّبة فيهن
create or replace function admin_overview() returns jsonb
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  perform admin_guard();
  select jsonb_build_object(
    'users',           (select count(*) from profiles where not is_admin),
    'active_subs',     (select count(*) from subscriptions
                         where status = 'active' and current_period_end > now()),
    'expiring_7d',     (select count(*) from subscriptions
                         where status = 'active'
                           and current_period_end between now() and now() + interval '7 days'),
    'expired',         (select count(*) from subscriptions
                         where status <> 'active' or current_period_end <= now()),
    'codes_unused',    (select count(*) from access_codes
                         where redeemed_at is null and revoked_at is null),
    'attempts_7d',     (select count(*) from attempts
                         where submitted_at > now() - interval '7 days'),
    'tests_published', (select count(*) from tests where published),
    'levels',          (select coalesce(jsonb_agg(jsonb_build_object(
                                 'id', id, 'title', title, 'published', published,
                                 'provider', provider, 'stufe', stufe)
                               order by coalesce(provider, 'zz'),
                                        stufe_rank(stufe), stufe, sort), '[]')
                        from levels)
  ) into r;
  return r;
end $$;
