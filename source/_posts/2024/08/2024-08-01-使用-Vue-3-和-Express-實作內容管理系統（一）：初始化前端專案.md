---
title: 使用 Vue 3 和 Express 實作內容管理系統（一）：初始化前端專案
date: 2024-08-01 23:43:41
tags: ["Programming", "JavaScript", "Vue", "Bootstrap", "Node.js", "Express", "Firebase", "Firestore", "CMS"]
categories: ["Programming", "JavaScript", "Vue"]
---

## 前言

本文是前端工作坊的教學文件，介紹如何使用 Vue 3 和 Express 實作內容管理系統，並搭配 Firebase 實現持久化和認證。

## 前置作業

### 檢查環境

下載、安裝，並確認 Node 版本。

```bash
node --version
```

下載、安裝，並確認 Git 版本。

```bash
git --version
```

### 安裝擴充套件

在 VS Code 編輯器，安裝以下擴充套件：

- [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
- [Vue - Official](https://marketplace.visualstudio.com/items?itemName=Vue.volar)

### 設定 GitHub SSH 金鑰

第一次使用 GitHub 的人，需要在本機建立 SSH 金鑰。

```bash
ssh-keygen
```

印出 SSH 公鑰。

```bash
cat ~/.ssh/id_rsa.pub
```

將 SSH 公鑰添加到 GitHub，此動作只需要做一次。

## 初始化 Vue 專案

> Ref: <https://vitejs.dev/>

首先，使用 Vite 初始化一個 Vue 3 專案。

```bash
npm create vite@latest simple-cms-ui -- --template vue
```

進入資料夾。

```bash
cd simple-cms-ui
```

開啟 VS Code 編輯器。

```bash
code .
```

安裝依賴套件。

```bash
npm install
```

啟動網頁伺服器。

```bash
npm run dev
```

## 添加 Git 版本控制

使用 Git 初始化版本控制，並到 GitHub 建立一個新的儲存庫。

```bash
git init
git add .
git commit -m "Initial commit"
```

複製 GitHub 儲存庫的 SSH URL，並指定預設的遠端儲存庫位址。

```bash
git remote add origin git@github.com:memochou1993/simple-cms-ui.git
```

將本地的 main 分支推送到預設的遠端儲存庫。

```bash
git push -u origin main
```

## 添加 ESLint 檢查工具

> Ref: <https://eslint.org/>

使用 ESLint 安裝工具初始化專案。

```bash
npm init @eslint/config@latest

✔ How would you like to use ESLint? · problems
✔ What type of modules does your project use? · esm
✔ Which framework does your project use? · vue
✔ Does your project use TypeScript? · javascript
✔ Where does your code run? · browser
```

生成的 `eslint.config.js` 檔如下：

```js
import globals from "globals";
import pluginJs from "@eslint/js";
import pluginVue from "eslint-plugin-vue";


export default [
  {files: ["**/*.{js,mjs,cjs,vue}"]},
  {languageOptions: { globals: globals.browser }},
  pluginJs.configs.recommended,
  ...pluginVue.configs["flat/essential"],
];
```

修改 `eslint.config.js` 檔，改為 `flat/recommended` 設定，並加上一些常用的檢查規則。

```js
// ...

export default [
  // ...
  ...pluginVue.configs['flat/recommended'],
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

## 添加 Bootstrap 介面框架

> Ref: <https://getbootstrap.com/>

### 使用 CDN 連結安裝

> Ref: <https://getbootstrap.com/docs/5.3/getting-started/introduction/#cdn-links>

修改 `index.html` 檔。

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Vite + Vue</title>
    <link href="<https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/>css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
  </head>
  <body>
    <div id="app"></div>
    <script src="<https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/>js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
    <script type="module" src="/src/main.js"></script>
  </body>
</html>
```

修改 `App.vue` 檔。

```html
<script setup>
import HelloWorld from './components/HelloWorld.vue';
</script>

<template>
  <div>
    <HelloWorld msg="Hello, World!" />
  </div>
</template>
```

修改 `HelloWorld.vue` 檔。

```html
<script setup>
defineProps({
  msg: String,
});
</script>

<template>
  <button type="button" class="btn btn-primary">
    {{ msg }}
  </button>
</template>
```

提交修改。

```bash
git add .
git commit -m "Add bootstrap"
git push
```

### 使用 npm 安裝

> Ref: <https://github.com/twbs/examples/tree/main/vue/>

使用 npm 安裝依賴套件。

```bash
npm install bootstrap @popperjs/core
npm install sass -D
```

修改 `index.html` 檔，將內容恢復原狀。

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Vite + Vue</title>
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="/src/main.js"></script>
  </body>
</html>
```

將 `style.css` 檔重新命名為 `style.scss` 檔，並引入 Bootstrap 的樣式。

```scss
@import "bootstrap/scss/bootstrap";

// ...
```

修改 `main.js` 檔。

```js
import { Popover } from 'bootstrap';
import { createApp } from 'vue';
import App from './App.vue';
import './style.scss';

createApp(App).mount('#app');

document.querySelectorAll('[data-bs-toggle="popover"]')
  .forEach(popover => {
    new Popover(popover);
  });
```

如果遇到以下問題，參考 [Issue #40621](https://github.com/twbs/bootstrap/issues/40621)  的討論，將 Sass 套件降級到 `1.77.6` 版。

```bash
Deprecation Warning: Sass's behavior for declarations that appear after nested
rules will be changing to match the behavior specified by CSS in an upcoming
version. To keep the existing behavior, move the declaration above the nested
rule. To opt into the new behavior, wrap the declaration in `& {}`.
```

使用 npm 將 Sass 套件降級。

```bash
npm install sass@1.77.6 -D
```

提交修改。

```bash
git add .
git commit -m "Add bootstrap via npm instead of cdn"
git push
```

## 程式碼

- [simple-cms-ui](https://github.com/memochou1993/simple-cms-ui)
- [simple-cms-api](https://github.com/memochou1993/simple-cms-api)
