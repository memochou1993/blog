---
title: 在 TypeScript 專案使用 ESLint 分析工具和 Airbnb 程式碼風格
permalink: 在-TypeScript-專案使用-ESLint-分析工具和-Airbnb-程式碼風格
date: 2021-05-08 16:05:38
tags: ["程式設計", "JavaScript", "ESLint", "Airbnb", "TypeScript"]
categories: ["程式設計", "JavaScript", "ESLint"]
---

## 做法

安裝依賴套件。

```BASH
npm install eslint \
    eslint-config-airbnb-typescript \
    eslint-plugin-import \
    @typescript-eslint/eslint-plugin \
    --save-dev
```

修改 `.eslintrc.js` 檔：

```JS
module.exports = {
  extends: [
    'airbnb-typescript/base',
  ],
  parserOptions: {
    project: './tsconfig.json',
  },
};
```

修改 `package.json` 檔：

```JS
{
  "scripts": {
    "lint": "eslint src"
  },
}
```

執行檢查。

```BASH
npm run lint
```
