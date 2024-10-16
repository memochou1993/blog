---
title: 使用 TypeScript 實作「stryle」套件
date: 2024-10-17 01:47:20
tags: ["Programming", "JavaScript", "TypeScript", "Vite", "npm", "Vitest"]
categories: ["Programming", "JavaScript", "TypeScript"]
---

## 前言

本文實作一個名為 `stryle` 的函式庫，用來轉換文字風格，以下以 `toTitleCase` 為例。

## 建立專案

建立專案。

```bash
npm create vite

✔ Project name: … stryle
✔ Select a framework: › Vanilla
✔ Select a variant: › TypeScript
```

建立 `lib` 資料夾，用來存放此套件相關的程式。

```bash
cd stryle
mkdir lib
```

修改 `tsconfig.json` 檔。

```json
{
  "include": ["src", "lib"],
}
```

安裝 TypeScript 相關套件。

```bash
npm i @types/node vite-plugin-dts -D
```

## 安裝檢查工具

安裝 ESLint 相關套件。

```bash
npm i eslint @eslint/js typescript-eslint globals @types/eslint__js @stylistic/eslint-plugin -D
```

建立 `eslint.config.js` 檔。

```js
import pluginJs from '@eslint/js';
import stylistic from '@stylistic/eslint-plugin';
import globals from 'globals';
import tseslint from 'typescript-eslint';

export default [
  pluginJs.configs.recommended,
  ...tseslint.configs.recommended,
  stylistic.configs.customize({
    semi: true,
    jsx: true,
    braceStyle: '1tbs',
  }),
  {
    files: [
      '**/*.{js,mjs,cjs,ts}',
    ],
  },
  {
    ignores: [
      'dist/**/*',
    ],
  },
  {
    languageOptions: {
      globals: globals.node,
    },
  },
  {
    rules: {
      'curly': ['error', 'multi-line'],
      'dot-notation': 'error',
      'no-console': ['warn', { allow: ['warn', 'error', 'debug'] }],
      'no-lonely-if': 'error',
      'no-useless-rename': 'error',
      'object-shorthand': 'error',
      'prefer-const': ['error', { destructuring: 'any', ignoreReadBeforeAssign: false }],
      'require-await': 'error',
      'sort-imports': ['error', { ignoreDeclarationSort: true }],
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

## 實作

修改 `tsconfig.json` 檔。

```json
{
  "compilerOptions": {
    "target": "ES2021",
    "useDefineForClassFields": true,
    "module": "ESNext",
    "lib": ["ES2021", "DOM", "DOM.Iterable"],
    "skipLibCheck": true,

    // ...

    "paths": {
      "~/*": ["./lib/*"]
    }
  }
}
```

進到 `lib` 資料夾。

```bash
cd lib
```

建立 `capitalize.ts` 檔。

```ts
const capitalize = (str: string): string => {
  return `${str.charAt(0).toUpperCase()}${str.slice(1)}`;
};

export default capitalize;
```

建立 `toTitleCase.ts` 檔。

```ts
import capitalize from './capitalize';

const EXCEPTIONS = /^(a|an|and|as|at|but|by|for|if|in|is|nor|of|on|or|the|to|with)$/i;
const PLACEHOLDER = '###PLACEHOLDER###';

interface ConverterOptions {
  specialWords?: string[];
}

class Converter {
  private str: string;

  private specialWords: string[];

  constructor(str: string, options: ConverterOptions = {}) {
    this.str = str;
    this.specialWords = options.specialWords?.filter(Boolean) ?? [];
  }

  public convert(): string {
    return this.encodeSpecialWords()
      .transform()
      .decodeSpecialWords()
      .getResult();
  }

  private encodeSpecialWords(): this {
    if (this.specialWords.length === 0) return this;
    const pattern = new RegExp(this.specialWords.join('|'), 'gi');
    this.str = this.str.replace(pattern, match => `${PLACEHOLDER}${match.toUpperCase()}${PLACEHOLDER}`);
    return this;
  }

  private transform(): this {
    this.str = this.str
      .replace(/[_]/g, ' ')
      .replace(/([a-z])([A-Z])/g, '$1 $2')
      .replace(/([A-Z]+)([A-Z][a-z])/g, '$1 $2')
      .split(' ')
      .map((word, index) => this.processWord(word, index === 0))
      .join(' ');
    return this;
  }

  private decodeSpecialWords(): this {
    if (this.specialWords.length === 0) return this;
    this.str = this.str.replace(new RegExp(`${PLACEHOLDER}(.+?)${PLACEHOLDER}`, 'g'), (_, match) => {
      return this.specialWords.find((word) => {
        return word.toUpperCase() === match.toUpperCase()
          || word.toUpperCase() === match.replace(/\s+/g, '_').toUpperCase();
      }) || match;
    });
    return this;
  }

  private getResult(): string {
    return this.str;
  }

  private processWord(word: string, isFirstWord: boolean): string {
    if (word === word.toUpperCase()) return word;
    if (word.includes('-')) {
      return word.split('-')
        .map((part, i) => this.processWord(part, i === 0))
        .join('-');
    }
    if (isFirstWord || !EXCEPTIONS.test(word)) {
      return capitalize(word);
    }
    return word.toLowerCase();
  }
}

