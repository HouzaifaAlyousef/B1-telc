# Overview — what this project is

> **Status — partly superseded.** The **no backend, no accounts, no network** decision below has been reversed.
> See [11-online-architecture.md](11-online-architecture.md) for the new design.
> What follows describes the code as it stands today.

## The core idea in one sentence

**Take the official telc Deutsch B1 practice exams — which exist only as a
scanned PDF — and turn them into an app that behaves like the real exam: real
time limits, real point weighting, real pass mark, instant correction.**

Everything else in the repo follows from that sentence.

## Why it exists

A student preparing for telc Deutsch B1 typically has a PDF of practice tests
and an answer key at the back. That is a bad way to practise:

- No timer, so you never learn to work under the real 90/30/30-minute pressure.
- Correcting yourself means flipping to the answer key for all 60 questions.
- No record of what you got wrong, so you re-practise what you already know.
- Points are printed in a table you have to apply by hand to know if you passed.

This app fixes exactly those four things, and nothing more. It is a **drilling
tool for people who already have a course or textbook** — it does not teach
grammar, it does not explain rules, it has no lessons.

## The design decision that shapes everything

**The interface is entirely in German — no Arabic, no English.**

That is on purpose: the exam is in German, so the practice environment is in
German. The student reads `Abgeben & korrigieren`, not "Submit". The only
Arabic in the product is in the repo's README, aimed at the developer, not
the learner.

The second shaping decision: **no backend, no accounts, no network**. The app
is a folder of static files. It installs to a phone home screen as a PWA and
works on a plane. This makes it free to host and impossible to break — and it
is also the single biggest obstacle to selling it (see
[10-commercialisation.md](10-commercialisation.md)).

## What a student actually does

```
Home  ──► pick one of 16 Modelltests
          │
          ├─► Leseverstehen + Sprachbausteine   40 questions   90 min   105 pts
          ├─► Hörverstehen                      20 questions   30 min    75 pts
          └─► Schriftlicher Ausdruck             1 letter      30 min    45 pts
                                                            ──────────────────
                                                              225 pts, pass ≥ 135

Start ──► timer runs ──► answer ──► Pause (timer stops, tasks blurred)
                              └──► Abgeben ──► score, grade, every question
                                               with your answer vs. the solution
                                                    │
                                                    └─► wrong ones go into
                                                        "Fehler wiederholen"
```

`Fehler wiederholen` is the feature that makes it more than a PDF viewer: it
collects every question you got wrong across all 16 tests, rebuilds the reading
passage and word bank each question needs, and drills you on just those —
untimed. Answer one correctly and it leaves the list.

## The three exam parts, and one honest gap

| Part | Status |
|------|--------|
| Leseverstehen (reading) | Full — texts, questions, answers |
| Sprachbausteine (grammar/vocab gaps) | Full |
| **Hörverstehen (listening)** | **Text only — no audio exists in the source PDF** |
| Schriftlicher Ausdruck (writing) | Full task, self-assessed against telc's 3 criteria |
| Mündliche Prüfung (speaking) | **Not covered at all** |

The listening gap is handled honestly: the app shows a warning before you start
that section, explaining it is for reviewing statements against the solution,
not for ear training. The speaking part is simply absent — telc B1 has an oral
exam and this app does not touch it.

Both gaps matter commercially and are covered in
[10-commercialisation.md](10-commercialisation.md).

## Content scale

| | |
|---|---|
| Modelltests | 16, named after the stamp on each PDF (PETRA, EVA1, SOPHIE, …) |
| Questions | 912 total |
| Complete tests | 11 of 16 have all 61 questions |
| Incomplete tests | 5 (models 12–16) are missing 64 questions total — cut off in the source scan |
| Questions with an explanation | 160 of 912 (17 %) — and those are auto-generated one-liners |

Incomplete tests are not hidden. The app tells you how many questions are
missing and **rescales your score to the official maximum**, so a 24-question
model-12 reading block still reports out of 105 points and stays comparable to a
complete one. See [07-scoring.md](07-scoring.md).

## What this project is not

- Not a course. No teaching material, no grammar explanations, no vocabulary trainer.
- Not a listening trainer. There is no audio.
- Not a speaking trainer.
- Not multi-user. One browser = one student, and clearing site data erases everything.
- Not a product yet. There is no account, no payment, no admin, no analytics.
