---
title: 在 JavaScript 專案使用 ESLint 分析工具和 Airbnb 程式碼風格
permalink: 在-JavaScript-專案使用-ESLint-分析工具和-Airbnb-程式碼風格
date: 2021-12-18 23:46:04
tags: ["程式設計", "JavaScript", "ESLint", "Airbnb"]
categories: ["程式設計", "JavaScript", "ESLint"]
---

## 做法

安裝依賴套件。

```BASH
npm install eslint \
    eslint-config-airbnb \
    eslint-plugin-jsx-a11y \
    eslint-plugin-react \
    eslint-plugin-import \
    --save-dev
```

新增 `.eslintrc.json` 檔：

```JS
{
    "extends": "airbnb",
    "env": {
        "browser": true,
        "node": true
    }
}
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
