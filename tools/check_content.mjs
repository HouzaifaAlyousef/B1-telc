/* فحص مجلّد content/ كامل بضغطة وحدة.
   
   ★ بيستعمل **نفس** المحلّل يلي باللوحة (admin/parse.js) — مو نسخة تانية.
     محلّل تاني معناه صيغتين بتفرقوا بصمت: نص بيمرق هون وبيفشل باللوحة،
     أو بالعكس. المحلّل واحد، فالجواب واحد.

   بيقول لكل نموذج: معبّى ولا فاضي، كم سؤال وكم حلّ، شو التحذيرات، وشو
   الملفات يلي النص بيطلبها ومو موجودة.

   الاستعمال:
     node tools/check_content.mjs              كل شي
     node tools/check_content.mjs telc/b1      مستوى واحد
*/
import { createRequire } from 'module';
import { readFileSync, readdirSync, existsSync, statSync } from 'fs';
import path from 'path';

const ROOT = path.resolve(import.meta.dirname, '..');
const require = createRequire(import.meta.url);
const Markup = require(path.join(ROOT, 'admin/parse.js'));

const only = process.argv[2] || '';
const dirs = (p) => existsSync(p)
  ? readdirSync(p).filter(d => !d.startsWith('.') && statSync(path.join(p, d)).isDirectory())
  : [];

let nFilled = 0, nEmpty = 0, nBad = 0, nMissing = 0, nUnreach = 0, nLying = 0;
const rows = [];

for (const prov of dirs(path.join(ROOT, 'content'))) {
  for (const lvl of dirs(path.join(ROOT, 'content', prov))) {
    if (only && !`${prov}/${lvl}`.startsWith(only)) continue;

    const lvlDir = path.join(ROOT, 'content', prov, lvl);
    const vorlage = path.join(lvlDir, '_vorlage.txt');
    const hasVorlage = existsSync(vorlage)
      && readFileSync(vorlage, 'utf8').split('\n').some(l => l.trim() && !l.startsWith('//'));

    for (const modell of dirs(lvlDir)) {
      const dir = path.join(lvlDir, modell);
      const txt = path.join(dir, 'text.txt');
      const id = `${prov}/${lvl}/${modell}`;

      if (!existsSync(txt)) { rows.push(['✗', id, 'ما في text.txt']); nBad++; continue; }

      const body = readFileSync(txt, 'utf8');
      if (!body.trim()) {
        nEmpty++;
        rows.push(['·', id, hasVorlage ? 'فاضي — القالب جاهز' : 'فاضي — والقالب كمان']);
        continue;
      }

      let r;
      try { r = Markup.parse(body); }
      catch (e) { rows.push(['✗', id, `ما انقرا: ${String(e.message).slice(0, 60)}`]); nBad++; continue; }

      const c = r.counts;
      // اسم الامتحان من أول سطر بالنص — «modell-03» لحاله ما بيقول شي
      const note = [r.test.title || '—', `${c.sections} قسم`,
                    `${c.items} سؤال`, `${c.answers} حلّ`];

      // الملفات يلي النص بيطلبها لازم تكون موجودة، وإلا القسم بيطلع فاضي
      const want = [];
      for (const s of r.test.sections) {
        if (s.bankImage) want.push(['img', s.bankImage]);
        if (s.audio)     want.push(['audio', s.audio]);
      }
      const gone = want.filter(([kind, f]) =>
        !existsSync(path.join(dir, kind, path.basename(f))));
      if (gone.length) {
        nMissing += gone.length;
        note.push(`★ ناقص ${gone.length}: ${gone.map(g => path.basename(g[1])).join(', ')}`);
      }
      // نقاط معلَنة ما إلها أسئلة: البلوك بيقول «45 نقطة» بس القطع
      // يلي جوّاته بتعطي ٣٥. الطالب بيشوف ٤٥ بالواجهة وما بيوصلها أبداً،
      // والتصحيح بيقسّم على القسم لا على البلوك فما في تعويض. لما يكون
      // النقص مصرّح فيه (Fehlend:) منسكت — هداك مقصود ومكتوب بالواجهة.
      // والاتجاه التاني كمان خلل: قطع بتعطي أكتر من يلي البلوك معلنه،
      // يعني الطالب فيه يجيب أعلى من العلامة الكاملة. هون ما في عذر
      // «Fehlend» — الأسئلة الناقصة بتنقّص المتاح، عمرها ما بتزيده.
      const unreachable = (r.test.blocks || []).filter(
        b => (b.availablePoints ?? 0) > (b.maxPoints ?? 0)
          || (!b.missing && (b.availablePoints ?? 0) < (b.maxPoints ?? 0)));
      if (unreachable.length) {
        nUnreach += unreachable.length;
        note.push('★ نقاط ما بتطابق: ' + unreachable
          .map(b => `${b.id} ${b.availablePoints}/${b.maxPoints}`).join('، '));
      }

      // العنوان الفرعي هو أوّل شي بيقرأه الطالب تحت اسم الامتحان
      // (assets/app.js). لمّا يقول «45 Aufgaben» والامتحان فيه ٥٣،
      // أو «150 Minuten» والكتل بتجمع ١٢٠، هاد كذب على الطالب
      // بمكان ما بيراجعه حدا. منقارنه بالملف نفسه.
      const st  = String(r.test.subtitle || '');
      const mins = (r.test.blocks || []).reduce((a, b) => a + (b.minutes || 0), 0);
      const nA = st.match(/(\d+)\s*Aufgaben/), nM = st.match(/(\d+)\s*Minuten/);
      const lying = [];
      if (nA && +nA[1] !== c.items) lying.push(`${nA[1]} Aufgaben بس فعلياً ${c.items}`);
      if (nM && +nM[1] !== mins)    lying.push(`${nM[1]} Minuten بس فعلياً ${mins}`);
      if (lying.length) {
        nLying += lying.length;
        note.push('★ العنوان الفرعي: ' + lying.join('، '));
      }

      if (r.warnings.length) note.push(`${r.warnings.length} تحذير`);

      // فحص صارم: تحذير، ملف مفقود، أو بلوك نقاطه ما بتنطال بيوقّف البناء
      const bad = r.warnings.length || gone.length || unreachable.length
              || lying.length;
      rows.push([bad ? '!' : '✓', id, note.join(' · ')]);
      if (bad) nBad++; else nFilled++;
    }
  }
}

const w = Math.max(...rows.map(r => r[1].length), 10);
for (const [m, id, note] of rows) console.log(`  ${m} ${id.padEnd(w)}  ${note}`);
console.log(`\n  ${nFilled} جاهز · ${nEmpty} فاضي · ${nBad} فيه مشكلة · `
            + `${nMissing} ملف ناقص · ${nUnreach} بلوك نقاطه ما بتطابق · `
            + `${nLying} عنوان فرعي بيكذب`);
process.exit(nBad ? 1 : 0);
