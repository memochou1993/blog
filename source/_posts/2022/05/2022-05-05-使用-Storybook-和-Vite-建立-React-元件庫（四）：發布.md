---
title: 使用 Storybook 和 Vite 建立 React 元件庫（四）：發布
permalink: 使用-Storybook-和-Vite-建立-React-元件庫（四）：發布
date: 2022-05-05 01:54:36
tags: ["程式設計", "JavaScript", "React", "Vite", "TypeScript"]
categories: ["程式設計", "JavaScript", "React"]
---

## 發布

修改 `package.json` 檔，注意套件名稱必須是獨一無二的。

```JSON
{
  "name": "@memochou1993/storybook-react",
  "repository": "https://github.com/memochou1993/storybook-react.git"
}
```

提交修改。

```BASH
git add .
git commit -m "Initial commit"
```

新增版本。

```BASH
npm version 0.1.0 -m "First release"
```

登入 NPM。

```BASH
npm login
```

發布套件。

```JSON
npm publish --access=public
```
