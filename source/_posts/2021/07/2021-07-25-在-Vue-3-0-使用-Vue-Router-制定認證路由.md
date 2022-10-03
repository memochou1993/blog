---
title: 在 Vue 3.0 使用 Vue Router 制定認證路由
date: 2021-07-25 15:08:03
tags: ["程式設計", "JavaScript", "Vue"]
categories: ["程式設計", "JavaScript", "Vue"]
---

## 做法

修改 `router/index.js` 檔。

```JS
import { createRouter, createWebHashHistory } from 'vue-router';
import store from '@/store';

const routes = [
  {
    path: '/login',
    name: 'login',
    component: () => import(/* webpackChunkName: "login" */ '@/views/Login.vue'),
    meta: {
      requiresGuest: true,
    },
  },
  {
    path: '/',
    name: 'home',
    component: () => import(/* webpackChunkName: "home" */ '@/views/Home.vue'),
    meta: {
      requiresAuth: true,
    },
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: {
      name: 'home',
    },
  },
];

const router = createRouter({
  history: createWebHashHistory(),
  routes,
});

router.beforeEach((to, from, next) => {
  // 檢查該路由是否需要令牌
  if (to.meta.requiresAuth) {
    // 如果有令牌，就通行，否則導到登入頁
    return store.state.token ? next() : next({ name: 'login' });
  }
  // 檢查該路由是否不可有令牌
  if (to.meta.requiresGuest)) {
    // 如果有令牌，就導到首頁
    return store.state.token ? next({ name: 'home' }) : next();
  }
  return next();
});

export default router;
```

## 參考資料

- [Route Meta Fields](https://next.router.vuejs.org/guide/advanced/meta.html)
