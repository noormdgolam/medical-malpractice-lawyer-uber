const CACHE_NAME = 'malpractice-guide-v2';
const urlsToCache = [
  '/',
  '/index.html',
  '/css/styles.css',
  '/js/main.js'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(urlsToCache))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

// Stale-While-Revalidate Strategy
self.addEventListener('fetch', event => {
  // Only apply to GET requests
  if (event.request.method !== 'GET') return;

  event.respondWith(
    caches.open(CACHE_NAME).then(cache => {
      return cache.match(event.request).then(cachedResponse => {
        const fetchedResponse = fetch(event.request).then(networkResponse => {
          // Update cache with the new network response
          cache.put(event.request, networkResponse.clone());
          return networkResponse;
        }).catch(() => {
            // Ignore fetch errors (e.g. offline)
        });

        // Return cached response immediately if available, otherwise wait for network
        return cachedResponse || fetchedResponse;
      });
    })
  );
});
