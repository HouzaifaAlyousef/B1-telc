# The build pipeline — `tools/`

> **Status — partly superseded.** Still valid for the existing 16 tests. New content arrives as **pasted text**, not PDFs.
> See [11-online-architecture.md](11-online-architecture.md) for the new design.
> What follows describes the code as it stands today.

This is where the real engineering is. Turning a scanned, double-printed,
watermarked PDF into 912 answer-checked questions is a much harder problem than
the app that displays them, and the four Python files solve it with coordinate
geometry rather than guesswork.

**You do not need any of this to run or deploy the app.** The output is
committed to `data/`. Read on only if you need to regenerate it.

## Running it

```bash
pip install pdfplumber pypdfium2 pillow pypdf pyspellchecker
python3 tools/build.py "Doku/B1 Telc.pdf" data
```

> The README lists only `pdfplumber pypdfium2 pillow`. `build.py` also imports
> `pypdf` and `spelling.py` imports `spellchecker` (the `pyspellchecker`
> package), so the README's line alone leaves you with an `ImportError`.

Output: `data/index.json`, `data/modell-01..16.json`, `data/img/mNN-lv3.jpg`,
plus a per-model line on stdout showing how many questions each section yielded.

## Stage 1 — `telcpdf.py`: pixels to rows

### The duplicated text layer
The PDF draws every glyph **twice**, at identical coordinates. Left alone, all
text comes out as `LLAANNGGUUAAGGEE`. `dedupe()` removes it by keying on
`(x0, top, text)` rounded to 0.1 pt:

```python
key = (round(c['x0'], 1), round(c['top'], 1), c['text'])
```

### Characters to rows
`rows_of(page)` groups characters whose `top` differs by ≤ `ROW_TOL` (2.5 pt)
into one line, sorts by x, then reinserts spaces the PDF does not contain:

- gap > `COL_GAP` (12 pt) → a column break, emitted as three spaces
- gap > 42 % of the previous glyph's width → an ordinary space

Each row comes out as `(y, x0, text, font_size)`. **Font size is carried all the
way through** because it is the only signal for headings — the PDF's font names
are obfuscated (`font2`, `font4`), so "is this bold?" is unanswerable and "is
this bigger than the page median?" is used instead.

### Multi-page sections
`rows_for()` merges the pages of one section, offsetting y by `page_index *
10000`. That gives every row a globally sortable y while keeping the page
recoverable as `y // 10000` — used later for per-page font-size medians.

### Finding the tests
Every model ends with a `Lösungen` page. `read()` classifies each page by
searching its de-spaced text for section headers (`Leseverstehen,Teil1` → `LV1`,
…), then cuts the document at each answer-key page. Everything between two keys
is one Modelltest.

### Parsing the answer key
The key page is a loose grid of numbers and letters that do **not** reliably
share a text line. `parse_key()` therefore matches by geometry: for each
question number, take the nearest answer token to its right within 130 pt
horizontally and 9 pt vertically.

```python
near = [c for c in cands if 0 < c[0] - x1 < 130 and abs(c[2] - y) <= 9]
pick = min(near, key=lambda c: (c[0] - x1) + abs(c[2] - y))
```

For Sprachbausteine the key also prints the correct **word** after the letter
("21 b Ihrem"). That word is captured into `words_for` and becomes both a
cross-check and the `explain` text.

## Stage 2 — `sections.py`: rows to questions

510 lines, one parser per section type. The recurring problem is that **question
numbers and option letters are frequently missing from the text layer or printed
on their own line**, so almost nothing can be matched by regex alone.

### `windows(rows, lo, hi)` — splitting on question numbers
Question *n* owns every row between its own y and the y of *n+1*. Because some
pages are scanned twice, the same numbers can appear more than once; the parser
collects every ascending run of numbers and keeps the longest (ties → the last).

### `paragraphs(rows)` — text into paragraphs and headings
- The median line gap is measured, and any jump larger than 1.4× starts a new
  paragraph. An indent also starts one.
- A row is a heading if its font size exceeds 1.12× the page's median **and**
  that size is not shared by four or more rows on the page (a whole block of
  larger text is a text block, not a heading).
- Two-line headings are merged back together; a "heading" longer than 120
  characters is demoted to body text.

### `parse_options()` — A/B/C without letters
Option letters are often absent. The parser leans on two invariants that always
hold: there are exactly three options, and their vertical order *is* the letter
order. Letters, where present, are used only to verify — if a found letter
contradicts the position, the whole question is rejected.

### `parse_sb1()` — the grid
The Sprachbausteine 1 options sit in a 3–4 column grid below the letter, each
cell holding a gap number and three choices. Three separate corruptions are
handled:

1. A gap number glued to the previous column's text (`"besondere 26"`) — split
   by interpolating the x of the break.
2. A gap number appearing twice (once in the letter, once in the grid) — the
   lower one wins, since the grid is always below.
3. An option letter glued to its own text (`"Aim"` vs. the real word `"Aber"`) —
   disambiguated by whether the token starts at the letter column's x.

