#!/usr/bin/env bash
# اختبارات المتصفّح: بتشغّل التطبيق الحقيقي مع API مزيّف مبني على بيانات
# مأخوذة من قاعدة Postgres المحلية. لازم supabase/tests/run.sh تكون انشغلت أول.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "▸ تصدير بيانات الاختبار من قاعدة البيانات"
psql -h /tmp -p "${PGPORT:-5433}" -U postgres -d telc -tAc "
select json_build_object(
  'test', json_build_object('id', t.id, 'slug', t.slug, 'title', t.title,
                            'subtitle', t.subtitle, 'blocks', t.blocks),
  'sections', (select json_agg(json_build_object(
      'id', s.id, 'section_id', s.section_id, 'group', s.\"group\", 'title', s.title,
      'minutes', s.minutes, 'instruction', s.instruction, 'format', s.format,
      'config', s.config, 'sort', s.sort,
      'items', (select json_agg(json_build_object('id', i.id, 'item_id', i.item_id,
                  'text', i.text, 'options', i.options, 'points', i.points,
                  'meta', i.meta, 'sort', i.sort) order by i.sort)
                from items i where i.section_id = s.id))
     order by s.sort)
    from sections s where s.test_id = t.id),
  'answers', (select json_object_agg(i.id, ia.answer)
     from items i join sections s on s.id=i.section_id
     join item_answers ia on ia.item_id=i.id where s.test_id=t.id)
) from tests t where t.slug='modell-01';" > tests/fixture.json

ln -sfn "$(npm root -g)" node_modules
trap 'rm -f node_modules' EXIT

echo "▸ تطبيق الطلاب"
node tests/browser.mjs

echo "▸ لوحة التحكّم"
# اللوحة بدها بيانات اختبار اللوحة بقاعدة البيانات
psql -h /tmp -p "${PGPORT:-5433}" -U postgres -d telc -q \
  -v ON_ERROR_STOP=1 -f supabase/tests/02_admin.sql >/dev/null
node tests/admin.mjs
