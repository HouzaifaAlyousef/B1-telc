# The frontend app — `assets/app.js`

> **Status — partly superseded.** `load`/`save` become async against Supabase, and grading moves out of the client.
> See [11-online-architecture.md](11-online-architecture.md) for the new design.
> What follows describes the code as it stands today.

853 lines, no dependencies, no build step. This document walks it top to bottom.

## Shape of the file

| Lines | Section | Contents |
|-------|---------|----------|
| 1–52 | Helpers | `esc`, `mmss`, `ask` (modal), `toast`, `load`/`save` |
| 54–96 | Timer & navigation | `startTimer`, `stopTimer`, `go`, back-button behaviour |
| 98–142 | Home | `boot`, `screenHome` |
| 144–250 | Test screen | `loadModell`, `screenModell`, `blockRun`, `reviewRun` |
| 252–307 | Intro screen | `screenIntro` — rules, resume vs. start |
| 309–375 | Exam screen | `screenExam`, part navigation, scroll spy |
| 376–521 | Rendering | `renderBrief`, `renderPassages`, `renderBank`, `renderItem`, `bindInputs`, `syncBank` |
| 523–558 | Progress & pause | `updateProgress`, `pauseExam` |
| 560–612 | Mistake list | `updateMistakes`, `drillRun` |
| 614–708 | Correction | `noteOf`, `saveResult`, draft/session storage, `finish` |
| 710–847 | Results | `screenResult`, `screenWriting` |
| 849–853 | Lifecycle | `pagehide` / `visibilitychange` save, `boot()` |

## Navigation

One function:

```js
function go(view, fn){
  S.view = view;
  elBack.hidden = (view === 'home');
  window.scrollTo(0, 0);
  fn();
}
```

No URL routing, no history entries. A consequence worth knowing: **the browser
back button leaves the app** rather than going back a screen, and a page reload
always lands on the home screen. The in-app `‹ Zurück` button is the only way
back, and it asks for confirmation if you are mid-exam.

## The five screens

### `screenHome`
Renders the 16 tiles from `S.index`, plus a `Fehler wiederholen` tile if
`b1.mistakes` is non-empty.

### `screenModell`
Renders the three block cards. Each shows minutes, question count, points, and —
if a previous attempt is stored — the score, the date, and `Ansehen` / `Löschen`
buttons. `Ansehen` calls `reviewRun`, which reconstructs the run and replays the
result screen with the answers you gave at the time.

### `screenIntro`
The pre-flight screen. It shows the instruction text, the parts, warnings
(missing questions, the no-audio note), and either `Start ▶` or —
if an unfinished session is stored — `Prüfung fortsetzen — 12:34 übrig`.

### `screenExam`
Builds every part in one long scrolling page:

```js
run.parts.map(p => `
  <section class="part" id="part-${p.id}">
    <h2>…</h2><div class="instr">…</div>
    ${renderPassages(p)}${renderBank(p)}
    ${p.items.map(it => renderItem(p, it)).join('')}
  </section>`)
```

Plus a sticky `.partnav` jump bar (LV 1, LV 2, SB 1 …) and a fixed bottom bar
with the progress counter, `Pause`, and `Abgeben & korrigieren`.

The jump bar has a scroll spy — `markCurrentPart()` runs inside a
`requestAnimationFrame` on a passive scroll listener and highlights whichever
part's top edge is above y=130. Answering a question also jumps the highlight
immediately via `markPart()`.

### `screenResult` / `screenWriting`
`screenResult` shows the score card, then every question with ✔/✘, your answer,
the correct answer, and the explanation if one exists.

`screenWriting` is different because a letter cannot be auto-graded. It shows
your text, the task again, and then telc's three criteria — Aufgabenbewältigung,
Kommunikative Gestaltung, Formale Richtigkeit — for you to grade yourself
A/B/C/D (5/3/1/0 points, sum × 3 = 45). The score card appears once all three
are rated. See [07-scoring.md](07-scoring.md).

## Rendering questions

`renderItem(sec, it)` switches on `sec.format`:

