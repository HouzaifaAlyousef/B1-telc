#!/usr/bin/env bash
# بيشغّل Postgres محلي، بينفّذ الترحيلات والبذور، وبيشغّل الاختبارات.
# ما بده Supabase ولا إنترنت — بس postgresql مثبّت محلياً.
#
#   ./supabase/tests/run.sh
set -euo pipefail
cd "$(dirname "$0")/../.."

PGBIN=$(dirname "$(ls /usr/lib/postgresql/*/bin/initdb 2>/dev/null | tail -1)")
[ -n "$PGBIN" ] || { echo "لازم postgresql مثبّت (apt-get install postgresql)"; exit 1; }
PGDATA=${PGDATA:-/var/lib/postgresql/telcdata}
PORT=${PGPORT:-5433}
PSQL="psql -h /tmp -p $PORT -U postgres -v ON_ERROR_STOP=1 -q"

if ! psql -h /tmp -p "$PORT" -U postgres -c '' 2>/dev/null; then
  echo "▸ تشغيل Postgres…"
  rm -rf "$PGDATA"; mkdir -p "$PGDATA"; chown postgres:postgres "$PGDATA"
  su postgres -s /bin/bash -c "$PGBIN/initdb -D $PGDATA -A trust -U postgres" >/dev/null
  su postgres -s /bin/bash -c "$PGBIN/pg_ctl -D $PGDATA -o '-p $PORT -k /tmp' -l $PGDATA/log start" >/dev/null
  sleep 2
fi

echo "▸ قاعدة نظيفة"
$PSQL -c "drop database if exists telc;" -c "create database telc;"

# محاكاة ما بتوفّره Supabase جاهزاً: سكيما auth ودالة auth.uid() وأدوار الوصول
$PSQL -d telc <<'SQL'
create schema if not exists auth;
create table auth.users (id uuid primary key default gen_random_uuid());
create or replace function auth.uid() returns uuid language sql stable as
  $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
do $r$ begin
  if not exists (select 1 from pg_roles where rolname='anon')          then create role anon;          end if;
  if not exists (select 1 from pg_roles where rolname='authenticated') then create role authenticated; end if;
end $r$;
SQL

echo "▸ الترحيلات"
for f in supabase/migrations/*.sql; do echo "   $(basename "$f")"; $PSQL -d telc -f "$f"; done

echo "▸ البذور"
python3 tools/export_sql.py data supabase/seed/b1.sql --level b1 >/dev/null
$PSQL -d telc -f supabase/seed/b1.sql

echo "▸ الاختبارات"
for f in supabase/tests/*.sql; do
  psql -h /tmp -p "$PORT" -U postgres -d telc -v ON_ERROR_STOP=1 -f "$f" 2>&1 \
    | grep -E "✓|✗|NOTICE" | sed 's/^psql:[^ ]* //;s/^NOTICE:  //'
done
echo "▸ تمّ"
