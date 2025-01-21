---
title: 使用 TypeScript 實作「markdown2html」套件
date: 2025-01-21 11:09:22
tags: ["Programming", "JavaScript", "TypeScript", "Vite", "npm", "Vitest"]
categories: ["Programming", "JavaScript", "TypeScript"]
---

## 建立專案

建立專案。

```bash
npm create vite

✔ Project name: … markdown2html
✔ Select a framework: › Vanilla
✔ Select a variant: › TypeScript
```

建立 `lib` 資料夾，用來存放此套件相關的程式。

```bash
cd markdown2html
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

修改 `tsconfig.json` 檔，添加 `~` 路徑別名。

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

### 實作功能

安裝依賴套件。

```bash
npm i --save-peer marked dompurify
npm i --save-dev jsdom @types/jsdom
```

在 `lib/converter` 資料夾，建立 `Converter.ts` 檔。

```ts
import createDOMPurify, { DOMPurify, Config as DOMPurifyConfig } from 'dompurify';
import { Marked, MarkedExtension } from 'marked';

interface ConverterOptions {
  marked?: Marked;
  markedExtensions?: MarkedExtension[];
  domPurify?: DOMPurify;
  domPurifyConfig?: DOMPurifyConfig;
}

class Converter {
  private markdown: string;

  private marked: Marked;

  private domPurify: DOMPurify;

  constructor(markdown: string, options: ConverterOptions = {}) {
    this.markdown = markdown;
    this.marked = options.marked ?? new Marked();
    this.setMarkedExtensions(options.markedExtensions);
    this.domPurify = options.domPurify ?? createDOMPurify();
    this.setDOMPurifyConfig(options.domPurifyConfig);
  }

  public setMarkedExtensions(extensions?: MarkedExtension[]): this {
    if (extensions) this.marked.use(...extensions);
    return this;
  }

  public setDOMPurifyConfig(config?: DOMPurifyConfig): this {
    if (config) this.domPurify.setConfig(config);
    return this;
  }

  /**
   * Converts the provided Markdown content into HTML code.
   */
  public static toHTML(markdown: string, options: ConverterOptions = {}): string {
    return new Converter(markdown, options).toHTML();
  }

  /**
   * Converts the provided Markdown content into HTML code.
   */
  public toHTML(domPurifyConfig: DOMPurifyConfig = {}): string {
    const html = this.marked
      .parse(this.markdown)
      .toString();

    return this.domPurify.sanitize(html, domPurifyConfig);
  }
}

export default Converter;
```

### 匯出模組

在 `lib/converter` 資料夾，建立 `index.ts` 檔。

```js
import Converter from './Converter';

export default Converter;
```

在 `lib` 資料夾，建立 `index.ts` 檔。

```js
import Converter from './converter';

export {
  Converter,
};
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
    "test": "npm run test:unit -- --run",
    "test:unit": "vitest"
  }
}
```

在 `lib/converter` 資料夾，建立 `Converter.test.ts` 檔。

```ts
import DOMPurify from 'dompurify';
import { JSDOM } from 'jsdom';
import { describe, expect, test } from 'vitest';
import Converter from './Converter';

const { window } = new JSDOM();

describe('Converter', () => {
  test('should convert and sanitize correctly', () => {
    const markdown = `# Heading 1

<a href="https://example.com" target="_blank" onmouseover="alert('XSS Attack!')">Link</a>
`;

    const converter = new Converter(markdown, {
      domPurify: DOMPurify(window),
      domPurifyConfig: {
        ADD_ATTR: [
          'target',
        ],
      },
    });

    const actual = converter.toHTML();

    const expected = `<h1>Heading 1</h1>
<p><a target="_blank" href="https://example.com">Link</a></p>
`;

    expect(actual).toBe(expected);
  });
});
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
      name: 'Markdown2HTML',
      fileName: format => format === 'es' ? 'index.js' : `index.${format}.js`,
    },
    rollupOptions: {
      external: [
        'dompurify',
        'marked',
      ],
      output: {
        globals: {
          dompurify: 'DOMPurify',
          marked: 'marked',
        },
      },
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
  "name": "@username/markdown2html-example",
  "private": false,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "lint": "eslint .",
    "test": "npm run test:unit -- --run",
    "test:unit": "vitest",
    "release": "npm run test && npm run build && npm publish --access public"
  },
  "peerDependencies": {
    "dompurify": "^3.2.3",
    "marked": "^15.0.6"
  },
  "devDependencies": {
    "@eslint/js": "^9.18.0",
    "@types/eslint__js": "^8.42.3",
    "@types/jsdom": "^21.1.7",
    "eslint": "^9.18.0",
    "globals": "^15.14.0",
    "jsdom": "^26.0.0",
    "typescript": "^5.0.2",
    "typescript-eslint": "^8.21.0",
    "vite": "^4.4.5",
    "vite-plugin-dts": "^4.5.0",
    "vitest": "^3.0.2"
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
├── converter
│   ├── Converter.d.ts
│   └── index.d.ts
├── index.d.ts
├── index.js
└── index.umd.js
```

## 使用

### 透過 ES 模組使用

修改 `src/main.ts` 檔，透過 ES 模組使用套件。

```js
import { Converter } from '../dist';
import './style.css';

const output = Converter.toHTML('# Hello, World! \n<a href="/" target="_blank" onmouseover="alert(\'XSS Attack!\')">It works!</a>', {
  domPurifyConfig: {
    ADD_ATTR: [
      'target',
      'onmouseover', // uncomment this line to test the XSS attack
    ],
  },
});

document.querySelector<HTMLDivElement>('#app')!.innerHTML = output;
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
    <title>Markdown2HTML</title>
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="/src/main.ts"></script>
    <script src="https://unpkg.com/marked/marked.min.js"></script>
    <script src="https://unpkg.com/dompurify/dist/purify.min.js"></script>
    <script src="dist/index.umd.js"></script>
    <script>
      const output = window.Markdown2HTML.Converter.toHTML('# Hello, World! \n<a href="/" target="_blank" onmouseover="alert(\'XSS Attack!\')">It works!</a>', {
        domPurifyConfig: {
          ADD_ATTR: [
            'target',
            // 'onmouseover', // uncomment this line to test the XSS attack
          ],
        },
      });

      console.log(output);
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
<h1>Hello, World!</h1>
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

- [markdown2html](https://github.com/memochou1993/markdown2html)