| format | UI |
|--------|-----|
| `mc` | radio-style `<label class="opt">` per option |
| `truefalse` | two inline options, Richtig / Falsch |
| `matching`, `wordbank` | a `<select>` listing the bank |
| `writing` | a `<textarea>` plus a live word counter |

Two behaviours are more thoughtful than they first appear:

**Struck-through previous choices.** When you change a multiple-choice answer,
the old letter is pushed into `S.dropped[itemId]` and rendered with a line
through it. This mirrors what a student does on paper and makes the trail of
reasoning visible.

**Bank options lock themselves.** `syncBank()` implements telc's rule "jede
Überschrift passt nur einmal": once a letter is used, it is `disabled` in every
other `<select>` of that part. `X` is exempt because in Leseverstehen Teil 3 it
means "no matching ad" and can repeat.

## Escaping

Every interpolation goes through `esc()`, which escapes `& < > "`. All HTML
attributes in the templates use double quotes, so this is sufficient. Content
originates from local JSON generated from the PDF, so there is no untrusted
input path today — but if user-generated content is ever added (a comment field,
a shared answer), this needs revisiting.

## The timer

```js
S.tick = setInterval(() => {
  S.left--;
  paint();
  if (S.left % 5 === 0) saveSession(S.run);
  if (S.left <= 0){ stopTimer(); onEnd && onEnd(); }
}, 1000);
```

It counts down a stored *remaining* value, not a wall-clock deadline. Two
consequences, both intentional:

- Closing the app and coming back later does **not** consume exam time. You
  resume with exactly the seconds you had.
- Browsers throttle `setInterval` in background tabs, so switching apps
  effectively pauses the clock too.

For a self-study tool that is the friendly behaviour, and the Arabic comment at
line 650 says so explicitly. Be aware it means the timer is not an enforceable
constraint — relevant if the app ever issues certificates
([10-commercialisation.md](10-commercialisation.md)).

`Pause` is the explicit version: it stops the timer, saves, blurs the questions
via `body.paused`, and shows a modal.

## Mistake tracking and the drill

`updateMistakes(run)` runs on every submit. For each question in the run it
builds `{m: modellId, s: sectionId, i: itemNumber}`, removes every previously
stored record for questions in this run, then re-adds the ones you got wrong.
So answering correctly on a retry removes the question from the list. The list
is capped at the most recent 500 entries. Writing tasks are skipped.

`drillRun()` is the interesting one. A stored mistake is just three ids — but a
Sprachbausteine gap is unanswerable without its text, and a matching question is
unanswerable without its bank. So the drill rebuilds a real section:

```js
parts.push({ ...sec,              // keep passages, bank, instruction, format
             mid, sid: sec.id,
             id: `${mid}-${sec.id}`,
             title: `${m.title} · ${sec.title}`,
             items,               // only the ones you got wrong
             pointsPerItem: 1, maxPoints: items.length,
             availablePoints: items.length });
```

Item ids are rewritten to `modell-01~lv1~3` so that question 3 from two
different tests cannot collide in `S.answers`, with the original number kept in
`num` for display. The drill runs untimed, scores 1 point per question, and
never overwrites a stored exam result.

## Persistence functions

| Function | Key |
|---|---|
| `saveResult(run, points, max, extra)` | `b1.progress` |
| `saveSession(run)` / `loadSession` / `clearSession` | `b1.session.<modell>.<run>` |
| `saveDraft(runId, text)` / `loadDraft` / `clearDraft` | `b1.draft.<modell>.<run>` |
| `updateMistakes(run)` | `b1.mistakes` |

`saveSession` is guarded by `S.view === 'exam'` and skipped for drills.
`saveDraft` has no guard and fires on every keystroke in the writing textarea —
which makes it redundant with the session, since `updateProgress()` (and
therefore `saveSession`) fires on the same keystroke. See
[09-code-review.md](09-code-review.md).

All storage calls are wrapped in try/catch so that Safari private mode, where
`localStorage.setItem` throws, degrades to a working-but-forgetful app rather
than a crash.
