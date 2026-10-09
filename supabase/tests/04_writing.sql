-- تصحيح التعبير الكتابي: الصلاحية، الحصّة، وحساب النقاط بالسيرفر
\set ON_ERROR_STOP on
\pset pager off

delete from writing_feedback;
delete from admin_audit_log; delete from mistakes; delete from attempts;
delete from imports; delete from resources;
delete from tests where level_id <> 'b1'; delete from levels where id <> 'b1';
delete from devices; delete from subscriptions; delete from access_codes;
delete from profiles; delete from auth.users;

insert into auth.users (id) values ('dddddddd-0000-0000-0000-000000000004');
insert into profiles (id) values ('dddddddd-0000-0000-0000-000000000004');
insert into subscriptions (user_id, levels, current_period_end, writing_quota)
values ('dddddddd-0000-0000-0000-000000000004', array['b1'], now() + interval '30 days', 2);

create or replace function t_check(label text, cond boolean)
returns void language plpgsql as $$
begin
  if cond then raise notice '  ✓ %', label;
  else raise exception '  ✗ فشل: %', label; end if;
end $$;

do $$
declare
  u    uuid := 'dddddddd-0000-0000-0000-000000000004';
  tid  uuid; sid uuid; iid uuid;
  aid  uuid; st jsonb; fin jsonb; declare_fid uuid;
  tid2 uuid; sid2 uuid; iid2 uuid; aid2 uuid;
  sid_form uuid; iid_form uuid;
  brief text := 'Liebe Anna, danke für deinen Brief. Ich möchte gern nach '
             || 'Deutschland kommen, weil ich die Sprache lernen will. Ich '
             || 'fliege am besten mit dem Flugzeug. Wir können zusammen die '
             || 'Stadt besuchen. Ich bringe meine Schwester mit. Viele Grüße';
