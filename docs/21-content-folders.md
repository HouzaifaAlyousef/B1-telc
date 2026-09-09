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
