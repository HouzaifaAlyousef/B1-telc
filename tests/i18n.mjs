/* اكتمال الترجمة.
   مفتاح ناقص بلغة بيرجع للألماني بصمت — يعني نص ألماني وسط واجهة
   عربية، وما حدا بينتبه إلا المستخدم. والفحص بيقارن المفاتيح فعلياً
   بدل ما يتّكل على المراجعة بالعين. */
import { readFileSync } from 'fs';
import { createRequire } from 'module';
const require = createRequire(import.meta.url);

// navigator بنودجي getter بس — منعرّفه بدل ما نسنده
Object.defineProperty(globalThis, 'navigator',
  { value: { languages: ['de'] }, configurable: true });
globalThis.localStorage = { getItem: () => null, setItem: () => {} };
globalThis.document = { documentElement: {} };
const I18N = require('../assets/i18n.js');

const R = [];
const check = (l, c) => { R.push([l, !!c]); console.log(`  ${c ? '✓' : '✗'} ${l}`); };

console.log('\n=== الترجمة ===');

const src = readFileSync(new URL('../assets/i18n.js', import.meta.url), 'utf8');
const block = lang => {
  const m = src.match(new RegExp(`^    ${lang}: \\{([\\s\\S]*?)\\n    \\},?\\n`, 'm'));
  return m ? m[1] : null;
};
const keysOf = b => [...b.matchAll(/^      (\w+):/gm)].map(m => m[1]);

const de = block('de');
check('قاموس الألماني انقرا', !!de);
const want = keysOf(de);
check(`الألماني فيه ${want.length} مفتاح`, want.length > 50);

for (const L of ['ar', 'uk']){
  const b = block(L);
  const have = new Set(keysOf(b || ''));
  const miss = want.filter(k => !have.has(k));
  check(`★ ${L}: ما في مفاتيح ناقصة${miss.length ? ' — ' + miss.join(', ') : ''}`,
        miss.length === 0);
}

/* الجمع لازم يعطي أشكال مختلفة فعلاً. لو أحد نسخ شكل واحد لكل الفئات،
   الفحص فوق بيمرق والنتيجة «٢ سؤال» بالعربي. */
for (const [L, n, want] of [
  ['de', 1, '1 Aufgabe'], ['de', 5, '5 Aufgaben'],
  ['ar', 1, 'سؤال واحد'], ['ar', 2, 'سؤالين'], ['ar', 5, '5 أسئلة'],
  ['uk', 1, '1 завдання'], ['uk', 5, '5 завдань'],
]){
  I18N.setLang(L);
  const got = I18N.plural(n, 'nTask');
  check(`جمع ${L} لـ${n}: ${got}`, got === want);
}

I18N.setLang('ar');
check('مفتاح مو موجود بيرجع لاسمه، ما بيرمي', I18N.t('nichtDa') === 'nichtDa');
check('المتغيّرات بتتعبّى', I18N.t('until', { date: '01.01.2027' }).includes('01.01.2027'));

const bad = R.filter(r => !r[1]);
console.log(bad.length ? `\n✗ ${bad.length} فشل من ${R.length}`
                       : `\n✓ كل الـ${R.length} فحوص نجحت`);
process.exit(bad.length ? 1 : 0);
