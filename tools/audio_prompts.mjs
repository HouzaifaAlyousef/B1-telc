/* طلب بحث جاهز لكل امتحان: «لاقيلي تسجيلات الاستماع تبع هالامتحان».
 *
 *   node tools/audio_prompts.mjs            → Doku/audio-suche/
 *
 * ليش: أقسام الاستماع عندنا فيها الأسئلة والحلول، بس **ما في ولا نصّ
 * مسموع ولا تسجيل** — لا بالمحتوى ولا بأي PDF من مصادرنا (انفحصوا
 * كلهن). يعني ما في شي نسجّله. التسجيلات لازم تجي من برّا.
 *
 * ★ البصمة هي جمل الأسئلة نفسها. عبارة ألمانية طويلة ومميّزة بتلاقي
 *   مصدرها بالبحث أسرع بكتير من «telc B2 Hörverstehen». فالطلب بيحمل
 *   النصّ الحرفي للأسئلة — بلا حلول: الحلول ما إلها شغل بالبحث، وما
 *   منطلّعها من الريبو بلا سبب.
 */
import { readFileSync, writeFileSync, mkdirSync, readdirSync, existsSync,
         statSync } from 'fs';
import { createRequire } from 'module';
import path from 'path';

const ROOT = path.resolve(import.meta.dirname, '..');
const Markup = createRequire(import.meta.url)(path.join(ROOT, 'admin/parse.js'));
const OUT = path.join(ROOT, 'Doku/audio-suche');

/* اسم المؤسسة متل ما بيعرفه العالم برّا، والموقع الرسمي —
   أوّل مطرح لازم يدوّر فيه. */
const PROV = {
  telc:   { name: 'telc',            site: 'telc.net' },
  oesd:   { name: 'ÖSD',             site: 'osd.at' },
  goethe: { name: 'Goethe-Institut', site: 'goethe.de' },
};

const isHoer = s => /^(Hören|Hörverstehen)$/i.test(s.group || '')
                 || /^hv/.test(s.id || '');

let n = 0;
mkdirSync(OUT, { recursive: true });

const dirsIn = d => readdirSync(d).filter(x => statSync(path.join(d, x)).isDirectory());

