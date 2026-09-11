-- المؤسسة كبُعد تاني: telc·B1 وGoethe·B1 منتجين منفصلين تماماً
\set ON_ERROR_STOP on
\pset pager off

delete from mistakes; delete from attempts; delete from code_redemptions;
delete from devices; delete from subscriptions; delete from access_codes;
delete from tests where level_id like 'goethe%' or level_id like 'oesd%';
delete from levels where id like 'goethe%' or id like 'oesd%';

insert into auth.users (id) values
  ('ffffffff-0000-0000-0000-000000000001'),   -- أدمن
  ('ffffffff-0000-0000-0000-000000000002')    -- طالب telc·B1
on conflict do nothing;
insert into profiles (id, is_admin) values
  ('ffffffff-0000-0000-0000-000000000001', true),
  ('ffffffff-0000-0000-0000-000000000002', false)
on conflict (id) do update set is_admin = excluded.is_admin;

create or replace function t_check(label text, cond boolean)
returns void language plpgsql as $$
begin
  if cond then raise notice '  ✓ %', label;
  else raise exception '  ✗ فشل: %', label;
  end if;
end $$;

do $$
declare
  adm   uuid := 'ffffffff-0000-0000-0000-000000000001';
  stud  uuid := 'ffffffff-0000-0000-0000-000000000002';
  r     jsonb;
  codes text[];
  n     int;
  n_b1  int;                  -- العدد الحقيقي، قبل تقمّص الطالب
begin
  select count(*) into n_b1 from tests where level_id = 'b1' ;
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', adm::text, true);

  ---------------------------------------------------------------- التعبئة
  perform t_check('المستوى الموجود انتعبّى من البذور (telc · B1)',
    (select provider = 'telc' and stufe = 'B1' from levels where id = 'b1'));

  ------------------------------------------------------- المعرّف المولّد
  r := admin_upsert_level(null, null, 0, true, 'Goethe', 'b1');
  perform t_check(format('المعرّف انولّد (%s) والعنوان (%s)',
                         r->>'id', r->>'title'),
                  r->>'id' = 'goethe-b1' and r->>'title' = 'Goethe B1');

  r := admin_upsert_level(null, null, 0, true, 'ÖSD', 'A2');
  perform t_check(format('★ الأحرف الألمانية بتصير ASCII (%s)', r->>'id'),
                  r->>'id' = 'oesd-a2');

  perform t_check('الدرجة بتنكتب كبيرة دايماً',
                  (select stufe = 'B1' from levels where id = 'goethe-b1'));

  ------------------------------------------------- مؤسسة+درجة ما بتتكرّر
  begin
    insert into levels (id, title, provider, stufe)
    values ('goethe-b1-2', 'x', 'Goethe', 'B1');
    perform t_check('★ نفس (مؤسسة، درجة) مرتين مرفوض', false);
  exception when unique_violation then
    perform t_check('★ نفس (مؤسسة، درجة) مرتين مرفوض', true);
  end;

  ------------------------------------------------- مؤسسة بلا درجة مرفوضة
  begin
    perform admin_upsert_level(null, null, 0, false, 'Goethe', null);
    perform t_check('مؤسسة بلا درجة مرفوضة', false);
  exception when others then
    perform t_check('مؤسسة بلا درجة مرفوضة',
                    sqlerrm = 'provider_and_stufe_required');
  end;

  ------------------------------------------ النداء القديم ما بيمحي شي
  -- زرّ «النشر» باللوحة بينده بالعنوان والترتيب بس. لو مرّر null
  -- للمؤسسة وانمحت، بتضيع تصنيفة المستوى بضغطة زرّ.
  perform admin_upsert_level('goethe-b1', 'Goethe B1', 5, false, null, null);
  perform t_check('★ نداء بلا مؤسسة ما بيمحي الموجودة',
    (select provider = 'Goethe' and stufe = 'B1' and not published
       from levels where id = 'goethe-b1'));

  ------------------------------------------------- ★ الفصل بين المنتجات
  perform admin_upsert_level('goethe-b1', 'Goethe B1', 0, true, 'Goethe', 'B1');
  insert into tests (level_id, slug, title, blocks, aufgaben, published, sort)
  values ('goethe-b1', 'goethe-modell-01', 'Goethe Modell 1',
          '[]'::jsonb, 0, true, 1);

  select array_agg(c) into codes
    from admin_create_codes(1, array['b1'], 30, 2, 'telc B1', 2) c;
  perform set_config('request.jwt.claim.sub', stud::text, true);
  perform redeem_code(codes[1], 'dev-1');

  select count(*) into n from tests where level_id = 'b1';
  perform t_check(format('مشترك telc·B1 بيشوف امتحاناته (%s من %s)', n, n_b1),
                  n = n_b1 and n_b1 > 0);
  select count(*) into n from tests where level_id = 'goethe-b1';
  perform t_check('★ وما بيشوف ولا امتحان Goethe·B1', n = 0);

  perform t_check('★ ولا has_test_access بيعطيه صلاحية عليه',
                  not has_test_access(stud, 'goethe-b1', 'goethe-modell-01'));

  --------------------------------------------------------- الترتيب
  perform set_config('request.jwt.claim.sub', adm::text, true);
  r := admin_content(null);
  perform t_check('اللوحة بترتّب بالمؤسسة ثم الدرجة',
    (r->'levels'->0->>'provider') <= coalesce(r->'levels'->1->>'provider', 'zz'));
  perform t_check('وبترجّع المؤسسة والدرجة',
    r->'levels'->0 ? 'provider' and r->'levels'->0 ? 'stufe');

  perform t_check('ترتيب الدرجات صح',
    stufe_rank('A1') < stufe_rank('B1')
    and stufe_rank('B1') < stufe_rank('C2')
    and stufe_rank('DTZ') = 99);

  raise notice '';
  raise notice '  كل اختبارات المؤسسة نجحت ✓';
end $$;

drop function t_check(text, boolean);
