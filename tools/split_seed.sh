#!/usr/bin/env bash
# بيقسّم ملف بذور لأجزاء صغيرة تنلصق باليد بـSQL Editor.
#
#   ./tools/split_seed.sh            → b1 (الافتراضي)
#   ./tools/split_seed.sh b2         → b2
# محرّر Supabase بيتعتّر بلصقة ٤٣٦ ك.ب، فالتقسيم بيخلّيها ممكنة.
# كل جزء مستقل: begin/commit خاص فيه، وبيعيد إدراج المستوى، وآمن للإعادة.
set -euo pipefail
cd "$(dirname "$0")/.."
LVL="${1:-b1}"
export LVL
python3 - <<'PY'
import re, pathlib
import os
LVL   = os.environ.get('LVL', 'b1')
src   = pathlib.Path(f'supabase/seed/{LVL}.sql').read_text()
lines = src.splitlines(keepends=True)

starts = [i for i, l in enumerate(lines) if l.startswith('-- ================= modell-')]
head   = ''.join(lines[:starts[0]]).replace('begin;\n', '')
end    = next(i for i, l in enumerate(lines) if l.strip() == 'commit;')
blocks = [''.join(lines[a:b]) for a, b in zip(starts, starts[1:] + [end])]

PARTS = 4
per   = -(-len(blocks) // PARTS)
out   = pathlib.Path('supabase/seed/parts'); out.mkdir(exist_ok=True)
for f in out.glob(f'{LVL}-*.sql'):
    f.unlink()

for n in range(PARTS):
    chunk = blocks[n*per:(n+1)*per]
    if not chunk:
        continue
    names = re.findall(r'^-- =+ (modell-\S+)', ''.join(chunk), re.M)
    p = out / f'{LVL}-{n+1}.sql'
    p.write_text(
        f'-- جزء {n+1} من {PARTS} — نماذج {names[0]}–{names[-1]}\n'
        f'-- مولّد من supabase/seed/{LVL}.sql بـtools/split_seed.sh — لا تعدّله بالإيد\n'
        '-- آمن للإعادة: شغّله مرتين ما بيغيّر شي.\n\n'
        'begin;\n\n' + head + ''.join(chunk) + '\ncommit;\n')
    print(f'  {p}  {p.stat().st_size//1024} KB')
PY
