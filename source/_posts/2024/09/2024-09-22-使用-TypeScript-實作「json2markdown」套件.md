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

安裝依賴套件。

```bash
npm i @memochou1993/stryle
```

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

### 實作介面

在 `lib` 資料夾，建立 `types` 資料夾。

```bash
mkdir types
```

在 `types` 資料夾，建立 `MarkdownSchema.ts` 檔。

```ts
interface MarkdownSchema {
  [key: string]: unknown;
  br?: string;
  h1?: string;
  h2?: string;
  h3?: string;
  h4?: string;
  h5?: string;
  h6?: string;
  indent?: number;
  li?: unknown;
  p?: string | boolean;
  td?: string[];
  tr?: string[];
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

### 實作功能

在 `lib/converter` 資料夾，建立 `Converter.ts` 檔。

```ts
import { toTitleCase } from '@memochou1993/stryle';
import { MarkdownSchema } from '~/types';

interface ConverterOptions {
  initialHeadingLevel?: number;
  disableTitleCase?: boolean;
}

class Converter {
  private schema: MarkdownSchema[] = [];

  private startLevel: number;

  private disableTitleCase: boolean;

  constructor(data: unknown, options: ConverterOptions = {}) {
    this.startLevel = options.initialHeadingLevel ?? 1;
    this.disableTitleCase = options.disableTitleCase ?? false;
    this.convert(data);
  }

  public static toMarkdown(data: unknown, options: ConverterOptions = {}): string {
    return new Converter(data, options).toMarkdown();
  }

  /**
   * Converts the provided data into Markdown format.
   *
   * This method processes a data structure and converts it into
   * Markdown, handling headings, list items, table rows, and paragraphs.
   */
  public toMarkdown(): string {
    const headings = Array.from({ length: 6 }, (_, i) => `h${i + 1}`);
    return this.schema
      .map((element) => {
        const level = headings.findIndex(h => element[h] !== undefined);
        if (level !== -1) {
          return `${'#'.repeat(level + 1)} ${this.toTitleCase(String(element[headings[level]]))}\n\n`;
        }
        if (element.li !== undefined) {
          return `${'  '.repeat(Number(element.indent))}- ${element.li}\n`;
        }
        if (element.tr !== undefined) {
          return `| ${element.tr.map(v => this.toTitleCase(v)).join(' | ')} |\n${element.tr.map(() => '| ---').join(' ')} |\n`;
        }
        if (element.td !== undefined) {
          return `| ${element.td.join(' | ')} |\n`;
        }
        if (typeof element.p === 'boolean') {
          return `${this.toTitleCase(String(element.p))}\n\n`;
        }
        if (element.br !== undefined) {
          return '\n';
        }
        return `${element.p}\n\n`;
      })
      .join('');
  }

  private convert(data: unknown): void {
    if (!data) return;
    if (Array.isArray(data)) {
      this.convertFromArray(data);
      return;
    }
    if (typeof data === 'object') {
      this.convertFromObject(data as Record<string, unknown>);
      return;
    }
    this.convertFromPrimitive(data);
  }

  private convertFromArray(data: unknown[], indent: number = 0): MarkdownSchema[] {
    for (const item of data) {
      if (Array.isArray(item)) {
        this.convertFromArray(item, indent + 1);
        continue;
      }
      this.schema.push({
        li: this.formatValue(item),
        indent,
      });
    }
    return this.schema;
  }

  private convertFromObject(data: Record<string, unknown>, level: number = 0): MarkdownSchema[] {
    const heading = `h${Math.min(Math.max(this.startLevel, 1) + level, 6)}`;
    for (let [key, value] of Object.entries(data)) {
      key = key.trim();
      if (typeof value === 'string') {
        value = value.trim().replaceAll('\\n', '\n');
      }
      this.schema.push({
        [heading]: key,
      });
      if (Array.isArray(value)) {
        const [item] = value;
        if (typeof item === 'object') {
          this.schema.push({
            tr: Object.keys(item),
          });
          value.forEach((item) => {
            this.schema.push({
              td: Object.values(item).map(v => this.formatValue(v)),
            });
          });
          this.schema.push({
            br: '',
          });
          continue;
        }
        this.convertFromArray(value);
        this.schema.push({
          br: '',
        });
        continue;
      }
      if (typeof value === 'object') {
        this.convertFromObject(value as Record<string, unknown>, level + 1);
        continue;
      }
      this.convertFromPrimitive(value);
    }
    return this.schema;
  }

  private convertFromPrimitive(value: unknown): MarkdownSchema[] {
    this.schema.push({
      p: this.formatValue(value),
    });
    return this.schema;
  }

  private formatValue(value: unknown): string {
    if (Array.isArray(value)) {
      return value.map(v => this.formatValue(v)).join(', ');
    }
    if (typeof value === 'object') {
      return JSON.stringify(value);
    }
    return String(value);
  }

