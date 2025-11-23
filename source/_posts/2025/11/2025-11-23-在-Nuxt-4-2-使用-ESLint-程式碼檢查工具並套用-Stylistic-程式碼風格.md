---
title: 在 Nuxt 4.2 使用 ESLint 程式碼檢查工具並套用 Stylistic 程式碼風格
date: 2025-11-23 16:03:08
tags: ["Programming", "JavaScript", "ESLint", "Vue", "Nuxt"]
categories: ["Programming", "JavaScript", "ESLint"]
---

## 做法

在 Nuxt 專案，添加 ESLint 模組。

```bash
npx nuxi module add eslint
```

修改 `nuxt.config.ts` 檔，註冊模組。

```js
// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  modules: [
    '@nuxt/eslint',
    // ...
  ],
  devtools: { enabled: true },
  compatibilityDate: '2025-07-15',
})
```

新增 `eslint.config.mjs` 檔，自訂 Stylistic 或其他程式碼風格。

```js
// @ts-check
import withNuxt from './.nuxt/eslint.config.mjs';

export default withNuxt({
  rules: {
    'brace-style': 'error',
    'curly': 'error',
    'dot-notation': 'error',
    'no-console': ['warn', { allow: ['warn', 'error', 'debug'] }],
    'no-lonely-if': 'error',
    'no-useless-rename': 'error',
    'object-shorthand': 'error',
    'prefer-const': ['error', { destructuring: 'any', ignoreReadBeforeAssign: false }],
    'require-await': 'error',
    'semi': 'error',
    'sort-imports': ['error', { ignoreDeclarationSort: true }],
  },
});
```

新增 `.vscode/settings.json` 檔，添加自動格式化的設定。

```json
{
  "editor.tabSize": 2,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit",
    "source.organizeImports": "explicit"
  }
}
```

修改 `package.json` 檔，加上 `lint` 命令腳本。

```json
{
  "scripts": {
    // ...
    "lint": "eslint .",
    "lint:fix": "eslint . --fix"
  }
}
```

執行檢查。

```bash
npm run lint
```

## 參考資料

- [Nuxt ESLint](https://eslint.nuxt.com/)
- [ESLint](https://eslint.org/)