Cells are then found by clustering lines on the *gap* between them rather than
by the numbers' own coordinates, because a gap number is often printed slightly
below its first option.

### `parse_sa()` — the letter
Closing formulas vary too much to match (`Herzliche Grüße`, `Alles Liebe`,
`Hoffentlich bis bald`…), so the parser works **backwards** from a fixed point:
find the first bullet, walk back to the `Schreiben/Antworten Sie` task line, and
whatever short line sits before that is the signature.

## Stage 3 — `spelling.py`: repairing OCR damage

The scan produces four recurring corruptions. Each has a rule:

| Damage | Example | Rule |
|---|---|---|
| Doubled letter | `wwie` | drop one if the result is a dictionary word |
| Lost umlaut | `wunderschon` | try ü/ö/ä substitutions |
| Two words glued | `passendeReihenfolge` | split at lowercase→uppercase if both halves are words |
| One word split | `Prak tikantinnen` | join if neither half stands alone and the join is plausible |

The discipline that makes this safe: **a fix is accepted only if the result is
in a German dictionary and the original is not.** So `Deutschkurs` — a valid
compound absent from the dictionary — is never touched, because the rule never
fires on a word it cannot improve.

Two escape hatches exist for where the rules misfire: `KEEP` (correct words the
rule would mangle — `Bess` from *Porgy and Bess*, `SBB CFF`, an email fragment
`aon`) and `OVERRIDE` (hand-written corrections such as
`Unterlangen → Unterlagen`, which the rule would turn into `Unterlängen`).

`learn()` additionally collects every word appearing twice or more in the PDF
itself as known vocabulary, used only to *permit* joins, never to block fixes.

## Stage 4 — `build.py`: assembling and scoring

Holds all the telc knowledge as data:

```python
POINTS = {'LV1': 5.0, 'LV2': 5.0, 'LV3': 2.5, 'SB1': 1.5, 'SB2': 1.5,
          'HV1': 5.0, 'HV2': 2.5, 'HV3': 5.0}
COUNTS = {'LV1': 5, 'LV2': 5, 'LV3': 10, 'SB1': 10, 'SB2': 10,
          'HV1': 5, 'HV2': 10, 'HV3': 5}
RANGE  = {'LV1': (1,5), 'LV2': (6,10), 'LV3': (11,20), …}
BLOCKS = [('block-lv-sb', …, 90, 'Aufgaben 1–40'), …]
```

### The answer-binding gate
The last step of every section is the reason the data can be trusted:

```python
for it in items:
    a = norm(key.get(int(it['id'])), fmt)
    if not a:                                          continue   # no key entry
    if fmt == 'mc'  and a not in option_keys:          continue   # key disagrees
    if fmt in ('matching','wordbank') and a not in bank_keys: continue
    it['answer'] = a
    keep.append(it)
```

Anything that cannot be tied to the official answer key is **dropped**, and the
count lands in `missing`. That is where the 64 absent questions come from — not
from parse failures being ignored, but from parse failures being refused.

### The SB1 double-check
Sprachbausteine 1 gets an extra layer, because its options are the hardest thing
in the document to parse. The key gives both a letter and the correct word, so
`build.py` matches the word against the parsed options:

- exactly one match → keep it, and **correct the letter from the word** if they
  disagree
- more than one match (`sie` vs. `Sie`) → retry case-sensitively
- the key's word is truncated in print (`beeindruck` for `beeindruckt`) → accept
  if the letter's own option starts with it
- still ambiguous → drop the question

### Image extraction
`export_ads()` pulls the Leseverstehen 3 ad page out as a JPEG. It scans the
section's pages plus the following one (the ad page sometimes has no text header
and so is not classified), picks the **largest by area** to avoid grabbing a
decorative thumbnail, and — if the embedded image is already JPEG — copies the
bytes verbatim for zero recompression loss. Only PNG/JPEG2000 sources get
re-encoded, at original resolution.

## `bundle.py` — the single-file build

```bash
python3 tools/bundle.py telc-b1-standalone.html
```

Inlines CSS, JS, all 16 model files and all 16 images (as `data:` URIs) into one
HTML file. It swaps the two `fetch()` calls for reads from an embedded `DATA`
object by string replacement:

```python
js = js.replace("S.index = await (await fetch('data/index.json?v=' + Date.now())).json();",
                "S.index = DATA.index;")
```

That is brittle — change the whitespace of either `fetch` line in `app.js` and
the bundle silently produces a broken file. See
[09-code-review.md](09-code-review.md).

The result opens from `file://` with no server, which makes it good for sharing
on a USB stick or by email, but it has no service worker and no install prompt.

## If you regenerate

The pipeline is deterministic, but it is tuned to *this* PDF: the footer regex
names a specific watermark, the model names are hard-coded in source order, and
`ROW_TOL`/`COL_GAP`/`head_factor` are fitted to this scan's geometry. A
different telc PDF will need retuning. Check the stdout summary — a section
suddenly yielding fewer questions is the signal that a threshold no longer fits.
