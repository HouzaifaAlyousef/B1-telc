# PWA and offline

The project is designed to install to a phone home screen and run without a
network. The install half works. **The offline half is currently broken** — see
the bug section below, which is the highest-priority fix in the repo.

## The three pieces

### `manifest.webmanifest`
```json
{ "name": "telc B1 Training", "short_name": "telc B1",
  "start_url": "./", "scope": "./",
  "display": "standalone", "orientation": "portrait",
  "background_color": "#f4f6fb", "theme_color": "#2f6bed",
  "icons": [ 192, 512, maskable-512 ] }
```

Relative `start_url` and `scope` are what let the app live at
`https://user.github.io/B1-telc/` rather than a domain root. `display:
standalone` removes the browser chrome; `maskable-512` lets Android crop the
icon to its own shape without white corners.

### `index.html`
```html
<link rel="manifest" href="manifest.webmanifest">
<meta name="theme-color" content="#2f6bed">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-title" content="telc B1">
<link rel="apple-touch-icon" href="assets/icons/apple-touch-icon.png">
```
iOS ignores the manifest for install, so the `apple-*` tags duplicate it.
Registration is deferred to `load` and failures are swallowed, so a browser
without service workers still runs the app normally:

```js
if ('serviceWorker' in navigator) {
  addEventListener('load', () => navigator.serviceWorker.register('sw.js').catch(() => {}));
}
```

### `sw.js` — network-first
```js
const CACHE = 'telc-b1-v2';
const CORE = ['./', './index.html', './manifest.webmanifest',
              './assets/style.css', './assets/app.js',
              './assets/icons/icon-192.png', './assets/icons/icon-512.png',
              './data/index.json'];
```

- **install** → precache `CORE`, then `skipWaiting()`
- **activate** → delete every cache whose name is not `CACHE`, then `clients.claim()`
- **fetch** → try the network; on success clone into the cache; on failure fall
  back to the cache, and finally to `./index.html`

Network-first is the right choice here: content updates whenever there is a
connection, and the cache is only a safety net. `skipWaiting` + `claim` means a
deployed change takes effect on the next load rather than after every tab is
closed. Bumping `CACHE` to `-v3` is what evicts the old files.

---

## The bug: offline does not work

### What happens
Install the app, then go offline and open it. The shell loads — correct styling,
correct fonts, the service worker is serving `index.html`, `app.js` and
`style.css` from cache. Then the screen reads:

> Die Testdaten konnten nicht geladen werden.
> Bitte über einen lokalen Server öffnen: `python3 -m http.server`

No test is reachable. This was reproduced by installing the app, stopping the
server, and reloading.

### Why
`app.js` appends a cache-buster to every data request:

```js
S.index = await (await fetch('data/index.json?v=' + Date.now())).json();
const fetchModell = async file => await (await fetch(`data/${file}?v=` + Date.now())).json();
```

`caches.match(request)` keys on the **full URL including the query string**. So:

| in the cache | requested next load | result |
|---|---|---|
| `/data/index.json` (precached by `CORE`) | `/data/index.json?v=1788455497188` | **MISS** |
| `/data/modell-01.json?v=1788455497188` | `/data/modell-01.json?v=1788455501422` | **MISS** |

`Date.now()` is different on every load, so a data request can never hit the
cache. The fetch handler then falls back to `./index.html`, `.json()` gets HTML
and throws, and `boot()` shows its error screen.

Measured directly in the running app:

```
cachedUrls: [ "/", "/index.html", "/manifest.webmanifest", "/assets/style.css",
              "/assets/app.js", "/assets/icons/icon-192.png",
              "/assets/icons/icon-512.png", "/data/index.json",
              "/data/modell-01.json?v=1788455497188" ]

caches.match('data/index.json?v=' + Date.now())                    → MISS
caches.match('data/index.json?v=' + Date.now(), {ignoreSearch:true}) → 200
caches.match('/data/index.json')                                    → 200
```

Every ingredient is in the cache. Only the key is wrong.

### The fix

One argument in `sw.js`:

```diff
-      .catch(() => caches.match(e.request).then(r => r || caches.match('./index.html')))
+      .catch(() => caches.match(e.request, { ignoreSearch: true })
+                     .then(r => r || caches.match('./index.html')))
```

`{ignoreSearch: true}` was verified to return 200 for exactly the URL the app
requests. Bump `CACHE` to `telc-b1-v3` at the same time so existing installs
pick it up.

Two improvements worth making in the same pass:

1. **Drop the cache-buster.** It exists to defeat HTTP caching, but the service
   worker is already network-first, so fresh data arrives whenever there is a
   connection. Removing `?v=` makes cache keys stable and lets the precached
   `/data/index.json` be used directly. If it stays, note that it also defeats
   the browser's own HTTP cache — every launch re-downloads the data.

2. **Precache the content.** `CORE` covers the shell and the index but none of
   the 16 model files or 16 images. Even with the key fixed, a student is only
   offline-capable for tests they happened to open while online. The full
   payload is 1.76 MB — small enough to precache outright:

   ```js
   const CORE = [ …shell…,
     './data/index.json',
     ...Array.from({length: 16}, (_, i) =>
       `./data/modell-${String(i+1).padStart(2,'0')}.json`),
     ...Array.from({length: 16}, (_, i) =>
       `./data/img/m${String(i+1).padStart(2,'0')}-lv3.jpg`) ];
   ```

   `addAll` is atomic — one 404 aborts the whole install — so keep this list in
   sync with `data/`, or generate it at build time.

### Why it was not noticed
Two reasons. During development there is always a server, so the fallback path
never runs. And the failure is not a crash — the app shows a tidy German error
message that reads like a deliberate "you opened this from `file://`" hint, so
it looks handled rather than broken.

---

## Installing

Because a PWA cannot install from `file://`, the app must be on a URL. The
README documents GitHub Pages; see [08-running-deploying.md](08-running-deploying.md).

| Platform | How |
|---|---|
| Android / Chrome | menu → *Zum Startbildschirm hinzufügen* |
| iOS / Safari | share → *Zum Home-Bildschirm* |
| Desktop Chrome | install icon in the address bar |

## Dark mode

`style.css` defines dark variables twice — once under
`@media (prefers-color-scheme: dark)` guarded by `:root:not([data-theme="light"])`,
and once under `:root[data-theme="dark"]` — so both a system preference and an
explicit choice are supported.

**But nothing in the app ever sets `data-theme`.** Confirmed:

```
$ grep -rn "data-theme" --include=*.js --include=*.html .
(no matches)
```

So the explicit-choice half is dead code today: dark mode follows the OS and
cannot be overridden. Either add a toggle that writes
`document.documentElement.dataset.theme` and stores it in `localStorage`, or
delete the `[data-theme]` block. The CSS is already written for the toggle — it
is roughly ten lines of JS to finish.
