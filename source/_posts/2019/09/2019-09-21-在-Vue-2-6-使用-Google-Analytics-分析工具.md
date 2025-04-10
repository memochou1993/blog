---
title: 在 Vue 2.6 使用 Google Analytics 分析工具
date: 2019-09-21 11:59:01
tags: ["Programming", "JavaScript", "Vue", "Google Analytics"]
categories: ["Programming", "JavaScript", "Vue"]
---

## 安裝

安裝 `vue-analytics` 套件。

```bash
npm install vue-analytics --save
```

在 `plugins` 資料夾新增 `analytics.js` 檔。

```js
import Vue from 'vue';
import VueAnalytics from 'vue-analytics';
import router from '@/router';

Vue.use(VueAnalytics, {
  id: 'UA-XXXXXXXXX-X',
  router,
  debug: {
    sendHitTask: process.env.NODE_ENV === 'production',
  },
  autoTracking: {
    pageviewOnLoad: false,
  },
});
```

在 `main.js` 檔引入。

```js
import '@/plugins/analytics';
```

## 參考資料

- [MatteoGabriele/vue-analytics](https://github.com/MatteoGabriele/vue-analytics)
