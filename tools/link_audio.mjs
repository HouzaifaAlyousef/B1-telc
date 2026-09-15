/* يربط تسجيلاتك المحمّلة بأقسام الاستماع — نسخ + كتابة `Hörtext:` بضربة.
 *
 *   node tools/link_audio.mjs ~/downloads/telc-b1 telc/b1 --dry-run
 *   node tools/link_audio.mjs ~/downloads/telc-b1 telc/b1
 *
 * بيتوقّع مجلّد لكل نموذج، اسمه بيبلّش بـmodell-NN (الباقي ما بيهمّ):
 *   modell-01_PETRA/hv1_Arbeitsplatz_fuer_ihren_Vater.mp3
 *   modell-08_FIRMENORGANIGRAMM/..._teil1.mp3
 *   modell-01_RAFAELA/ZA1_MS_A1_060917.mp3
 *
 * ★ الاسم بالدلو لازم يكون فريد **بكل المستويات**: دلو الصوت مسطّح متل
 *   دلو الصور، و«modell-01-hv1.mp3» موجود بتلات مستويات. فالاسم الناتج
 *   بيحمل مستواه: telc-b1-m01-hv1.mp3
 *
 * ★ telc/b1 مصدره data/*.json مو content/ — الأداة بتكتب هونيك، وبتقلّك
 *   تشغّل sync_b1_content بعدها. غيره بينكتب بـtext.txt مباشرةً.
 */
import { readdirSync, existsSync, mkdirSync, copyFileSync, statSync } from 'fs';
import { setAudio as writeLink } from './lib/audio_link.mjs';
import { spawnSync } from 'child_process';
import path from 'path';

const ROOT = path.resolve(import.meta.dirname, '..');
const [src, ...rest] = process.argv.slice(2);
const dry   = rest.includes('--dry-run');
const plays = Number((rest.find(x => x.startsWith('--plays=')) || '').split('=')[1]) || 2;
let rel = rest.find(x => x.includes('/') && !x.startsWith('-'));

if (!src) {
  console.error('الاستعمال:\n'
    + '  node tools/link_audio.mjs <مجلّد التحميل الكبير> [--plays=2] [--dry-run]\n'
    + '  node tools/link_audio.mjs <مجلّد مستوى واحد> <مؤسسة>/<درجة>');
  process.exit(2);
}
if (!existsSync(src)) { console.error(`✗ ما في ${src}`); process.exit(1); }

/* ★ بلا تحديد مستوى: منمشي على مجلّدات التحميل ومنستنتجه من اسم كل
   وحدة. «01_oesd_a1» و«03_telc_b2_beruf» ← oesd/a1 وtelc/b2: منشيل
   الترقيم من الأوّل، وأوّل كلمتين هنّ المؤسسة والدرجة، والباقي وصف.
   هيك أمر واحد بيمشّي كل شي، وما بتغلط بالمسار. */
const levelOf = (dir) => {
  const parts = dir.replace(/^\d+[_-]/, '').split(/[_-]/).filter(Boolean);
  if (parts.length < 2) return null;
  const guess = `${parts[0]}/${parts[1]}`;
  return existsSync(path.join(ROOT, 'content', parts[0], parts[1])) ? guess : null;
};

if (!rel) {
  const subs = readdirSync(src)
    .filter(d => statSync(path.join(src, d)).isDirectory())
    .map(d => [d, levelOf(d)]);
  const ok = subs.filter(([, l]) => l);
  if (!ok.length) {
    console.error('✗ ما عرفت المستوى من أسماء المجلّدات. حدّده صراحةً:\n'
      + '   node tools/link_audio.mjs <مجلّد> <مؤسسة>/<درجة>');
    subs.forEach(([d]) => console.error(`   · ${d}`));
    process.exit(1);
  }
  let code = 0;
  for (const [d, l] of ok) {
    console.log(`\n━━ ${d}  →  ${l}`);
    const r = spawnSync(process.execPath,
      [import.meta.filename, path.join(src, d), l, ...rest],
      { stdio: 'inherit' });
    code ||= r.status ?? 0;
  }
  subs.filter(([, l]) => !l).forEach(([d]) =>
    console.log(`\n· ${d}: ما عرفت أي مستوى — شغّله لحاله مع <مؤسسة>/<درجة>`));
  process.exit(code);
}

