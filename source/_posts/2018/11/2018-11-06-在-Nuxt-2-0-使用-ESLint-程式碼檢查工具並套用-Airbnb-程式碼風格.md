---
title: 在 Nuxt 2.0 使用 ESLint 程式碼檢查工具並套用 Airbnb 程式碼風格
date: 2018-11-06 00:22:26
tags: ["Programming", "JavaScript", "ESLint", "Airbnb", "Vue", "Nuxt"]
categories: ["Programming", "JavaScript", "ESLint"]
---

## 環境

- Windows 7
- node 8.11.1
- npm 5.6.0

## 做法

使用以下指令安裝。

```bash
npm install -g install-peerdeps
install-peerdeps --dev eslint-config-airbnb-base
```

修改 `.prettierrc` 檔。

```json
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "arrowParens": "always"
}
```

修改 `.eslintrc.js` 檔。

```js
extends: [
  'plugin:vue/recommended',
  'plugin:prettier/recommended',
  'airbnb-base'
],
// ...
rules: {
  'arrow-parens': ['error', 'always'],
  'no-console': process.env.NODE_ENV === 'production' ? 'error' : 'off',
  'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'off',
  'no-param-reassign': ['error', { 'props': false }],
  'no-return-assign': ['error', 'except-parens'],
  'space-before-function-paren': ['error', 'never'],
}
```

## 程式碼

- [nuxt-airbnb-preset](https://github.com/memochou1993/nuxt-airbnb-preset)
