---
title: 使用 Vue 3 和 Express 實作內容管理系統（十）：實作前端認證功能
date: 2024-08-07 20:36:31
date: 2024-08-06 00:17:22
tags: ["Programming", "JavaScript", "Vue", "Bootstrap", "Node", "Express", "Firebase", "Firestore", "CMS"]
categories: ["Programming", "JavaScript", "Vue"]
---

## 前言

本文是前端工作坊的教學文件，介紹如何使用 Vue 3 和 Express 實作內容管理系統，並搭配 Firebase 實現持久化和認證。

## 開啟專案

開啟前端專案。

```bash
cd simple-cms-ui
code .
```

## 實作認證模組

> Ref: <https://firebase.google.com/docs/web/setup?hl=zh-tw#add-sdk-and-initialize>

安裝依賴套件。

```bash
npm install firebase
```

新增 `src/firebase/app.js` 檔，嘗試註冊一個使用者。

```js
import { initializeApp } from 'firebase/app';
import { createUserWithEmailAndPassword, getAuth } from 'firebase/auth';

// Your web app's Firebase configuration
const firebaseConfig = {
  // ...
};

const app = initializeApp(firebaseConfig);

const auth = getAuth(app);

export const signUp = ({ email, password }) => createUserWithEmailAndPassword(auth, email, password);

signUp({ email: 'test@example.com', password: 'password' });
```

執行腳本。

```bash
node src/firebase/auth.js
```

### 重構

新增 `src/firebase/app.js` 檔，初始化 Firebase 實例。

```js
import { initializeApp } from 'firebase/app';

const { VITE_FIREBASE_API_KEY, VITE_FIREBASE_AUTH_DOMAIN, VITE_FIREBASE_PROJECT_ID, VITE_FIREBASE_STORAGE_BUCKET, VITE_FIREBASE_MESSAGING_SENDER_ID, VITE_FIREBASE_APP_ID } = import.meta.env;

const firebaseConfig = {
  apiKey: VITE_FIREBASE_API_KEY,
  authDomain: VITE_FIREBASE_AUTH_DOMAIN,
  projectId: VITE_FIREBASE_PROJECT_ID,
  storageBucket: VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: VITE_FIREBASE_APP_ID,
};

const app = initializeApp(firebaseConfig);

export default app;
```

修改 `src/firebase/auth.js` 檔，添加其他方法。

```js
import { createUserWithEmailAndPassword, getAuth, signInWithEmailAndPassword } from 'firebase/auth';
import app from './app';

const auth = getAuth(app);

export const signUp = ({ email, password }) => createUserWithEmailAndPassword(auth, email, password);

export const signIn = ({ email, password }) => signInWithEmailAndPassword(auth, email, password);

export const signOut = () => auth.signOut();

export const onAuthStateChanged = (callback) => auth.onAuthStateChanged(callback);

export const getCurrentUser = () => {
  return new Promise((resolve, reject) => {
    const unsubscribe = auth.onAuthStateChanged((user) => {
      resolve(user);
      unsubscribe();
    }, (error) => {
      reject(error);
    });
  });
};
```

建立 `src/firebase/index.js` 檔，匯出 `auth` 模組。

```js
export * as auth from './auth';
```

提交修改。

```bash
git add .
git commit -m "Add firebase auth"
git push
```

## 實作頁面

### 註冊頁面

建立 `src/views/SignUp.vue` 檔。

```html
<script setup>
import { auth } from '@/firebase';
import router from '@/router';
import { reactive } from 'vue';

const state = reactive({
  formData: {
    email: '',
    password: '',
  },
});

const submit = async () => {
  try {
    await auth.signUp(state.formData);
    router.push({ name: 'sign-in' });
  } catch (err) {
    alert(err);
  }
};
</script>

<template>
  <div class="d-flex justify-content-center">
    <div
      class="card"
      style="width: 20rem;"
    >
      <div class="card-header">
        <span class="fs-5">Sign Up</span>
      </div>
      <div class="card-body">
        <form
          ref="form"
          @submit.prevent="submit"
        >
          <div class="mb-3">
            <label
              for="email"
              class="form-label"
            >
              Email
            </label>
            <input
              id="email"
              v-model="state.formData.email"
              type="text"
              class="form-control"
              required
            >
          </div>
          <div class="mb-3">
            <label
              for="password"
              class="form-label"
            >
              Password
            </label>
            <input
              id="password"
              v-model="state.formData.password"
              type="password"
              class="form-control"
              required
            >
          </div>
          <div class="mb-3">
            Already have an account?
            <router-link to="/sign-in">
              Sign In
            </router-link>
          </div>
          <div class="d-grid">
            <button
              type="submit"
              class="btn btn-primary"
            >
              Sign Up
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>
```

### 登入頁面

建立 `src/views/SignIn.vue` 檔。

```html
<script setup>
import { auth } from '@/firebase';
import router from '@/router';
import { reactive } from 'vue';

const state = reactive({
  formData: {
    email: '',
    password: '',
  },
});

const submit = async () => {
  try {
    await auth.signIn(state.formData);
    router.push({ name: 'home' });
  } catch (err) {
    alert(err);
  }
};
</script>

<template>
  <div class="d-flex justify-content-center">
    <div
      class="card"
      style="width: 20rem;"
    >
      <div class="card-header">
        <span class="fs-5">Sign In</span>
      </div>
      <div class="card-body">
        <form
          ref="form"
          @submit.prevent="submit"
        >
          <div class="mb-3">
            <label
              for="email"
              class="form-label"
            >
              Email
            </label>
            <input
              id="email"
              v-model="state.formData.email"
              type="text"
              class="form-control"
              required
            >
          </div>
          <div class="mb-3">
            <label
              for="password"
              class="form-label"
            >
              Password
            </label>
            <input
              id="password"
              v-model="state.formData.password"
              type="password"
              class="form-control"
              required
            >
          </div>
          <div class="mb-3">
            Don't have an account? <router-link to="/sign-up">
              Sign Up
            </router-link>
          </div>
          <div class="d-grid">
            <button
              type="submit"
              class="btn btn-primary"
            >
              Sign In
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>
```

