---
title: 在 Vue 3.0 安裝 Tailwind CSS UI 框架
permalink: 在-Vue-3-0-安裝-Tailwind-CSS-UI-框架
date: 2020-10-29 22:31:16
tags: ["程式設計", "JavaScript", "Vue", "UI Framework", "Tailwind CSS"]
categories: ["程式設計", "JavaScript", "Vue"]
---

## 做法

建立 Vue 專案。

```BASH
vue create vue-tailwind
```

安裝 `tailwindcss` 套件。

```BASH
yarn add tailwindcss
```

安裝 `autoprefixer` 套件。

```BASH
yarn add autoprefixer@^9.0.0
```

- 避免使用太新的版本，否則可能會導致編譯失敗。

在 `src/assets/css` 資料夾新增 `tailwind.css` 檔：

```CSS
/* noinspection CssInvalidAtRule */
@tailwind base;
/* noinspection CssInvalidAtRule */
@tailwind components;
/* noinspection CssInvalidAtRule */
@tailwind utilities;
```

在根目錄新增 `tailwind.config.js` 檔：

```JS
module.exports = {
  future: {
    // removeDeprecatedGapUtilities: true,
    // purgeLayersByDefault: true,
  },
  purge: [
    '@/**/*.html',
    '@/**/*.vue',
  ],
  theme: {
    extend: {},
  },
  variants: {},
  plugins: [],
};
```

在根目錄新增 `postcss.config.js` 檔：

```JS
const tailwindcss = require('tailwindcss');
const autoprefixer = require('autoprefixer');

module.exports = {
  plugins: [
    tailwindcss,
    autoprefixer,
  ],
};
```

修改 `main.js` 檔，將 `tailwind.css` 檔引入：

```JS
import { createApp } from 'vue';
import App from '@/App';
import router from '@/router';
import '@/assets/css/tailwind.css';

createApp(App).use(router).mount('#app');
```

使用：

```HTML
<div class="flex flex-wrap">
  <div class="w-full text-center">
    Form
  </div>
</div>
```

## 程式碼

- [vue-tailwind-example](https://github.com/memochou1993/vue-tailwind-example)

## 參考資料

- [Tailwind CSS - Documentation](https://tailwindcss.com/docs/installation)
