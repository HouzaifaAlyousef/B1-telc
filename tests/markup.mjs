/* round-trip: امتحان حقيقي ← نص ← امتحان.
   إذا الـ١٦ كلهن رجعوا متطابقين، فالصيغة بتوسّع المحتوى الفعلي.
   وإذا لأ، الفرق بيطلع بالضبط وين. */
import { createRequire } from 'module';
import { readFileSync, readdirSync } from 'fs';
import path from 'path';
const require = createRequire(import.meta.url);
const ROOT = path.resolve(import.meta.dirname, '..');
const Markup = require(path.join(ROOT, 'admin/parse.js'));

/* الحقول يلي بيحسبها المحلّل — منقارنها لحالها */
const strip = t => ({
  title: t.title, subtitle: t.subtitle ?? null,
  blocks: (t.blocks || []).map(b => ({
    id: b.id, title: b.title ?? undefined, minutes: b.minutes ?? undefined,
    hint: b.hint || undefined, parts: b.parts,
    maxPoints: b.maxPoints, availablePoints: b.availablePoints, missing: b.missing
  })),
  sections: (t.sections || []).map(s => ({
    id: s.id, format: s.format, title: s.title ?? undefined,
    group: s.group ?? undefined, minutes: s.minutes ?? undefined,
    instruction: s.instruction || undefined, note: s.note || undefined,
    bankTitle: s.bankTitle || undefined, bankImage: s.bankImage || undefined,
    pointsPerItem: s.pointsPerItem ?? undefined,
    maxPoints: s.maxPoints, availablePoints: s.availablePoints, missing: s.missing,
    bank: s.bank, passages: s.passages,
    brief: s.brief, hints: s.hints, criteria: s.criteria,
    grades: s.grades, factor: s.factor,
    items: (s.items || []).map(i => ({
      id: i.id, text: String(i.text || '').replace(/\s+/g,' ').trim(),
      options: i.options, answer: i.answer, explain: i.explain,
      minWords: i.minWords, points: i.points
    }))
  }))
});
const J = o => JSON.stringify(o, (k, v) => v === undefined ? undefined : v);

let pass = 0, fail = 0, totItems = 0, totWarn = 0;
console.log('\n=== round-trip الصيغة على الامتحانات الحقيقية ===');

for (const f of readdirSync(path.join(ROOT,'data')).filter(x => /^modell-\d+\.json$/.test(x)).sort()){
  const orig = JSON.parse(readFileSync(path.join(ROOT,'data',f),'utf8'));
  const text = Markup.serialize(orig);
  const { test: back, warnings, counts } = Markup.parse(text);

  const a = J(strip(orig)), b = J(strip(back));
  totItems += counts.items;
  const realWarn = warnings.filter(w => !/keine Lösung/.test(w));  // التعبير الكتابي بلا حل: متوقّع
  totWarn += realWarn.length;

  if (a === b && !realWarn.length){ pass++; console.log(`  ✓ ${f} — ${counts.items} سؤال، ${counts.answers} حل`); }
  else {
    fail++;
    console.log(`  ✗ ${f}`);
    realWarn.slice(0,3).forEach(w => console.log(`      تحذير: ${w}`));
    if (a !== b){
      // نلاقي أول قسم مختلف
      const A = strip(orig).sections, B = strip(back).sections;
      for (let i = 0; i < Math.max(A.length, B.length); i++){
        if (J(A[i]) !== J(B[i])){
          console.log(`      أول اختلاف بالقسم ${A[i]?.id ?? '?'} :`);
          const ka = A[i] || {}, kb = B[i] || {};
          for (const k of new Set([...Object.keys(ka), ...Object.keys(kb)])){
            if (J(ka[k]) !== J(kb[k])){
              console.log(`        ${k}:`);
              const va = ka[k], vb = kb[k];
              if (Array.isArray(va) && Array.isArray(vb)){
                if (va.length !== vb.length)
                  console.log(`          طول مختلف: ${va.length} ← ${vb.length}`);
                for (let z = 0; z < Math.max(va.length, vb.length); z++){
                  if (J(va[z]) !== J(vb[z])){
                    console.log(`          [${z}] قبل: ${String(J(va[z])).slice(0,200)}`);
                    console.log(`          [${z}] بعد: ${String(J(vb[z])).slice(0,200)}`);
                    break;
                  }
                }
              } else {
                console.log(`          قبل: ${String(J(va)).slice(0,200)}`);
                console.log(`          بعد: ${String(J(vb)).slice(0,200)}`);
              }
            }
          }
          break;
        }
      }
    }
  }
}
console.log(`\n${fail ? '✗' : '✓'} ${pass}/${pass+fail} امتحان مرقوا · ${totItems} سؤال · ${totWarn} تحذير`);
process.exit(fail ? 1 : 0);
