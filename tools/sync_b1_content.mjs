/* data/ ← ملفّات telc B1 الـ١٦ ← content/telc/b1/modell-NN/
   
   ★ ملفّات text.txt تحت content/telc/b1 **مولّدة**، مو مكتوبة بالإيد.
     مصدرها data/*.json، لأن مصدّر SQL (tools/export_sql.py) بايثون
     والمحلّل جافاسكربت — يعني data/ لازم تضل هي المصدر لمسار البذور.
     نفس فكرة vorlagen.js وsetup.sql: مولّد، مع اختبار بيفشل لو فرقوا.

     المستويات الجديدة (A2، ÖSD …) بتنكتب بـcontent/ مباشرةً — ما إلها
     مصدر تاني.

   الاستعمال:
     node tools/sync_b1_content.mjs           بيكتب
     node tools/sync_b1_content.mjs --check    بيفحص بس (للاختبارات)
*/
import { createRequire } from 'module';
import { readFileSync, writeFileSync, mkdirSync, existsSync, copyFileSync } from 'fs';
import path from 'path';

const ROOT = path.resolve(import.meta.dirname, '..');
const require = createRequire(import.meta.url);
const Markup = require(path.join(ROOT, 'admin/parse.js'));

const CHECK = process.argv.includes('--check');
const OUT = path.join(ROOT, 'content/telc/b1');
const index = JSON.parse(readFileSync(path.join(ROOT, 'data/index.json'), 'utf8'));

let wrote = 0, drift = [], noImg = [];

for (const m of index.modelle) {
  const test = JSON.parse(readFileSync(path.join(ROOT, 'data', m.file), 'utf8'));
  const text = Markup.serialize(test);
  const dir = path.join(OUT, m.id);
  const txt = path.join(dir, 'text.txt');

  if (CHECK) {
    if (!existsSync(txt) || readFileSync(txt, 'utf8') !== text) drift.push(m.id);
  } else {
    mkdirSync(path.join(dir, 'img'), { recursive: true });
    mkdirSync(path.join(dir, 'audio'), { recursive: true });
    writeFileSync(txt, text);
    writeFileSync(path.join(dir, 'audio/.gitkeep'), '');
    wrote++;
  }

  /* الصور: النص بيسمّيها، والملف لازم يكون جنبه بنفس الاسم.
     مصدرها Doku/ — هي المكان يلي انستخرجت فيه من الـPDF. */
  for (const s of test.sections) {
    if (!s.bankImage) continue;
    const name = path.basename(s.bankImage);
    const dest = path.join(dir, 'img', name);
    const src = path.join(ROOT, 'Doku', name);
    if (existsSync(dest)) continue;
    if (!existsSync(src)) { noImg.push(`${m.id}/${name}`); continue; }
    if (!CHECK) { copyFileSync(src, dest); }
  }
}

if (CHECK) {
  if (drift.length) {
    console.error(`✗ content/telc/b1 مو مطابق لـdata/: ${drift.join(', ')}`);
    console.error('  شغّل: node tools/sync_b1_content.mjs');
    process.exit(1);
  }
  console.log(`✓ content/telc/b1 مطابق لـdata/ (${index.modelle.length} نموذج)`);
} else {
  console.log(`✓ ${wrote} نموذج انكتب بـcontent/telc/b1/`);
  if (noImg.length) console.log(`  · صور ما انلقيت بـDoku/: ${noImg.join(', ')}`);
}
