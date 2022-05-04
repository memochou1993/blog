---
title: 使用 Storybook 和 Vite 建立 React 元件庫（二）：使用 Babel 打包
permalink: 使用-Storybook-和-Vite-建立-React-元件庫（二）：使用 Babel 打包
date: 2022-04-21 15:24:54
tags: ["程式設計", "JavaScript", "React", "Vite", "Storybook"]
categories: ["程式設計", "JavaScript", "React"]
---

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

## 程式碼

- [storybook-react](https://github.com/memochou1993/storybook-react)

## 參考資料

- [Creating a component library with Vite and Storybook](https://divotion.com/blog/creating-a-component-library-with-vite-and-storybook)
- [Storybook for React tutorial](https://storybook.js.org/tutorials/intro-to-storybook/react/zh-TW/get-started/)
