/* ماسح التعليقات: الحالات يلي بتخدع أي regex.
   لو انشال شي من جوّا نص أو تعبير نمطي، التطبيق بينكسر عند المستخدم
   بس — الاختبارات بتشتغل على المصدر مو على الناتج. */
import { execFileSync } from 'child_process';
import { writeFileSync, readFileSync, mkdtempSync } from 'fs';
import { tmpdir } from 'os';
import path from 'path';

const dir = mkdtempSync(path.join(tmpdir(), 'strip-'));
const R = [];
const check = (l, c) => { R.push([l, !!c]); console.log(`  ${c ? '✓' : '✗'} ${l}`); };

const strip = (src, ext = '.js') => {
  const i = path.join(dir, 'in' + ext), o = path.join(dir, 'out' + ext);
  writeFileSync(i, src);
  execFileSync('python3', ['tools/strip_comments.py', i, o]);
  return readFileSync(o, 'utf8');
};

console.log('\n=== ماسح التعليقات ===');

const cases = [
  ['تعليق سطر بينشال',        'let a = 1; // شرح\nlet b = 2;', /شرح/, false],
  ['تعليق كتلة بينشال',       '/* شرح */ let a = 1;',          /شرح/, false],
  ['★ «//» جوّا نص بيضل',      'const u = "http://x.de/y";',     /http:\/\/x\.de/, true],
  ['★ «/*» جوّا نص بيضل',      "const s = '/* مو تعليق */';",    /مو تعليق/, true],
  ['★ «//» جوّا template',     'const s = `a http://b c`;',      /http:\/\/b/, true],
  ['★ تعبير نمطي فيه //',      'const r = /https?:\\/\\//g;',     /https\?/, true],
  ['★ تعبير نمطي فيه *',       'const r = /a\\/*b/;',             /a\\\/\*b/, true],
  ['★ قسمة مو تعبير نمطي',     'const x = a / b; // ه\nconst y = 2;', /const y = 2/, true],
  ['★ template متداخل',        'const s = `${`in ${1}`} out`;',   /in \$\{1\}/, true],
  ['★ نص جوّا ${}',            'const s = `${ "a//b" }`;',        /a\/\/b/, true],
];
for (const [label, src, re, want] of cases){
  const got = strip(src);
  check(`${label} — ${JSON.stringify(got.trim()).slice(0, 46)}`, re.test(got) === want);
}

// ★ الملفات الحقيقية: بعد الشيل لازم تضل صحيحة نحوياً وبلا تعليقات
for (const f of ['assets/app.js', 'assets/api.js', 'assets/i18n.js', 'sw.js']){
  const out = path.join(dir, path.basename(f));
  execFileSync('python3', ['tools/strip_comments.py', f, out]);
  let ok = true;
  try { execFileSync('node', ['--check', out]); } catch { ok = false; }
  const txt = readFileSync(out, 'utf8');
  const before = readFileSync(f, 'utf8');
  check(`${f}: صحيح نحوياً بعد الشيل`, ok);
  check(`${f}: صغر (${before.length} → ${txt.length})`, txt.length < before.length);
  // ولا تعليق باقي: منفحص أسطر بتبدأ بـ// أو /*
  check(`${f}: ولا تعليق باقي`,
        !/^\s*\/\/|^\s*\/\*/m.test(txt));
}

const css = strip(readFileSync('assets/style.css', 'utf8'), '.css');
check('style.css: التعليقات انشالت', !/\/\*/.test(css));
check('style.css: القواعد ضلّت', /\.abo\{/.test(css) && css.includes('--brand'));

const bad = R.filter(r => !r[1]);
console.log(bad.length ? `\n✗ ${bad.length} فشل من ${R.length}`
                       : `\n✓ كل الـ${R.length} فحوص نجحت`);
process.exit(bad.length ? 1 : 0);
