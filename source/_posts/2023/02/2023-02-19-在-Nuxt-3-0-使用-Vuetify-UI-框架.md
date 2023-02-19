---
title: 在 Nuxt 3.0 使用 Vuetify UI 框架
date: 2023-02-19 14:37:41
tags: ["程式設計", "JavaScript", "Nuxt", "Vuetify"]
categories: ["程式設計", "JavaScript", "Nuxt"]
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
npm i vuetify@next sass
```

新增 `plugins/vuetify.js` 檔。

```js
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'

export default defineNuxtPlugin(nuxtApp => {
  const vuetify = createVuetify({
    ssr: true,
    components,
    directives,
  })

  nuxtApp.vueApp.use(vuetify)
})
```

修改 `nuxt.config.js` 檔。

```js
// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  css: [
    'vuetify/lib/styles/main.sass'
  ],
  build: {
    transpile: ['vuetify']
  },
  vite: {
    define: {
      'process.env.DEBUG': false
    }
  }
})
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

## 參考資料

- [How to use Vuetify with Nuxt 3](https://codybontecou.com/how-to-use-vuetify-with-nuxt-3.html)