const [prov, lvl] = rel.split('/');
const cdir = path.join(ROOT, 'content', prov, lvl);
if (!existsSync(cdir)) { console.error(`✗ ما في ${cdir}`); process.exit(1); }

/* أي ملف لأي قسم. الترتيب مهمّ: «komplett» قبل «hv1» تا ما يلقفه hv1. */
const RULES = [
  [/hoeren[_-]?komplett|hoeren\.mp3$|_hoeren_simulation/i, '*'],   // الامتحان كله
  [/hoeren[_-]?schreiben/i, 'hvs'],
  [/(^|[^a-z])hv1|teil[_-]?1|_A1_/i, 'hv1'],
  [/(^|[^a-z])hv2|teil[_-]?2|_A2_/i, 'hv2'],
  [/(^|[^a-z])hv3|teil[_-]?3|_A3_/i, 'hv3'],
  [/(^|[^a-z])hv4|teil[_-]?4|_A4_/i, 'hv4'],
];
const sectionOf = (name) => (RULES.find(([re]) => re.test(name)) || [])[1] ?? null;

const models = readdirSync(cdir)
  .filter(d => d.startsWith('modell-') && statSync(path.join(cdir, d)).isDirectory())
  .sort();

let linked = 0, whole = [], missing = [], extra = [];

for (const m of models) {
  const nn  = m.slice('modell-'.length);
  const box = readdirSync(src).find(d =>
    statSync(path.join(src, d)).isDirectory() && d.startsWith(`modell-${nn}`));
  if (!box) { missing.push(m); continue; }

  const files = readdirSync(path.join(src, box))
    .filter(f => /\.(mp3|m4a|ogg|wav)$/i.test(f));
  const pick = {};
  for (const f of files) {
    const sec = sectionOf(f);
    if (sec === '*') { whole.push(`${box}/${f}`); continue; }
    if (!sec) { extra.push(`${box}/${f}`); continue; }
    pick[sec] ??= f;                       // أول تطابق بيفوز
  }
  if (!Object.keys(pick).length) continue;

  const adir = path.join(cdir, m, 'audio');
  for (const [sec, f] of Object.entries(pick)) {
    const ext  = path.extname(f).toLowerCase();
    const name = `${prov}-${lvl}-m${nn}-${sec}${ext}`;
    console.log(`  ${m}/${sec.padEnd(3)} ← ${f}`);
    console.log(`      → audio/${name}`);
    if (!dry) {
      mkdirSync(adir, { recursive: true });
      copyFileSync(path.join(src, box, f), path.join(adir, name));
      writeLink(ROOT, prov, lvl, m, sec, name, plays);
    }
    linked++;
  }
}


console.log(`\n${linked} قسم انربط${dry ? ' (تجربة — ما انحفظ شي)' : ''}`);
if (whole.length)   console.log(`\n⚠ ${whole.length} ملف للامتحان كامل — ما بينقسم لأقسام، فانتخطّى:\n   ${whole.slice(0,4).join('\n   ')}${whole.length>4?'\n   …':''}`);
if (missing.length) console.log(`\n⚠ ${missing.length} نموذج ما لقيتله مجلّد: ${missing.join(', ')}`);
if (extra.length)   console.log(`\n· ${extra.length} ملف ما عرفت لأي قسم: ${extra.slice(0,3).join(', ')}${extra.length>3?' …':''}`);
if (!dry && linked) {
  console.log('\n▸ وبعدها:');
  if (prov === 'telc' && lvl === 'b1')
    console.log('   node tools/sync_b1_content.mjs && python3 tools/export_sql.py data supabase/seed/b1.sql --level b1');
  else
    console.log(`   node tools/content_to_seed.mjs ${rel} supabase/seed/…sql`);
  console.log('   python3 tools/upload_audio.py content');
}
