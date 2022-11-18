---
title: 在 Node 專案使用 Firebase SDK 操作 Firestore 資料庫
date: 2022-11-19 00:11:53
tags: ["程式設計", "JavaScript", "Node", "Firebase", "Firestore"]
categories: ["程式設計", "JavaScript", "Node"]
---

## 前置作業

首先，在 [Firebase](https://console.firebase.google.com/) 創建一個應用程式，並且創建一個 Firestore 資料庫。如果是由後端程式存取資料庫，則可以選取「鎖定模式」，避免資源被濫用。

為了讓後端程式存取資料庫，需要創建一個憑證。點選「專案設定」、「服務帳戶」，然後點選「產生新的私密金鑰」，將憑證下載到專案目錄中。

## 建立專案

建立專案。

```bash
mkdir firebase-firestore-node-example
cd firebase-firestore-node-example
```

初始化專案。

```bash
npm init
```

安裝依賴套件。

```bash
npm install firebase firebase-admin
```

修改 `package.json` 檔。

```json
{
  "type": "module"
}
```

新增 `.gitignore` 檔。

```env
/node_modules
/.vscode
credentials.json
```

## 操作資料庫

新增 `index.mjs` 檔，初始化應用程式。

```js
import { cert, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const app = initializeApp({
  credential: cert('./credentials.json'),
});

const db = getFirestore(app);
```

### 寫入資料

```js
(async () => {
  const docRef = db.collection('users').doc('memochou1993');
  await docRef.set({
    name: 'Memo Chou',
    age: 18,
  });
})();
```

執行程式。

```bash
node index.mjs
```

### 讀取資料

```js
(async () => {
  const snapshot = await db.collection('users').get();
  snapshot.forEach((doc) => {
    console.log(doc.id, '=>', doc.data());
  });
})();
```

執行程式。

```bash
node index.mjs
```

### 刪除資料

```js
(async () => {
  const res = await db.collection('users').doc('memochou1993').delete();
  console.log(res);
})();
```

執行程式。

```bash
node index.mjs
```

## 程式碼

- [firebase-firestore-node-example](https://github.com/memochou1993/firebase-firestore-node-example)

## 參考資料

- [Get started with Cloud Firestore](https://firebase.google.com/docs/firestore/quickstart)
- [Add the Firebase Admin SDK to your server](https://firebase.google.com/docs/admin/setup)