for (const prov of dirsIn(path.join(ROOT, 'content'))) {
  const pdir = path.join(ROOT, 'content', prov);
  for (const lvl of dirsIn(pdir)) {
    const ldir = path.join(pdir, lvl);
    for (const m of readdirSync(ldir).filter(d => d.startsWith('modell-')).sort()) {
      const f = path.join(ldir, m, 'text.txt');
      if (!existsSync(f)) continue;
      const body = readFileSync(f, 'utf8');
      if (!body.trim()) continue;
      const { test } = Markup.parse(body);
      const parts = (test.sections || []).filter(isHoer);
      if (!parts.length) continue;           // ما في استماع — ما في شي ندوّر عليه

      const meta = PROV[prov] || { name: prov, site: '' };
      const stufe = lvl.toUpperCase();
      const total = parts.reduce((a, p) => a + p.items.length, 0);
      const mins  = parts.reduce((a, p) => a + (p.minutes || 0), 0);

      /* ★ بصمة الامتحان.
         أسئلة الاستماع بمستويات كتير عامّة («Text 1»، «Person 3») وما
         بتدلّ على شي بالبحث. يلي بيعرّف النموذج هو **نصّ القراءة**:
         إعلان أو رسالة مطبوعة، جملها طويلة وفريدة. منشيلها من أطول
         الفقرات بالأقسام غير الاستماع. */
      const pool = (test.sections || []).filter(x => !isHoer(x)).flatMap(x => [
        ...(x.passages || []).flatMap(ps => (ps.paragraphs || []).map(y => y.t)),
        ...x.items.map(it => it.text),
      ]);
      const finger = [...new Set(pool.map(t => String(t || '').replace(/\s+/g, ' ').trim()))]
        .filter(t => t.length > 55 && /[a-zäöüß]/i.test(t))
        .sort((a, b) => b.length - a.length).slice(0, 4);

      const teile = parts.map(p => {
        const items = p.items.map(it => {
          const t = `  ${it.id}. ${String(it.text || '').replace(/\s+/g, ' ').trim()}`;
          // خيارات الأسئلة بتحمل نصّ مميّز أكتر من السؤال نفسه أحياناً
          const opts = (it.options || [])
            .map(o => `       ${o.key}) ${String(o.text || '').replace(/\s+/g, ' ').trim()}`)
            .filter(x => x.trim().length > 10);
          return [t, ...opts].join('\n');
        }).join('\n');
        return [
          `### ${p.title || p.id}  (\`${p.id}\`)`,
          '',
          `- عدد الأسئلة: **${p.items.length}**`,
          `- الزمن بالامتحان: **${p.minutes || '؟'} دقيقة**`,
          `- شكل الأسئلة: \`${p.format}\``,
          p.instruction ? `- التعليمة الحرفية: «${p.instruction}»` : '',
          '',
          'نصّ الأسئلة حرفياً (هي البصمة — دوّر فيها):',
          '',
          '```',
          items,
          '```',
        ].filter(Boolean).join('\n');
      }).join('\n\n');

      const doc = `# بحث عن تسجيلات الاستماع — ${meta.name} ${stufe} · ${test.title}

> الصق كل هالملف كما هو لمساعد ذكي عنده بحث بالإنترنت.

## المهمّة

عندي امتحان تجريبي (Modelltest) وعندي أسئلة قسم الاستماع كاملة، بس
**ما عندي التسجيلات الصوتية ولا نصوصها**. دوّرلي بالإنترنت عن ملفّات
الصوت الأصلية تبع **هالامتحان بالذات**، وارجعلي بالروابط.

## الامتحان

| | |
|---|---|
| المؤسسة | **${meta.name}** |
| المستوى | **${stufe}** |
| اسم النموذج عندي | **${test.title}** |
| معرّفه عندي | \`${prov}/${lvl}/${m}\` |
| أقسام الاستماع | **${parts.length}** |
| مجموع أسئلة الاستماع | **${total}** |
| زمن الاستماع | **${mins} دقيقة** |

## أقسام الاستماع، بالتفصيل

${teile}

## بصمة الامتحان — لتعرف أي نموذج هو

أسئلة الاستماع لحالها ممكن تكون عامّة. هدول جمل **حرفية من قسم
القراءة بنفس الامتحان** — فريدة، وبتلاقي النموذج نفسه بالبحث. أوّل ما
تعرف أي Modellsatz هو، التسجيلات بتكون بنفس الصفحة عادةً.

${finger.length
  ? finger.map(t => `- «${t}»`).join('\n')
  : '- (ما في نصّ قراءة كافي بهالنموذج)'}

## شو بدّي منّك بالضبط

1. **ابدأ من الموقع الرسمي** (${meta.site || 'موقع المؤسسة'}): صفحة
   «Modellsatz / Übungstest / Prüfungsvorbereitung» لهالمستوى. المؤسسات
   بتنشر التسجيلات مجّاناً مع النماذج عادةً.
2. **وبعدها**: ناشرين الكتب (Hueber · Klett · Cornelsen)، أرشيف
   الإنترنت، YouTube، ومنصّات التحضير.
3. **ابحث بالجمل الحرفية** يلي فوق بين علامتَي اقتباس — هي أدقّ بصمة.
   جملة وحدة مميّزة بتوصلك للمصدر أسرع من أي كلمة مفتاحية عامّة.

## شكل الجواب

جدول، وبس. لكل رابط لقيته:

| القسم | الرابط | شو فيه | المدّة | نوع الملف | مصدر رسمي؟ |
|---|---|---|---|---|---|

وبعد الجدول، ثلاث أسطر:

- **كم قسم لقيتله صوت** من ${parts.length}
- **مين ما لقيتله** — سمّيه بالاسم
- **الترخيص**: هل الصفحة بتسمح بالتحميل وإعادة الاستعمال؟ إذا ما بتعرف، قول «ما بعرف»

## ممنوع

- **لا تخترع روابط.** إذا ما لقيت، اكتب «ما لقيت» — وهاد جواب مفيد.
- لا ترجّعلي صفحة عامّة عن المستوى؛ بدّي صفحة فيها ملفّ صوت فعلاً.
- لا تكتبلي نصّ الاستماع من عندك. بدّي **مصدر**، مو تأليف.
`;
      writeFileSync(path.join(OUT, `${prov}-${lvl}-${m}.md`), doc);
      n++;
    }
  }
}
console.log(`✓ ${n} طلب بـ${path.relative(ROOT, OUT)}/`);
