---
title: 將 Node 專案部署至 Vercel 平台
date: 2022-12-07 00:49:17
tags: ["Programming", "JavaScript", "Node", "Vercel"]
categories: ["Programming", "JavaScript", "Deployment"]
---

## 建立專案

建立專案。

```bash
mkdir vercel-node-example
cd vercel-node-example
```

初始化專案。

```bash
npm init -y
```

安裝依賴套件。

```bash
npm install express
```

新增 `.gitignore` 檔。

```env
/node_modules
```

新增 `api/index.js` 檔。

```js
const express = require('express');

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/api', (req, res) => {
  res.sendStatus(200);
});

module.exports = app;
```

## 部署

新增 `vercel.json` 檔。

```json
{
  "rewrites": [{ "source": "/api/(.*)", "destination": "/api" }]
}
```

將程式碼推送到 GitHub 儲存庫。

在 [Vercel](https://vercel.com/) 平台註冊帳號，並且連結儲存庫。

## 程式碼

- [vercel-node-example](https://github.com/memochou1993/vercel-node-example)

## 參考資料

- [Using Express.js with Vercel](https://vercel.com/guides/using-express-with-vercel)
