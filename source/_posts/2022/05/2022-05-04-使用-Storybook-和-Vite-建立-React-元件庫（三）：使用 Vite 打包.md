---
title: 使用 Storybook 和 Vite 建立 React 元件庫（三）：使用 Vite 打包
permalink: 使用-Storybook-和-Vite-建立-React-元件庫（三）：使用 Vite 打包
date: 2022-05-04 01:54:36
tags: ["程式設計", "JavaScript", "React", "Vite", "TypeScript"]
categories: ["程式設計", "JavaScript", "React"]
---

## 做法

更新 `package.json` 檔。

```JSON
{
  "name": "@memochou1993/storybook-react",
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

```TS
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

```JSON
{
  "isolatedModules": true,
}
```

執行編譯。

```BASH
npm run build
```

## 參考資料

- [Create a React component library with Vite and Typescript](https://dev.to/nicolaserny/create-a-react-component-library-with-vite-and-typescript-1ih9)
- [Vite - Library Mode](https://vitejs.dev/guide/build.html#library-mode)
