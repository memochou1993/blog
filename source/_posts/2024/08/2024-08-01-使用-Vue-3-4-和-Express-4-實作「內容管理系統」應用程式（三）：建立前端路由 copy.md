---
title: 使用 Vue 3.4 和 Express 4 實作「內容管理系統」應用程式（三）：建立前端路由
date: 2024-08-01 23:43:43
tags: ["Programming", "JavaScript", "Vue", "Bootstrap", "Node", "Express", "Firebase", "Firestore", "CMS"]
categories: ["Programming", "JavaScript", "Vue"]
---

## 前言

本文是前端工作坊的教學文件，介紹如何使用 Vue 和 Express 實作「內容管理系統」應用程式，並搭配 Firebase 實現資料持久化和認證。

## 建立佈局

修改 `App.vue` 檔。

```html
<script setup>
import HelloWorld from '~/components/HelloWorld.vue';
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
            <li class="nav-item">
              <a
                class="nav-link active"
                href="/"
              >
                Home
              </a>
            </li>
            <li class="nav-item">
              <a
                class="nav-link"
                href="/about"
              >
                About
              </a>
            </li>
          </ul>
        </div>
      </div>
    </div>
  </nav>
  <main class="container py-5">
    <HelloWorld msg="Hello, World!" />
  </main>
  <footer class="footer py-2 bg-dark fixed-bottom text-center">
    <span class="text-light">
      © {{ new Date().getFullYear() }} Simple CMS
    </span>
  </footer>
</template>

<style lang="scss" scoped>
main {
  margin-top: 56px;
  margin-bottom: 40px;
}
</style>
```

### 重構佈局

建立 `AppHeader.vue` 檔，將相關程式碼移動到 `AppHeader` 元件。

```html
<template>
  <!-- ... -->
</template>
```

建立 `AppFooter.vue` 檔，將相關程式碼移動到 `AppFooter` 元件。

```html
<template>
  <!-- ... -->
</template>
```

修改 `App.vue` 檔，引入元件。

```html
<script setup>
import AppFooter from '~/components/AppFooter.vue';
import AppHeader from '~/components/AppHeader.vue';
import HelloWorld from '~/components/HelloWorld.vue';
</script>

<template>
  <AppHeader />
  <main class="container py-5">
    <HelloWorld msg="Hello, World!" />
  </main>
  <AppFooter />
</template>

<style lang="scss" scoped>
main {
  margin-top: 56px;
  margin-bottom: 40px;
}
</style>
```

