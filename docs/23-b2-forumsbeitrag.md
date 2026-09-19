# Aufgabe 58 (Forumsbeitrag) — تعليمات للتنفيذ

## ★ تصحيح مهم قبل ما تبلّش

المهمّتين **مو لامتحانين مختلفين**. الاتنين (`160201` و `160221`)
بينتموا لنفس النموذج: **`modell-08`** وبس.

هيك تأكّدنا، مو تخمين — صفحة ١٧٦ من
`Doku/feed pdf/Alle Informati B2 - Deutsch (übersetzt).pdf` بتقول:

```
Lesen Teil 4 (Variante ·8)(Test ·160201, 160221) - 100%
Lesen und Schreiben Beschwerde (neue Variante ·8) (· 160201, 160221) - 100%
```

ونفس الصفحة فيها أسئلة ١٤–٢٠ بنصّها. طابقناها مع الملفات:

| الدليل | لقيناه بـ |
|---|---|
| `Schramm` | modell-08 وبس |
| `T-Shirts` | modell-08 وبس |
| `Überstundenregelung` + `Umsatzsteigerung` + `Jobticket` | modell-08 |
| مفتاح الحل: ١٩ → **A** | modell-08 → `A` ✓ |
| مفتاح الحل: ٢٠ → **C** | modell-08 → `C` ✓ |

**فالتعديل على ملف واحد بس:**

```
content/telc/b2/modell-08/text.txt
```

**النماذج السبعة التانية بتضلّ بلا Aufgabe 58.** هاد مقصود — ما في
مادة إلهن بالـPDF، وممنوع يتخترعلهن شي.

---

## التعديل ١ — رأس كتلة `block-sb`

بدّل الكتلة كاملة (حوالي سطر ٣٢):

**من:**
```
## Block: block-sb
Titel: Sprachbausteine
Minuten: 20
Hinweis: Aufgaben 46–57
Punkte: 6
Teile: sb1, sb2
```

**لَ:**
```
## Block: block-sb
Titel: Sprachbausteine und Schreiben
Minuten: 35
Hinweis: Aufgaben 46–58
Punkte: 20
Teile: sb1, sb2, fb
```

الـ٣٥ دقيقة والـ٢٠ نقطة من صفحة ٦٥ بالـPDF: الـ٣٥ دقيقة بتغطّي
SB1 وSB2 والـForumsbeitrag سوا، والنقاط ٣ + ٣ + ١٤ = ٢٠.

---

## التعديل ٢ — قسم جديد بآخر الملف

زيد هالقسم **بآخر الملف** (بعد `### Teil: sb2` وكل أسئلته):

```
### Teil: fb
Format: writing
Titel: Schreiben, Forumsbeitrag
Gruppe: Sprachbausteine und Schreiben
Minuten: 35
Punkte: 14
Maximum: 14
Anweisung: Wählen Sie eines der beiden Themen und schreiben Sie einen Forumsbeitrag von mindestens 100 Wörtern.
Text:
**Thema A**
Homeoffice 2 Tage pro Woche mit privatem Laptop.

**Thema B**
Betriebsausflug am Samstag. Man darf aber einen Tag frei nehmen.
Aufgaben:
[58] Schreiben Sie Ihre Meinung zu Thema A oder Thema B in das Firmenforum.
Punkt: Einleitung — worum geht es?
Punkt: Ihre eigene Meinung mit Begründung
Punkt: Zwei Argumente aus Ihrer Sicht
Punkt: Ein Vorschlag und ein Schlusssatz
```

### من وين إجت كل قطعة

- **نصّ Thema A وThema B:** حرفياً من صفحة ١٧٦، امتحان `160201`.
  ولا كلمة متغيّرة.
- **أسطر `Punkt:` الأربعة:** مبنيّة على الهيكل الرسمي بصفحة ٢١٠–٢١١
  (`ANREDE → EINLEITUNG → EIGENE MEINUNG → ARGUMENT → ARGUMENT →
  VORSCHLAG → SCHLUSSSATZ → GRUSSFORMEL`) — **مو مخترعة**، بس مو
  منقولة حرف بحرف من ورقة امتحان، لأنّ الـPDF ما بيعطي نقاط المهمّة
  مفصّلة. لو لقيت النقاط الأصلية بالتيليغرام، بدّلهن.

---

## محجوز — ممنوع تستعمله هلق

امتحان `160221` (نفس الصفحة ١٧٦) إله مواضيعه كمان:

> **Thema A:** Urlaubssperre im August und September wegen des
> Großauftrags. Es wurde vorgeschlagen, als Ausgleich für Urlaub eine
> Geldprämie in Höhe von 500 Euro zu zahlen.
>
> **Thema B:** Bei Online-Konferenzen soll die Kamera zwingend
> eingeschaltet sein.

**ما تحطّه بأي ملف.** نفس النموذج ما بياخد زوجين مواضيع — بالامتحان
الحقيقي الطالب بياخد زوج واحد. هاد مكتوب هون لحتى ما يضيع، لو صار في
نموذج تاني من نفس الـVariante بعدين.

---

## التحقّق

```bash
node tools/check_content.mjs telc/b2
```

**المطلوب بالضبط:**

```
✓ telc/b2/modell-08  FIRMENORGANIGRAMM · 14 قسم · 54 سؤال · 51 حلّ
...
8 جاهز · 0 فاضي · 0 فيه مشكلة · 0 ملف ناقص · 0 بلوك نقاطه ما بتطابق
```

انتبه: **١٤ قسم و٥٤ سؤال** (كانوا ١٣ و٥٣). والحلول بتضل ٥١ — طبيعي،
لأنّ مهامّ الكتابة ما إلها «حلّ».

الوصفة مجرّبة فعلياً: بتنقرا بلا ولا تحذير، زرّ Veröffentlichen
باللوحة بيشتغل، و`block-sb` بيصير `20/20`، ومجموع الامتحان `153`.

---

## المحظورات

- ❌ **ما تزيد Aufgabe 58 لَـmodell-01 … 07.** ما في مادة إلهن.
  خلّيهن ناقصين — ناقص معروف أحسن من مخترع.
- ❌ ما تخترع مواضيع Forumsbeitrag ولا نقاط ولا نصوص.
- ❌ ما تلمس ولا سؤال ولا حلّ ولا رقم نقاط موجود — كلهن انتصلّحوا
  وانتأكّد منهن مقابل الجدول الرسمي.
- ❌ ما تعمل محلّل تاني. المحلّل الوحيد `admin/parse.js`.
- ❌ ما تلمس `content/telc/b1/` — مولّد من `data/`.
