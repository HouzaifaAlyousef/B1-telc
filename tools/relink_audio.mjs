/* بيرجّع ربط التسجيلات من **قائمة الدلو** — بلا ما يلزم الملفّات المحلية.
 *
 *   export SUPABASE_URL=https://xxxx.supabase.co
 *   export SUPABASE_SERVICE_KEY=eyJ...         # service_role، من جهازك بس
 *   node tools/relink_audio.mjs --dry-run
 *   node tools/relink_audio.mjs
 *
 *   # أو بلا إنترنت، من قائمة أسماء (سطر لكل اسم):
 *   node tools/relink_audio.mjs --from namen.txt
 *
 * ★ ليش موجودة: ملفّات الصوت مستثناة من git عن قصد (٣٠٠ ميغا ما إلهن
 *   محلّ بمستودع)، ومحلّهن الدائم هو الدلو. يعني مين ما مسح مجلّد
 *   التحميل بعد الرفع ما خسر شي — بس link_audio.mjs بده المجلّد تا
 *   يعرف مين لمين. هالأداة بتاخد نفس المعلومة من اسم الملفّ بالدلو:
 *   telc-b1-m01-hv1.mp3 ← المؤسسة، الدرجة، النموذج، القسم.
 *
 * الكتابة بتصير بنفس دالة link_audio.mjs — كاتب واحد، مو اتنين.
 */
import { readFileSync, existsSync } from 'fs';
import path from 'path';
import { parseAudioName, setAudio } from './lib/audio_link.mjs';

const ROOT = path.resolve(import.meta.dirname, '..');
const argv = process.argv.slice(2);
const dry   = argv.includes('--dry-run');
const from  = (argv.find(a => a.startsWith('--from=')) || '').split('=')[1]
           || (argv.includes('--from') ? argv[argv.indexOf('--from') + 1] : null);
const plays = Number((argv.find(a => a.startsWith('--plays=')) || '').split('=')[1]) || 2;
const bucket = (argv.find(a => a.startsWith('--bucket=')) || '').split('=')[1] || 'exam-audio';

async function fromBucket(){
  const base = (process.env.SUPABASE_URL || '').replace(/\/+$/, '');
  const key  = process.env.SUPABASE_SERVICE_KEY || '';
  if (!base || !key) {
    console.error('لازم SUPABASE_URL و SUPABASE_SERVICE_KEY بالبيئة —\n'
      + 'Supabase ← Project Settings ← API ← service_role.\n'
      + 'أو بلا إنترنت:  node tools/relink_audio.mjs --from <ملف أسماء>');
    process.exit(2);
  }
  const out = [];
  // الدلو بيرجّع صفحة صفحة؛ ١٠٠ بالمرّة لحدّ ما تخلص
  for (let offset = 0; ; offset += 100) {
    const r = await fetch(`${base}/storage/v1/object/list/${bucket}`, {
      method: 'POST',
      headers: { apikey: key, authorization: `Bearer ${key}`,
                 'content-type': 'application/json' },
      body: JSON.stringify({ prefix: '', limit: 100, offset,
                             sortBy: { column: 'name', order: 'asc' } }),
    });
    if (!r.ok) {
      console.error(`✗ ما قدرت أقرا الدلو «${bucket}» (${r.status})`);
      console.error(String(await r.text()).slice(0, 200));
      process.exit(1);
    }
    const page = await r.json();
    if (!Array.isArray(page) || !page.length) break;
    out.push(...page.map(o => o.name));
    if (page.length < 100) break;
  }
  return out;
}

const names = from
  ? readFileSync(path.resolve(from), 'utf8').split('\n')
      .map(l => l.trim()).filter(Boolean).map(l => path.basename(l))
  : await fromBucket();

console.log(`▸ ${names.length} ملف بالمصدر`);

let done = 0; const skipped = [], failed = [];
for (const n of names.sort()) {
  const a = parseAudioName(n);
  if (!a) { skipped.push(n); continue; }
  const src = a.prov === 'telc' && a.lvl === 'b1'
    ? path.join(ROOT, 'data', `${a.model}.json`)
    : path.join(ROOT, 'content', a.prov, a.lvl, a.model, 'text.txt');
  if (!existsSync(src)) { failed.push(`${n} ← ما في ${path.relative(ROOT, src)}`); continue; }
  try {
    if (!dry) setAudio(ROOT, a.prov, a.lvl, a.model, a.sec, a.name, plays);
    console.log(`  ${a.prov}/${a.lvl} ${a.model} ${a.sec.padEnd(3)} ← ${n}`);
    done++;
  } catch (e) { failed.push(`${n} ← ${e.message}`); }
}

console.log(`\n${done} قسم انربط${dry ? ' (تجربة — ما انحفظ شي)' : ''}`);
if (skipped.length)
  console.log(`\n· ${skipped.length} اسم مو على الصيغة <مؤسسة>-<درجة>-mNN-<قسم>.mp3:\n   `
    + skipped.slice(0, 5).join('\n   ') + (skipped.length > 5 ? '\n   …' : ''));
if (failed.length) {
  console.log(`\n⚠ ${failed.length} ما انربط:\n   ` + failed.slice(0, 8).join('\n   '));
}
if (!dry && done) {
  console.log('\n▸ وبعدها:');
  console.log('   node tools/sync_b1_content.mjs');
  console.log('   python3 tools/export_sql.py data supabase/seed/b1.sql --level b1');
  console.log('   node tools/content_to_seed.mjs oesd/a1  supabase/seed/a1.sql');
  console.log('   node tools/content_to_seed.mjs telc/b2  supabase/seed/b2.sql');
  console.log('   ./tools/deploy_db.sh');
}
process.exit(failed.length ? 1 : 0);
