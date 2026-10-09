# Code review

> **Status — mostly resolved.** Where each finding stands after the move to
> Supabase:
>
> | # | Finding | Now |
> |---|---|---|
> | 1, 2 | Offline broken | Superseded — exams require a network by design ([11](11-online-architecture.md)) |
> | 3 | `bundle.py` breaks silently | **Deleted** — its premise (all tests in one file) is what the architecture now prevents |
> | 4 | „1 Aufgaben" | **Fixed** — one `plural()` helper |
> | 5 | Dead dark-mode toggle | Was already gone |
> | 6 | Wrong dependency list | Superseded — the README no longer lists build deps |
> | 7 | 11 MB PDF ships to visitors | **Fixed** — `tools/build_dist.sh` refuses to build if `data/` or any answer key reaches the output |
> | 8 | Two persistence mechanisms | **Fixed** — the draft is gone; the session already saved the same text, and the misleading "Entwurf wiederhergestellt" banner went with it |
> | 9 | Convoluted `missing` | Still there in `tools/build.py`, which only runs when regenerating from the PDF |
> | 10 | Unused parameters | Minor, unchanged |
> | 11 | README stale | **Fixed** — rewritten |
> | 12 | No tests, no CI | **Fixed** — 245 assertions across five runners; CI still not set up |
>
> The findings below are the original text, kept for the reasoning.

Findings from a full read of every file, ranked by what they cost you. Each one
was verified against the running app or the data, not inferred.

**Overall: this is well-built.** 2,500 lines with no dependencies that does
something genuinely hard (parse a scanned PDF into 912 answer-checked questions)
and something genuinely useful (a faithful exam simulator). The comments explain
*why*, not *what* — the note about why a matching question needs its whole bank
rebuilt for the drill is the kind of thing most codebases lose. The parser's
refusal to ship a question it cannot tie to the answer key is the right
engineering instinct. What follows is a list of specific things to fix, not a
verdict on the whole.

---

## 1. Offline is broken — the headline feature does not work · **HIGH**

`assets/app.js:101`, `assets/app.js:146`, `sw.js:30`

Reproduced: install the app, stop the server, reload. The shell loads from cache
correctly, then the screen reads *"Die Testdaten konnten nicht geladen werden."*
No test is reachable offline, on any platform.

Cause: the app requests `data/index.json?v=<Date.now()>`, and
`caches.match(request)` keys on the full URL **including the query string**. The
timestamp differs every load, so a data request can never hit the cache.

Measured in the running app:

```
cache contains: /data/index.json, /data/modell-01.json?v=1788455497188
caches.match('data/index.json?v=' + Date.now())                     → MISS
caches.match('data/index.json?v=' + Date.now(), {ignoreSearch:true}) → 200
```

Fix, in `sw.js`:

```diff
-      .catch(() => caches.match(e.request).then(r => r || caches.match('./index.html')))
+      .catch(() => caches.match(e.request, { ignoreSearch: true })
+                     .then(r => r || caches.match('./index.html')))
```

Then bump `CACHE` to `telc-b1-v3` so installed copies pick it up. Better still,
also drop the `?v=` cache-buster — it is redundant under a network-first worker
and it defeats the browser's own HTTP cache, so every launch re-downloads data.

Full analysis in [06-pwa-offline.md](06-pwa-offline.md).

## 2. Offline only covers tests you already opened · **HIGH**

`sw.js:3-8`

Even after fix #1, `CORE` precaches the shell and `data/index.json` but none of
the 16 model files or 16 images. A student who installs the app and boards a
plane can open only the tests they happened to load while online.

The entire content set is 1.76 MB. Precache all of it. `addAll` is atomic — one
404 aborts the install — so generate the list at build time rather than
hand-maintaining it.

## 3. `bundle.py` breaks silently · **MEDIUM**

`tools/bundle.py:29-34`

The bundler swaps the app's two `fetch` calls for reads from an inlined object
using exact string replacement:

```python
js = js.replace("S.index = await (await fetch('data/index.json?v=' + Date.now())).json();",
                "S.index = DATA.index;")
```

Reformat either line in `app.js` — or apply fix #1's suggestion to remove `?v=` —
and `str.replace` matches nothing, returns the string unchanged, and the bundler
**exits successfully** having produced an HTML file that tries to `fetch()` from
`file://` and shows the error screen. Nothing warns you.

