---
title: 使用 TypeScript 實作「密碼產生器」套件
date: 2021-05-09 00:50:31
tags: ["程式設計", "JavaScript", "TypeScript", "npm", "Jest"]
categories: ["程式設計", "JavaScript", "TypeScript"]
---

## 建立專案

```bash
mkdir password-generator-js
```

使用以下指令建立 `package.json` 檔：

```bash
npm init
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

安裝 `eslint` 代碼檢查套件。

```bash
npm install eslint \
    eslint-config-airbnb-typescript \
    eslint-plugin-import@^2.22.0 \
    @typescript-eslint/eslint-plugin@^4.4.1 \
    --save-dev
```

修改 `.eslintrc.js` 檔：

```js
module.exports = {
  extends: [
    'airbnb-typescript/base',
  ],
  parserOptions: {
    project: './tsconfig.json',
  },
};
```

新增 `.eslintignore` 檔：

```bash
node_modules/
dist/
jest.config.js
```

在 `package.json` 檔的腳本中，加入以下指令：

```json
{
  "scripts": {
    "build": "tsc",
    "test": "jest",
    "lint": "eslint src test"
  },
}
```

## 實作

在 `src` 資料夾建立 `index.ts` 檔：

```ts
interface Config {
  length: number,
  letters: boolean,
  symbols: boolean,
  numbers: boolean,
}

export default class Generator {
  static generate(config: Config): string {
    const { length } = config;
    const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const symbols = '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~';
    const numbers = '012345678901234567890123456789012345678901234567890123456789';
    let characters = '';
    if (config.letters) characters += letters;
    if (config.symbols) characters += symbols;
    if (config.numbers) characters += numbers;
    if (!characters) return '';
    const rdn = (n: number): number => Math.floor(Math.random() * n);
    const rds = (s: string): string => s[(rdn(s.length))];
    let s = '';
    for (let i = 0; i < length; i += 1) { s += rds(characters); }
    return s;
  }
}
```

## 測試

在 `test` 資料夾新增 `index.test.ts` 檔：

```js
import Generator from '../src';

test('generate', () => {
  const config = {
    length: 20,
    letters: true,
    symbols: false,
    numbers: false,
  };
  const password = Generator.generate(config);
  expect(password).toHaveLength(20);
});
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

## 程式碼

- [password-generator-js](https://github.com/memochou1993/password-generator-js)
