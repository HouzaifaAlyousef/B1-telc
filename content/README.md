# content/

One folder per Modelltest: its text, its images, its recordings.

```
content/<anbieter>/<stufe>/modell-NN/
    text.txt     ← the exam (format: docs/12-import-format.md)
    img/         ← pictures named exactly as `Bild:` says
    audio/       ← recordings named exactly as `Hörtext:` says
```

Check everything before importing:

```bash
node tools/check_content.mjs
```

Full instructions: [docs/21-content-folders.md](../docs/21-content-folders.md)

⚠ **These files hold the answer keys.** They are never deployed — the build
refuses if they reach the output.
