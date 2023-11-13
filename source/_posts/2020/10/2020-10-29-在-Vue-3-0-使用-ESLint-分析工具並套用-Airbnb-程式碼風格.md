---
title: 在 Vue 3.0 使用 ESLint 分析工具並套用 Airbnb 程式碼風格
date: 2020-10-29 23:05:27
tags: ["Programming", "JavaScript", "ESLint", "Airbnb", "Vue"]
categories: ["Programming", "JavaScript", "ESLint"]
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
    '@vue/airbnb',
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
