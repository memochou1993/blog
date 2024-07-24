---
title: 使用 TypeScript 實作「Vuetify Validator」套件
date: 2024-07-25 22:25:53
tags: ["Programming", "JavaScript", "TypeScript", "Vite", "npm", "Vitest"]
categories: ["Programming", "JavaScript", "TypeScript"]
---

## 建立專案

建立專案。

```bash
npm create vite

✔ Project name: … formulate
✔ Select a framework: › Vue
✔ Select a variant: › TypeScript
```

建立 `lib` 資料夾，用來存放此套件相關的程式。

```bash
cd formulate
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
npm i eslint@^8.57.0 @eslint/js typescript-eslint globals @types/eslint__js -D
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
    "lint": "eslint lib"
  }
}
```

執行檢查。

```bash
npm run lint
```

## 實作

進到 `lib` 資料夾。

```bash
cd lib
```

## 建立介面

建立 `types/Rule.d.ts` 檔。

```ts
interface Rule {
  (args?: object): (value: unknown) => boolean;
}

export default Rule;
```

建立 `types/LocaleMessages.d.ts` 檔。

```ts
interface LocaleMessages {
  [key: string]: (field: string, args?: object) => string;
}

export default LocaleMessages;
```

建立 `types/MessageRule.d.ts` 檔。

```ts
interface MessageRule {
  (value: unknown): boolean | string;
}

export default MessageRule;
```

建立 `types/index.ts` 檔。

```ts
import LocaleMessages from './LocaleMessages';
import MessageRule from './MessageRule';
import Rule from './Rule';

export type {
  LocaleMessages,
  MessageRule,
  Rule,
};
```

### 建立工具函式

建立 `utils/isEmpty.ts` 檔。

```ts
const isEmpty = (value: unknown): boolean => {
  return value === ''
    || value === null
    || value === undefined
    || (Array.isArray(value) && value.length < 1);
};

export default isEmpty;
```

建立 `utils/index.ts` 檔。

```ts
import isEmpty from './isEmpty.ts';

export {
  isEmpty,
};
```

### 建立規則函式

建立 `rules/required.ts` 檔。

```ts
import Rule from '../types/Rule';
import { isEmpty } from '../utils';

const required: Rule = () => (v) => {
  return !isEmpty(v);
};

export default required;
```

建立 `rules/index.ts` 檔。

```ts
import { Rule } from '~/types';
import required from './required';

const locales: {
  [key: string]: Rule;
} = {
  required,
};

export default locales;
```

### 建立驗證訊息函式

建立 `locales/en.ts` 檔。

```ts
import { LocaleMessages } from '~/types';

const en: LocaleMessages = {
  required: (field: string) => `The ${field} field is required.`,
};

export default en;
```

建立 `locales/index.ts` 檔。

```ts
import { LocaleMessages } from '~/types';
import en from './en';

const locales: {
  [key: string]: LocaleMessages;
} = {
  en,
};

export default locales;
```

建立 `FieldValidator.ts` 檔。

```ts
import locales from './locales';
import rules from './rules';
import { MessageRule } from './types';
import { isEmpty } from './utils';

class FieldValidator {
  fieldName: string;
  locale: string;
  messageRules: MessageRule[] = [];
  shouldSkip: boolean = false;

  constructor(fieldName: string, locale: string) {
    this.fieldName = fieldName.toLowerCase();
    this.locale = locale;
  }

  get localeMessages() {
    return locales[this.locale];
  }

  validate(value: unknown): boolean | string {
    if (this.shouldSkip) return true;
    for (const messageRule of this.messageRules) {
      const result = messageRule(value);
      if (typeof result === 'string') {
        return result;
      }
    }
    return true;
  }

  getMessageRules() {
    return this.shouldSkip ? [] : this.messageRules;
  }

  getRuleMessage(name: string, args?: object) {
    return (this.localeMessages[name] || this.localeMessages['default'])(this.fieldName, args);
  }

  buildMessageRule(name: string, args?: object) {
    const rule = rules[name](args);
    const ruleMessage = this.getRuleMessage(name, args);
    return (value: unknown) => (name !== 'required' && isEmpty(value)) || rule(value) || ruleMessage;
  }

  pushMessageRule(name: string, args?: object) {
    const messageRule = this.buildMessageRule(name, args);
    this.messageRules.push(messageRule);
    return this;
  }

  when(condition: boolean) {
    if (!condition) {
      this.shouldSkip = true;
    }
    return this;
  }

  required() {
    return this.pushMessageRule('required');
  }
}

export default FieldValidator;
```

建立 `FormValidator.ts` 檔。

