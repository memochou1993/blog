---
title: 使用 Storybook 和 Vite 建立 React 元件庫（一）：啟動
permalink: 使用-Storybook-和-Vite-建立-React-元件庫（一）：啟動
date: 2022-04-20 15:24:54
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

## 程式碼

- [storybook-react](https://github.com/memochou1993/storybook-react)

## 參考資料

- [Creating a component library with Vite and Storybook](https://divotion.com/blog/creating-a-component-library-with-vite-and-storybook)
- [Storybook for React tutorial](https://storybook.js.org/tutorials/intro-to-storybook/react/zh-TW/get-started/)
