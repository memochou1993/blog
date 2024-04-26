---
title: 在 Next 13.0 使用 ESLint 程式碼檢查工具並套用 Airbnb 程式碼風格
date: 2023-10-18 17:52:05
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
  extends: [
    'next/core-web-vitals',
    'airbnb',
  ],
  globals: {
    React: 'readonly',
  },
  rules: {
    'react/jsx-filename-extension': ['error', { extensions: ['.js', '.jsx', '.ts', '.tsx'] }],
  },
};
```

執行檢查。

```bash
npm run lint
```
