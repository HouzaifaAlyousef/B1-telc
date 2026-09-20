# Architecture

> **Status — partly superseded.** The **no server / `localStorage` only** architecture below is being replaced by Supabase.
> See [11-online-architecture.md](11-online-architecture.md) for the new design.
> What follows describes the code as it stands today.

## The one idea worth understanding

The project is split into **two stages that never run at the same time**:

```
   ONCE, on a developer's machine              EVERY TIME, in the student's browser
  ┌──────────────────────────────────┐        ┌───────────────────────────────────┐
  │  Doku/B1 Telc.pdf   (11 MB scan) │        │  index.html                       │
  │            │                     │        │     │                             │
  │            ▼                     │        │     ├── assets/style.css          │
  │  tools/telcpdf.py   PDF → rows   │        │     ├── assets/app.js   (the app) │
  │  tools/sections.py  rows → parts │        │     └── sw.js           (offline) │
  │  tools/spelling.py  OCR repair   │        │            │                      │
  │  tools/build.py     orchestrate  │        │            │ fetch()              │
  │            │                     │        │            ▼                      │
  │            ▼                     │        │  data/index.json                  │
  │  data/*.json  +  data/img/*.jpg  │───────►│  data/modell-NN.json              │
  └──────────────────────────────────┘        │  data/img/mNN-lv3.jpg             │
         Python, heavy deps                   └───────────────────────────────────┘
         run maybe twice a year                  Vanilla JS, zero dependencies
                                                 runs on any static host
```

**Nothing from the left half ships to the student.** Python, pdfplumber, the
11 MB PDF — none of it is needed at runtime. What ships is 460 KB of JSON,
1.3 MB of images, and ~1,200 lines of hand-written JS/CSS/HTML.

That separation is the best structural decision in the project. It means the
fragile part (parsing a scanned PDF with a duplicated text layer and OCR
artefacts) is a one-off batch job whose output is committed to git, while the
part students touch has no moving parts at all.

## File map

```
index.html                36 lines   — the entire page: header, <main>, SW registration
manifest.webmanifest      18 lines   — PWA install metadata
sw.js                     32 lines   — network-first cache
.nojekyll                            — stops GitHub Pages running Jekyll on the files
run.sh                               — one-click local server (added for this repo)

assets/
  app.js                 853 lines   — everything: routing, rendering, timer, scoring
  style.css              308 lines   — light + dark, mobile-first
  icons/                             — 192/512/maskable/apple-touch

data/
  index.json                         — list of the 16 tests (id, file, title, counts)
  modell-01..16.json                 — one self-contained test each (~30 KB)
  img/mNN-lv3.jpg          16 files  — the Leseverstehen 3 ad pages (images in the PDF)

tools/
  telcpdf.py             195 lines   — PDF → (page, y, x, text, font-size) rows
  sections.py            510 lines   — rows → questions, options, passages, banks
  spelling.py            129 lines   — repairs OCR damage using a German dictionary
  build.py               363 lines   — orchestrates the above, applies telc's point table
  bundle.py               66 lines   — packs everything into one standalone .html

Doku/
  B1 Telc.pdf             11 MB      — the source scan (see the copyright note below)

docs/                                — you are here
```

## Runtime architecture

There is no framework, no router, no build step, no `node_modules`. The whole
app is a **state object plus a set of functions that overwrite `main.innerHTML`.**

```js
const S = {
  index,    // the 16-test list
  modell,   // the open test
  run,      // the active run: which parts, how long, how many points
  answers,  // { itemId: answer }
  dropped,  // { itemId: [previously chosen letters] } — shown struck through
  tick,     // setInterval handle
  left,     // seconds remaining
  view      // 'home' | 'modell' | 'intro' | 'exam' | 'result'
};
```

Every screen is a `screenXxx()` function that builds an HTML string, assigns it
to `app.innerHTML`, and wires up `onclick` handlers. `go(view, fn)` is the only
navigation primitive: it sets `S.view`, shows/hides the back button, scrolls to
the top, and calls the renderer.

That is the entire architecture. For an app of this size it is the right call —
a framework would add more concepts than it removes. See
[03-frontend.md](03-frontend.md) for the detail, and
[09-code-review.md](09-code-review.md) for where this approach starts to strain.

## Data flow at runtime

```
boot()
  └─ fetch data/index.json ──────────────► S.index
       └─ screenHome()   16 tiles + "Fehler wiederholen" if mistakes exist
            └─ openModell(id)
                 └─ fetch data/modell-NN.json (cached in modellCache) ──► S.modell
                      └─ screenModell()  3 block cards + last results
                           └─ blockRun(m, blockId) ──► S.run
                                └─ screenIntro()   rules, resume/start
                                     └─ screenExam()   render + timer
                                          └─ finish()
                                               ├─ updateMistakes()  → localStorage
                                               ├─ saveResult()      → localStorage
                                               └─ screenResult()    score + per-question correction
```

Model files are fetched lazily, one at a time, and memoised in `modellCache`.
Opening all 16 would still be under 500 KB, so nothing here needs optimising.

## Persistence — four `localStorage` keys

| Key | Shape | Written when | Cleared when |
|---|---|---|---|
| `b1.progress` | `{modellId: {blockId: {points, max, pct, date, answers, grades?}}}` | on submit | user presses "Löschen" |
| `b1.mistakes` | `[{m: modellId, s: sectionId, i: itemNum}]`, capped at 500 | on submit | answered correctly later |
| `b1.session.<modell>.<run>` | `{answers, dropped, left, date}` | every 5 s while the timer runs, and on `pagehide`/`visibilitychange` | on submit or "Neu beginnen" |
| `b1.draft.<modell>.<run>` | the letter text | on every keystroke in the writing task | on submit or "Neu beginnen" |

There is no server, so this is the entire persistence layer. Its consequences:
clearing browser data wipes all progress, progress does not follow a student to
a second device, and nothing is recoverable. That is fine for a free tool and
disqualifying for a paid one — see [10-commercialisation.md](10-commercialisation.md).

The session and draft keys overlap almost completely; see
[09-code-review.md](09-code-review.md).

## A note on `Doku/B1 Telc.pdf`

The source PDF is a scan of published telc practice material. `tools/telcpdf.py`
even carries a regex to strip a third party's name out of the page footer:

```python
FOOTER = re.compile(r'ABDELLAH\s*FARHAN|LANGUAGE\s*Test|^\d{1,3}$')
```

That footer is a strong signal this is a redistributed copy, not a licensed
source. It has no effect on how the code works, but it decides whether the
project can legally be sold. Read
[10-commercialisation.md](10-commercialisation.md#the-blocking-issue-content-licensing)
before investing in payments or an admin panel.
