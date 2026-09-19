#!/usr/bin/env bash
# بيولّد admin/vorlagen.js من ملفات القوالب النصّية.
#
# القوالب لازم تكون ملفات نص حقيقية: بتنفتح، بتنقرا، بتنعطى للذكاء
# الاصطناعي، وبينختبروا بـtests/import.mjs. وبنفس الوقت لازم تكون جوّا
# اللوحة بلا أي نداء شبكة. فالمصدر هو الـ.txt، وهاد بيولّد منه.
#
# لا تعدّلي admin/vorlagen.js بالإيد — شغّلي هاد بعد أي تعديل على القوالب.
set -euo pipefail
cd "$(dirname "$0")/.."

python3 - <<'PY'
import json, pathlib
out = ['/* مولّد من docs/vorlage/*.txt بـtools/build_vorlagen.sh',
       '   لا تعدّليه بالإيد — عدّلي ملفات النص وأعيدي التوليد. */',
       "'use strict';", '']
for name, src in (('BEISPIEL', 'docs/vorlage/b1-beispiel.txt'),
                  ('LEER',     'docs/vorlage/b1-leer.txt')):
    out.append(f'const VORLAGE_{name} = {json.dumps(pathlib.Path(src).read_text())};')
    out.append('')
pathlib.Path('admin/vorlagen.js').write_text('\n'.join(out))
print('✓ admin/vorlagen.js — ' +
      f'{pathlib.Path("admin/vorlagen.js").stat().st_size // 1024} ك.ب')
PY
