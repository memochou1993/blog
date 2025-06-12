---
title: 在 Nuxt 3.13 使用 Google Fonts 字體和圖示
date: 2025-06-12 12:29:48
tags: ["Programming", "JavaScript", "Vue", "Nuxt", "Google Fonts"]
categories: ["Programming", "JavaScript", "Nuxt"]
---

## 做法

安裝 Nuxt Google Fonts 模組。

```bash
npx nuxi@latest module add google-fonts
```

修改 `nuxt.config.ts` 檔。

```js
export default defineNuxtConfig({
  modules: [
    '@nuxtjs/google-fonts',
  ],
  googleFonts: {
    display: 'swap',
    families: {
      'Roboto': {
        wght: [400, 500, 700],
      },
      'Noto Sans TC': {
        wght: [400, 500, 700],
      },
      'Noto Sans JP': {
        wght: [400, 500, 700],
      },
    },
  },
});
```

## 參考資料

[Nuxt Scripts](https://scripts.nuxt.com/scripts/tracking/google-tag-manager)
