---
title: 使用 Storybook 和 Vite 建立 React 元件庫
permalink: 使用-Storybook-和-Vite-建立-React-元件庫
date: 2022-04-21 15:24:54
tags: ["程式設計", "JavaScript", "React", "Vite", "Storybook"]
categories: ["程式設計", "JavaScript", "React"]
---

## 建立專案

建立專案。

```BASH
mkdir storybook-react
cd storybook-react
```

初始化專案。

```BASH
npm init
```

新增 `.gitignore` 檔。

```ENV
/node_modules
/dist
```

## 安裝依賴套件

安裝 Vite 工具。

```BASH
npm i vite -D
```

安裝 React 框架。

```BASH
npm i react@17.0.0 react-dom@17.0.0 -D
```

安裝 Storybook 工具。

```BASH
npx sb@latest init
```

## 啟動介面

啟動 Storybook 介面。

```BASH
npm run storybook
```

## 編譯

安裝依賴套件。

```BASH
npm i @babel/cli cross-env babel-preset-react-app -D
```

將 `stories` 資料夾重新命名為 `src`，並修改 `.storybook/main.js` 檔。

```JS
module.exports = {
  stories: [
    '../src/**/*.stories.mdx',
    '../src/**/*.stories.@(js|jsx|ts|tsx)'
  ],
  addons: [
    '@storybook/addon-links',
    '@storybook/addon-essentials',
    '@storybook/addon-interactions'
  ],
  framework: '@storybook/react'
}
```

建立 `src/index.js` 檔。

```JS
export * from './Button';
```

修改 `package.json` 檔。

```JSON
{
  "scripts": {
    "build": "cross-env BABEL_ENV=production babel src -d dist",
  },
  "babel": {
    "presets": [
      "react-app"
    ]
  }
}
```

執行編譯。

```BASH
npm run build
```

## 發布

修改 `package.json` 檔，注意套件名稱必須是獨一無二的。

```JSON
{
  "name": "@memochou1993/storybook-react",
  "version": "0.1.0",
  "description": "",
  "main": "dist/index.js",
  "repository": "https://github.com/memochou1993/storybook-react.git"
}
```

提交修改。

```BASH
git add .
git commit -m "Rename folder"
```

新增版本。

```BASH
npm version 0.1.0 -m "First release"
```

登入 NPM。

```BASH
npm login
```

發布套件。

```JSON
npm publish --access=public
```

## 程式碼

- [storybook-react](https://github.com/memochou1993/storybook-react)

## 參考資料

- [Creating a component library with Vite and Storybook](https://divotion.com/blog/creating-a-component-library-with-vite-and-storybook)
- [Storybook for React tutorial](https://storybook.js.org/tutorials/intro-to-storybook/react/zh-TW/get-started/)