Minimum fix — assert the substitution happened:

```python
def swap(js, old, new):
    if old not in js:
        raise SystemExit(f'bundle.py: pattern not found in app.js:\n  {old}')
    return js.replace(old, new)
```

Better: have `app.js` read from `window.DATA` when it exists and fall back to
`fetch` otherwise, so the bundler injects data and never rewrites code.

## 4. German plural: "1 Aufgaben" · **MEDIUM**

`assets/app.js:181`, `assets/app.js:269`

Every student sees this on every test screen — the Schriftlicher Ausdruck card
reads **"1 Aufgaben · 45 Punkte"**. It should be *1 Aufgabe*.

In a German-language product sold to people learning German, a grammar error in
the chrome is worse than a cosmetic bug. The author already handles this
correctly one screen earlier (`${nMist === 1 ? '' : 'n'}` at line 129), so it is
an oversight, not a gap in knowledge. Extract that into a helper:

```js
const plural = (n, one, many) => `${n} ${n === 1 ? one : many}`;
// plural(n, 'Aufgabe', 'Aufgaben')
```

and use it at all four call sites.

## 5. Dark mode's explicit toggle is dead code · **MEDIUM**

`assets/style.css:19-25`

The CSS supports a manual theme override via `:root[data-theme="dark"]` and
`:root:not([data-theme="light"])`. Nothing ever sets the attribute:

```
$ grep -rn "data-theme" --include=*.js --include=*.html .
(no matches)
```

So dark mode follows the OS and cannot be overridden. Since students often study
at night on a phone whose system theme is light, the toggle is worth having, and
the CSS is already written for it — about ten lines of JS plus a header button.
Otherwise delete the `[data-theme]` block so the next reader is not misled.

## 6. The build's dependency list is wrong · **MEDIUM**

`README.md:57`

```bash
pip install pdfplumber pypdfium2 pillow
```

`build.py:4` imports `pypdf` and `spelling.py:48` imports `spellchecker`
(package `pyspellchecker`). Following the README gives you an `ImportError`.
Verified on a clean environment.

Fix the line, and add a `requirements.txt` so the versions are pinned — this
pipeline depends on `pdfplumber`'s coordinate output, which is not a stable API.

## 7. The 11 MB source PDF ships to every visitor · **MEDIUM**

`Doku/B1 Telc.pdf`

GitHub Pages serves the whole repo, so the scan is publicly downloadable at
`https://<user>.github.io/B1-telc/Doku/B1%20Telc.pdf`. It is also 11 MB of a
25 MB `.git`.

Two separate reasons to move it: it is dead weight at runtime (nothing needs it
after the build), and it is redistribution of copyrighted telc material from a
public URL — see [10-commercialisation.md](10-commercialisation.md). Keep it out
of the deployed tree; if the repo goes public, keep it out of the repo.

## 8. Two persistence mechanisms for the same data · **LOW**

`assets/app.js:643-665`

The writing task saves through both `b1.draft.*` (on every keystroke) and
`b1.session.*` (also on every keystroke, via `updateProgress` → `saveSession`).
They are cleared together, restored in the same place, and the session's
`answers` already contains the letter text.

Tracing the states: pressing `Start` clears both; pressing `Fortsetzen` restores
from the session and the draft is ignored; drills never contain writing sections
so `saveDraft` never fires there. The draft has no path where it is the only
copy. Delete `saveDraft`/`loadDraft`/`clearDraft`/`draftKey` and the branch in
`screenIntro` — about 15 lines — and keep the session.

One nuance: the `Entwurf wiederhergestellt` banner in `renderItem` currently
fires on every resume, not only after a crash, so its wording is misleading
either way.

## 9. Convoluted `missing` computation · **LOW**

`tools/build.py:336-338`

```python
'missing': sum(by_id[p]['missing'] for p in mine)
         + sum(COUNTS[k.upper()] for k, _, ps, _, _ in [(bid, t, parts, mins, hint)]
               for k in ps if k not in mine and k != 'sa')
```

The second term builds a one-element list to unpack a tuple it already has in
scope, then rebinds `k` from block id to part id mid-comprehension. It computes
the right answer — verified across all 48 blocks — but it reads like a bug.

