---
title: 在 Nuxt 3.12 使用 Supabase 實現認證機制
date: 2024-09-02 01:10:58
tags: ["Programming", "JavaScript", "Nuxt", "Supabase"]
categories: ["Programming", "JavaScript", "Nuxt"]
---

## 做法

安裝 Supabase 的 Nuxt 模組。

```bash
npx nuxi@latest module add supabase
```

修改 `.env` 檔。

```bash
NUXT_PUBLIC_SUPABASE_URL=https://example.supabase.co
NUXT_PUBLIC_SUPABASE_KEY=<your_key>
```

修改 `nuxt.config.ts` 檔。

```js
export default defineNuxtConfig({
  modules: ['@nuxtjs/supabase'],
  supabase: {
    redirect: false,
  },
});
```

新增 `composables/useAuth.js` 檔。

```js
export function useAuth() {
  const client = useSupabaseClient();
  const user = useSupabaseUser();

  const signIn = ({
    email,
    password,
  }) => client.auth.signInWithPassword({
    email,
    password,
  });

  const signOut = () => client.auth.signOut();

  const signUp = ({
    email,
    password,
    fullName,
  }) => client.auth.signUp({
    email,
    password,
    options: {
      data: {
        full_name: fullName,
      },
      emailRedirectTo: 'http://localhost:3000',
    },
  });

  return {
    user,
    signIn,
    signOut,
    signUp,
  };
};
```

新增 `middleware/auth.global.js` 檔。

```js
export default defineNuxtRouteMiddleware((to) => {
  const router = useRouter();
  const auth = useAuth();

  if (to.meta.middleware?.includes('guest')) {
    return null;
  }

  if (!auth.user.value) {
    return router.push({ name: 'sign-in' });
  }

  return null;
});
```

新增 `middleware/guest.js` 檔。

```js
export default defineNuxtRouteMiddleware(() => {
  const auth = useAuth();

  if (auth.user.value) {
    return navigateTo({ name: 'index' });
  }

  return null;
});
```

新增 `pages/sign-in.vue` 檔。

```html
<script setup>
definePageMeta({
  middleware: [
    'guest',
  ],
});

const auth = useAuth();
const router = useRouter();

const state = reactive({
  isLoading: false,
  formData: {
    email: '',
    password: '',
  },
});

const signIn = async () => {
  state.isLoading = true;
  const { error } = await auth.signIn(state.formData);
  if (error) {
    // Handle error
    alert(error);
  }
  state.isLoading = false;
  await router.push({ name: 'index' });
};
</script>

<template>
  <v-main class="d-flex justify-center align-center">
    <v-form @submit.prevent="signIn">
      <v-card
        color="grey-lighten-2"
        :width="400"
      >
        <v-card-title class="text-center pa-4">
          Nuxt App
        </v-card-title>
        <v-card-text class="py-0">
          <div class="mb-3">
            <span>
              電子郵件
            </span>
            <v-text-field
              v-model.trim="state.formData.email"
              autofocus
              density="compact"
              hide-details
              variant="outlined"
            />
          </div>
          <div class="mb-3">
            <span>
              密碼
            </span>
            <v-text-field
              v-model.trim="state.formData.password"
              density="compact"
              hide-details
              type="password"
              variant="outlined"
            />
          </div>
          <span>
            沒有帳號嗎？<NuxtLink :to="{ name: 'sign-up' }">註冊</NuxtLink>
          </span>
        </v-card-text>
        <v-card-actions class="d-flex justify-center pa-4">
          <v-btn
            :loading="state.isLoading"
            type="submit"
            variant="flat"
            class="text-none"
          >
            登入
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-form>
  </v-main>
</template>
```

新增 `pages/sign-up.vue` 檔。

```html
<script setup>
definePageMeta({
  middleware: [
    'guest',
  ],
});

const auth = useAuth();
const router = useRouter();

const state = reactive({
  isLoading: false,
  formData: {
    email: '',
    fullName: '',
    password: '',
  },
});

const signUp = async () => {
  state.isLoading = true;
  const { error } = await auth.signUp(state.formData);
  if (error) {
    // Handle error
    alert(error);
  }
  state.isLoading = false;
  await router.push({ name: 'sign-in' });
};
</script>

<template>
  <v-main class="d-flex justify-center align-center">
    <v-form @submit.prevent="signUp">
      <v-card
        color="grey-lighten-2"
        :width="400"
      >
        <v-card-title class="text-center pa-4">
          Nuxt App
        </v-card-title>
        <v-card-text class="py-0">
          <div class="mb-3">
            <span>
              電子郵件
            </span>
            <v-text-field
              v-model.trim="state.formData.email"
              autofocus
              density="compact"
              hide-details
              variant="outlined"
            />
          </div>
          <div class="mb-3">
            <span>
              全名
            </span>
            <v-text-field
              v-model.trim="state.formData.fullName"
              density="compact"
              hide-details
              variant="outlined"
            />
          </div>
          <div class="mb-3">
            <span>
              密碼
            </span>
            <v-text-field
              v-model.trim="state.formData.password"
              density="compact"
              hide-details
              type="password"
              variant="outlined"
            />
          </div>
          <span>
            已經有帳號嗎？<NuxtLink :to="{ name: 'sign-in' }">登入</NuxtLink>
          </span>
        </v-card-text>
        <v-card-actions class="d-flex justify-center pa-4">
          <v-btn
            :loading="state.isLoading"
            type="submit"
            variant="flat"
            class="text-none"
          >
            註冊
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-form>
  </v-main>
</template>
```

新增 `pages/sign-out.vue` 檔。

```html
<script setup>
const auth = useAuth();
const router = useRouter();

const signOut = async () => {
  await auth.signOut();
  router.push({ name: 'sign-in' });
};

signOut();
</script>

<template>
  <v-main />
</template>
```

新增 `pages/index.vue` 檔。

```html
<script setup>
const router = useRouter();
</script>

<template>
  <v-main>
    <v-container>
      <v-btn @click="router.push({ name: 'sign-out' })">
        登出
      </v-btn>
    </v-container>
  </v-main>
</template>
```

## 程式碼

- [supabase-nuxt-auth](https://github.com/memochou1993/supabase-nuxt-auth)

## 參考資料

- [Nuxt Supabase](https://supabase.nuxtjs.org/)
- [Supabase - Auth](https://supabase.com/docs/reference/javascript/auth-api)