const toTitleCase = (str: string, options: ConverterOptions = {}): string => new Converter(str, options).convert();

export default toTitleCase;
```

## 單元測試

安裝 Vitest 相關套件。

```bash
npm i vitest -D
```

修改 `package.json` 檔。

```json
{
  "scripts": {
    "test": "vitest"
  }
}
```

建立 `capitalize.test.ts` 檔。

```ts
import { expect, test } from 'vitest';
import capitalize from './capitalize';

test('capitalize', () => {
  const cases = [
    ['foo', 'Foo'],
    ['FOO', 'FOO'],
  ];

  cases.forEach(([input, expected]) => {
    const actual = capitalize(input);
    expect(actual).toBe(expected);
  });
});
```

建立 `toTitleCase.test.ts` 檔。

```ts
import { describe } from 'node:test';
import { expect, test } from 'vitest';
import toTitleCase from './toTitleCase';

describe('toTitleCase', () => {
  test('should convert correctly', () => {
    const cases = [
      ['hello, world!', 'Hello, World!'],
      ['snake_case', 'Snake Case'],
      ['camelCase', 'Camel Case'],
      ['PascalCase', 'Pascal Case'],
      ['kebab-case', 'Kebab-Case'],
      ['HTMLElement', 'HTML Element'],
      ['This is an HTML element', 'This is an HTML Element'],
      ['Is this an HTML element', 'Is This an HTML Element'],
    ];

    cases.forEach(([input, expected]) => {
      const actual = toTitleCase(input);
      expect(actual).toBe(expected);
    });
  });

  test('should convert considering special words', () => {
    const specialWords = ['', 'iPhone', 'iOS', 'Snake_Case'];

    const cases = [
      ['This is an iphone', 'This is an iPhone'],
      ['This is an IPHONE', 'This is an iPhone'],
      ['This is an iPhone', 'This is an iPhone'],
      ['This is an ios app', 'This is an iOS App'],
      ['This is an IOS app', 'This is an iOS App'],
      ['This is an iOS app', 'This is an iOS App'],
      ['This is a snake_case', 'This is a Snake_Case'],
      ['This is a SNAKE_CASE', 'This is a Snake_Case'],
      ['This is a Snake_Case', 'This is a Snake_Case'],
    ];

    cases.forEach(([input, expected]) => {
      const actual = toTitleCase(input, { specialWords });
      expect(actual).toBe(expected);
    });
  });
});
```

執行測試。

```bash
npm run test
```

## 編譯

建立 `vite.config.ts` 檔。

```ts
import path from 'path';
import { defineConfig } from 'vite';
import dts from 'vite-plugin-dts';

export default defineConfig({
  plugins: [
    dts({
      include: [
        'lib',
      ],
      exclude: [
        '**/*.test.ts',
      ],
    }),
  ],
  build: {
    copyPublicDir: false,
    lib: {
      entry: path.resolve(__dirname, 'lib/index.ts'),
      name: 'Stryle',
      fileName: format => format === 'es' ? 'index.js' : `index.${format}.js`,
    },
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
  "name": "@memochou1993/stryle",
  "private": false,
  "version": "0.0.1",
  "license": "MIT",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc -p ./tsconfig.build.json && vite build",
    "preview": "vite preview",
    "lint": "eslint .",
    "test": "vitest"
  },
  "devDependencies": {
    "@eslint/js": "^9.11.0",
    "@stylistic/eslint-plugin": "^2.9.0",
    "@types/eslint__js": "^8.42.3",
    "@types/node": "^22.5.5",
    "eslint": "^9.11.0",
    "globals": "^15.9.0",
    "typescript": "^5.5.4",
    "typescript-eslint": "^8.6.0",
    "vite": "^4.4.5",
    "vite-plugin-dts": "^4.2.1",
    "vitest": "^2.1.1"
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
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/memochou1993/stryle"
  },
  "keywords": [
    "string",
    "style",
    "converter"
  ]
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
├── capitalize.d.ts
├── index.d.ts
├── index.js
├── index.umd.js
└── toTitleCase.d.ts
```

## 使用

### 透過 ES 模組使用

修改 `src/main.ts` 檔，透過 ES 模組使用套件。

```js
import { toTitleCase } from '../dist';
import './style.css';

document.querySelector<HTMLDivElement>('#app')!.innerHTML = `<pre>${toTitleCase('hello, world!')}</pre>`;
```

啟動服務。

```bash
npm run dev
```

輸出如下：

```md
Hello, World!
```

### 透過 UMD 模組使用

修改 `index.html` 檔。

```html
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
    <script src="dist/index.umd.js"></script>
    <script>
      console.log(window.Stryle.toTitleCase('hello, world!'));
    </script>
  </body>
</html>
```

啟動服務。

```bash
npm run dev
```

輸出如下：

```md
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

- [stryle](https://github.com/memochou1993/stryle)