  private toTitleCase(value: string): string {
    if (this.disableTitleCase) return value;
    return toTitleCase(value);
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
import fs from 'fs';
import { describe, expect, test } from 'vitest';
import Converter from './Converter';

const OUTPUT_DIR = '.output';

describe('Converter', () => {
  test('should convert from array', () => {
    // @ts-expect-error Ignore error for testing private method
    const actual = new Converter(undefined).convertFromArray([
      1,
      [
        2,
        [
          3,
        ],
      ],
    ]);

    const expected = [
      { li: '1', indent: 0 },
      { li: '2', indent: 1 },
      { li: '3', indent: 2 },
    ];

    expect(actual).toStrictEqual(expected);
  });

  test('should convert from object', () => {
    // @ts-expect-error Ignore error for testing private method
    const actual = new Converter(undefined).convertFromObject({
      foo: 'bar',
    });

    const expected = [
      { h1: 'foo' },
      { p: 'bar' },
    ];

    expect(actual).toStrictEqual(expected);
  });

  test('should convert from primitive', () => {
    // @ts-expect-error Ignore error for testing private method
    const actual = new Converter(undefined).convertFromPrimitive('foo');

    const expected = [
      { p: 'foo' },
    ];

    expect(actual).toStrictEqual(expected);
  });

  test('should start from specified heading level', () => {
    const data = {
      heading_2: 'Hello, World!',
    };

    const actual = Converter.toMarkdown(data, {
      initialHeadingLevel: 2,
    });

    const expected = `## Heading 2

Hello, World!

`;

    expect(actual).toBe(expected);
  });

  test('should disable title case', () => {
    const data = {
      heading_1: 'Hello, World!',
    };

    const actual = Converter.toMarkdown(data, {
      disableTitleCase: true,
    });

    const expected = `# heading_1

Hello, World!

`;

    expect(actual).toBe(expected);
  });

  test('should convert correctly', () => {
    const data = {
      heading_1: 'Hello, World!',
      nested: {
        heading_2: 'Hello, World!',
        nested: {
          heading_3: 'Hello, World!',
          nested: {
            heading_4: 'Hello, World!',
            nested: {
              heading_5: 'Hello, World!',
              nested: {
                heading_6: 'Hello, World!',
                nested: {
                  heading_7: 'Hello, World!',
                },
              },
            },
          },
        },
      },
      table: [
        {
          id: 1,
          name: 'Alice',
          email: 'alice@example.com',
          friends: ['Bob', 'Charlie'],
          settings: {
            theme: 'dark',
          },
        },
        {
          id: 2,
          name: 'Bob',
          email: 'bob@example.com',
          friends: ['Charlie'],
          settings: {
            theme: 'light',
          },
        },
        {
          id: 3,
          name: 'Charlie',
          email: 'charlie@example.com',
          friends: [],
        },
      ],
      array: [
        1,
        [
          2,
          [
            3,
          ],
        ],
        {
          foo: 'bar',
        },
      ],
      markdown_code: '```\nconsole.log(\'Hello, World!\');\n```',
      markdown_table: '| foo | bar | baz |\n| --- | --- | --- |\n| 1 | 2 | 3 |',
    };

    const converter = new Converter(data);

    const actual = converter.toMarkdown();

    const expected = `# Heading 1

Hello, World!

# Nested

## Heading 2

Hello, World!

## Nested

### Heading 3

Hello, World!

### Nested

#### Heading 4

Hello, World!

#### Nested

##### Heading 5

Hello, World!

##### Nested

###### Heading 6

Hello, World!

###### Nested

###### Heading 7

Hello, World!

# Table

| Id | Name | Email | Friends | Settings |
| --- | --- | --- | --- | --- |
| 1 | Alice | alice@example.com | Bob, Charlie | {"theme":"dark"} |
| 2 | Bob | bob@example.com | Charlie | {"theme":"light"} |
| 3 | Charlie | charlie@example.com |  |

# Array

- 1
  - 2
    - 3
- {"foo":"bar"}

# Markdown Code

\`\`\`
console.log('Hello, World!');
\`\`\`

# Markdown Table

| foo | bar | baz |
| --- | --- | --- |
| 1 | 2 | 3 |

`;

    if (!fs.existsSync(OUTPUT_DIR)) fs.mkdirSync(OUTPUT_DIR);
    fs.writeFileSync(`${OUTPUT_DIR}/actual.md`, actual);
    fs.writeFileSync(`${OUTPUT_DIR}/expected.md`, expected);

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
      name: 'JSON2MD',
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
├── converter
│   ├── Converter.d.ts
│   └── index.d.ts
├── index.d.ts
├── index.js
├── index.umd.js
└── types
    ├── MarkdownSchema.d.ts
    └── index.d.ts
```

## 使用

### 透過 ES 模組使用

修改 `src/main.ts` 檔，透過 ES 模組使用套件。

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
