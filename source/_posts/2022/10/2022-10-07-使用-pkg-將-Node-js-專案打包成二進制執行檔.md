---
title: 使用 pkg 將 Node-js 專案打包成二進制執行檔
date: 2022-10-07 21:21:25
tags: ["Programming", "JavaScript", "Node.js", "CLI"]
categories: ["Programming", "JavaScript", "Node.js"]
---

## 做法

安裝依賴套件。

```bash
npm install pkg -D
```

修改 `package.json` 檔。

```json
{
  // ...
  "scripts": {
    "build": "pkg index.js -o my-app",
  },
  // ...
}
```

執行編譯。

```bash
npm run build
```

執行二進制執行檔。

```bash
./my-app
```

## 參考資料

- [vercel/pkg](https://github.com/vercel/pkg)
