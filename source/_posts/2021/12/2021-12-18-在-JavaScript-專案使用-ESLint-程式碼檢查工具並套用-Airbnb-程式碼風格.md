---
title: 在 JavaScript 專案使用 ESLint 程式碼檢查工具並套用 Airbnb 程式碼風格
date: 2021-12-18 23:46:04
tags: ["Programming", "JavaScript", "ESLint", "Airbnb"]
categories: ["Programming", "JavaScript", "ESLint"]
---

## 做法

建立專案。

```bash
npm create vite@latest
```

安裝依賴套件。

```bash
npm install eslint eslint-config-airbnb -D
```

在根目錄新增 `.eslintrc.cjs` 檔：

```js
module.exports = {
  extends: 'airbnb',
  env: {
    browser: true,
    node: true,
  },
};
```

修改 `package.json` 檔：

```js
{
  "type": "module",
  "scripts": {
    "lint": "eslint ."
  },
}
```

執行檢查。

```bash
npm run lint
```
