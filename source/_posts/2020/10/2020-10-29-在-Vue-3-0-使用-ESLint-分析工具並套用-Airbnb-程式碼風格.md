---
title: 在 Vue 3.0 使用 ESLint 分析工具並套用 Airbnb 程式碼風格
date: 2020-10-29 23:05:27
tags: ["程式設計", "JavaScript", "ESLint", "Airbnb", "Vue"]
categories: ["程式設計", "JavaScript", "ESLint"]
---

## 做法

建立專案。

```bash
npm create vite@latest example -- --template vue
cd example
```

安裝套件。

```bash
npm i @vue/eslint-config-airbnb \
  eslint-import-resolver-typescript \
  -D
```

在專案根目錄新增 `.eslintrc.cjs` 檔：

```js
module.exports = {
  extends: [
    'plugin:vue/recommended',
    '@vue/airbnb',
  ],
  settings: {
    'import/resolver': {
      typescript: {},
    },
  },
  rules: {
    'no-console': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'import/extensions': ['error', 'ignorePackages'],
  },
};
```
