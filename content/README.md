# content/

One folder per Modelltest: its text, its images, its recordings.

```
content/<anbieter>/<stufe>/modell-NN/
    text.txt     ← the exam (format: docs/12-import-format.md)
    img/         ← pictures named exactly as `Bild:` says
    audio/       ← recordings named exactly as `Hörtext:` says
```

**telc B1 is generated, not hand-written.** Its 16 `text.txt` files come from
`data/*.json` via `node tools/sync_b1_content.mjs`. Edit `data/`, then re-run
it — a test fails if the two drift apart. Every other level is authored here
directly.

Check everything before importing:

```bash
node tools/check_content.mjs
```

Full instructions: [docs/21-content-folders.md](../docs/21-content-folders.md)

⚠ **These files hold the answer keys.** They are never deployed — the build
refuses if they reach the output.
