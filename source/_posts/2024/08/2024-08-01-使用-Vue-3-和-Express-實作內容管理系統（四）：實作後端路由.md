---
title: 使用 Vue 3 和 Express 實作內容管理系統（四）：實作後端路由
date: 2024-08-01 23:43:44
tags: ["Programming", "JavaScript", "Vue", "Bootstrap", "Node", "Express", "Firebase", "Firestore", "CMS"]
categories: ["Programming", "JavaScript", "Vue"]
---

## 前言

本文是前端工作坊的教學文件，介紹如何使用 Vue 3 和 Express 實作內容管理系統，並搭配 Firebase 實現持久化和認證。

## 開啟專案

開啟後端專案。

```bash
cd simple-cms-api
code .
```

## 添加熱重載功能

安裝 `nodemon` 套件，每當程式碼有更新，就能透過 `nodemon` 自動重啟應用程式，實現熱重載功能。

```bash
npm install nodemon -D
```

修改 `package.json` 檔。

```json
{
  // ...
  "scripts": {
    // ...
    "dev": "nodemon index.js"
  }
  // ...
}
```

啟動伺服器。

```bash
npm run dev
```

提交修改。

```bash
git add .
git commit -m "Add nodemon"
git push
```

## 實作路由

修改 `index.js` 檔，建立一個測試端點。

```js
const express = require('express');
const app = express();
const port = 3000;

// 測試端點
app.get('/api', (req, res) => {
  res.json({ message: 'Hello, World!' });
});

// 啟動伺服器
app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
```

使用瀏覽器查看：<http://localhost:3000/api>

### 定義 RESTful API

> Ref: <https://aws.amazon.com/tw/what-is/restful-api/>

修改 `index.js` 檔，定義 RESTful API 端點，以客戶管理為例。

```js
const express = require('express');
const app = express();
const port = 3000;

// 測試端點
app.get('/api', (req, res) => {
  res.json({ message: 'Hello, World!' });
});

// 取得所有客戶
app.get('/api/customers', (req, res) => {
  // TODO
});

// 取得單個客戶
app.get('/api/customers/:id', (req, res) => {
  // TODO
});

// 建立客戶
app.post('/api/customers', (req, res) => {
  // TODO
});

// 更新客戶
app.put('/api/customers/:id', (req, res) => {
  // TODO
});

// 刪除客戶
app.delete('/api/customers/:id', (req, res) => {
  // TODO
});

// 啟動伺服器
app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
```

提交修改。

```bash
git add .
git commit -m "Add todo api endpoints"
git push
```

### 實作 RESTful API

修改 `index.js` 檔，實作 RESTful API 端點，使用假資料模擬。

```js
const express = require('express');
const app = express();
const port = 3000;

// 啟用 JSON 解析
app.use(express.json());

// 假資料
const customers = [
  { id: 1, name: 'Customer 1' },
  { id: 2, name: 'Customer 2' },
];

// 測試端點
app.get('/api', (req, res) => {
  res.json({ message: 'Hello, World!' });
});

// 取得所有客戶端點
app.get('/api/customers', (req, res) => {
  res.json(customers);
});

// 取得單個客戶端點
app.get('/api/customers/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const customer = customers.find(customer => customer.id === id);
  if (!customer) {
    return res.status(404).json({
      message: 'Customer not found',
    });
  }

  res.json(customer);
});

// 建立客戶端點
app.post('/api/customers', (req, res) => {
  const customer = {
    id: customers.length + 1,
    name: req.body.name,
  };

  customers.push(customer);

  res.status(201).json(customer);
});

// 更新客戶端點
app.put('/api/customers/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const customer = customers.find(customer => customer.id === id);
  if (!customer) {
    return res.status(404).json({
      message: 'Customer not found',
    });
  }

  customer.name = req.body.name;

  res.json(customer);
});

// 刪除客戶端點
app.delete('/api/customers/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const index = customers.findIndex(customer => customer.id === id);
  if (index === -1) {
    return res.status(404).json({
      message: 'Customer not found',
    });
  }

  customers.splice(index, 1);

  res.status(204).send();
});

// 啟動伺服器
app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
```

啟動伺服器。

```bash
npm run dev
```

提交修改。

```bash
git add .
git commit -m "Implement api endpoints"
git push
```

使用 Postman 測試 API。

## 轉換為 ES 模組

> Ref: <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules>

### 認識 ES 模組

ES 模組（ECMAScript Modules，ESM）是 JavaScript 的官方標準模組系統，與 CommonJS 不同，ES 模組提供更清晰、靈活的語法來管理模組。隨著 Node 和瀏覽器對 ES 模組支援度的提升，轉換為 ES 模組有助於保持程式碼的現代性和兼容性。除此之外，ES 模組使用 `import` 和 `export` 語法，比 CommonJS 的 `require` 和 `module.exports` 更加簡潔明了。

### 重構

修改 `package.json` 檔。

```json
{
  "type": "module",
}
```

將 `eslint.config.mjs` 檔重新命名為 `eslint.config.js` 檔。

```bash
mv eslint.config.mjs eslint.config.js
```

修改 `index.js` 檔，使用 `import` 語法引入依賴。

```js
import express from 'express';
```

提交修改。

```bash
git add .
git commit -m "Use es modules instead of commonjs"
git push
```

## 程式碼

- [simple-cms-ui](https://github.com/memochou1993/simple-cms-ui)
- [simple-cms-api](https://github.com/memochou1993/simple-cms-api)
