-- ما بتوفّره Supabase جاهزاً، وبنعيد بناءه محلياً تا تنشغل الترحيلات
-- والاختبارات بلا مشروع حقيقي.
--
-- بيستعمله run.sh وtests/tools.sh. لو تفرّقوا، اختبار بيمرق محلياً
-- وبيفشل على Supabase (أو العكس) — فالمصدر واحد.

create schema if not exists auth;
create table if not exists auth.users (id uuid primary key default gen_random_uuid());
create or replace function auth.uid() returns uuid language sql stable as
  $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;

do $r$ begin
  if not exists (select 1 from pg_roles where rolname='anon')          then create role anon;          end if;
  if not exists (select 1 from pg_roles where rolname='authenticated') then create role authenticated; end if;
end $r$;

-- Supabase Storage: عليه RLS خاص فيه، منفصل تماماً عن سياسات جداولنا.
-- منعيد بناء الجدولين تا تنفحص سياسة 0013 فعلاً.
create schema if not exists storage;
create table if not exists storage.buckets (
  id text primary key, name text, public boolean not null default false);
create table if not exists storage.objects (
  id uuid primary key default gen_random_uuid(),
  bucket_id text references storage.buckets(id), name text);
alter table storage.objects enable row level security;

-- Supabase بيعطي authenticated صلاحيات كتابة كاملة وبيتّكل على السياسات.
-- لو منعطي select بس، اختبار «الطالب ممنوع يرفع» بينجح بسبب نقص GRANT
-- مو بسبب السياسة — يعني بيفحص الشي الغلط.
grant usage  on schema storage to anon, authenticated;
grant select, insert, update, delete on storage.objects  to authenticated;
grant select on storage.objects  to anon;
grant select on storage.buckets  to anon, authenticated;
