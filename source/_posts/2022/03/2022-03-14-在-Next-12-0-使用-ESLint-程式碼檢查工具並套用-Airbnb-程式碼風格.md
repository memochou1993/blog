---
title: 在 Next 12.0 使用 ESLint 程式碼檢查工具並套用 Airbnb 程式碼風格
date: 2022-03-14 23:56:36
tags: ["Programming", "JavaScript", "ESLint", "Airbnb", "React", "Next"]
categories: ["Programming", "JavaScript", "ESLint"]
---

## 做法

安裝 `eslint` 依賴套件。

```bash
npm i eslint \
    eslint-config-next \
    eslint-config-airbnb \
    -D
```

修改 `.eslintrc.js` 檔，並添加相關規則。

```js
module.exports = {
  env: {
    commonjs: true,
    es2021: true,
    node: true,
  },
  extends: [
    'next/core-web-vitals',
    'airbnb',
  ],
  overrides: [
  ],
  parserOptions: {
    ecmaVersion: 'latest',
  },
  rules: {
    'react/prop-types': 'off',
    'react/jsx-props-no-spreading': 'off',
  },
};
```

執行檢查。

```bash
npm run lint
```
