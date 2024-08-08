---
title: 使用 Vue 3 和 Express 實作內容管理系統（二）：初始化後端專案
date: 2024-08-01 23:43:42
tags: ["Programming", "JavaScript", "Vue", "Bootstrap", "Node", "Express", "Firebase", "Firestore", "CMS"]
categories: ["Programming", "JavaScript", "Vue"]
---

## 前言

本文是前端工作坊的教學文件，介紹如何使用 Vue 3 和 Express 實作內容管理系統，並搭配 Firebase 實現持久化和認證。

## 認識 Node 執行環境

> Ref: <https://nodejs.org/en>

Node.js 是一個開放原始碼的 JavaScript 執行環境，讓開發者可以在伺服器端執行 JavaScript。範例如下：

```js
const http = require('http');

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello, World!\n');
});

server.listen(3000, '127.0.0.1', () => {
  console.log('Server running at http://127.0.0.1:3000/');
});
```

執行腳本。

```bash
node index.js
```

## 初始化 Express 專案

> Ref: <https://expressjs.com/>

建立資料夾。

```bash
mkdir simple-cms-api
```

進入資料夾。

```bash
cd simple-cms-api
```

使用 npm 初始化專案。

```bash
npm init
```

開啟 VS Code 編輯器。

```bash
code .
```

安裝 Express 框架。

```bash
npm install express
```

## 添加 Git 版本控制

新增 `.gitignore` 檔。

```bash
/node_modules
```

使用 Git 初始化版本控制，並到 GitHub 建立一個新的儲存庫。

```bash
git init
git add .
git commit -m "Initial commit"
```

複製 GitHub 儲存庫的 SSH URL，並指定預設的遠端儲存庫位址。

```bash
git remote add origin git@github.com:memochou1993/simple-cms-api.git
```

將本地的 main 分支推送到預設的遠端儲存庫。

```bash
git push -u origin main
```

## 添加 ESLint 檢查工具

> Ref: <https://eslint.org/>

```bash
npm init @eslint/config@latest
```

```bash
npm init @eslint/config@latest

✔ How would you like to use ESLint? · problems
✔ What type of modules does your project use? · commonjs
✔ Which framework does your project use? · none
✔ Does your project use TypeScript? · javascript
✔ Where does your code run? · node
```

生成的 `eslint.config.mjs` 檔如下：

```js
import globals from "globals";
import pluginJs from "@eslint/js";


export default [
  {files: ["**/*.js"], languageOptions: {sourceType: "commonjs"}},
  {languageOptions: { globals: globals.node }},
  pluginJs.configs.recommended,
];
```

修改 `eslint.config.mjs` 檔，加上一些常用的檢查規則。

```js
// ...

export default [
  // ...
  {
    rules: {
      'comma-dangle': ['error', 'always-multiline'],
      'eol-last': ['error', 'always'],
      'no-multiple-empty-lines': ['error', { max: 1, maxEOF: 0 }],
      'object-curly-spacing': ['error', 'always'],
      indent: ['error', 2],
      quotes: ['error', 'single'],
      semi: ['error', 'always'],
    },
  },
];
```

修改 `package.json` 檔，加上 `lint` 命令腳本。

```json
{
  // ...
  "scripts": {
    // ...
    "lint": "eslint"
  }
  // ...
}
```

執行檢查。

```bash
npm run lint
```

新增 `.vscode/settings.json` 檔，添加讓 ESLint 自動修正程式碼的設定，和一些常用的編輯器設定。

```json
{
  "editor.tabSize": 2,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit",
    "source.organizeImports": "explicit"
  }
}
```

提交修改。

```bash
git add .
git commit -m "Add eslint"
git push
```

## 建立網頁伺服器

> Ref: <https://expressjs.com/en/starter/hello-world.html>

新增 `index.js` 檔，建立一個網頁伺服器。

```js
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
```

啟動伺服器。

```bash
node index.js
```

提交修改。

```bash
git add .
git commit -m "Add web server"
git push
```

## 程式碼

- [simple-cms-ui](https://github.com/memochou1993/simple-cms-ui)
- [simple-cms-api](https://github.com/memochou1993/simple-cms-api)
