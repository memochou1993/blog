---
title: 在 SvelteKit 專案建立 PWA 漸進式網頁應用程式
date: 2024-05-22 17:15:16
tags: ["Programming", "JavaScript", "Svelte", "SvelteKit", "PWA"]
categories: ["Programming", "JavaScript", "Svelte"]
---

## 前置作業

首先，到 [Image Generator](https://www.pwabuilder.com/imageGenerator) 產生 PWA 會使用到的應用程式圖示。

## 做法

安裝依賴。

```bash
npm i @vite-pwa/sveltekit -D
```

修改 `src/app.html` 檔。

```html
<link rel="apple-touch-icon" href="/favicon-192x192.png" />
<link rel="mask-icon" href="/favicon.png" color="#ffffff" />
<meta name="msapplication-TileColor" content="#ffffff" />
<meta name="theme-color" content="#ffffff" />
```

修改 `src/routes/+layout.svelte` 檔。

```html
<script lang="ts">
import { pwaInfo } from 'virtual:pwa-info';

// ...

$: webManifest = pwaInfo ? pwaInfo.webManifest.linkTag : '';
</script>

<svelte:head>
  {@html webManifest}
</svelte:head>
```

修改 `svelte.config.js` 檔。

```js
const config = {
  // ...
  kit: {
    // ...
    serviceWorker: {
      // Disable automatic registration of the service worker,
      // allowing the virtual:pwa-info virtual module to fully take over
      // the registration and management process of the service worker
      register: false,
    },
  },
};

export default config;
```

修改 `vite.config.ts` 檔。

```ts
import { sveltekit } from '@sveltejs/kit/vite';
import { SvelteKitPWA } from '@vite-pwa/sveltekit';
import type { UserConfig } from 'vite';

const config: UserConfig = {
  plugins: [
    sveltekit(),
    SvelteKitPWA({
      srcDir: './src',
      manifest: {
        short_name: 'My App',
        name: 'My App',
        start_url: '/',
        scope: '/',
        display: 'standalone',
        theme_color: '#ffffff',
        background_color: '#ffffff',
        icons: [
          {
            src: '/favicon-192x192.png',
            sizes: '192x192',
            type: 'image/png',
          },
          {
            src: '/favicon-512x512.png',
            sizes: '512x512',
            type: 'image/png',
          },
          {
            src: '/favicon-512x512.png',
            sizes: '512x512',
            type: 'image/png',
            purpose: 'any maskable',
          },
        ],
        screenshots: [
          {
            src: '/favicon-620x300.png',
            sizes: '620x300',
            type: 'image/png',
            form_factor: 'wide',
            label: 'My App',
          },
        ],
      },
      injectManifest: {
        globPatterns: ['client/**/*.{js,css,ico,png,svg,webp,woff,woff2}'],
      },
      workbox: {
        globPatterns: ['client/**/*.{js,css,ico,png,svg,webp,woff,woff2}'],
      },
      devOptions: {
        enabled: true,
        suppressWarnings: process.env.SUPPRESS_WARNING === 'true',
        type: 'module',
        navigateFallback: '/',
      },
    }),
  ],
};

export default config;
```

## 參考資料

- [Vite PWA - SvelteKit](https://vite-pwa-org.netlify.app/frameworks/sveltekit)
- [vite-pwa/sveltekit](https://github.com/vite-pwa/sveltekit)
