# The paste format

> **Ready-made templates** — you rarely need to write this by hand:
>
> | File | What it is |
> |---|---|
> | [`vorlage/b1-beispiel.txt`](vorlage/b1-beispiel.txt) | A complete telc B1 exam: all three blocks, all nine parts, all five formats, image and audio. Loads from **Beispiel einfügen**. |
> | [`vorlage/b1-leer.txt`](vorlage/b1-leer.txt) | The same skeleton with all 61 task slots empty. Loads from **Leere Vorlage**. |
> | [`vorlage/ki-prompt.md`](vorlage/ki-prompt.md) | The prompt to hand an AI together with a telc PDF, so it fills the blank template for you. |
>
> Lines starting with `//` are comments and are stripped before parsing —
> except inside `Extra:`, where every line is part of the JSON.
>
> Any `<…>` left over from a template is reported as a warning. A slot the
> AI forgot would otherwise import as content: `Lösung: <A bis J>` becomes
> an answer no student can ever match.

How exam text becomes an exam. The admin panel parses what you paste, shows you
what it understood, and only then offers to publish it.

## Why a fixed format and not an AI

The parser in `admin/parse.js` is deterministic. It costs nothing to run, needs
no API key, and never invents a question that was not in the text. When it
cannot read something it says so, in the preview, before anything is published.

If your source text is unstructured, convert it to this format *outside* the
app — that is a good use of an LLM — then paste the result and check the
preview. The review step is the point: nothing reaches students that you have
not looked at.

## Confidence in the format

`tests/markup.mjs` round-trips all 16 existing Modelltests through it: each test
is written out as markup, parsed back, and compared field by field against the
original. All 16 come back identical — 912 questions, no warnings. The format
is known to express real telc content, not just the easy cases.

## Structure

```
# TESTNAME                       ← the test
Untertitel: 61 Aufgaben · 150 Minuten

## Block: block-lv-sb            ← a timed part of the exam
Titel: Leseverstehen und Sprachbausteine
Minuten: 90
Hinweis: Aufgaben 1–40
Punkte: 105                      ← official maximum for the block
Fehlend: 0                       ← questions missing from the source
Teile: lv1, lv2, lv3, sb1, sb2

### Teil: lv1                    ← a section
Format: matching
Titel: Leseverstehen, Teil 1
Gruppe: Leseverstehen
Minuten: 20
Punkte: 5                        ← points per question
Maximum: 25                      ← official maximum for the section
Anweisung: Lesen Sie die Texte und die Überschriften.
Auswahl:
A = Bildband: Babys im Garten
B = Ratgeber für junge Eltern
Aufgaben:
[1] Ich möchte, dass Menschen die Welt mit anderen Augen sehen.
Lösung: A
[2] Ein Buch für alle, die gerade Eltern geworden sind.
Lösung: B
```

## The five formats

| `Format:` | What it is | How the answer is written |
|---|---|---|
| `matching` | match a text to an entry in `Auswahl:` | `Lösung: G` |
| `mc` | multiple choice, options on the question | `Lösung: B` |
| `wordbank` | fill a gap from `Auswahl:` | `Lösung: D` |
| `truefalse` | Richtig / Falsch | `Lösung: richtig` or `falsch` |
| `writing` | a letter to write; no answer key | — |

## Questions

A question starts with `[` its number `]`. Everything after it is the question
text until the next marker:

```
[6] Die Werbung in den Vereinigten Staaten
A) beschäftigt sich überhaupt nicht mit Deutschland.
B) zeigt immer wieder dasselbe Bild von Deutschland.
C) ist selten zu sehen.
Lösung: B
Erklärung: Im zweiten Absatz steht …
```

`Erklärung:` is optional and is shown to the student **after** submitting.

For a writing task:

```
[A] Antworten Sie auf den Brief.
Mindestwörter: 100
Punkt: Warum Sie gern nach Deutschland kommen möchten
Punkt: Wie Sie anreisen wollen
```

## Reading texts

```
Text:
**Leipzigerin geht in den USA auf Sendung**
Drei Monate Praktikum für junge Sachsen.
Manchmal fühle ich mich wie im Film, sagt sie.
```

One line is one paragraph. `**…**` marks a heading. Two reading texts in one
section are separated by a line containing `§§§`.

## Anything the format does not cover

`Extra:` takes raw JSON, merged into the section. This is how the writing task
carries its letter, hints, marking criteria and grade bands:

```
Extra:
{
 "brief": { "intro": "Eine Bekannte hat Ihnen geschrieben:", "greeting": "Liebe(r)…" },
 "hints": ["Schreiben Sie mindestens 100 Wörter."],
 "criteria": [{ "title": "Aufgabenbewältigung", "hint": "Sind alle vier Leitpunkte bearbeitet?" }],
 "grades": [{ "key": "A", "points": 5 }, { "key": "B", "points": 3 }],
 "factor": 3
}
```

The JSON may span several lines; it ends when its brackets balance.

## What the parser will not let past

The **Veröffentlichen** button stays disabled when the text has a structural
problem: no title, no sections, a section with no questions, a block pointing
at a section that does not exist, or a duplicated section or question id.

Other findings are warnings — shown, but not blocking. The most common is a
question with no `Lösung:`. That question will still be imported, and it will
never be graded, because grading reads `item_answers` and it will have no row
there. Read the warnings.

## What happens on publish

`admin_apply_import()` writes the whole test in one transaction. If the slug
already exists, its sections are deleted and rebuilt — an import replaces, it
never merges. Answers go to `item_answers`, which no client can read; the
questions go to `items`, which has no answer column at all.

Re-running the same import is safe and produces the same result.
