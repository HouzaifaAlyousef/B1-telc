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
    'Guter Brief.', brief, 'claude-opus-5');
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

  raise notice '';
  raise notice '  كل اختبارات التعبير الكتابي نجحت ✓';
end $$;

drop function t_check(text, boolean);
