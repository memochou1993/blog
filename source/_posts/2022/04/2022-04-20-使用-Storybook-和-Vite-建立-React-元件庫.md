---
title: 使用 Storybook 和 Vite 建立 React 元件庫
date: 2022-04-20 15:24:54
tags: ["程式設計", "JavaScript", "React", "TypeScript", "Vite", "Storybook"]
categories: ["程式設計", "JavaScript", "React"]
---

## 建立專案

建立專案。

```bash
mkdir react-storybook
cd react-storybook
```

初始化專案。

```bash
npm init
```

新增 `.gitignore` 檔。

```env
/node_modules
/dist
```

## 安裝依賴套件

安裝 Vite 工具。

```bash
npm i vite -D
```

安裝 React 框架。

```bash
npm i react@17.0.0 react-dom@17.0.0 -D
```

安裝 Storybook 工具。

```bash
npx sb@latest init
```

## 啟動介面

啟動 Storybook 介面。

```bash
npm run storybook
```

## 編譯

新增 `index.ts` 檔，將元件匯出。

```ts
import Button from "./components/Button";

const components = {
  Button,
};

export {
  components as default,
  Button,
};
```

更新 `package.json` 檔。

```json
{
  "name": "@memochou1993/react-storybook",
  "version": "0.1.0",
  "description": "",
  "main": "./dist/index.cjs.js",
  "module": "./dist/index.es.js",
  "types": "./dist/index.d.ts",
  "files": [
    "dist"
  ],
  "repository": "",
  "scripts": {
    "build": "vite build",
    "test": "echo \"Error: no test specified\" && exit 1",
    "storybook": "start-storybook -p 6006",
    "build-storybook": "build-storybook",
    "lint": "eslint src --ext .jsx,.js,.tsx,.ts"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "react": "^17.0.0",
    "react-dom": "^17.0.0",
    "styled-components": "^5.3.5"
  },
  "devDependencies": {
    "@storybook/addon-actions": "^6.4.22",
    "@storybook/addon-essentials": "^6.4.22",
    "@storybook/addon-interactions": "^6.4.22",
    "@storybook/addon-links": "^6.4.22",
    "@storybook/react": "^6.4.22",
    "@storybook/testing-library": "^0.0.11",
    "@types/styled-components": "^5.1.25",
    "@typescript-eslint/eslint-plugin": "^5.21.0",
    "@vitejs/plugin-react": "^1.3.2",
    "eslint-plugin-react": "^7.29.4",
    "vite": "^2.9.5",
    "vite-plugin-dts": "^1.1.1",
    "vue-tsc": "^0.34.11"
  },
  "exports": {
    ".": {
      "import": "./dist/index.es.js",
      "require": "./dist/index.cjs.js"
    }
  }
}
```

新增 `vite.config.ts` 檔：

```ts
import react from '@vitejs/plugin-react';
import path from 'node:path';
import { defineConfig } from 'vite';
import dts from 'vite-plugin-dts';

export default defineConfig({
  plugins: [
    react(),
    dts({
      insertTypesEntry: true,
    }),
  ],
  build: {
    lib: {
      entry: path.resolve(__dirname, 'src/index.ts'),
      name: 'Web3',
      formats: ['es', 'cjs'],
      fileName: (format) => `index.${format}.js`,
    },
    rollupOptions: {
      external: ['react', 'react-dom', 'styled-components'],
      output: {
        exports: "named",
        globals: {
          react: 'React',
          'react-dom': 'ReactDOM',
          'styled-components': 'styled',
        },
      },
    },
  },
});
```

修改 `tsconfig.json` 檔。

```json
{
  "isolatedModules": true,
}
```

執行編譯。

```bash
npm run build
```

## 發布

修改 `package.json` 檔，注意套件名稱必須是獨一無二的。

```json
{
  "name": "@memochou1993/react-storybook",
  "repository": "https://github.com/memochou1993/react-storybook.git"
}
```

提交修改。

```bash
git add .
git commit -m "Initial commit"
```

新增版本。

```bash
npm version 0.1.0 -m "First release"
```

登入 npm。

```bash
npm login
```

發布套件。

```json
npm publish --access=public
```

## 程式碼

- [react-storybook](https://github.com/memochou1993/react-storybook)

## 參考資料

- [Creating a component library with Vite and Storybook](https://divotion.com/blog/creating-a-component-library-with-vite-and-storybook)
- [Create a React component library with Vite and Typescript](https://dev.to/nicolaserny/create-a-react-component-library-with-vite-and-typescript-1ih9)
- [Storybook for React tutorial](https://storybook.js.org/tutorials/intro-to-storybook/react/zh-TW/get-started/)
- [Vite - Building for Production](https://cn.vitejs.dev/guide/build.html)
