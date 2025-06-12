---
title: 在 Nuxt 3.13 使用 Google Analytics 分析工具
date: 2025-03-08 17:55:06
tags: ["Programming", "JavaScript", "Vue", "Nuxt", "Google Analytics"]
categories: ["Programming", "JavaScript", "Nuxt"]
---


## 做法

安裝 Nuxt Scripts 模組。

```bash
npx nuxi@latest module add scripts
```

修改 `.env` 檔。

```env
NUXT_PUBLIC_GOOGLE_TAG_ID=your-id
```

修改 `nuxt.config.ts` 檔。

```js
export default defineNuxtConfig({
  modules: [
    '@nuxt/scripts',
  ],
  scripts: {
    registry: {
      googleAnalytics: {
        id: process.env.NUXT_PUBLIC_GOOGLE_TAG_ID as string,
      },
    },
  },
});
```

## 參考資料

[Nuxt Scripts](https://scripts.nuxt.com/scripts/tracking/google-tag-manager)
