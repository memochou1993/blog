---
title: 在 Nuxt 3.12 使用 ESLint 程式碼檢查工具和 ESLint Stylistic 格式化工具
date: 2024-08-20 01:21:16
tags: ["Programming", "JavaScript", "ESLint", "Vue", "Nuxt"]
categories: ["Programming", "JavaScript", "ESLint"]
---

## 做法

添加 ESLint 的 Nuxt 模組。

```bash
npx nuxi module add eslint
```

修改 `nuxt.config.ts` 檔，註冊模組。

```js
// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-04-03',
  devtools: { enabled: true },
  modules: [
    '@nuxt/eslint',
  ],
});
```

安裝 ESLint 套件，以及管理 Nuxt 規則的套件。

```bash
npm install eslint @nuxt/eslint-config -D
```

新增 `eslint.config.js` 檔，添加規則。

```js
import { createConfigForNuxt } from '@nuxt/eslint-config/flat';

export default createConfigForNuxt({
  features: {
    stylistic: {
      braceStyle: '1tbs',
      semi: true,
    },
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
  // ...
  "scripts": {
    // ...
    "lint": "eslint ."
  }
  // ...
}
```

執行檢查。

```bash
npm run lint
```

## 參考資料

- [Nuxt ESLint](https://eslint.nuxt.com/)
