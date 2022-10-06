---
title: 在 React 17.0 使用 ESLint 分析工具並套用 Airbnb 程式碼風格
date: 2022-03-24 02:31:43
tags: ["程式設計", "JavaScript", "ESLint", "Airbnb", "React"]
categories: ["程式設計", "JavaScript", "ESLint"]
---

## 做法

安裝 `eslint` 依賴套件。

```bash
npm i eslint \
    eslint-plugin-react \
    eslint-config-airbnb \
    --save-dev
```

新增 `.eslintrc.js` 檔。

```js
module.exports = {
  extends: 'airbnb',
  plugins: [
    'react',
  ],
  parserOptions: {
    ecmaVersion: '2020', // or above
  },
  rules: {
    //
  },
};
```

修改 `package.json` 檔。

```json
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

```bash
npm run lint
```
