---
title: 在 Nuxt 3.11 使用 ESLint 程式碼檢查工具和 ESLint Stylistic 格式化工具
date: 2024-05-13 06:25:45
tags: ["Programming", "JavaScript", "ESLint", "Vue", "Nuxt"]
categories: ["Programming", "JavaScript", "ESLint"]
---

## 安裝依賴

安裝依賴。

```bash
npm i eslint @stylistic/eslint-plugin eslint-plugin-vue typescript-eslint -D
```

新增 `eslint.config.js` 檔。

```js
import stylistic from '@stylistic/eslint-plugin';
import pluginVue from 'eslint-plugin-vue';
import tseslint from 'typescript-eslint';

export default [
  ...tseslint.configs.recommended,
  ...pluginVue.configs['flat/recommended'],
  stylistic.configs.customize({
    semi: true,
    jsx: true,
    braceStyle: '1tbs',
  }),
  {
    ignores: [
      '.nuxt/**',
    ],
  },
  {
    rules: {
      'no-console': 1,
    },
  },
];
```

新增 `.vscode/settings.json` 檔。

```json
{
  "editor.formatOnSave": true,
  "eslint.experimental.useFlatConfig": true
}
```

## 參考資料

- [ESLint Stylistic](https://eslint.style/)
