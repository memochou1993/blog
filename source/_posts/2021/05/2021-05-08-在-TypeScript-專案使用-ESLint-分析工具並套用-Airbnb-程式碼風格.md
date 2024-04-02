---
title: 在 TypeScript 專案使用 ESLint 分析工具並套用 Airbnb 程式碼風格
date: 2021-05-08 16:05:38
tags: ["Programming", "JavaScript", "ESLint", "Airbnb", "TypeScript"]
categories: ["Programming", "JavaScript", "ESLint"]
---

## 做法

安裝依賴套件。

```bash
npm install eslint \
  eslint-config-airbnb-typescript \
  eslint-import-resolver-typescript \
  --save-dev
```

修改 `.eslintrc.js` 檔：

```js
module.exports = {
  extends: [
    'airbnb-base',
    'airbnb-typescript/base',
  ],
  parserOptions: {
    project: './tsconfig.json',
  },
  rules: {
    //
  },
  ignorePatterns: [
    '**/*.js',
  ],
};
```

修改 `package.json` 檔：

```js
{
  "scripts": {
    "lint": "eslint src"
  },
}
```

執行檢查。

```bash
npm run lint
```
