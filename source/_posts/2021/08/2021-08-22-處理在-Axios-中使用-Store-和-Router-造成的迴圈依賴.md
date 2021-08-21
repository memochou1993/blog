---
title: 處理在 Axios 中使用 Store 和 Router 造成的迴圈依賴
permalink: 處理在-Axios-中使用-Store-和-Router-造成的迴圈依賴
date: 2021-08-22 02:24:46
tags: ["程式設計", "JavaScript", "Vue"]
categories: ["程式設計", "JavaScript", "Vue"]
---

## 做法

將攔截器封裝成方法並匯出，以參數的方式將 Store 和 Router 傳入，而不是直接引入。

```JS
export const setInterceptors = (store, router) => {
  client.interceptors.request.use((config) => {
    // use store
  });
  client.interceptors.response.use(
    (res) => res,
    async (e) => {
      // use router
    },
  );
};
```

在 `main.js` 引入方法，並將 Store 和 Router 傳入。

```JS
import {
  setInterceptors,
} from '@/plugins/axios';
import store from './store';
import router from './router';

setInterceptors(store, router);

// ...
```

## 參考資料

- [Vuejs | Circular Dependency | Vuex + API + Axios](https://qiita.com/yo_instead_what/items/df886c6baed88252654c)
