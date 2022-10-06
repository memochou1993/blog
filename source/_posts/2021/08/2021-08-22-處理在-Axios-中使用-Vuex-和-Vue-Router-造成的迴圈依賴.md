---
title: 處理在 Axios 中使用 Vuex 和 Vue Router 造成的迴圈依賴
date: 2021-08-22 02:24:46
tags: ["程式設計", "JavaScript", "Vue"]
categories: ["程式設計", "JavaScript", "Vue"]
---

## 做法

有時會在 Axios 的攔截器使用到 Vuex 或 Vue Router，這時如果出現迴圈依賴（circular dependency）的錯誤訊息，需要將攔截器封裝成方法並匯出，並以參數的方式將 Vuex 和 Vue Router 傳入，而不是直接引入。

```js
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

在 `main.js` 引入方法，並將 Vuex 和 Vue Router 引入，並傳進方法中。

```js
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
