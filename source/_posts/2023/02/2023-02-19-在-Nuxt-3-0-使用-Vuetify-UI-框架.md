---
title: 在 Nuxt 3.0 使用 Vuetify UI 框架
date: 2023-02-19 14:37:41
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

安裝 Vuetify 框架。

```bash
npm i -D vuetify vite-plugin-vuetify sass
```

新增 `plugins/vuetify.js` 檔。

```js
import { createVuetify } from 'vuetify';
import 'vuetify/styles';
import * as components from 'vuetify/components';
import * as directives from 'vuetify/directives';
import '@mdi/font/css/materialdesignicons.css';

export default defineNuxtPlugin((nuxtApp) => {
  const vuetify = createVuetify({
    ssr: true,
    components,
    directives,
  });
  nuxtApp.vueApp.use(vuetify);
});
```

修改 `nuxt.config.js` 檔。

```js
// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: {
    enabled: true,
  },
  build: {
    transpile: ['vuetify'],
  },
});
```

安裝 MDI 字型。

```bash
npm i @mdi/font
```

修改 `nuxt.config.js` 檔。

```js
import {defineNuxtConfig} from 'nuxt'

export default defineNuxtConfig({
    css: [
        // ...
        '@mdi/font/css/materialdesignicons.min.css'
    ],
})
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

- [Vuetify](https://vuetifyjs.com/en/getting-started/installation/#existing-projects)
