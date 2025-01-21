---
title: 使用 Vite 和 TypeScript 建立 npm 套件
date: 2024-07-24 21:19:05
tags: ["Programming", "JavaScript", "TypeScript", "Vite", "npm", "Vitest"]
categories: ["Programming", "JavaScript", "TypeScript"]
---

## 建立專案

建立專案。

```bash
npm create vite

✔ Project name: … vite-library-ts-example
✔ Select a framework: › Vanilla
✔ Select a variant: › TypeScript
```

建立 `lib` 資料夾，用來存放此套件相關的程式。

```bash
cd vite-library-ts-example
mkdir lib
```

修改 `tsconfig.json` 檔。

```json
{
  // ...
  "include": ["src", "lib"]
}
```

安裝 TypeScript 相關套件。

```bash
npm i @types/node -D
```

## 安裝檢查工具

安裝 ESLint 相關套件。

```bash
npm i eslint @eslint/js typescript-eslint globals @types/eslint__js -D
```

建立 `eslint.config.js` 檔。

```js
import pluginJs from '@eslint/js';
import globals from 'globals';
import tseslint from 'typescript-eslint';

export default [
  {
    files: [
      '**/*.{js,mjs,cjs,ts}',
    ],
  },
  {
    languageOptions: {
      globals: globals.node,
    },
  },
  pluginJs.configs.recommended,
  ...tseslint.configs.recommended,
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

修改 `package.json` 檔。

```json
{
  "scripts": {
    "lint": "eslint ."
  }
}
```

執行檢查。

```bash
npm run lint
```

## 建立單元測試

安裝 Vitest 相關套件。

```bash
npm i vitest -D
```

建立 `lib/index.ts` 檔。

```ts
const greet = (): string => {
  // TODO
};

export default greet;
```

建立 `lib/index.test.ts` 檔。

```ts
import { expect, test } from 'vitest';
import { greet } from '.';

test('greet', () => {
  expect(greet()).toBe('Hello, World!');
});
```

修改 `package.json` 檔。

```json
{
  "scripts": {
    "test": "vitest"
  }
}
```

執行測試。

```bash
npm run test
```

## 實作

修改 `lib/index.ts` 檔。

```ts
const greet = (): string => {
  return 'Hello, World!';
};

export {
  greet,
};
```

執行測試。

```bash
npm run test
```

## 編譯

安裝 `vite-plugin-dts` 套件，用來產生定義檔。

```bash
npm i vite-plugin-dts -D
```

建立 `vite.config.ts` 檔。

```ts
import path from 'path';
import { defineConfig } from 'vite';
import dts from 'vite-plugin-dts';

export default defineConfig({
  plugins: [
    dts({ include: ['lib'] }),
  ],
  build: {
    lib: {
      entry: path.resolve(__dirname, 'lib/index.ts'),
      name: 'MyLib',
      fileName: (format) => format === 'es' ? 'index.js' : `index.${format}.js`,
    },
    copyPublicDir: false,
  },
  resolve: {
    alias: {
      '~': path.resolve(__dirname, 'lib'),
    },
  },
});
```

建立 `tsconfig.build.json` 檔。

```json
{
  "extends": "./tsconfig.json",
  "include": ["lib"]
}
```

修改 `package.json` 檔。

```json
{
  "name": "@memochou1993/vite-library-ts-example",
  "private": false,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc -p ./tsconfig.build.json && vite build",
    "preview": "vite preview",
    "test": "vitest",
    "lint": "eslint lib"
  },
  "devDependencies": {
    "@eslint/js": "^9.7.0",
    "@types/node": "^20.14.12",
    "eslint": "^8.57.0",
    "jsdom": "^24.1.1",
    "typescript": "^5.0.2",
    "typescript-eslint": "^7.17.0",
    "vite": "^4.4.5",
    "vite-plugin-dts": "^4.0.0-beta.1",
    "vitest": "^2.0.4"
  },
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "files": [
    "dist"
  ],
  "exports": {
    ".": {
      "import": "./dist/index.js",
      "require": "./dist/index.umd.js"
    }
  }
}
```

執行編譯。

```bash
npm run build
```

檢查 `dist` 資料夾。

```bash
tree dist

dist
├── index.d.ts
├── index.js
└── index.umd.js
```

## 使用

修改 `src/main.ts` 檔，透過 ES 模組使用套件。

```ts
import { greet } from '../dist'; // 引入編譯過的模組
import './style.css';

document.querySelector<HTMLDivElement>('#app')!.innerHTML = `
  <div>
    ${greet()}
  </div>
`;
```

修改 `index.html` 檔，透過 UMD 模組使用套件。

```js
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Vite + TS</title>
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="/src/main.ts"></script>
    <script src="/dist/index.umd.js"></script>
    <script>
      // 從 window 取得 MyLib 物件
      console.log(window.MyLib.greet())
    </script>
  </body>
</html>
```

啟動服務。

```bash
npm run dev
```

輸出如下：

```bash
Hello, World!
```

## 發布

登入 `npm` 套件管理平台。

```bash
npm login
```

測試發布，查看即將發布的檔案列表。

```bash
npm publish --dry-run
```

發布套件。

```bash
npm publish --access=public
```

## 程式碼

- [vite-library-ts-example](https://github.com/memochou1993/vite-library-ts-example)

## 參考文件

- [Create a Component Library Fast](https://dev.to/receter/how-to-create-a-react-component-library-using-vites-library-mode-4lma)
