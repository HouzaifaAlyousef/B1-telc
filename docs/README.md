# Documentation

Written for someone who has never seen this repo before. Read them in order the
first time; after that use it as a reference.

The app's UI is German, the source comments are Arabic, and these docs are
English — that is a deliberate split (see [09-code-review.md](09-code-review.md),
"Three languages in one repo").

| # | Document | What it answers |
|---|----------|-----------------|
| 01 | [Overview](01-overview.md) | What is this product, who is it for, what does it *not* do |
| 02 | [Architecture](02-architecture.md) | How the pieces fit together; the two-stage design |
| 03 | [Frontend app](03-frontend.md) | `assets/app.js` — state, screens, rendering, persistence |
| 04 | [Data format](04-data-format.md) | The JSON contract between build pipeline and app |
| 05 | [Build pipeline](05-build-pipeline.md) | `tools/*.py` — how a scanned PDF becomes 912 questions |
| 06 | [PWA & offline](06-pwa-offline.md) | Service worker, manifest, install, cache behaviour |
| 07 | [Scoring](07-scoring.md) | telc point rules, the rescaling of incomplete tests, grades |
| 08 | [Running & deploying](08-running-deploying.md) | `run.sh`, GitHub Pages, the single-file bundle |
| 09 | [Code review](09-code-review.md) | Concrete defects and improvements, ranked |
| 10 | [Commercialisation](10-commercialisation.md) | Path to a paid product, admin panel, competitor gap analysis |
| 11 | [Going online](11-online-architecture.md) | Accounts, access codes, server-side grading, multiple levels, admin panel |
| 12 | [Paste format](12-import-format.md) | How pasted exam text becomes an exam |
| 13 | [Setup](13-setup.md) | Empty Supabase project → working app, step by step |

## Quick start

```bash
./run.sh
```

## Facts at a glance

| | |
|---|---|
| Type | Static PWA today; moving to static frontend + Supabase |
| Code | ~1,200 lines JS/CSS/HTML, ~1,300 lines Python (build-time only) |
| Content | 16 Modelltests, 912 questions — moving into the database, multi-level |
| Runtime deps | none |
| Build deps | `pdfplumber pypdfium2 pillow pypdf pyspellchecker` (only to regenerate data) |
| Storage | `localStorage` today; Postgres via Supabase in progress |
| Backend | none today — planned in [11-online-architecture.md](11-online-architecture.md) |
