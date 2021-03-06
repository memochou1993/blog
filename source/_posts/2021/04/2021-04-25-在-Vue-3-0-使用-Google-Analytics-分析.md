---
title: 在 Vue 3.0 使用 Google Analytics 分析
permalink: 在-Vue-3-0-使用-Google-Analytics-分析
date: 2021-04-25 23:29:13
tags: ["程式設計", "JavaScript", "Vue", "Google Analytics"]
categories: ["程式設計", "JavaScript", "Vue"]
---

## 安裝

安裝 `vue-gtag-next` 套件。

```BASH
yarn add vue-gtag-next
```

修改 `main.js` 檔：

```JS
import VueGtag from 'vue-gtag-next';
import App from './App.vue';

createApp(App)
  .use(VueGtag, {
    property: {
      id: 'G-XXXXXXXXXX',
    },
  })
  .mount('#app');
```

## 參考資料

- [MatteoGabriele/vue-gtag-next](https://github.com/MatteoGabriele/vue-gtag-next)
