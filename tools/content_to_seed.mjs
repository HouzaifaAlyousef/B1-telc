/* من مجلّد content لملف بذور SQL جاهز للّصق.
 *   content/<مؤسسة>/<درجة>/modell-NN/text.txt
 *
 * ★ ما في مولّد SQL تاني هون. هالسكربت بس بيترجم شكل text.txt لشكل
 *   data/*.json، وبعدها بينده tools/export_sql.py — نفس المولّد يلي
 *   بيعمل بذور B1. مولّد تاني معناه صيغتين بتفرقوا بصمت.
 *
 * وبنفس المنطق: التحليل بـadmin/parse.js — نفس المحلّل يلي باللوحة.
 * فاللي بيمرق هون بيمرق باللوحة، والعكس.
 *
 *   node tools/content_to_seed.mjs telc/b2 supabase/seed/b2.sql
 */
import { createRequire } from 'module';
import { readFileSync, readdirSync, existsSync, mkdtempSync, writeFileSync,
         statSync, rmSync } from 'fs';
import { execFileSync } from 'child_process';
import { tmpdir } from 'os';
import path from 'path';

const ROOT = path.resolve(import.meta.dirname, '..');
const require = createRequire(import.meta.url);
const Markup = require(path.join(ROOT, 'admin/parse.js'));

const rel = process.argv[2];                 // مثلاً telc/b2
const out = process.argv[3];
if (!rel || !out) {
  console.error('الاستعمال: node tools/content_to_seed.mjs telc/b2 supabase/seed/b2.sql');
  process.exit(2);
}

const [prov, lvl] = rel.split('/');
const dir = path.join(ROOT, 'content', prov, lvl);
if (!existsSync(dir)) { console.error(`✗ ما في ${dir}`); process.exit(1); }

const modelle = readdirSync(dir)
  .filter(d => d.startsWith('modell-') && statSync(path.join(dir, d)).isDirectory())
  .sort();

const tmp = mkdtempSync(path.join(tmpdir(), 'seed-'));
const index = { modelle: [] };
const docs = [];
let empty = 0;

for (const m of modelle) {
  const f = path.join(dir, m, 'text.txt');
  if (!existsSync(f)) continue;
  const body = readFileSync(f, 'utf8');
  if (!body.trim()) { empty++; continue; }   // قالب فاضي: منتخطّاه بصمت

  const r = Markup.parse(body);
  const fatal = r.warnings.filter(w =>
    /keine Aufgaben|unbekannten Teil|doppelt|Kein Titel|Keine Teile|kein Format|unbekanntes Format/
      .test(w));
  if (fatal.length) {
    console.error(`✗ ${m}: ${fatal[0]}`);
    process.exit(1);                          // ما منبني بذور من نصّ مكسور
  }

  // export_sql.py بياخد المعرّف من d.id، والمجلّد هو المعرّف
  const doc = { id: m, ...r.test };
  writeFileSync(path.join(tmp, `${m}.json`), JSON.stringify(doc, null, 1));
  index.modelle.push({ file: `${m}.json`, aufgaben: r.counts.items });
  docs.push({ id: m, title: r.test.title, n: r.counts.items,
              min: (r.test.blocks || []).reduce((a, b) => a + (b.minutes || 0), 0),
              pts: (r.test.blocks || []).reduce((a, b) => a + (b.maxPoints || 0), 0) });
}

if (!index.modelle.length) { console.error('✗ ما في ولا نموذج معبّى'); process.exit(1); }
writeFileSync(path.join(tmp, 'index.json'), JSON.stringify(index, null, 1));

/* اسم المؤسسة للعرض وعنوان المستوى.
   المجلّد بيعطي المعرّف («oesd»)، بس الطالب لازم يشوف «ÖSD». جدول
   صغير للعرض بس — مين مو فيه بياخد اسم مجلّده، والعنوان فيك تعدّله
   من اللوحة بأي وقت. */
const PROV = {
  telc:   { name: 'telc',   title: (s) => `telc Deutsch ${s}` },
  oesd:   { name: 'ÖSD',    title: (s) => `ÖSD Zertifikat ${s}` },
  goethe: { name: 'Goethe', title: (s) => `Goethe-Zertifikat ${s}` },
  dtz:    { name: 'DTZ',    title: (s) => `Deutsch-Test für Zuwanderer ${s}` },
};

const stufe = lvl.toUpperCase();
const meta = PROV[prov] ?? { name: prov, title: (s) => `${prov} ${s}` };
/* ★ والفهرس كمان: مكتوب بالإيد معناه إنّه بيصير قديم بصمت أوّل ما
   يتغيّر اسم أو عدد. هون بينولّد من نفس القراءة. */
const head = readFileSync(path.join(dir, 'README.md'), 'utf8')
  .split('\n| Ordner')[0].trimEnd();
writeFileSync(path.join(dir, 'README.md'),
  head + '\n\n| Ordner | Name | Aufgaben | Minuten | Punkte |\n|---|---|---|---|---|\n'
  + docs.map(d => `| [${d.id}](${d.id}/) | **${d.title}** | ${d.n} | ${d.min} `
                + `| ${d.pts} |`).join('\n') + '\n');

execFileSync('python3', [
  path.join(ROOT, 'tools/export_sql.py'), tmp, path.resolve(ROOT, out),
  '--level', `${prov}-${lvl}`,
  '--level-title', meta.title(stufe),
  '--provider', meta.name, '--stufe', stufe,
  // ★ اسم ثابت مو المجلّد المؤقّت: بلاه الناتج بيتغيّر كل تشغيل
  //   وفحص الانحراف ما بيقدر يشتغل أصلاً
  '--label', `content/${prov}/${lvl}`,
], { stdio: 'inherit' });
rmSync(tmp, { recursive: true, force: true });
if (empty) console.log(`  (${empty} نموذج فاضي انتخطّى)`);
