# Running and deploying

> **Status — partly superseded.** Deployment becomes a static frontend **plus a Supabase project**.
> See [11-online-architecture.md](11-online-architecture.md) for the new design.
> What follows describes the code as it stands today.

## Locally

```bash
./run.sh
```

That is the whole thing. The script:

- finds `python3`, and says what to install if it is missing
- checks it is in the project folder (`data/index.json` must exist)
- picks the first free port from 8000 upward, so a second run does not collide
- starts `python3 -m http.server` bound to `127.0.0.1`
- waits until the port actually answers before continuing
- opens your browser (`xdg-open` → `open` → `sensible-browser`)
- kills the server on Ctrl-C via a `trap`

```bash
./run.sh              # first free port from 8000
./run.sh 9000         # fixed port
./run.sh --no-open    # no browser (headless / remote)
./run.sh --bundle     # also build the standalone single-file version
./run.sh --help
```

### Why a server is required

Opening `index.html` directly from `file://` gives an empty screen. Two browser
rules cause it: `fetch()` on a `file://` URL is blocked by CORS, and service
workers are not available outside secure origins. `localhost` counts as secure,
so a plain HTTP server on localhost is enough — no certificates needed.

The app detects this case and says so:

> Die Testdaten konnten nicht geladen werden.
> Bitte über einen lokalen Server öffnen: `python3 -m http.server`

If you need something that genuinely works from `file://`, build the bundle.

## The single-file bundle

```bash
python3 tools/bundle.py telc-b1-standalone.html
# or: ./run.sh --bundle
```

Produces one self-contained HTML file with the CSS, JS, all 16 tests and all 16
images inlined as `data:` URIs. It opens by double-click, needs no server, and
can be emailed or carried on a USB stick.

Trade-offs: roughly 2.5 MB, all 16 tests parsed at load instead of lazily, and
no service worker or install prompt. Use it for sharing, not as the product.

> `bundle.py` rewrites two `fetch` calls in `app.js` by exact string match. If
> you reformat those lines, the bundle will build without error and produce a
> broken file. See [09-code-review.md](09-code-review.md).

## GitHub Pages

The repo is already set up for it — `.nojekyll` is present, which stops GitHub
from running the files through Jekyll (without it, anything starting with an
underscore is dropped).

1. **Settings → Pages**
2. **Source: Deploy from a branch**
3. Branch `main`, folder `/ (root)` → **Save**
4. After a minute: `https://<user>.github.io/B1-telc/`

Everything is relative — `start_url`, `scope`, the manifest link, the service
worker path — so the sub-path deployment works without configuration.

To install on a phone: open that URL in the mobile browser → menu → *Add to
Home Screen*.

### Other static hosts

Nothing is GitHub-specific. Netlify, Cloudflare Pages, Vercel, S3 + CloudFront
or any Nginx root all work by copying the folder. Requirements: serve `.json` as
`application/json`, serve `sw.js` from the root of the scope (not a subfolder),
and use HTTPS so the service worker registers.

`Doku/` (11 MB) and `tools/` are not needed at runtime. Excluding them cuts the
deployment to about 2 MB.

## Regenerating the data

Only when the source PDF changes. See
[05-build-pipeline.md](05-build-pipeline.md).

```bash
pip install pdfplumber pypdfium2 pillow pypdf pyspellchecker
python3 tools/build.py "Doku/B1 Telc.pdf" data
```

Then check the printed per-model summary — a section suddenly returning fewer
questions means a parser threshold no longer fits the input.

## After deploying a change

The service worker precaches the shell, so a returning visitor may keep the old
`app.js` for one load. To force an update, bump the cache name in `sw.js`:

```js
const CACHE = 'telc-b1-v3';   // was v2
```

`activate` deletes every cache that is not the current name, so the bump is the
eviction. Do this in the same commit as any change to `app.js`, `style.css` or
`index.html`.