begin
  select t.id, s.id into tid, sid
    from tests t join sections s on s.test_id = t.id
   where t.slug = 'modell-01' and s.format = 'writing';
  select i.id into iid from items i where i.section_id = sid limit 1;

  ---------------------------------------------------------------- ١
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', u::text, true);

  insert into attempts (user_id, test_id, block_id, answers, submitted_at)
  values (u, tid, 'block-sa', jsonb_build_object(iid::text, brief), now())
  returning id into aid;

  st := writing_start(aid);
  perform t_check('بدء التصحيح نجح', (st->>'ok')::boolean);
  perform t_check('النص وصل كامل', st->>'text' = brief);
  perform t_check(format('٣ معايير و٤ درجات ومعامل %s', st->>'factor'),
                  jsonb_array_length(st->'criteria') = 3
                  and jsonb_array_length(st->'grades') = 4
                  and (st->>'factor')::numeric = 3);
  perform t_check('النقاط المطلوبة وصلت', jsonb_array_length(st->'points') = 4);
  perform t_check('الحد الأدنى للكلمات وصل', (st->>'min_words')::int = 100);
  perform t_check('صفّ معلّق انعمل',
                  (select status from writing_feedback where id = (st->>'feedback_id')::uuid) = 'pending');

  ---------------------------------------------------------------- ٢ حساب النقاط
  reset role;   -- writing_finish لـservice_role بس
  fin := writing_finish((st->>'feedback_id')::uuid,
    '[{"criterion":"Aufgabenbewältigung","key":"A","why":"alle vier Punkte"},
      {"criterion":"Kommunikative Gestaltung","key":"B","why":"Anrede fehlt"},
      {"criterion":"Formale Richtigkeit","key":"A","why":"kaum Fehler"}]'::jsonb,
    '[{"type":"Grammatik","original":"Ich fliege","correction":"Ich fliege am liebsten","why":"x"}]'::jsonb,
    'Guter Brief.', brief, 'gemini-flash-latest');
  -- A=5, B=3, A=5 → 13 × معامل ٣ = 39
  perform t_check(format('النقاط: (5+3+5) × 3 = 39، طلعت %s', fin->>'points'),
                  (fin->>'points')::numeric = 39);
  perform t_check('العلامة القصوى ٤٥', (fin->>'max_points')::numeric = 45);
  perform t_check('الحالة صارت done',
                  (select status from writing_feedback where id = (st->>'feedback_id')::uuid) = 'done');

  ---------------------------------------------------------------- ٣
  -- ★ النموذج ما بيقدر يعطي علامة: حروف بس، والحساب من grades المخزّن
  declare_fid := gen_random_uuid();
  insert into writing_feedback (id, attempt_id, user_id, section_id, text, max_points)
  values (declare_fid, aid, u, sid, brief, 45);
  fin := writing_finish(declare_fid,
    '[{"criterion":"X","key":"Z","why":"erfunden"}]'::jsonb,
    '[]'::jsonb, 's', 't', 'm');
  perform t_check(format('★ حرف مو موجود بجدول الدرجات = صفر (طلع %s)', fin->>'points'),
                  (fin->>'points')::numeric = 0);

  ---------------------------------------------------------------- ٤ الحصّة
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', u::text, true);
  st := writing_start(aid);
  perform t_check(format('الحصّة ٢ استُهلكت ← رفض (%s)', st->>'error'),
                  (st->>'ok')::boolean is false and st->>'error' = 'quota_exceeded');

  ---------------------------------------------------------------- ٥
  reset role;
  update subscriptions set writing_quota = 10 where user_id = u;
  delete from writing_feedback where user_id = u;
  update subscriptions set status = 'revoked' where user_id = u;
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', u::text, true);
  st := writing_start(aid);
  perform t_check('اشتراك ملغى ← ممنوع', st->>'error' = 'not_entitled');

  ---------------------------------------------------------------- ٦
  reset role;
  update subscriptions set status = 'active' where user_id = u;
  update attempts set answers = '{}'::jsonb where id = aid;
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', u::text, true);
  st := writing_start(aid);
  perform t_check('نص فاضي ← رفض', st->>'error' = 'empty_text');

  ---------------------------------------------------------------- ٧
  -- ★ الانحدار الحقيقي: مستوى غير B1. بس telc B1 عنده criteria/grades
  --   مكتوبين بالمحتوى — ÖSD وGoethe وB2 وDTZ كلهن بلا. قبل 0031:
  --   writing_finish بيلاقي جدول درجات فاضي، وcoalesce(null,0) بيخلّي
  --   النتيجة صفر مهما كتب الطالب. بلا خطأ، بلا تحذير. وفوقها، بلوك
  --   الكتابة بـÖSD فيه قسمين (استمارة + رسالة) و`limit 1` بلا ترتيب
  --   كان ممكن يصحّح الاستمارة.
  reset role;
  insert into levels (id, title, provider, stufe, sort, published)
  values ('a1x', 'ÖSD Zertifikat A1', 'ÖSD', 'A1', 9, true);
  insert into tests (level_id, slug, title, blocks, published)
  values ('a1x', 'modell-01', 'ÖSD-Probe',
          '[{"id":"block-sa","parts":["sa1","sa2"]}]'::jsonb, true)
  returning id into tid2;
  -- الاستمارة: أول بالترتيب، بلا حدّ أدنى كلمات
  insert into sections (test_id, section_id, title, format, config, sort)
  values (tid2, 'sa1', 'Formular', 'writing', '{}'::jsonb, 0)
  returning id into sid_form;
  insert into items (section_id, item_id, text, meta, sort)
  values (sid_form, '1', 'Formular ausfüllen', '{}'::jsonb, 0)
  returning id into iid_form;
  -- الرسالة: تانية بالترتيب، وإلها حدّ أدنى — هي المقصودة
  insert into sections (test_id, section_id, title, format, config, sort)
  values (tid2, 'sa2', 'Brief', 'writing', '{"maxPoints":20}'::jsonb, 1)
  returning id into sid2;
  insert into items (section_id, item_id, text, meta, sort)
  values (sid2, '2', 'Schreiben Sie eine E-Mail.',
          '{"minWords":30,"points":["Grund","Termin","Frage"]}'::jsonb, 0)
  returning id into iid2;

  update subscriptions set levels = array['b1','a1x'], writing_quota = 10
   where user_id = u;
  delete from writing_feedback where user_id = u;

  set local role authenticated;
  perform set_config('request.jwt.claim.sub', u::text, true);
  insert into attempts (user_id, test_id, block_id, answers, submitted_at)
  values (u, tid2, 'block-sa',
          jsonb_build_object(iid_form::text, 'Mustermann',
                             iid2::text, brief), now())
  returning id into aid2;

  st := writing_start(aid2);
  perform t_check('مستوى غير B1: البداية نجحت', (st->>'ok')::boolean);
  perform t_check(format('★ اختار الرسالة مو الاستمارة (%s)', st->>'min_words'),
                  (select section_id from writing_feedback
                    where id = (st->>'feedback_id')::uuid) = sid2
                  and (st->>'min_words')::int = 30);
  perform t_check(format('★ معيار افتراضي انوجد: %s معايير و%s درجات',
                         jsonb_array_length(st->'criteria'),
                         jsonb_array_length(st->'grades')),
                  jsonb_array_length(st->'criteria') = 3
                  and jsonb_array_length(st->'grades') = 4);
  perform t_check('ومعلّم إنّه عام مو رسمي', (st->>'generic_rubric')::boolean);
  perform t_check(format('★ اسم الامتحان من قاعدة البيانات: %s', st->>'exam'),
                  st->>'exam' = 'ÖSD A1');
  perform t_check(format('العلامة القصوى من القسم (%s)', st->>'max_points'),
                  (st->>'max_points')::numeric = 20);

  reset role;
  -- A=6.67 · B=4.00 · C=2.00  →  12.67 → 12.7
  fin := writing_finish((st->>'feedback_id')::uuid,
    '[{"criterion":"Aufgabenerfüllung","key":"A","why":"x"},
      {"criterion":"Kommunikative Gestaltung","key":"B","why":"y"},
      {"criterion":"Formale Richtigkeit","key":"C","why":"z"}]'::jsonb,
    '[]'::jsonb, 's', brief, 'gemini');
  perform t_check(format('★★ مستوى بلا معايير صار بياخد نقاط مو صفر: %s/20',
                         fin->>'points'),
                  (fin->>'points')::numeric = 12.7);

  -- تلات A = 20.01 — محسوبة بتزيد عن السقف، لازم تنقصّ على ٢٠
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', u::text, true);
  st := writing_start(aid2);
  reset role;
  fin := writing_finish((st->>'feedback_id')::uuid,
    '[{"criterion":"Aufgabenerfüllung","key":"A","why":"x"},
      {"criterion":"Kommunikative Gestaltung","key":"A","why":"y"},
      {"criterion":"Formale Richtigkeit","key":"A","why":"z"}]'::jsonb,
    '[]'::jsonb, 's', brief, 'gemini');
  perform t_check(format('★ التقريب ما بيطلّع فوق السقف (%s ≤ 20)', fin->>'points'),
                  (fin->>'points')::numeric = 20);

  ---------------------------------------------------------------- ٨
  -- ★ الحصّة بتنحرق بالسيرفر: نصّ من كم كلمة (تلفون-نوتيتس) لازم
  --   ينرفض قبل ما ينبعت لـGemini، مو بعد ما يتدفع تمنه
  reset role;
  update attempts set answers = jsonb_build_object(iid2::text, 'Herr Müller, Dienstag 14 Uhr')
   where id = aid2;
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', u::text, true);
  st := writing_start(aid2);
  perform t_check(format('★ نصّ من %s كلمات ← رفض قبل النموذج (%s)',
                         st->>'words', st->>'error'),
                  st->>'error' = 'too_short');
  perform t_check('وما انحرقت حصّة',
                  (select count(*) from writing_feedback
                    where user_id = u and status = 'pending') = 0);

  ---------------------------------------------------------------- ٩
  -- بلوك مو بلوك كتابة: لازم يرفض بهدوء، مو ينهار
  set local role authenticated;
  perform set_config('request.jwt.claim.sub', u::text, true);
  insert into attempts (user_id, test_id, block_id, answers, submitted_at)
  values (u, tid2, 'block-lv', '{}'::jsonb, now()) returning id into aid2;
  st := writing_start(aid2);
  perform t_check(format('بلوك بلا كتابة ← رفض نظيف (%s)', st->>'error'),
                  (st->>'ok')::boolean is false
                  and st->>'error' = 'not_a_writing_block');

  raise notice '';
  raise notice '  كل اختبارات التعبير الكتابي نجحت ✓';
end $$;

drop function t_check(text, boolean);