如果遇到以下問題，參考 [Issue #40621](https://github.com/twbs/bootstrap/issues/40621)  的討論，將 Sass 套件降級到 `1.77.6` 版。

```bash
Deprecation Warning: Sass's behavior for declarations that appear after nested
rules will be changing to match the behavior specified by CSS in an upcoming
version. To keep the existing behavior, move the declaration above the nested
rule. To opt into the new behavior, wrap the declaration in `& {}`.
```

使用 npm 將 Sass 套件降級。

```bash
npm i sass@1.77.6 -D
```

提交修改。

```bash
git add .
git commit -m "Add header and footer components"
git push
```

## 實作路由

> Ref: <https://router.vuejs.org/>

### 認識 Vue Router 套件

客戶端路由的作用是在單頁應用程式（SPA）中將瀏覽器的 URL 和使用者看到的內容綁定起來。當使用者在應用程式中瀏覽不同頁面時，URL 會隨之更新，但頁面不需要從伺服器重新載入。

Vue Router 基於 Vue 的元件系統構建，開發者可以透過設定路由來告訴 Vue Router 為每個 URL 路徑顯示哪些元件。

#### Hash 模式

Hash 模式使用 `createWebHashHistory()` 創造：

```js
import { createRouter, createWebHashHistory } from 'vue-router'

const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    //...
  ],
})
```

它在內部傳遞的實際 URL 之前使用了一個哈希字元（`#`），URL 看起來會有點特殊，例如：<http://localhost:5173/#/about>。由於這部分 URL 從未被傳送到伺服器，所以它不需要在伺服器層面上進行任何特殊處理。不過，它在 SEO 中可能會有不好的影響。

#### HTML5 模式

HTML5 模式使用 `createWebHistory()` 創造：

```js
import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    //...
  ],
})
```

當使用這種歷史模式時，URL 會看起來很「正常」，例如：<http://localhost:5173/about>。

不過，由於此應用程式是一個單頁的客戶端應用，如果沒有適當的伺服器配置，使用者在瀏覽器中直接訪問，就會得到一個 404 錯誤。

要解決這個問題，需要在伺服器上添加一個簡單的回退路由。如果 URL 不符合任何靜態資源，它應提供與應用程式中的 `index.html` 相同的頁面。

### 建立路由

安裝依賴套件。

```bash
npm install vue-router@4
```

建立 `src/router` 資料夾。

```bash
mkdir src/router
```

在 `src/router` 資料夾，建立 `index.js` 檔，在這裡定義所有的路由與對應的頁面元件。因為是後台系統，不需要考慮對 SEO 的影響，因此這裡使用 Hash 模式。

```js
import HomeView from '@/views/HomeView.vue';
import { createRouter, createWebHashHistory } from 'vue-router';

const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView,
    },
    {
      path: '/about',
      name: 'about',
      // route level code-splitting
      // this generates a separate chunk (About.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () => import('@/views/AboutView.vue'),
    },
  ],
});

export default router;
```

建立 `src/views` 資料夾。

```bash
mkdir src/views
```

在 `src/views` 資料夾，建立 `views/AboutView.vue` 檔，當作「首頁」頁面元件。

```html
<script setup>
//
</script>

<template>
  Home
</template>
```

在 `src/views` 資料夾，建立 `views/HomeView.vue` 檔，當作「關於」頁面元件。

```html
<script setup>
//
</script>

<template>
  About
</template>
```

修改 `main.js` 檔，引入路由定義檔。

```js
import { Popover } from 'bootstrap';
import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import './style.scss';

createApp(App)
  .use(router)
  .mount('#app');

// ...
```

修改 `App.vue` 檔，將 `HelloWorld` 元件替換為 `RouterView` 元件，來讓 Vue Router 渲染對應 URL 所指定的頁面元件。

```html
<!-- ... -->

<template>
  <AppHeader />
  <main class="container py-5">
    <RouterView />
  </main>
  <AppFooter />
</template>

<!-- ... -->
```

修改 `AppHeader.vue` 檔，將常規的 `<a>` 標籤，替換為 `RouterLink` 元件，來讓 Vue Router 能夠在不重新載入頁面的情況下改變 URL。

```html
<!-- ... -->

<ul class="navbar-nav justify-content-end flex-grow-1 pe-3">
  <li class="nav-item">
    <RouterLink
      class="nav-link active"
      :to="{ name: 'home' }"
    >
      Home
    </RouterLink>
  </li>
  <li class="nav-item">
    <RouterLink
      class="nav-link"
      :to="{ name: 'about' }"
    >
      About
    </RouterLink>
  </li>
</ul>

<!-- ... -->
```

提交修改。

```bash
git add .
git commit -m "Add vue router"
git push
```

### 練習一：將側邊欄的連結改成迴圈

讓側邊欄的連結改成迴圈的寫法，可以讓程式碼變得更簡潔，更容易維護。

#### 做法

修改 `AppHeader.vue` 檔。

```html
<script setup>
const links = [
  {
    title: 'Home',
    name: 'home',
  },
  {
    title: 'About',
    name: 'about',
  },
];
</script>

<template>
  <nav class="navbar navbar-dark bg-dark fixed-top">
    <div class="container-fluid">
      <!-- ... -->
      <div
        id="offcanvasDarkNavbar"
        class="offcanvas offcanvas-end text-bg-dark"
        tabindex="-1"
        aria-labelledby="offcanvasDarkNavbarLabel"
      >
        <!-- ... -->
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

### 練習二：切換 active 樣式

當切換路由時，超連結的 `active` 也要跟著切換。

#### 做法

修改 `AppHeader.vue` 檔。

```html
<script setup>
import { useRoute } from 'vue-router';

const route = useRoute();

const links = [
  {
    title: 'Home',
    name: 'home',
  },
  {
    title: 'About',
    name: 'about',
  },
];
</script>

<template>
  <nav class="navbar navbar-dark bg-dark fixed-top">
    <div class="container-fluid">
      <!-- ... -->
      <div
        id="offcanvasDarkNavbar"
        class="offcanvas offcanvas-end text-bg-dark"
        tabindex="-1"
        aria-labelledby="offcanvasDarkNavbarLabel"
      >
        <!-- ... -->
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
git commit -m "Update links"
git push
```

## 程式碼

- [simple-cms-ui](https://github.com/memochou1993/simple-cms-ui)
- [simple-cms-api](https://github.com/memochou1993/simple-cms-api)
