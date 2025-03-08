---
title: 在 Vue 3.0 使用 Google Analytics 分析工具
date: 2021-04-25 23:29:13
tags: ["Programming", "JavaScript", "Vue", "Google Analytics"]
categories: ["Programming", "JavaScript", "Vue"]
---

## 安裝

安裝 `vue-gtag-next` 套件。

```bash
yarn add vue-gtag-next
```

修改 `main.js` 檔：

```js
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
