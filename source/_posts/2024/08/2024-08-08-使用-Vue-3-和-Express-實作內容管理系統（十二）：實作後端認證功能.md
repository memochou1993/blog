---
title: 使用 Vue 3 和 Express 實作內容管理系統（十二）：實作後端認證功能
date: 2024-08-08 20:36:33
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

## 實作認證模組

### 重構

新增 `firebase` 資料夾。

```bash
mkdir firebase
```

新增 `firebase/app.js` 檔，初始化 Firebase 實例。

```js
import { cert, initializeApp } from 'firebase-admin/app';
import path from 'path';

const app = initializeApp({
  credential: cert(path.join(import.meta.dirname, '../serviceAccountKey.json')),
});

export default app;
```

將 `collection.js` 檔移動到 `firebase` 資料夾，並修改如下：

```js
import { getFirestore } from 'firebase-admin/firestore';
import app from './app.js';

class Collection {
  constructor(collection) {
    const db = getFirestore(app);
    this.collection = db.collection(collection);
  }

  // ...
}

export default Collection;
```

新增 `firebase/index.js` 檔，匯出模組。

```js
export { default as Collection } from './collection.js';
```

修改 `index.js` 檔。

```js
import { Collection } from './firebase/index.js';
```

提交修改。

```bash
git add .
git commit -m "Refactor collection module"
git push
```

### 建立認證模組

新增 `firebase/auth.js` 檔。

```js
import { getAuth } from 'firebase-admin/auth';
import app from './app.js';

const auth = getAuth(app);

export const verifyIdToken = (token) => auth.verifyIdToken(token);
```

修改 `firebase/index.js` 檔，匯出模組。

```js
export * as auth from './auth.js';
// ...
```

提交修改。

```bash
git add .
git commit -m "Add auth module"
git push
```

## 實作中介層

新增 `middleware/auth.js` 檔。

```js
import { auth } from '../firebase/index.js';

const authMiddleware = async (req, res, next) => {
  try {
    const token = String(req.headers.authorization).replace('Bearer ', '');
    await auth.verifyIdToken(token);
    next();
  } catch (err) {
    res.status(401).json(err);
  }
};

export default authMiddleware;
```

修改 `middleware/index.js` 檔，匯出模組。

```js
import authMiddleware from './auth.js';
import loggingMiddleware from './logging.js';

export {
  authMiddleware,
  loggingMiddleware,
};
```

修改 `index.js` 檔。

```js
// ...
import { authMiddleware, loggingMiddleware } from './middleware/index.js';

// ...

app.get('/api/customers', [
  authMiddleware,
], async (req, res) => {
  // ...
});

app.get('/api/customers/:id', [
  authMiddleware,
], async (req, res) => {
  // ...
});

app.post('/api/customers', [
  authMiddleware,
  // ...
], async (req, res) => {
  // ...
});

app.put('/api/customers/:id', [
  authMiddleware,
  // ...
], async (req, res) => {
  // ...
});

app.delete('/api/customers/:id', [
  authMiddleware,
], async (req, res) => {
  // ...
});
```

提交修改。

```bash
git add .
git commit -m "Add auth middleware"
git push
```

## 程式碼

- [simple-cms-ui](https://github.com/memochou1993/simple-cms-ui)
- [simple-cms-api](https://github.com/memochou1993/simple-cms-api)