### 登出頁面

建立 `src/views/SignOut.vue` 檔。

```html
<script setup>
import { auth } from '@/firebase';
import router from '@/router';

auth.signOut();

router.push({ name: 'sign-in' });
</script>

<template>
  <div />
</template>
```

### 首頁

修改 `src/views/HomeView.vue` 檔，在登入後的首頁顯示使用者的電子信箱。

```html
<script setup>
import { auth } from '@/firebase';
import { reactive } from 'vue';

const state = reactive({
  user: null,
});

auth.onAuthStateChanged((user) => {
  state.user = user;
});
</script>

<template>
  <template v-if="state.user">
    <div>
      Hi, {{ state.user.email }}
    </div>
  </template>
</template>
```

### 隱藏導覽列

修改 `src/components/AppHeader.vue` 檔，當使用者還沒有登入的時候，將導覽列隱藏。

```html
<script setup>
import { auth } from '@/firebase';
import * as bootstrap from 'bootstrap';
import { reactive } from 'vue';
import { useRoute } from 'vue-router';

const route = useRoute();

const links = [
  {
    title: 'Home',
    name: 'home',
  },
  {
    title: 'Customers',
    name: 'customer-list',
  },
  {
    title: 'About',
    name: 'about',
  },
  {
    title: 'Sign Out',
    name: 'sign-out',
  },
];

const state = reactive({
  user: null,
});

auth.onAuthStateChanged((user) => {
  state.user = user;
  if (!user) {
    // 關閉導覽列
    bootstrap.Offcanvas.getOrCreateInstance('#offcanvasDarkNavbar').hide();
  }
});
</script>

<template>
  <nav class="navbar navbar-dark bg-dark fixed-top">
    <div class="container-fluid">
      <a
        class="navbar-brand"
        href="/"
      >
        Simple CMS
      </a>
      <button
        v-if="state.user"
        class="navbar-toggler"
        type="button"
        data-bs-toggle="offcanvas"
        data-bs-target="#offcanvasDarkNavbar"
        aria-controls="offcanvasDarkNavbar"
        aria-label="Toggle navigation"
      >
        <span class="navbar-toggler-icon" />
      </button>
      <div
        id="offcanvasDarkNavbar"
        class="offcanvas offcanvas-end text-bg-dark"
        tabindex="-1"
        aria-labelledby="offcanvasDarkNavbarLabel"
      >
        <div class="offcanvas-header">
          <h5
            id="offcanvasDarkNavbarLabel"
            class="offcanvas-title"
          >
            Simple CMS
          </h5>
          <button
            type="button"
            class="btn-close btn-close-white"
            data-bs-dismiss="offcanvas"
            aria-label="Close"
          />
        </div>
        <div class="offcanvas-body">
          <ul class="navbar-nav justify-content-end flex-grow-1 pe-3">
            <template
              v-for="(link, i) in links"
              :key="i"
            >
              <li
                class="nav-item"
              >
                <router-link
                  class="nav-link"
                  :class="{
                    'active': link.name === route.name,
                  }"
                  :to="{
                    name: link.name,
                  }"
                >
                  {{ link.title }}
                </router-link>
              </li>
            </template>
          </ul>
        </div>
      </div>
    </div>
  </nav>
</template>
```

提交修改。

```bash
git add .
git commit -m "Add auth pages"
git push
```

## 建立路由守衛

修改 `src/router/index.js` 檔，限制特定的路由只能在登入時進入。

```js
import { auth } from '@/firebase';
import HomeView from '@/views/HomeView.vue';
import { createRouter, createWebHashHistory } from 'vue-router';

const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView,
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/sign-up',
      name: 'sign-up',
      component: () => import('@/views/SignUp.vue'),
      meta: {
        requiresAuth: false,
      },
    },
    {
      path: '/sign-in',
      name: 'sign-in',
      component: () => import('@/views/SignIn.vue'),
      meta: {
        requiresAuth: false,
      },
    },
    {
      path: '/sign-out',
      name: 'sign-out',
      component: () => import('@/views/SignOut.vue'),
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/about',
      name: 'about',
      component: () => import('@/views/AboutView.vue'),
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/customers',
      name: 'customer-list',
      component: () => import('@/views/CustomerListView.vue'),
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/customers/create',
      name: 'customer-create',
      component: () => import('@/views/CustomerCreateView.vue'),
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/customers/:id/edit',
      name: 'customer-edit',
      component: () => import('@/views/CustomerEditView.vue'),
      meta: {
        requiresAuth: true,
      },
    },
  ],
});

router.beforeEach(async (to, from, next) => {
  const currentUser = await auth.getCurrentUser();

  if (to.meta.requiresAuth) {
    if (!currentUser) {
      return next({ name: 'sign-in' });
    }
  }

  next();
});

export default router;
```

提交修改。

```bash
git add .
git commit -m "Add navigation guards"
git push
```
