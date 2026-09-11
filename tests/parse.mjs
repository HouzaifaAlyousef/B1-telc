/* اختبار وحدات للمحلّل: حالات حدّية ومدخلات عدائية.
   الـround-trip بـmarkup.mjs بيثبت إنه بيقرا المحتوى الحقيقي؛
   هون منثبت إنه بيتصرّف صح مع المدخلات السيّئة. */
import { createRequire } from 'module';
import path from 'path';
const require = createRequire(import.meta.url);
const M = require(path.join(path.resolve(import.meta.dirname, '..'), 'admin/parse.js'));

const R = [];
const check = (l, c) => { R.push([l, !!c]); console.log(`  ${c ? '✓' : '✗'} ${l}`); };
const warned = (r, re) => r.warnings.some(w => re.test(w));

console.log('\n=== المحلّل: حالات حدّية ===');

/* ---- ما بيرمي استثناء أبداً ---- */
const nasty = ['', '   \n\n  ', '#', '###', '[1]', 'Format: mc',
  String.fromCharCode(0xFFFD), String.fromCharCode(0),
  '# T\n'.repeat(500), '### Teil: '.repeat(200),
  '# T\n### Teil: x\nFormat: mc\nAufgaben:\n[1] ' + 'ä'.repeat(50000) + '\nLösung: A'];
let threw = 0;
for (const t of nasty){ try { M.parse(t); } catch { threw++; } }
check(`${nasty.length} مدخل سيّئ بلا استثناء`, threw === 0);

/* ---- تحذيرات بنيوية ---- */
let r = M.parse('# T\n### Teil: x\nAufgaben:\n[1] a\nLösung: A');
check('★ قسم بلا صيغة ← تحذير', warned(r, /kein Format/));

r = M.parse('# T\n### Teil: x\nFormat: quantum\nAufgaben:\n[1] a\nLösung: A');
check('★ صيغة مجهولة ← تحذير', warned(r, /unbekanntes Format/));

r = M.parse('# T\n### Teil: x\nFormat: mc\nAufgaben:\n[1] a');
check('سؤال بلا حل ← تحذير', warned(r, /keine Lösung/));

r = M.parse('# T\n### Teil: x\nFormat: mc\nAufgaben:\n[1] a\nLösung: A\n[1] b\nLösung: B');
check('رقم سؤال مكرّر ← تحذير', warned(r, /doppelt/));

r = M.parse('# T\n### Teil: x\nFormat: mc\nAufgaben:\n[1] a\nLösung: A\n'
          + '### Teil: x\nFormat: mc\nAufgaben:\n[2] b\nLösung: B');
check('قسم مكرّر ← تحذير', warned(r, /kommt doppelt/));

r = M.parse('# T\n## Block: b\nTeile: gibtsnicht\n'
          + '### Teil: x\nFormat: mc\nAufgaben:\n[1] a\nLösung: A');
check('كتلة بتشاور على قسم مو موجود ← تحذير', warned(r, /unbekannten Teil/));

check('بلا عنوان ← تحذير', warned(M.parse('### Teil: x\nFormat: mc'), /Kein Titel/));
check('بلا أقسام ← تحذير', warned(M.parse('# T'), /Keine Teile/));

/* ---- صحة القراءة ---- */
r = M.parse([
  '# T',
  '### Teil: x',
  'Format: truefalse',
  'Punkte: 5',
  'Maximum: 25',
  'Aufgaben:',
  '[41] Aussage eins',
  'Lösung: richtig',
  '[42] Aussage zwei',
  'Lösung: falsch',
  '[43] Aussage drei',
  'Lösung: r',
].join('\n'));
const it = r.test.sections[0].items;
check('truefalse: richtig/falsch/r ← r,f,r',
      it[0].answer === 'r' && it[1].answer === 'f' && it[2].answer === 'r');
check('النقاط المتاحة = ٣ × ٥ = ١٥', r.test.sections[0].availablePoints === 15);
check('الناقص = (٢٥ − ١٥) ÷ ٥ = ٢', r.test.sections[0].missing === 2);

r = M.parse([
  '# T',
  '### Teil: y',
  'Format: mc',
  'Aufgaben:',
  '[6] Die Frage',
  'A) erste',
  'B) zweite',
  'C) dritte',
  'Lösung: B',
  'Erklärung: weil B',
].join('\n'));
const q = r.test.sections[0].items[0];
check('mc: ٣ خيارات + حل + شرح',
      q.options?.length === 3 && q.answer === 'B' && q.explain === 'weil B');
check('نص السؤال بلا الخيارات', q.text === 'Die Frage');

/* ---- نص متعدّد الأسطر ---- */
r = M.parse([
  '# T',
  '### Teil: z',
  'Format: mc',
  'Text:',
  '**Überschrift**',
  'Erster Absatz.',
  '§§§',
  'Zweiter Text.',
  'Aufgaben:',
  '[1] Frage',
  'Lösung: A',
].join('\n'));
const ps = r.test.sections[0].passages;
check('نصّين مفصولين بفاصل النصوص', ps?.length === 2);
check('العنوان انعلّم fett', ps[0].paragraphs[0].b === true);
check('★ سطر Aufgaben: ما انبلع كفقرة',
      !JSON.stringify(ps).includes('Aufgaben'));

/* ---- Extra JSON ---- */
r = M.parse([
  '# T',
  '### Teil: w',
  'Format: writing',
  'Extra:',
  '{',
  ' "factor": 3,',
  ' "grades": [{"key":"A","points":5}]',
  '}',
  'Aufgaben:',
  '[A] Schreiben Sie.',
  'Mindestwörter: 100',
  'Punkt: erstens',
  'Punkt: zweitens',
].join('\n'));
const w = r.test.sections[0];
check('Extra JSON على أسطر انقرا صح', w.factor === 3 && w.grades?.length === 1);
check('★ Extra ما بلع باقي الملف', w.items?.length === 1);
check('writing: minWords والنقاط',
      w.items[0].minWords === 100 && w.items[0].points?.length === 2);

/* ---- أقواس بالنص ---- */
r = M.parse('# T\n### Teil: x\nFormat: mc\nAufgaben:\n'
          + '[1] siehe [Anhang] und [2]\nLösung: A');
check('أقواس جوّا السطر مو بداية سؤال جديد',
      r.counts.items === 1 && r.test.sections[0].items[0].text.includes('[Anhang]'));

/* ---- الصوت ---- */
r = M.parse('# T\n### Teil: hv1\nFormat: truefalse\n'
          + 'Hörtext: m01.mp3\nWiedergaben: 2\nAufgaben:\n[1] a\nLösung: r');
check('Hörtext + Wiedergaben انقروا',
      r.test.sections[0].audio === 'm01.mp3' && r.test.sections[0].audioPlays === 2);

/* ---- الذهاب والإياب على شي مبني بالإيد ---- */
const round = M.parse(M.serialize(r.test)).test;
check('round-trip على قسم صوت',
      JSON.stringify(round.sections[0]) === JSON.stringify(r.test.sections[0]));

const bad = R.filter(x => !x[1]);
console.log(bad.length ? `\n✗ ${bad.length} فشل من ${R.length}`
                       : `\n✓ كل الـ${R.length} اختبارات نجحت`);
process.exit(bad.length ? 1 : 0);
