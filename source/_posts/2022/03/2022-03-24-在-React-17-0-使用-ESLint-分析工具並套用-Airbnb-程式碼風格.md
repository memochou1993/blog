---
title: 在 React 17.0 使用 ESLint 分析工具並套用 Airbnb 程式碼風格
permalink: 在-React-17-0-使用-ESLint-分析工具並套用-Airbnb-程式碼風格
date: 2022-03-24 02:31:43
tags: ["程式設計", "JavaScript", "ESLint", "Airbnb", "React"]
categories: ["程式設計", "JavaScript", "ESLint"]
---

## 做法

安裝 `eslint` 依賴套件。

```BASH
npm i eslint \
    eslint-plugin-react \
    eslint-config-airbnb \
    --save-dev
```

新增 `.eslintrc.js` 檔。

```JS
module.exports = {
  extends: 'airbnb',
  plugins: [
    'react',
  ],
  rules: {
    //
  },
};
```

修改 `package.json` 檔。

```JSON
{
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject",
    "lint": "eslint src"
  }
}
```

執行檢查。

```BASH
npm run lint
```