```python
+ sum(COUNTS[p.upper()] for p in parts if p not in mine and p != 'sa')
```

## 10. Unused parameters · **LOW**

`tools/build.py:114`

`build_section(kind, model_no, pages, words_by, key, keyword, pdfdoc, extra_rows=())`
never references `model_no` or `pdfdoc` (confirmed by AST walk). Both are passed
at the call site. Drop them.

## 11. README is stale · **LOW**

`README.md:10` says **٨٩٠ سؤال** (890 questions). The actual count after the last
two commits is **912**. `README.md:39-53` also omits `tools/spelling.py` and
`tools/bundle.py` from the structure listing.

The question count is printed by `build.py` on every run; worth pasting in when
the data is regenerated.

## 12. No tests, no CI · **MEDIUM for a product, LOW today**

There is no test of any kind and no `.github/workflows`. For a hobby project
that is a fair trade. For something you intend to charge for, two cheap safety
nets pay for themselves immediately:

- **A data validator** run in CI. The eight invariants in
  [04-data-format.md](04-data-format.md) are all checkable in about 40 lines,
  and they are exactly what a parser regression would break. I ran them against
  the current data — all 16 files pass, so you would be locking in a green state.
- **A smoke test** that boots the app in a headless browser, runs one block,
  submits, and asserts the score. That would have caught findings #1 and #4.

---

## Structure

**Is the structure good? Yes, for what it is today — with one part that will not
scale.**

What is right:

- **The two-stage split is excellent.** The fragile PDF parsing runs once on a
  developer machine and its output is committed; the student-facing app has no
  dependencies and no build step. This is the decision that keeps the runtime at
  zero maintenance, and it should be preserved through any rewrite.
- `tools/` decomposes sensibly along real seams — `telcpdf` (geometry),
  `sections` (content), `spelling` (repair), `build` (orchestration and telc's
  rules). Each is independently understandable.
- Domain knowledge lives in **data**, not code — `POINTS`, `COUNTS`, `BLOCKS`
  are tables in one place, baked into the JSON at build time, so the app never
  hard-codes telc's rules.
- Naming follows the domain in German throughout (`modell`, `blocks`, `sections`,
  `Aufgaben`), which makes the code readable next to the actual exam.

What will not scale:

- **`assets/app.js` is 853 lines doing five jobs** — routing, rendering, timing,
  scoring, persistence — in one flat scope. It is still navigable today because
  the sections are ordered and commented. It stops being navigable the moment you
  add accounts, sync, payments and audio. Split along the seams that already
  exist in the file's own comment banners:

  ```
  assets/
    state.js       S, load/save, the storage keys
    screens/       home, modell, intro, exam, result, writing
    render.js      renderItem, renderBank, renderPassages, renderBrief
    scoring.js     finish, saveResult, noteOf, fmtP
    drill.js       updateMistakes, drillRun
  ```

  Plain ES modules (`<script type="module">`) need no bundler and keep the
  zero-dependency property.

- **`innerHTML` + `onclick` rebuilds every screen from scratch.** Fine at this
  size. It becomes a problem when a screen has state worth preserving across a
  re-render — which is exactly what per-question feedback, saved progress
  indicators or a live sync status will need.

- **All persistence goes through `localStorage` with keys assembled by string
  concatenation.** There is no schema and no migration path, so any change to a
  stored shape silently breaks returning students. Before you have paying users,
  put a version number in the stored objects and a single `migrate()` on boot.

---

## The three-language question

The UI is German, the code comments are Arabic (Levantine), and these docs are
English. The German UI is a correct and deliberate product decision. The Arabic
comments are good comments — they explain reasoning, which is the hard part.

It is worth naming the trade-off, though, because it bears on the commercial
goal: Arabic comments mean the pool of developers who can maintain
`tools/sections.py` is roughly "you". The parser is the most intricate code in
the repo and the least self-evident — if this becomes a business, that is a
single point of failure. There is also one inconsistency worth tidying:
`app.js` is commented in German except for lines 650–652, which are Arabic.

No need to rewrite anything. But if you take on a collaborator, translating
`sections.py`'s docstrings first would buy the most.
