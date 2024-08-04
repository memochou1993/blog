---
title: 使用 Vue 3 和 Express 實作內容管理系統（六）：實現持久化
date: 2024-08-03 23:43:45
tags: ["Programming", "JavaScript", "Vue", "Bootstrap", "Node", "Express", "Firebase", "Firestore", "CMS"]
categories: ["Programming", "JavaScript", "Vue"]
---

## 前言

本文是前端工作坊的教學文件，介紹如何使用 Vue 3 和 Express 實作內容管理系統，並搭配 Firebase 實現持久化和認證。

## 建立 Firebase 專案

首先，在 [Firebase](https://console.firebase.google.com/u/0/) 建立一個專案。

- 名稱：simple-cms

在專案中，註冊一個應用程式。

- 平台：網頁
- 名稱：simple-cms

## 建立 Firestore 資料庫

在 [Cloud Firestore](https://console.firebase.google.com/u/0/project/simple-cms-e9c56/firestore) 頁面，建立一個資料庫。

- 位置：Taiwan
- 安全性規則：以正式版模式啟動

為了讓後端程式存取資料庫，需要創建一個憑證。點選「專案設定」、「服務帳戶」，然後點選「產生新的私密金鑰」，將憑證下載到專案目錄中。

```bash
mv ~/Downloads/simple-cms-e9c56-firebase-adminsdk.json serviceAccountKey.json
```

最後，在資料庫中，建立一個集合。

- ID：customers

## 開啟專案

開啟後端專案。

```bash
cd simple-cms-api
code .
```

## 建立資料庫連線

> Ref: <https://firebase.google.com/docs/firestore/quickstart?hl=zh-tw#node.js>

修改 `.gitignore` 檔。

```bash
/node_modules
serviceAccountKey.json
```

安裝依賴套件。

```bash
npm install firebase-admin
```

新增 `firebase.js` 檔，初始化 Firebase 實例。

```js
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('./serviceAccountKey.json');

initializeApp({
  credential: cert(serviceAccount),
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
node firebase.js
```

輸出如下：

```bash
Document written with ID:  aJsDiZhJYmoRX01dRpH8
```

## 實現持久化

TODO

## 程式碼

- [simple-cms-ui](https://github.com/memochou1993/simple-cms-ui)
- [simple-cms-api](https://github.com/memochou1993/simple-cms-api)
