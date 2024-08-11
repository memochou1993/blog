---
title: 使用 Vue 3 和 Express 實作內容管理系統（六）：實現後端表單驗證
date: 2024-08-03 00:08:25
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

## 實作欄位驗證

修改 `index.js` 檔，為建立客戶端點新增欄位必填檢查。

```js
app.post('/api/customers', (req, res) => {
  if (!req.body.name) {
    return res.status(422).json({
      message: 'Name is required',
    });
  }

  // ...
});
```

修改 `index.js` 檔，為更新客戶端點新增欄位必填檢查。

```js
app.put('/api/customers/:id', (req, res) => {
  if (!req.body.name) {
    return res.status(422).json({
      message: 'Name is required',
    });
  }

  // ...
});
```

## 使用驗證套件

> Ref: <https://github.com/express-validator/express-validator>

安裝 `express-validator` 套件，可以更方便地驗證欄位類型。

```bash
npm install express-validator
```

修改 `index.js` 檔，為建立客戶端點新增欄位必填和類型檢查。

```js
import { body, validationResult } from 'express-validator';

// ...

app.post('/api/customers', [
  body('name').notEmpty().withMessage('Name is required').isString().withMessage('Name must be a string'),
], (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json(errors);
  }

  // ...
});
```

修改 `index.js` 檔，為更新客戶端點新增欄位必填和類型檢查。

```js
import { body, validationResult } from 'express-validator';

// ...

app.put('/api/customers/:id', [
  body('name').notEmpty().withMessage('Name is required').isString().withMessage('Name must be a string'),
], (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(422).json(errors);
  }

  // ...
});
```

提交修改。

```bash
git add .
git commit -m "Add express-validator"
git push
```

## 程式碼

- [simple-cms-ui](https://github.com/memochou1993/simple-cms-ui)
- [simple-cms-api](https://github.com/memochou1993/simple-cms-api)
