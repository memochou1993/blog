---
title: 使用 Vue 3 和 Express 實作內容管理系統（八）：實現後端持久化
date: 2024-08-05 23:43:45
tags: ["Programming", "JavaScript", "Vue", "Bootstrap", "Node", "Express", "Firebase", "Firestore", "CMS"]
categories: ["Programming", "JavaScript", "Vue"]
---

## 前言

本文是前端工作坊的教學文件，介紹如何使用 Vue 3 和 Express 實作內容管理系統，並搭配 Firebase 實現持久化和認證。

## 前置作業

### 建立 Firebase 專案

首先，在 [Firebase](https://console.firebase.google.com/u/0/) 建立一個專案。

- 名稱：simple-cms

### 建立應用程式

在專案中，註冊一個應用程式。

- 平台：網頁
- 名稱：simple-cms

### 建立 Firestore 資料庫

在 [Cloud Firestore](https://console.firebase.google.com/u/0/project/simple-cms-e9c56/firestore) 頁面，建立一個資料庫。

- 位置：Taiwan
- 安全性規則：以正式版模式啟動

### 建立集合

在資料庫中，建立一個集合。

- ID：customers

### 建立金鑰

最後，為了讓後端程式存取資料庫，需要創建一個憑證。點選「專案設定」、「服務帳戶」，然後點選「產生新的私密金鑰」，將憑證下載到專案目錄中。

```bash
cd simple-cms-api
mv ~/Downloads/simple-cms-e9c56-firebase-adminsdk.json serviceAccountKey.json
```

## 開啟專案

開啟後端專案。

```bash
cd simple-cms-api
code .
```

## 建立連線

> Ref: <https://firebase.google.com/docs/firestore/quickstart?hl=zh-tw#node.js>

安裝依賴套件。

```bash
npm install firebase-admin
```

新增 `collection.js` 檔，初始化 Firebase 實例，並且新增一筆文件。

```js
import { cert, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const { pathname: serviceAccountKeyPath } = new URL('./serviceAccountKey.json', import.meta.url);

initializeApp({
  credential: cert(serviceAccountKeyPath),
});

const db = getFirestore();

const run = async () => {
  try {
    const data = { name: 'Alice' };
    const docRef = await db.collection('customers').add(data);
    console.log('Document written with ID: ', docRef.id);
  } catch (e) {
    console.error('Error adding document: ', e);
  }
};

run();
```

執行腳本。

```bash
node collection.js
```

輸出如下：

```bash
Document written with ID:  aJsDiZhJYmoRX01dRpH8
```

修改 `.gitignore` 檔。

```bash
/node_modules
serviceAccountKey.json
```

提交修改。

```bash
git add .
git commit -m "Add firebase"
git push
```

### 重構

將 `firebase.js` 檔重新命名為 `collection.js` 檔。

```js
import { cert, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const { pathname: serviceAccountKeyPath } = new URL('./serviceAccountKey.json', import.meta.url);

initializeApp({
  credential: cert(serviceAccountKeyPath),
});

class Collection {
  constructor(collection) {
    const db = getFirestore();
    this.collection = db.collection(collection);
  }

  async getItem(path) {
    const snapshot = await this.collection.doc(path).get();
    return snapshot.data();
  }

  async getItems() {
    const snapshot = await this.collection.get();
    const items = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));
    return items;
  }

  async addItem(value) {
    const docRef = await this.collection.add(value);
    return docRef.id;
  }

  async updateItem(key, value) {
    return await this.collection.doc(key).set(value);
  }

  async removeItem(key) {
    return await this.collection.doc(key).delete();
  }

  async getCount() {
    return (await this.collection.count().get()).data().count;
  }
}

export default Collection;
```

提交修改。

```bash
git add .
git commit -m "Implement firebase collection"
git push
```

## 實現持久化

修改 `index.js` 檔。

```js
import express from 'express';
import Collection from './collection.js';
const app = express();
const port = 3000;

// 啟用 JSON 解析
app.use(express.json());

// 實例化集合
const collection = new Collection('customers');

// 測試端點
app.get('/api', (req, res) => {
  res.json({ message: 'Hello, World!' });
});

// 取得所有客戶端點
app.get('/api/customers', async (req, res) => {
  const customers = await collection.getItems();
  res.json(customers);
});

// 取得單個客戶端點
app.get('/api/customers/:id', async (req, res) => {
  const id = req.params.id;
  const customer = await collection.getItem(id);
  if (!customer) {
    return res.status(404).json({
      message: 'Customer not found',
    });
  }

  res.json(customer);
});

// 建立客戶端點
app.post('/api/customers', async (req, res) => {
  const customer = {
    name: req.body.name,
  };

  const id = await collection.addItem(customer);
  customer.id = id;

  res.status(201).json(customer);
});

// 更新客戶端點
app.put('/api/customers/:id', async (req, res) => {
  const id = req.params.id;
  const customer = await collection.getItem(id);
  if (!customer) {
    return res.status(404).json({
      message: 'Customer not found',
    });
  }

  customer.name = req.body.name;
  await collection.updateItem(id, customer);

  res.json(customer);
});

// 刪除客戶端點
app.delete('/api/customers/:id', async (req, res) => {
  const id = req.params.id;
  const customer = await collection.getItem(id);
  if (!customer) {
    return res.status(404).json({
      message: 'Customer not found',
    });
  }

  await collection.removeItem(id);

  res.status(204).send();
});

// 啟動伺服器
app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
```

提交修改。

```bash
git add .
git commit -m "Implement persistence"
git push
```

## 設定 CORS

> Ref: <https://developer.mozilla.org/zh-TW/docs/Web/HTTP/CORS>

### 認識 CORS

跨來源資源共享（CORS）是一種基於 HTTP 標頭的機制，允許伺服器指示瀏覽器允許從除其自身以外的任何來源（域名、協定或通訊埠）加載資源。CORS 還依賴於瀏覽器向承載跨來源資源的伺服器發出「預檢」請求，以檢查伺服器是否允許實際請求。在預檢請求中，瀏覽器會發送標頭，指示將在實際請求中使用的 HTTP 方法和標頭。

### 啟用 CORS

安裝依賴套件。

```bash
npm install cors
```

修改 `index.js` 檔。

```js
import cors from 'cors';

// ...

// 添加 CORS 中介層
app.use(cors());
```

提交修改。

```bash
git add .
git commit -m "Add cors"
git push
```

## 程式碼

- [simple-cms-ui](https://github.com/memochou1993/simple-cms-ui)
- [simple-cms-api](https://github.com/memochou1993/simple-cms-api)
