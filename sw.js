/* خدمة عامل: بتخزّن التطبيق تا يشتغل بدون إنترنت */
const CACHE = 'telc-b1-v1';
const CORE = [
  './', './index.html', './manifest.webmanifest',
  './assets/style.css', './assets/app.js',
  './assets/icons/icon-192.png', './assets/icons/icon-512.png',
  './data/index.json',
];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(CORE)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', e => {
  e.waitUntil(caches.keys()
    .then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k))))
    .then(() => self.clients.claim()));
});

/* الشبكة أولاً وبعدها الكاش — تا تجي أحدث نسخة لما يكون في إنترنت */
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  e.respondWith(
    fetch(e.request)
      .then(res => {
        const copy = res.clone();
        caches.open(CACHE).then(c => c.put(e.request, copy)).catch(() => {});
        return res;
      })
      .catch(() => caches.match(e.request).then(r => r || caches.match('./index.html')))
  );
});
