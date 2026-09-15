# `content/` — one folder per Modelltest

Where exam material lives before it goes into the database. One folder per
Modelltest, holding its text, its images and its recordings together.

The point: you can hand a folder to someone — or to another AI — and they can
fill it without knowing anything about the app.

## The tree

```
content/
  telc/
    b1/
      _vorlage.txt              ← empty template for this exam shape
      modell-01/
        text.txt                ← the exam, filled in
        img/    muster-01-lv3.jpg
        audio/  muster-01-hv1.mp3 …
      modell-02/
    a1/  a2/  b2/  c1/
  oesd/
    a1/  a2/  b1/  b2/  c1/
```

Add a Modelltest by copying `modell-01/` to `modell-02/`. Add a provider by
copying a whole provider folder.

### Three naming decisions, and why

**`telc/b1/`, not `telc/telc b1/`.** The provider is already the parent
folder, so repeating it adds nothing — and a space in a folder name breaks
every script that forgets to quote a path. Lowercase, no spaces.

**A `modell-NN` layer.** One level is not one exam: telc B1 alone has 16
Modelltests. Without this layer there is nowhere to put the second one.

**`text.txt`, not `text.json`.** This is the format the admin panel's Import
page already reads, and the parser behind it has 23 edge-case tests. A new
JSON format would need a second parser — and two parsers drift apart
silently: a file passes one and fails the other.

It also fails better. JSON dies on one missing comma, with an error pointing
at a character offset. The text format is line-based: a broken line breaks
one question, and the parser tells you which. You can read it and fix it by
eye, which matters when the content came out of an AI.

## telc B1 is already in there — and it is generated

The 16 existing B1 Modelltests live in `content/telc/b1/`, with their
Leseverstehen-3 images alongside them. You did not have to type them: they
are produced from `data/*.json` by

```bash
node tools/sync_b1_content.mjs
```

**`data/` stays the source for B1.** Not for tidiness — because the SQL
seeder (`tools/export_sql.py`) is Python and the markup parser is
JavaScript. Making `content/` the source for B1 would mean a second parser
in Python, and two parsers drift apart silently.

So B1's `text.txt` files are generated files, like `vorlagen.js` and
`setup.sql`. Edit `data/`, re-run the command, and a test catches you if you
forget. **Every other level is authored in `content/` directly** — those have
no other source.

## Filling a folder

1. Open the level's `_vorlage.txt` and copy the whole thing.
2. Give an AI the exam PDF and the prompt in
   [vorlage/ki-prompt.md](vorlage/ki-prompt.md), with the template below it.
3. Save what comes back as `modell-NN/text.txt`.
4. Cut the images out of the PDF into `img/`, put the recordings in `audio/`.
   **The filenames must match what the text says** — the lines `Bild:` and
   `Hörtext:` name them.
5. Check it (see below), fix what it reports.
6. Panel → **Import** → paste the text → Prüfen → publish. Then panel →
   **Dateien** → upload the images and recordings.

## Checking a folder

```bash
node tools/check_content.mjs           # everything
node tools/check_content.mjs telc/b1   # one level
```

It reports, per Modelltest: how many sections, questions and answers it
found, any parser warnings, and **which referenced files are missing**. That
last one is the common mistake — a text that says `Bild: img/x.jpg` with no
`x.jpg` next to it publishes a section that renders blank.

It runs the **same parser as the admin panel** (`admin/parse.js`), not a copy.
One format, one answer.

## Templates for the other levels are not written yet

`content/telc/b1/_vorlage.txt` is real and works. Every other `_vorlage.txt`
is a stub that says so.

That is not laziness — a template encodes the *shape* of one exam: how many
parts, which question formats, how many points each, how many minutes. telc
B1 is 61 questions and 225 points across three blocks. telc A2 is a different
exam, and ÖSD B1 is a different exam again. Guessing those numbers produces
material that trains people for a test that does not exist.

**So: one real PDF per exam shape, once.** Send it over and the template gets
written from it; after that the template serves every Modelltest of that
level.

## `content/` must never be deployed

The `text.txt` files contain the answer keys, on `Lösung:` lines.
`tools/build_dist.sh` refuses to build if `content/` — or any file named
`text.txt` — reaches the output, the same way it already guards `data/`.
Two tests plant that leak on purpose and check the build fails.

## من المحتوى للقاعدة — لصقة وحدة

```bash
node tools/content_to_seed.mjs goethe/a1 supabase/seed/goethe-a1.sql
```

بيقرا `content/goethe/a1/modell-*/text.txt` وبيطلّع ملف بذور واحد بيعمل
المستوى **وبينشره** وبيدخّل كل الامتحانات. الصقه بـSQL Editor وخلص.

## الصور: JPEG، مو PNG

مسوحات الامتحانات بتجي PNG من الماسح. PNG بلا خسارة، يعني بيخزّن ضجيج
الماسح حرف بحرف — صفحة صور وحدة بتطلع ٢ ميغا، والطالب على موبايل
بشبكة ضعيفة بيستنّاها. نفس الصفحة بـJPEG ٨٥ بتصير ٢٦٠ ك.ب والنص متل
ما هو (وهي أصلاً صيغة صور telc B1 من أوّل يوم).

```bash
python3 tools/shrink_images.py content --dry-run   # شوف شو رح يصير
python3 tools/shrink_images.py content             # وبعدها نفّذ
```

بيحوّل، وبيمسح الـPNG، وبيعدّل سطر `Bild:` بنفسه. بعدها **ولّد البذور
من جديد والصقها** — المسار تغيّر، والبذور بتعمل `config = excluded.config`
فاللصقة بتحدّثه.

