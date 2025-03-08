---
title: 在 Nuxt 3.12 使用 Supabase 實作電子信箱登入
date: 2024-09-02 01:10:58
tags: ["Programming", "JavaScript", "Nuxt", "Supabase"]
categories: ["Programming", "JavaScript", "Nuxt"]
---

## 前置作業

首先，到 [Supabase](https://supabase.com/) 建立一個新專案，並取得 API URL 和 API 金鑰。

## 建立專案

建立專案。

```bash
npx nuxi@latest init supabase-auth-nuxt
```

安裝 Supabase 的 Nuxt 模組。

```bash
npx nuxi@latest module add supabase
```

修改 `.env` 檔。

```bash
NUXT_PUBLIC_SUPABASE_URL=<your_supabase_url>
NUXT_PUBLIC_SUPABASE_KEY=<your_supabase_key>
```

修改 `nuxt.config.ts` 檔。

```js
export default defineNuxtConfig({
  modules: [
    '@nuxtjs/supabase',
  ],
  supabase: {
    // 自行實作中介層
    redirect: false,
  },
});
```

## 實作頁面

修改 `app.vue` 檔。

```html
<template>
  <div>
    <NuxtPage />
  </div>
</template>
```

新增 `pages/sign-in.vue` 檔。

```html
<script setup>
const supabase = useSupabaseClient();
const router = useRouter();

const state = reactive({
  email: '',
  password: '',
});

const signIn = async () => {
  const { error } = await supabase.auth.signInWithPassword({
    email: state.email,
    password: state.password,
  })
  if (error) alert(error);
  router.push('/');
};
</script>

<template>
  <form @submit.prevent="signIn">
    <input v-model="state.email" type="email" />
    <input v-model="state.password" type="password" />
    <button type="submit">Sign In</button>
    &nbsp;or
    <NuxtLink to="/sign-up">Sign Up</NuxtLink>
  </form>
</template>
```

新增 `pages/sign-up.vue` 檔。

```html
<script setup>
const supabase = useSupabaseClient();

const state = reactive({
  email: '',
  password: '',
});

const signUp = async () => {
  const { error } = await supabase.auth.signUp({
    email: state.email,
    password: state.password,
  });
  if (error) alert(error);
};
</script>

<template>
  <form @submit.prevent="signUp">
    <input v-model="state.email" type="email" />
    <input v-model="state.password" type="password" />
    <button type="submit">Sign Up</button>
    &nbsp;or
    <NuxtLink to="/sign-in">Sign In</NuxtLink>
  </form>
</template>
```

新增 `pages/sign-out.vue` 檔。

```html
<script setup>
const supabase = useSupabaseClient();
const router = useRouter();

await supabase.auth.signOut();
router.push('/sign-in');
</script>

<template>
  <div />
</template>
```

新增 `pages/index.vue` 檔。

```html
<script setup>
const user = useSupabaseUser();

console.log(user);
</script>

<template>
  <NuxtLink to="/sign-out">
    Sign Out
  </NuxtLink>
</template>
```

## 實作中介層

新增 `middleware/auth.global.js` 檔。

```js
export default defineNuxtRouteMiddleware((to) => {
  const user = useSupabaseUser();
  const router = useRouter();

  if (to.meta.middleware?.includes('guest')) {
    return null;
  }

  if (!user.value) {
    return router.push('/sign-in');
  }

  return null;
});
```

新增 `middleware/guest.js` 檔。

```js
export default defineNuxtRouteMiddleware((to) => {
  const user = useSupabaseUser();
  const router = useRouter();

  if (user.value) {
    return router.push('/');
  }

  return null;
});
```

修改 `sign-in.vue` 檔。

```js
definePageMeta({
  middleware: [
  'guest',
  ],
});

// ...
```

修改 `sign-up.vue` 檔。

```js
definePageMeta({
  middleware: [
  'guest',
  ],
});

// ...
```

啟動本地伺服器。

```bash
npm run dev
```

前往 <http://localhost:3000> 瀏覽。

## 程式碼

- [supabase-auth-nuxt](https://github.com/memochou1993/supabase-auth-nuxt)

## 參考資料

- [Nuxt Supabase](https://supabase.nuxtjs.org/)
- [Supabase - Auth](https://supabase.com/docs/reference/javascript/auth-api)
