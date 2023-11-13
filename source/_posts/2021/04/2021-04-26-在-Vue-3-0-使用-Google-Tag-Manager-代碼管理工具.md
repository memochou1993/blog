---
title: 在 Vue 3.0 使用 Google Tag Manager 代碼管理工具
date: 2021-04-26 00:46:40
tags: ["Programming", "JavaScript", "Vue", "Google Tag Manager"]
categories: ["Programming", "JavaScript", "Vue"]
---

## 安裝

安裝 `vue-gtm` 套件。

```bash
yarn add vue-gtm
```

修改 `main.js` 檔：

```js
import { createGtm } from 'vue-gtm';
import App from './App.vue';

createApp(App)
  .use(createGtm({
    id: 'GTM-XXXXXXX',
    debug: true,
    vueRouter: router,
    trackOnNextTick: false,
  }))
  .mount('#app');
```

## 推送事件

使用 `gtm.trackEvent()` 方法推送事件。

```js
gtm.trackEvent({
    event: 'my-event',
    category: 'common',
    action: 'click',
    value: 'hello',
});
```

## 參考資料

- [mib200/vue-gtm](https://github.com/mib200/vue-gtm)
