---
title: 在 Vue 3.0 使用 Tailwind CSS UI 框架
date: 2020-10-29 22:31:16
tags: ["Programming", "JavaScript", "Vue", "UI Framework", "Tailwind CSS"]
categories: ["Programming", "JavaScript", "Vue"]
---

## 做法

建立 Vue 專案。

```bash
vue create vue-tailwind
```

安裝 `tailwindcss` 套件。

```bash
yarn add tailwindcss
```

安裝 `autoprefixer` 套件。

```bash
yarn add autoprefixer@^9.0.0
```

- 避免使用太新的版本，否則可能會導致編譯失敗。

在 `src/assets/css` 資料夾新增 `tailwind.css` 檔：

```css
/* noinspection CssInvalidAtRule */
@tailwind base;
/* noinspection CssInvalidAtRule */
@tailwind components;
/* noinspection CssInvalidAtRule */
@tailwind utilities;
```

在根目錄新增 `tailwind.config.js` 檔：

```js
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

```js
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

```js
import { createApp } from 'vue';
import App from '@/App';
import router from '@/router';
import '@/assets/css/tailwind.css';

createApp(App).use(router).mount('#app');
```

使用：

```html
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
