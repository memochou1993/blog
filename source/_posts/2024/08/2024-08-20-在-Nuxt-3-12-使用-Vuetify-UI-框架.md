---
title: 在 Nuxt 3.12 使用 Vuetify UI 框架
date: 2024-08-20 23:07:16
tags: ["Programming", "JavaScript", "Nuxt", "Vuetify"]
categories: ["Programming", "JavaScript", "Nuxt"]
---

## 做法

建立專案。

```bash
npx nuxi init nuxt-app
cd nuxt-app
```

安裝依賴套件。

```bash
npm i
```

安裝 Vuetify 框架和 MDI 字型。

```bash
npm i vuetify vite-plugin-vuetify
```

安裝 Sass 預處理器。

```bash
npm i sass -D
```

修改 `nuxt.config.js` 檔。

```js
import vuetify, { transformAssetUrls } from 'vite-plugin-vuetify';

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-04-03',
  devtools: { enabled: true },
  build: {
    transpile: ['vuetify'],
  },
  modules: [
    '@nuxt/eslint',
    (_options, nuxt) => {
      nuxt.hooks.hook('vite:extendConfig', (config) => {
        // @ts-expect-error
        config.plugins.push(vuetify({ autoImport: true }));
      });
    },
  ],
  vite: {
    vue: {
      template: {
        transformAssetUrls,
      },
    },
  },
});
```

新增 `plugins/vuetify.js` 檔。

```js
import '@mdi/font/css/materialdesignicons.css';
import { defineNuxtPlugin } from 'nuxt/app';
import { createVuetify } from 'vuetify';
import 'vuetify/styles';

export default defineNuxtPlugin((app) => {
  const vuetify = createVuetify({
    //
  });
  app.vueApp.use(vuetify);
});
```

修改 `eslint.config.js` 檔。

```js
import { createConfigForNuxt } from '@nuxt/eslint-config/flat';

export default createConfigForNuxt({
  features: {
    stylistic: {
      braceStyle: '1tbs',
      semi: true,
    },
  },
})
  .override('nuxt/typescript/rules', {
    rules: {
      '@typescript-eslint/ban-ts-comment': 0,
    },
  });
```

新增 `layouts/default.vue` 檔。

```html
<template>
  <v-app>
    <v-layout>
      <v-app-bar
        color="grey"
        :height="48"
        flat
      />
      <ClientOnly>
        <v-navigation-drawer
          color="grey-lighten-1"
          :width="240"
        />
      </ClientOnly>
      <ClientOnly>
        <v-navigation-drawer
          color="grey-lighten-2"
          :width="240"
        />
      </ClientOnly>
      <v-main>
        <NuxtPage />
      </v-main>
    </v-layout>
  </v-app>
</template>
```

修改 `app.vue` 檔。

```html
<template>
  <NuxtLayout>
    <v-app>
      <NuxtPage />
    </v-app>
  </NuxtLayout>
</template>
```

新增 `pages/about.vue` 檔。

```html
<template>
  <div>
    <h1>About</h1>
    <v-btn>
      Hello
    </v-btn>
    <v-icon>
      mdi-pen
    </v-icon>
  </div>
</template>
```

啟動本地伺服器。

```bash
npm run dev
```

前往 <http://localhost:3000/about> 瀏覽。

## 參考資料

- [Vuetify](https://vuetifyjs.com/en/getting-started/installation/#using-nuxt-3)
