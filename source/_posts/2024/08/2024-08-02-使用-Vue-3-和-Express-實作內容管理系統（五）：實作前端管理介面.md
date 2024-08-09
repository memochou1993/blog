---
title: 使用 Vue 3 和 Express 實作內容管理系統（五）：實作前端管理介面
date: 2024-08-02 23:43:45
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

## 設置路徑別名

> Ref: <https://github.com/vuejs/create-vue/tree/main/template/base>

在開發過程中，為了避免使用相對路徑引入元件時查找路徑的繁瑣，可以改成透過路徑別名來使用絕對路徑引入元件。

```js
import HomeView from '@/views/HomeView.vue';
// import HomeView from '../views/HomeView.vue';
```

修改 `vite.config.js` 檔，在 `alias` 區塊新增 `@` 路徑別名，用來在引入檔案時表示根目錄。

```js
import vue from '@vitejs/plugin-vue';
import { fileURLToPath, URL } from 'node:url';
import { defineConfig } from 'vite';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
});
```

新增 `jsconfig.json` 檔，讓 VS Code 支援路徑別名。

```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "exclude": ["node_modules", "dist"]
}
```

修改 `src/router/index.js` 檔，現在可以使用 `@` 路徑別名來表示根目錄，而不是使用相對路徑。

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

提交修改。

```bash
git add .
git commit -m "Add alias path for root directory"
git push
```

## 建立列表頁面

在 `src/views` 資料夾，建立 `CustomerListView.vue` 檔，作為客戶管理的列表頁面，並使用假資料實作管理功能。

```html
<script setup>
import { ref } from 'vue';

const customers = ref([
  { id: 1, name: 'Alice' },
  { id: 2, name: 'Bob' },
  { id: 3, name: 'Charlie' },
]);

const createCustomer = () => {
  const name = prompt('Enter customer name');
  if (!name) return;
  const customer = {
    id: customers.value.length + 1,
    name,
  };
  customers.value.push(customer);
};

const updateCustomer = (id) => {
  const name = prompt('Enter customer name');
  if (!name) return;
  const customer = customers.value.find(customer => customer.id === id);
  customer.name = name;
};

const deleteCustomer = (id) => {
  const index = customers.value.findIndex(customer => customer.id === id);
  customers.value.splice(index, 1);
};
</script>

<template>
  <div class="d-flex justify-content-between align-items-end mb-3">
    <div class="fs-2">
      Customers
    </div>
    <div>
      <button
        type="button"
        class="btn btn-primary btn-sm"
        @click="createCustomer"
      >
        Create
      </button>
    </div>
  </div>
  <table class="table table-striped table-bordered align-middle">
    <thead>
      <tr>
        <th>
          ID
        </th>
        <th>
          Name
        </th>
        <th>
          Actions
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="customer in customers"
        :key="customer.id"
      >
        <td>
          {{ customer.id }}
        </td>
        <td>
          {{ customer.name }}
        </td>
        <td>
          <button
            type="button"
            class="btn btn-warning btn-sm me-3"
            @click="updateCustomer(customer.id)"
          >
            Edit
          </button>
          <button
            type="button"
            class="btn btn-danger btn-sm"
            @click="deleteCustomer(customer.id)"
          >
            Delete
          </button>
        </td>
      </tr>
    </tbody>
  </table>
</template>
```

修改 `src/router/index.js` 檔，添加客戶管理的列表頁面的路由。

```js
const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    // ...
    {
      path: '/customers',
      name: 'customer-list',
      component: () => import('@/views/CustomerListView.vue'),
    },
  ],
});
```

修改 `src/components/AppHeader.vue` 檔，添加客戶管理的列表頁面的連結。

```js
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
];
```

提交修改。

```bash
git add .
git commit -m "Add customer list view"
git push
```

## 建立新增頁面

在 `src/views` 資料夾，建立 `CustomerCreateView.vue` 檔，作為客戶管理的新增頁面。實際功能需要等到後端 API 完成再實作。

