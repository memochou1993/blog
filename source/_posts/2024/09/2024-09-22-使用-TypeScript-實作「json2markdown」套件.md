---
title: 使用 TypeScript 實作「json2markdown」套件
date: 2024-09-22 19:53:56
tags: ["Programming", "JavaScript", "TypeScript", "Vite", "npm", "Vitest"]
categories: ["Programming", "JavaScript", "TypeScript"]
---

## 建立專案

建立專案。

```bash
npm create vite

✔ Project name: … json2markdown
✔ Select a framework: › Vanilla
✔ Select a variant: › TypeScript
```

建立 `lib` 資料夾，用來存放此套件相關的程式。

```bash
cd json2markdown
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
      '@typescript-eslint/ban-ts-comment': 'off',
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

### 實作介面

在 `lib` 資料夾，建立 `types` 資料夾。

```bash
mkdir types
```

在 `types` 資料夾，建立 `MarkdownSchema.ts` 檔。

```ts
interface MarkdownSchema {
  [key: string]: string | string[] | boolean | undefined;
  h1?: string;
  h2?: string;
  h3?: string;
  h4?: string;
  h5?: string;
  h6?: string;
  p?: string | boolean;
  ul?: string[];
}

export default MarkdownSchema;
```

在 `types` 資料夾，建立 `index.ts` 檔。

```ts
import MarkdownSchema from './MarkdownSchema';

export type {
  MarkdownSchema,
};
```

### 實作工具函式

在 `lib` 資料夾，建立 `utils` 資料夾。

```bash
mkdir utils
```

在 `utils` 資料夾，建立 `toTitleCase.ts` 檔。

```ts
const titleCaseExceptions = /^(a|an|and|as|at|but|by|for|if|in|is|nor|of|on|or|the|to|with)$/i;

const toTitleCase = (str: string): string => {
  return str
    .replace(/[_-]/g, ' ')
    .split(' ')
    .map((word, index) => {
      if (index === 0 || !titleCaseExceptions.test(word)) {
        return `${word.charAt(0).toUpperCase()}${word.slice(1).toLowerCase()}`;
      }
      return word.toLowerCase();
    })
    .join(' ');
};

export default toTitleCase;
```

在 `utils` 資料夾，建立 `index.ts` 檔。

```ts
import toTitleCase from './toTitleCase';

export {
  toTitleCase,
};
```

建立 `Converter.ts` 檔。

```ts
import { MarkdownSchema } from '~/types';
import { toTitleCase } from './utils';

class Converter {
  static toMarkdown(obj: object) {
    return Converter.toMarkdownSchema(obj)
      .map((element) => {
        const headings = Array.from({ length: 6 }, (_, i) => `h${i + 1}`);
        const level = headings.findIndex(h => element[h]);
        if (level !== -1) {
          return `${'#'.repeat(level + 1)} ${toTitleCase(element[headings[level]] as string)}\n\n`;
        }
        if (element.ul) {
          return `${element.ul.map(li => `- ${li}\n`).join('')}\n`;
        }
        if (typeof element.p === 'boolean') {
          return `${toTitleCase(String(element.p))}\n\n`;
        }
        return `${element.p}\n\n`;
      })
      .join('');
  }

  static toMarkdownSchema(obj: object, schema: MarkdownSchema[] = [], level = 1) {
    if (!obj) return [];
    for (let [key, value] of Object.entries(obj)) {
      if (key.startsWith('_')) continue;
      key = key.trim();
      if (typeof value === 'string') {
        value = value.trim().replaceAll('\\n', '\n');
      }
      const tag = `h${Math.min(level, 6)}`;
      schema.push({ [tag]: key });
      if (Array.isArray(value)) {
        const [item] = value;
        if (Array.isArray(item) && item.length > 0) {
          schema.push({ ul: value.map(item => JSON.stringify(item)) });
          continue;
        }
        if (typeof item === 'object') {
          Converter.toMarkdownSchema(item, schema, level + 1);
          continue;
        }
        schema.push({ ul: value.map(item => typeof item === 'string' ? item : JSON.stringify(item)) });
        continue;
      }
      if (typeof value === 'object') {
        Converter.toMarkdownSchema(value, schema, level + 1);
        continue;
      }
      schema.push({ p: value });
    }
    return schema;
  }
}

