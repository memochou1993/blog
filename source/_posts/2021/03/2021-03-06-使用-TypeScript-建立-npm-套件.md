---
title: 使用 TypeScript 建立 npm 套件
date: 2021-03-06 20:16:35
tags: ["程式設計", "JavaScript", "TypeScript", "npm", "Jest"]
categories: ["程式設計", "JavaScript", "TypeScript"]
---

## 建立專案

```bash
mkdir ts-example-package
```

使用以下指令建立 `package.json` 檔：

```bash
npm init
```

生成後 `package.json` 檔如下：

```json
{
  "name": "@memochou1993/ts-example-package",
  "version": "1.0.0",
  "description": "",
  "main": "dist/index.js",
  "scripts": {
    "test": "jest"
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/memochou1993/ts-example-package.git"
  },
  "author": "Memo Chou",
  "license": "ISC",
  "bugs": {
    "url": "https://github.com/memochou1993/ts-example-package/issues"
  },
  "homepage": "https://github.com/memochou1993/ts-example-package#readme"
}
```

安裝 TypeScript 和 Jest 測試套件。

```bash
npm i -D typescript jest ts-jest @types/jest
```

建立 `tsconfig.json` 檔：

```bash
{
  "compilerOptions": {
    "outDir": "dist",
    "lib": [
      "es2016",
    ],
    "sourceMap": true
  },
  "include": [
    "src/**/*.ts"
  ]
}
```

- 參數 `compilerOptions.outDir` 指定生成的 JavaScript 檔所放置的位置。
- 參數 `compilerOptions.lib` 表示 ES6 語法是可被使用的。
- 參數 `include` 指定要被編譯的檔案。

在 `package.json` 檔的腳本中，加入以下指令：

```json
{
  "scripts": {
    "build": "tsc",
    "test": "jest"
  },
}
```

在 `src` 資料夾新增 `index.ts` 檔，並新增主要程式碼。

```ts
export function hello(name: string): string {
  return `Hello ${name}`;
}
```

執行編譯。

```bash
npm run build
```

編譯後的 JavaScript 檔在 `dist` 資料夾裡，內容如下：

```js
"use strict";
exports.__esModule = true;
exports.hello = void 0;
function hello(name) {
    return "Hello " + name;
}
exports.hello = hello;
//# sourceMappingURL=index.js.map
```

## 單元測試

在 `test` 資料夾新增 `index.test.ts` 檔：

```ts
import { hello } from '../src';

test('hello', () => {
  expect(hello('World')).toEqual('Hello World');
});
```

建立 Jest 設定檔：

```bash
node_modules/.bin/ts-jest config:init
```

建立的 `jest.config.js` 檔如下：

```json
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
};
```

執行測試。

```bash
npm run test 
```

## 發布套件

建立 `.gitignore` 檔，並推送至 GitHub。

```bash
dist/
node_modules/
```

修改 `package.json` 檔，指定只有 `dist` 資料夾中的內容需要被發布。

```json
{
  "main": "dist/index.js",
  "files": [
    "dist"
  ]
}
```

測試發布，查看即將發布的檔案列表。

```bash
npm publish --dry-run
```

登入 `npm` 套件管理平台。

```bash
npm login
```

發布套件。

```bash
npm publish --access=public
```

## 參考資料

- [Creating a TS-written NPM package for use in Node-JS or Browser.](https://dev.to/charperbonaroo/creating-a-ts-written-npm-package-for-use-in-node-js-or-browser-5gm3)
