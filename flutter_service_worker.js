'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"404.html": "db97eab1e1c43a81503afe3b55b1ae52",
"app-manifest.json": "c8fda3b5c85d2322e49cd1d14b6ba29e",
"assets/AssetManifest.bin": "119e528cb3c4648af0d8f6c9472954eb",
"assets/AssetManifest.bin.json": "792bca82b8e3e192f2d64dc39bf346ae",
"assets/AssetManifest.json": "0c57f95468fcac5968c04f00f143125f",
"assets/assets/brand/README.md": "94324473e9b07a3939d814de7f896fd9",
"assets/assets/core/creed.json": "e14c863859b907a0ae42502ca37cd8fc",
"assets/assets/core/truth_anchors.json": "318f53064f1045c0e5a530aa643416bb",
"assets/assets/courses/discipleship_12w.json": "f7dbc3b8c2e00536e844c1de336e5cb2",
"assets/assets/courses/light_onramp_7d.json": "f09f874021ab7402779b8373898dc30c",
"assets/assets/courses/ur4more_core_12w.json": "3fc164228649f28430b55a7db058beaa",
"assets/assets/data/courses_seed.json": "71ba1d3991b3934512da2cf11240724a",
"assets/assets/data/scriptures.json": "16e067e45a68598a2b963b501af0029c",
"assets/assets/data/ur4more_core_12wk.json": "3280ff33364336778fb5baaf71e5fd56",
"assets/assets/icons/body.svg": "1a90bbffff79e379a12375c65e86c4ba",
"assets/assets/icons/mind.svg": "644f0dcab3d1a70a460b57908631b273",
"assets/assets/icons/rewards.svg": "ff5db6569d3ae12b371011f7a8db418a",
"assets/assets/icons/spirit.svg": "d2b26b51c5212f5db9532ba8a500f927",
"assets/assets/images/coping/breathing.png": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/breathing.webp": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/call_friend.png": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/call_friend.webp": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/cold_shower.png": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/cold_shower.webp": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/creative.png": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/creative.webp": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/exercise.png": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/exercise.webp": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/gratitude.png": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/gratitude.webp": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/journaling.png": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/journaling.webp": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/mindful_eating.png": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/mindful_eating.webp": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/music.png": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/music.webp": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/pray.png": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/pray.webp": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/scripture.png": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/scripture.webp": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/walk.png": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/coping/walk.webp": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/discipleship_background.png": "18e728e2685e9595b74be8dee9825a52",
"assets/assets/images/fish_logo.png": "014b4213cf65fea229c26dd180ddc8d0",
"assets/assets/images/home_bg.png": "efa5142ac24943057dc95b5c01864c6f",
"assets/assets/images/img_app_logo.svg": "52e0f13a4898fcb7e2e6b785bc50d3e8",
"assets/assets/images/logo-ur4more-1760380957365.png": "01ed7a597181c0a9525cc71e04a53552",
"assets/assets/images/logo-ur4more-4-1760392710884.png": "cb9518e386113dda06d82a213ddfe107",
"assets/assets/images/logo-ur4more-4-1760393143197.png": "cb9518e386113dda06d82a213ddfe107",
"assets/assets/images/logo-ur4more-4.png": "cb9518e386113dda06d82a213ddfe107",
"assets/assets/images/logo-ur4more.png": "01ed7a597181c0a9525cc71e04a53552",
"assets/assets/images/no-image.jpg": "1a5d2f8e2ae237e2dd853bd7b3fa7287",
"assets/assets/images/sad_face.svg": "4eccb4273d492e76924127c7520b7890",
"assets/assets/images/sample.jpf": "f6bb092c171d9f97cf0efb793903694f",
"assets/assets/images/sample.png": "4ccbe1b868fe43e9368c257e1f69f6ad",
"assets/assets/images/sample2.png": "fab749706193bf8083001ba7e135e479",
"assets/assets/images/scripture.jpg": "c1d1816bd3edae3ec3fc41a93777edec",
"assets/assets/images/spalsh%2520phone%2520card.png": "c318dde48b35095cd1208ae4a868556e",
"assets/assets/images/spalsh%2520phone%2520card2.png": "46ee9c39ea8847a97ef5b43f83016d0a",
"assets/assets/images/splash.png": "b03664c753a6a804d9c7817b6ba32999",
"assets/assets/images/splash_phone_card2.png": "46ee9c39ea8847a97ef5b43f83016d0a",
"assets/assets/images/waves_logo.png": "6390f74230dec60b7efe5f235bffb3b6",
"assets/assets/images/Wellness%2520journey%2520start%2520screen%2520card.png": "41a96947b7f607366ca4674369dca575",
"assets/assets/images/wellness_journey_start_card.png": "41a96947b7f607366ca4674369dca575",
"assets/assets/images/Whole%2520Wellness%2520Hero%2520body%2520transparent.png": "7e9a3ff8e3103d4b53a7be29df4e5302",
"assets/assets/images/Whole%2520Wellness%2520Hero%2520body.png": "d58f4cd37dc5b8c2012bd35d046b0576",
"assets/assets/images/Whole%2520Wellness%2520Hero%2520card.png": "bfc37808c33a6171c238cd9239ebc3c1",
"assets/assets/images/Whole%2520Wellness%2520Hero.png": "64a204918cd9e215e628d87e90e8ec07",
"assets/assets/images/whole_wellness_hero_body.png": "7e9a3ff8e3103d4b53a7be29df4e5302",
"assets/assets/images/whole_wellness_hero_card.png": "bfc37808c33a6171c238cd9239ebc3c1",
"assets/assets/inspiration/scripture_kjv.json": "b7e6b218f23af8f1e7b69ce831f5e6b5",
"assets/assets/inspiration/secular_quotes.json": "fc55d19407cca93da20fb9a73297b1ce",
"assets/assets/mind/coach_prompts.json": "4d9898a1c2dea06c1e196ccd8be8a133",
"assets/assets/mind/exercises/defusion_label.json": "4a398261e117927d282f02880bf87add",
"assets/assets/mind/exercises/grounding_54321.json": "3f1ae60c63aee8a9e5311a4ca620a529",
"assets/assets/mind/exercises/pmr_short.json": "efe0df0359f95f60a5138589c7a0aafc",
"assets/assets/mind/exercises/tiny_wins.json": "0098414649284a049023555164b55a3c",
"assets/assets/mind/exercises/urge_surfing.json": "18ce56c0cab9ad3007114d2e762af832",
"assets/assets/mind/exercises/worry_postpone.json": "e6d17f68c34ac09dd2705a198ed06b0f",
"assets/assets/mind/exercises_core.json": "f7f5e3f44efe41e75214ad968e348cd7",
"assets/assets/mind/exercises_faith.json": "5e2d6e7cec47c76d6b0849c9add435c9",
"assets/assets/mind/go_deeper_card.json": "f94333a2a7f76a17766341872403ce5c",
"assets/assets/mind/lessons/walk_in_light_renewing_mind.md": "b790e4cab67d3d7c9c1885e7be347b32",
"assets/assets/mind/quotes/quotes.json": "9e7ccddc53a3615dc26020b9674332ff",
"assets/assets/mind/scripture_sets/renewing_mind_kjv.json": "335e89acc2a293bbf04dc8a6875cc5fe",
"assets/assets/mind/scripture_sets/walk_in_light_scriptures.json": "e2a4cd2f3a656ba66bd5e48ac7b1bae1",
"assets/assets/mind/week_completion_invites.json": "d5229fafd5a1cc77c6529e4a143ec779",
"assets/assets/quotes/manifest.json": "4a7d9231be30f24dde0ef8e84b3c670a",
"assets/assets/quotes/shards/quotes_000.json": "f4c08139126f6b1b0193b2094a911d82",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/fonts/MaterialIcons-Regular.otf": "5a9b1320d5c4c01dfb04d4d78833405d",
"assets/NOTICES": "acf5caf563de71df0f9ae012166cae5b",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "d2e891038680b41eea2f9dc8296c7b9a",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "906ab68e3177bf3e9773db885a6db3db",
"/": "906ab68e3177bf3e9773db885a6db3db",
"main.dart.js": "4f7541a22d8aff4b68bcbd59ec5b9470",
"manifest.json": "70fbd6505c5dc48cb6115644c3bb579b",
"sitemap.txt": "4fc73af34445323dfda71e0c959486d3",
"version.json": "77eb3f4dbabfea15daf051b2b4562407"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