export default Converter;
```

## 單元測試

安裝 Vitest 相關套件。

```bash
npm i vitest -D
```

建立 `tests/data/before.json` 檔。

```json
{
  "_ignored": {
    "foo": "bar"
  },
  "heading_1": "Hello, World!",
  "list": [
    "foo",
    "bar",
    "baz"
  ],
  "nested": [
    {
      "heading_2": "Hello, World!",
      "list": [
        "foo",
        "bar",
        "baz"
      ],
      "nested": [
        {
          "heading_3": "Hello, World!",
          "list": [
            "foo",
            "bar",
            "baz"
          ],
          "nested": [
            {
              "heading_4": "Hello, World!",
              "list": [
                "foo",
                "bar",
                "baz"
              ],
              "nested": [
                {
                  "heading_5": "Hello, World!",
                  "list": [
                    "foo",
                    "bar",
                    "baz"
                  ],
                  "nested": [
                    {
                      "heading_6": "Hello, World!",
                      "list": [
                        "foo",
                        "bar",
                        "baz"
                      ],
                      "nested": [
                        {}
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  ],
  "table": "| foo | bar | baz |\n| --- | --- | --- |\n| 1 | 2 | 3 |",
  "links": [
    "https://example.com",
    "https://example.com",
    "https://example.com"
  ],
  "unsupported": [
    [
      "foo",
      "bar",
      "baz"
    ]
  ]
}
```

建立 `after.md` 檔。

```md
# Heading 1

Hello, World!

# List

- foo
- bar
- baz

# Nested

## Heading 2

Hello, World!

## List

- foo
- bar
- baz

## Nested

### Heading 3

Hello, World!

### List

- foo
- bar
- baz

### Nested

#### Heading 4

Hello, World!

#### List

- foo
- bar
- baz

#### Nested

##### Heading 5

Hello, World!

##### List

- foo
- bar
- baz

##### Nested

###### Heading 6

Hello, World!

###### List

- foo
- bar
- baz

###### Nested

# Table

| foo | bar | baz |
| --- | --- | --- |
| 1 | 2 | 3 |

# Links

- https://example.com
- https://example.com
- https://example.com

# Unsupported

- ["foo","bar","baz"]


```

修改 `package.json` 檔。

```json
{
  "scripts": {
    "test": "vitest"
  }
}
```

建立 `tests/Converter.test.ts` 檔。

```ts
import { readFileSync } from 'fs';
import { expect, test } from 'vitest';
import Converter from '../lib/Converter';

const { dirname } = import.meta;

test('Converter.toMarkdownSchema', () => {
  const schema = Converter.toMarkdownSchema({ title: 'Hello, World!' });

  expect(schema).toStrictEqual([
    { h1: 'title' },
    { p: 'Hello, World!' },
  ]);
});

test('Converter.toMarkdown', () => {
  const before = readFileSync(`${dirname}/data/before.json`, 'utf-8');
  const after = readFileSync(`${dirname}/data/after.md`, 'utf-8');
  
  const markdown = Converter.toMarkdown(JSON.parse(before));

  expect(markdown).toBe(after);
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
    dts({ include: ['lib'] }),
  ],
  build: {
    lib: {
      entry: path.resolve(__dirname, 'lib/index.ts'),
      name: 'JSON2MD',
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
  "name": "@memochou1993/json2markdown",
  "private": true,
  "version": "0.0.0",
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
├── Converter.d.ts
├── index.d.ts
├── index.js
├── index.umd.js
├── types
│   ├── MarkdownSchema.d.ts
│   └── index.d.ts
└── utils
    ├── index.d.ts
    └── toTitleCase.d.ts
```

## 使用

修改 `src/main.ts` 檔，透過 ES 模組使用套件。

```ts
import Converter from '~/Converter.ts';
import './style.css';

const markdown = Converter.toMarkdown({
  title: 'Hello, World!',
});

document.querySelector<HTMLDivElement>('#app')!.innerHTML = `<pre>${markdown}</pre>`;
```

### 透過 ES 模組使用

```js
import { Converter } from '../dist';
import './style.css';

const markdown = Converter.toMarkdown({
  title: 'Hello, World!',
});

document.querySelector<HTMLDivElement>('#app')!.innerHTML = `<pre>${markdown}</pre>`;
```

啟動服務。

```bash
npm run dev
```

輸出如下：

```md
# Title

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
      const markdown = window.JSON2MD.Converter.toMarkdown({
        title: 'Hello, World!',
      });
      console.log(JSON.stringify(markdown));
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
"# Title\n\nHello, World!\n\n"
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

- [json2markdown](https://github.com/memochou1993/json2markdown)