```ts
import FieldValidator from './FieldValidator';
import locales from './locales/index';

class FormValidator {
  locale: string;

  constructor() {
    const { language } = window.navigator;
    this.locale = language in locales ? language : 'en';
  }

  setLocale(locale: string) {
    if (!(locale in locales)) {
      throw new Error(`Locale ${locale} is not supported`);
    }
    this.locale = locale;
    return this;
  }

  defineField(name: string) {
    return new FieldValidator(name, this.locale);
  }
}

export default FormValidator;
```

建立 `index.ts` 檔。

```ts
import FieldValidator from './FieldValidator';
import FormValidator from './FormValidator';

export {
  FieldValidator,
  FormValidator,
};
```

## 建立單元測試

安裝 Vitest 相關套件。

```bash
npm i vitest jsdom -D
```

建立 `lib/rules/required.test.ts` 檔。

```ts
import { expect, test } from 'vitest';
import required from './required';

test('rule "required" with valid input should pass', () => {
  const validate = required();
  expect(validate('foo')).toBe(true);
  expect(validate(true)).toBe(true);
  expect(validate(false)).toBe(true);
  expect(validate(1)).toBe(true);
  expect(validate(0)).toBe(true);
  expect(validate({})).toBe(true);
});

test('rule "required" with invalid input should fail', () => {
  const validate = required();
  expect(validate(undefined)).toBe(false);
  expect(validate(null)).toBe(false);
  expect(validate('')).toBe(false);
  expect(validate([])).toBe(false);
});
```

建立 `lib/index.test.ts` 檔。

```ts
import { expect, test } from 'vitest';
import Validator from './FormValidator';

test('validator with rule "required"', () => {
  const v = new Validator()
    .defineField('title')
    .required();

  // should pass
  expect(v.validate('foo')).toBe(true);
  
  // should fail
  expect(v.validate(undefined)).toBe('The title field is required.');
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

## 編譯

建立 `vite.config.ts` 檔。

```ts
import vue from '@vitejs/plugin-vue';
import path from 'path';
import { defineConfig } from 'vite';
import dts from 'vite-plugin-dts';

export default defineConfig({
  plugins: [
    vue(),
    dts({ include: ['lib'] }),
  ],
  build: {
    lib: {
      entry: path.resolve(__dirname, 'lib/index.ts'),
      name: 'Formulate',
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
  "name": "@memochou1993/formulate",
  "private": false,
  "version": "0.0.1",
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
    "@vitejs/plugin-vue": "^4.6.2",
    "eslint": "^8.57.0",
    "jsdom": "^24.1.1",
    "typescript": "^5.0.2",
    "typescript-eslint": "^7.17.0",
    "vite": "^4.4.5",
    "vite-plugin-dts": "^4.0.0-beta.1",
    "vitest": "^2.0.4",
    "vue": "^3.4.33",
    "vue-tsc": "^2.0.28",
    "vuetify": "^3.6.13"
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
├── FieldValidator.d.ts
├── FormValidator.d.ts
├── index.d.ts
├── index.js
├── index.test.d.ts
├── index.umd.js
├── locales
│   ├── en.d.ts
│   └── index.d.ts
├── rules
│   ├── index.d.ts
│   ├── required.d.ts
│   └── required.test.d.ts
├── types
│   └── index.d.ts
└── utils
    ├── index.d.ts
    └── isEmpty.d.ts
```

## 使用

安裝 Vuetify 框架。

```bash
npm i vuetify -D
```

修改 `src/main.ts` 檔，透過 ES 模組使用套件。

```ts
import { createApp } from 'vue';
import { createVuetify } from 'vuetify';
import * as components from 'vuetify/components';
import 'vuetify/styles';
import App from './App.vue';

const vuetify = createVuetify({ components });

createApp(App)
  .use(vuetify)
  .mount('#app');
```

修改 `index.html` 檔，透過 UMD 模組使用套件。

```html
<script setup lang="ts">
import { computed, ref } from 'vue';
import { FormValidator } from '../dist';

const form = ref();

const validator = new FormValidator();

const rules = computed(() => {
  return validator
    .defineField('Title')
    .required()
    .getMessageRules();
})
</script>

<template>
  <div>
    <v-app>
      <v-container>
        <v-form ref="form">
          <v-text-field
            variant="outlined"
            label="Title"
            :rules="rules"
          />
        </v-form>
        <div class="d-flex justify-end">
          <v-btn variant="outlined" @click="form.validate()">
            Submit
          </v-btn>
        </div>
      </v-container>
    </v-app>
  </div>
</template>
```

啟動服務。

```bash
npm run dev
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

- [formulate](https://github.com/memochou1993/formulate)

## 參考文件

- [Create a Component Library Fast](https://dev.to/receter/how-to-create-a-react-component-library-using-vites-library-mode-4lma)
