---
title: 在 Node 專案使用 ESLint 分析工具並套用 Airbnb 程式碼風格
date: 2022-11-18 00:00:56
tags: ["Programming", "JavaScript", "ESLint", "Airbnb", "Node"]
categories: ["Programming", "JavaScript", "ESLint"]
---

## 做法

建立專案。

```bash
mkdir my-project
cd my-project
```

初始化專案。

```bash
npm init
```

安裝依賴套件。

```bash
npm i eslint eslint-config-airbnb -D
```

建立 ESLint 設定檔。

```bash
npm init @eslint/config
```

修改 `.eslintrc.js` 檔。

```js
module.exports = {
  env: {
    commonjs: true,
    es2021: true,
    node: true,
  },
  extends: 'airbnb',
  overrides: [
  ],
  parserOptions: {
    ecmaVersion: 'latest',
  },
  rules: {
  },
};
```

新增 `src/index.js` 檔。

```js
console.log('Hello World!');
```

修改 `package.json` 檔，新增 `lint` 指令。

```bash
{
  "scripts": {
    "lint": "eslint src"
  }
}
```

執行檢查。

```bash
npm run lint
```
