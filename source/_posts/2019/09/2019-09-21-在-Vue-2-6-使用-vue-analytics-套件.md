---
title: 在 Vue 2.6 使用 vue-analytics 套件
permalink: 在-Vue-2-6-使用-vue-analytics-套件
date: 2019-09-21 11:59:01
tags: ["程式寫作", "JavaScript", "Vue", "Google Analytics"]
categories: ["程式寫作", "JavaScript", "Vue"]
---

## 步驟

安裝 `vue-analytics` 套件。

```BASH
npm install vue-analytics --save
```

在 `plugins` 資料夾新增 `analytics.js` 檔。

```JS
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

```JS
import '@/plugins/analytics';
```