### الاسم لازم يكون فريد بكل المستويات

الدلو **مسطّح**: كل الصور بتنزل جنب بعض تحت `img/`. يعني `m01-lv3.jpg`
تبع ÖSD و`m01-lv3.jpg` تبع telc بيدعسوا بعض.

فالجداد بياخدوا بادئة مستواهم:

```
img/oesd-a1-m01-lv3.jpg
img/goethe-a1-m01-s1.jpg
img/m01-lv3.jpg            ← telc B1، بلا بادئة: مرفوعة بالإنتاج من زمان
```

تلات فحوص بـ`tests/tools.sh` بيمنعوا الرجوع: ولا صورة فوق ٥٠٠ ك.ب،
ولا PNG بمجلدات `img/`، والأسماء فريدة.

★ **سمّي الملف `<مؤسسة>-<درجة>.sql`.** الدرجة لحالها ما بتكفي: ÖSD A1
وGoethe A1 درجتهن وحدة ومنتجين مختلفين. (التلاتة القدام — `b1.sql`
و`b2.sql` و`a1.sql` — انعملوا قبل هالقاعدة وضلّوا بأساميهن.)

الملف الكبير بينقسم لأجزاء تنلصق وحدة وحدة (المحرّر بيتعتّر فوق
~٢٠٠ ك.ب):

```bash
./tools/split_seed.sh b2        # → supabase/seed/parts/b2-1.sql …
```

★ **ما في مولّد SQL تاني:** السكربت بس بيترجم شكل `text.txt` لشكل
`data/*.json` وبينده `tools/export_sql.py` — نفس المولّد يلي بيعمل
بذور B1. والتحليل بـ`admin/parse.js`، نفس المحلّل يلي باللوحة.

★ **وفحص انحراف تلقائي:** `tests/tools.sh` بيدور على كل مستوى إله
بذور وبيتأكّد إنّها مطابقة للمحتوى. **بلا قايمة مكتوبة بالإيد** —
مستوى جديد بيندخل بالفحص لحاله، فما بيصير مستوى يمرق بلا فحص.

### أسماء المؤسسات

المجلّد بيعطي المعرّف، والجدول بـ`content_to_seed.mjs` بيعطي اسم
العرض:

| المجلّد | الطالب بيشوف | عنوان المستوى |
|---|---|---|
| `telc` | telc | telc Deutsch B2 |
| `oesd` | **ÖSD** | ÖSD Zertifikat A1 |
| `goethe` | Goethe | Goethe-Zertifikat B1 |

مؤسسة مو بالجدول بتاخد اسم مجلّدها. والعنوان فيك تعدّله من اللوحة
بأي وقت.

## أقسام الاستماع — الوضع الحقيقي

**ما في ولا تسجيل ولا نصّ مسموع** بأي مستوى. وهاد مو «نسينا نرفعهن»:
انفحصت كل المصادر (`B1 Telc.pdf` ٢٢٠ صفحة · منهاج Goethe ١٨٤ صفحة ·
كل Modelsätze تبع ÖSD) — **صفر** إشارة لـ`Transkript` أو `Hörtext`.
يعني ما في شي نسجّله ولا حتى نولّده بصوت آلي.

| المستوى | أقسام استماع | وزنها | بيحذّر الطالب؟ |
|---|---|---|---|
| telc B1 | ٤٧ | ٣٣٪ من النقاط | ✅ بكل قسم `Hinweis:` |
| telc B2 | ٤٠ | ٤٧٪ | ❌ ولا وحدة |
| ÖSD A1 | ٢٤ | ٣٧٪ | ❌ ولا وحدة |
| Goethe A1 | ٠ | — | البلوك مو مكتوب أصلاً (القالب فيه) |

التطبيق بيعرض `Hinweis:` كصندوق تحذير قبل البلوك **طالما ما في `Hörtext:`**
(`assets/app.js` — `.filter(p => !p.audio)`). فأوّل ما ينضاف صوت، التحذير
بيختفي لحاله.

### طلبات البحث عن التسجيلات

```bash
node tools/audio_prompts.mjs     # → Doku/audio-suche/<مؤسسة>-<درجة>-modell-NN.md
```

ملف لكل امتحان، جاهز تلصقه لمساعد عنده بحث بالإنترنت. فيه هويّة
الامتحان، بنية كل قسم استماع، نصّ الأسئلة حرفياً، و**بصمة الامتحان** —
جمل طويلة وفريدة من قسم القراءة، لأنّ أسئلة الاستماع لحالها ممكن تكون
عامّة («Text 1»، «Person 3») وما بتدلّ على شي بالبحث.

### رابط صوت خارجي — للتجربة بس

`Hörtext:` بيقبل رابط كامل، مو بس اسم ملف:

```
Hörtext: https://example.com/hv1.mp3
Wiedergaben: 2
```

التطبيق بيمرّر أي مسار بيبلّش بـ`http` كما هو بلا توقيع
(`assets/api.js` — `signed()`)، فالمشغّل بيشتغل بلا رفع ولا دلو.

بيظهر بلوحة **Dateien** بعلامة `Link` (مو `fehlt`)، وبـ`health.sql`
بسطر لحاله. و`check_content.mjs` ما بيفتّش عنه بالقرص.

⚠️ **مؤقّت بطبعه.** الملف عند غيرك: ممكن ينشال، وممكن يمنعوا الوصول
من برّا، وأخد ملفّ من موقع تاني وعرضه بمنتج مدفوع سؤال ترخيص. لمّا توصل
التسجيلات الحقيقية، حطّها بـ`audio/` وارفعها بـ`tools/upload_audio.py`
وبدّل السطر لاسم الملف.
