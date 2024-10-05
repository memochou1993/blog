---
title: 在 Nuxt 3.11 使用 useFetch 語法發送 HTTP 請求
date: 2024-05-11 14:24:02
tags: ["Programming", "JavaScript", "Nuxt", "Vue"]
categories: ["Programming", "JavaScript", "Nuxt"]
---

## 前言

在 Nuxt 3 專案中，有三種發送 HTTP 請求的方法：

- `useFetch`
- `$fetch`
- `useAsyncData`

官方文件推薦使用 `useFetch` 或 `useAsyncData + $fetch` 的方式獲取資料，以避免重複發出請求。

## useFetch

首先，`useFetch` 是伺服器端渲染友善的組合式函式（composable），能夠從 API 端點取得資料。

這個組合式函式是 `useAsyncData` 和 `$fetch` 的封裝。它會自動根據 URL 和 fetch 選項生成一個鍵，提供基於伺服器路由的請求 URL 的類型提示，並推斷 API 回應的類型。

由於 `useFetch` 是一個組合式函式，可以直接在 `setup` 函式、套件（plugin）或路由中介層（route middleware）中呼叫。它返回響應式的組合式函式，並處理將回應添加到 Nuxt 有效 payload 中，這樣它們可以從伺服器端傳遞到客戶端，而不需要在客戶端重新取得資料進行頁面水合（page hydrates）。

所有的 `fetch` 選項都可以給予一個 `computed` 或 `ref` 值。這些值會被監聽，如果選項的值被更新了，就會自動進行新的請求。

## $fetch

Nuxt 使用 `ofetch` 來全域性地公開 `$fetch` 助手函式，以便在 Nuxt 應用程式或 API 路由中進行 HTTP 請求。

在元件中使用 `$fetch`，如果沒有把它包在 `useAsyncData` 中，會導致資料被抓取兩次：首先在伺服器端，然後在客戶端進行水合（hydration）期間再次抓取，因為 `$fetch` 不會將狀態從伺服器端轉移到客戶端。因此，該抓取將在兩側執行，因為客戶端必須再次獲取資料。

## useAsyncData

而 `useAsyncData` 可以在伺服器端渲染的組合式函式中，解析非同步資料。

它可以直接在 Nuxt 上下文中調用。它返回響應式的組合式函式，並處理將回應添加到 Nuxt 有效載荷中，這樣它們可以在頁面水合（page hydrates）時從伺服器端傳遞到客戶端，而不需要在客戶端重新取得資料。

## 實作

建立專案。

```bash
npx nuxi@latest init nuxt-fetch-example
cd nuxt-fetch-example
```

修改 `app.vue` 檔。

```js
<template>
  <div>
    <NuxtPage />
  </div>
</template>
```

在 `pages` 資料夾，新增 `index.vue` 檔。

```js
<template>
  <div>
    <ul>
      <li>
        <NuxtLink to="useFetch">useFetch</NuxtLink>
      </li>
      <li>
        <NuxtLink to="$fetch">$fetch</NuxtLink>
      </li>
      <li>
        <NuxtLink to="useAsyncData">useAsyncData</NuxtLink>
      </li>
    </ul>
  </div>
</template>
```

### useFetch

在 `pages` 資料夾，新增 `useFetch.vue` 檔。

```html
<script setup>
const completed = ref('false');

const { data: todos, error, refresh } = await useFetch('https://jsonplaceholder.typicode.com/todos', {
  params: {
    completed: completed, // without ".value"
  },
  // watch: false, // Disable watching for changes
  // immediate: false, // Do not fetch immediately
  // server: false, // Do not fetch on server-side
});
if (error.value) {
  // Handle error
  console.log(error);
}
console.log('[useFetch] TODO Count:', todos.value?.length);

await useFetch('https://hub.dummyapis.com/delay?seconds=1', {
  // lazy: true, // Resolve async function after loading the route
});
</script>

<template>
  <div>
    <form>
      Completed:
      <input type="radio" v-model="completed" value="true" />Yes
      <input type="radio" v-model="completed" value="false" />No
      <input type="button" @click="refresh" value="Refresh" />
    </form>
    <div v-for="(todo, i) in todos" :key="i">
      <input type="checkbox" v-model="todo.completed" />
      {{ todo.title }}
    </div>
  </div>
</template>
```

### $fetch

在 `pages` 資料夾，新增 `$fetch.vue` 檔。

```html
<script setup>
const completed = ref('false');

const todos = await $fetch('https://jsonplaceholder.typicode.com/todos', {
  params: {
    completed: completed.value, // with ".value"
  },
});
console.log('[$fetch] TODO Count:', todos.length);
</script>

<template>
  <div>
    <div v-for="(todo, i) in todos" :key="i">
      <input type="checkbox" v-model="todo.completed" />
      {{ todo.title }}
    </div>
  </div>
</template>
```

### useAsyncData

在 `pages` 資料夾，新增 `useAsyncData.vue` 檔。

```html
<script setup>
const completed = ref('false');

const { data: todos, error } = await useAsyncData('todos', () => $fetch('https://jsonplaceholder.typicode.com/todos', {
  params: {
    completed: completed.value, // with ".value"
  },
}));
if (error.value) {
  // Handle error
  console.log(error);
}
console.log('[useAsyncData] TODO Count:', todos.value.length);
</script>

<template>
  <div>
    <div v-for="(todo, i) in todos" :key="i">
      <input type="checkbox" v-model="todo.completed" />
      {{ todo.title }}
    </div>
  </div>
</template>
```

## 程式碼

- [nuxt-fetch-example](https://github.com/memochou1993/nuxt-fetch-example)

## 參考資料

- [Nuxt - useAsyncData](https://nuxt.com/docs/api/composables/use-async-data)
- [Nuxt - useFetch](https://nuxt.com/docs/api/composables/use-fetch)
- [Nuxt - $fetch](https://nuxt.com/docs/api/utils/dollarfetch)
