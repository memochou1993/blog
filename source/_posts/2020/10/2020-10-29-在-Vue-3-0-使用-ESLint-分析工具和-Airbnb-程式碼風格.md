---
title: 在 Vue 3.0 使用 ESLint 分析工具和 Airbnb 程式碼風格
permalink: 在-Vue-3-0-使用-ESLint-分析工具和-Airbnb-程式碼風格
date: 2020-10-29 23:05:27
tags: ["程式設計", "JavaScript", "ESLint", "Airbnb", "Vue"]
categories: ["程式設計", "JavaScript", "ESLint"]
---

## 做法

安裝 `@vue/eslint-config-airbnb` 套件。

```BASH
yarn add @vue/eslint-config-airbnb --dev
```

在根目錄新增 `.eslintrc.js` 檔：

```JS
module.exports = {
  root: true,
  env: {
    node: true,
  },
  extends: [
    'plugin:vue/recommended',
    '@vue/airbnb',
  ],
  parserOptions: {
    parser: 'babel-eslint',
  },
  rules: {
    'no-console': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'import/extensions': ['error', 'ignorePackages'],
  },
};
```
