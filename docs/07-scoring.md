# Scoring

> **Status — partly superseded.** The point rules are unchanged, but scoring now runs **on the server** in `submit_attempt()`.
> See [11-online-architecture.md](11-online-architecture.md) for the new design.
> What follows describes the code as it stands today.

The app reproduces telc's official point table rather than counting questions.
This document is the reference for those rules and how the code applies them.

## The official table

telc Deutsch B1, written exam — 225 points, pass at 60 % = 135.

| Block | Part | Questions | Points each | Part total | Block total | Time |
|---|---|---|---|---|---|---|
| Leseverstehen + Sprachbausteine | Leseverstehen 1 | 5 | 5.0 | 25 | **105** | **90 min** |
| | Leseverstehen 2 | 5 | 5.0 | 25 | | |
| | Leseverstehen 3 | 10 | 2.5 | 25 | | |
| | Sprachbausteine 1 | 10 | 1.5 | 15 | | |
| | Sprachbausteine 2 | 10 | 1.5 | 15 | | |
| Hörverstehen | Hörverstehen 1 | 5 | 5.0 | 25 | **75** | **30 min** |
| | Hörverstehen 2 | 10 | 2.5 | 25 | | |
| | Hörverstehen 3 | 5 | 5.0 | 25 | | |
| Schriftlicher Ausdruck | — | 1 letter | — | 45 | **45** | **30 min** |
| | | **61** | | | **225** | **150 min** |

Note the weighting: one Leseverstehen 1 question is worth 5 points while one
Sprachbausteine question is worth 1.5. Counting correct answers would misreport
a student's result badly — hence the table.

The values live in `tools/build.py` (`POINTS`, `COUNTS`, `BLOCKS`) and are baked
into each `modell-NN.json` at build time, so the app never hard-codes them.

## Block time is not the sum of part times

Each section carries a `minutes` field (LV1 15, LV2 20, LV3 20, SB1 20, SB2 15
= 90) used only as guidance. The **block** carries the authoritative 90 minutes,
and that is what the timer counts. The student allocates their own time across
the five parts, exactly as in the real exam.

## Rescaling incomplete tests

Five of the sixteen tests are missing questions that were cut off in the source
scan. Rather than hide them or let them score out of a different maximum, each
section stores two numbers:

- `maxPoints` — the **official** maximum (always 25 / 15 / 45 …)
- `availablePoints` — what is reachable from the questions that survived

`finish()` scales the first onto the second:

```js
let earned = 0;
run.parts.forEach(p => p.items.forEach(it => {
  if (S.answers[it.id] === it.answer) earned += p.pointsPerItem;
}));
const points = Math.round(earned / run.availablePoints * run.maxPoints * 10) / 10;
```

**Worked example — Modell 12, Leseverstehen + Sprachbausteine.** 16 of 40
questions are missing, so `availablePoints` is 62.5 against an official
`maxPoints` of 105. A student who earns 50 of the available 62.5 is reported as

```
50 / 62.5 × 105 = 84.0 points out of 105   (80 %)
```

Their percentage is therefore comparable with a complete test, which is the
point. The app also warns before the block starts:

> In diesem Modelltest fehlen 16 Aufgaben — sie sind in der Vorlage
> abgeschnitten. Ihr Ergebnis wird auf die offiziellen 105 Punkte umgerechnet.

The same rescaling runs per part on the result screen, so each part's line also
reads out of its official maximum.

**The caveat to state plainly:** rescaling assumes the missing questions would
have been answered at the same rate as the present ones. With 16 of 40 missing
that is a real extrapolation, not a measurement. It is the honest choice among
the available options — but a student's Modell 12 score is an estimate, and
Modelltests 1–11 remain the ones to trust.

## Grades

telc's bands, applied to the percentage:

```js
function noteOf(pct){
  if (pct >= 90) return 'sehr gut';
  if (pct >= 80) return 'gut';
  if (pct >= 70) return 'befriedigend';
  if (pct >= 60) return 'ausreichend';
  return 'nicht bestanden';
}
```

The result card shows points, percentage, grade, a progress bar coloured by
pass/fail, and `bestanden ab 135 Punkten (60 %)`.

## The writing task

A letter cannot be auto-graded, so the app implements telc's own rubric as
guided self-assessment. Three criteria, four grades each:

| Criterion | What the student judges |
|---|---|
| Aufgabenbewältigung | Are all four content bullets covered appropriately? |
| Kommunikative Gestaltung | Salutation, closing, register, connected sentences? |
| Formale Richtigkeit | Do grammar/vocabulary/spelling errors impede understanding? |

Grades A = 5, B = 3, C = 1, D = 0. Sum × `factor` (3) = up to 45 points.

The score appears only once all three are rated. The chosen grades are stored in
`b1.progress` alongside the result, so `Ansehen` restores both the text and the
rating. Between submitting and rating, the result is stored with `points: null`
and displayed as `noch nicht bewertet` — the text is never lost while awaiting a
grade.

Self-assessment is the weakest link in the whole app. A learner at B1 is not
well placed to judge their own *Formale Richtigkeit* — the errors they can see
are not the ones costing them points. This is the single clearest place where an
LLM would add real value; see
[10-commercialisation.md](10-commercialisation.md).

## Formatting

`fmtP()` renders points in German convention — `2.5 → "2,5"`, `25.0 → "25"` —
and rounds to one decimal:

```js
const fmtP = n => (Math.round(n * 10) / 10).toString().replace('.', ',');
```

## Verification

Scoring was checked against a live run: Hörverstehen with 10 of 20 answers
correct produced **37,5 / 75 · 50 % · nicht bestanden**, with per-part lines of
15/25, 12,5/25 and 10/25. That matches the table by hand (2×5.0 + 5×2.5 + 2×5.0
= 32.5 … rescaled per part), and all 48 block-level point totals across the 16
tests were verified to be internally consistent.
