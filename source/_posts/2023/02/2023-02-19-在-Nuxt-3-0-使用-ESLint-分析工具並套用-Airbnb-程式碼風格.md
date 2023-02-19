---
title: 在 Nuxt 3.0 使用 ESLint 分析工具並套用 Airbnb 程式碼風格
date: 2023-02-19 14:51:20
tags: ["程式設計", "JavaScript", "ESLint", "Airbnb", "Vue", "Nuxt"]
categories: ["程式設計", "JavaScript", "ESLint"]
---

## 做法

建立專案。

```bash
npx nuxi init nuxt-app
cd nuxt-app
```

安裝 ESlint 套件。

```bash
npm i @vue/eslint-config-airbnb \
  eslint-import-resolver-typescript \
  -D
```

新增 `.eslintrc.js` 檔。

```js
module.exports = {
  extends: [
    '@vue/eslint-config-airbnb',
  ],
  settings: {
    'import/resolver': {
      typescript: {},
    },
  },
  rules: {
  },
};
```