```html
<script setup>
import { useRouter } from 'vue-router';

const router = useRouter();

const createCustomer = () => {
  // TODO
};
</script>

<template>
  <div class="d-flex justify-content-between align-items-end mb-3">
    <div class="fs-2">
      Create Customer
    </div>
    <div>
      <button
        type="button"
        class="btn btn-danger btn-sm me-3"
        @click="router.push({ name: 'customer-list' })"
      >
        Cancel
      </button>
      <button
        type="button"
        class="btn btn-success btn-sm"
        @click="createCustomer"
      >
        Save
      </button>
    </div>
  </div>
  <form class="border p-3">
    <div class="mb-3">
      <label
        for="name"
        class="form-label"
      >
        Name
      </label>
      <input
        id="name"
        type="text"
        class="form-control"
      >
    </div>
  </form>
</template>
```

修改 `src/router/index.js` 檔，添加客戶管理的新增頁面的路由。

```js
const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    // ...
    {
      path: '/customers/create',
      name: 'customer-create',
      component: () => import('@/views/CustomerCreateView.vue'),
    },
  ],
});
```

重構 `src/views/CustomerListView.vue` 檔，將 `createCustomer` 方法改成導向新增頁面。

```html
<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

// ...

const createCustomer = () => {
  router.push({ name: 'customer-create' });
};

// ...
</script>
```

提交修改。

```bash
git add .
git commit -m "Add customer create view"
git push
```

## 建立編輯頁面

在 `src/views` 資料夾，建立 `CustomerEditView.vue` 檔，作為客戶管理的編輯頁面。實際功能需要等到後端 API 完成再實作。

```html
<script setup>
import { useRouter } from 'vue-router';

const router = useRouter();

const updateCustomer = () => {
  // TODO
};
</script>

<template>
  <div class="d-flex justify-content-between align-items-end mb-3">
    <div class="fs-2">
      Edit Customer
    </div>
    <div>
      <button
        type="button"
        class="btn btn-danger btn-sm me-3"
        @click="router.push({ name: 'customer-list' })"
      >
        Cancel
      </button>
      <button
        type="button"
        class="btn btn-success btn-sm"
        @click="updateCustomer"
      >
        Save
      </button>
    </div>
  </div>
  <form class="border p-3">
    <div class="mb-3">
      <label
        for="name"
        class="form-label"
      >
        Name
      </label>
      <input
        id="name"
        type="text"
        class="form-control"
      >
    </div>
  </form>
</template>
```

修改 `src/router/index.js` 檔，添加客戶管理的編輯頁面的路由。

```js
const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    // ...
    {
      path: '/customers/:id/edit',
      name: 'customer-edit',
      component: () => import('@/views/CustomerEditView.vue'),
    },
  ],
});
```

重構 `src/views/CustomerListView.vue` 檔，將 `updateCustomer` 方法改成導向編輯頁面。

```html
<script setup>
// ...

const updateCustomer = (id) => {
  router.push({ name: 'customer-edit', params: { id } });
};

// ...
</script>
```

提交修改。

```bash
git add .
git commit -m "Add customer edit view"
git push
```

## 練習

### 練習一：將表單獨立成元件

在 `src/components` 資料夾，建立 `CustomerForm.vue` 檔，將原先在新增頁面或編輯頁面的表單內容移動到這裡。

```html
<template>
  <form class="border p-3">
    <div class="mb-3">
      <label
        for="name"
        class="form-label"
      >
        Name
      </label>
      <input
        id="name"
        type="text"
        class="form-control"
      >
    </div>
  </form>
</template>
```

重構 `CustomerCreateView.vue` 頁面。

```html
<script setup>
import CustomerForm from '@/components/CustomerForm.vue';
// ...
</script>

<template>
  <!-- ... -->
  <CustomerForm />
</template>
```

重構 `CustomerEditView.vue` 頁面。

```html
<script setup>
import CustomerForm from '@/components/CustomerForm.vue';
// ...
</script>

<template>
  <!-- ... -->
  <CustomerForm />
</template>
```

提交修改。

```bash
git add .
git commit -m "Refactor views and add CustomerForm component"
git push
```

## 程式碼

- [simple-cms-ui](https://github.com/memochou1993/simple-cms-ui)
- [simple-cms-api](https://github.com/memochou1993/simple-cms-api)
