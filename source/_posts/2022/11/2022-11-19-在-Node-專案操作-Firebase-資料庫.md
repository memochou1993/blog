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
serviceAccountKey.json
```

## 操作資料庫

新增 `index.mjs` 檔。

```js
import { cert, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import serviceAccount from './serviceAccountKey.json' assert { type: 'json' };

const app = initializeApp({
  credential: cert(serviceAccount),
});

class Storage {
  constructor(collection) {
    const db = getFirestore(app);
    this.collection = db.collection(collection);
  }

  // 取得資料筆數
  async getCount() {
    return (await this.collection.count().get()).data().count;
  }

  // 設置資料
  async setItem(key, value) {
    await this.collection.doc(key).set(value);
  }

  // 取得特定資料
  async getItem(key) {
    return (await this.collection.doc(key).get()).data();
  }

  // 取得所有資料
  async fetchItems() {
    const items = {};
    const snapshot = await this.collection.get();
    snapshot.forEach((item) => {
      items[item.id] = item.data();
    });
    return items;
  }

  // 刪除資料
  async removeItem(key) {
    await this.collection.doc(key).delete();
  }
}

const storage = new Storage('links');

(async () => {
  console.log(await storage.getCount());
  await storage.setItem('0', { foo: 'bar' });
  console.log(await storage.fetchItems());
  await storage.removeItem('0');
})();
```

## 程式碼

- [firebase-firestore-node-example](https://github.com/memochou1993/firebase-firestore-node-example)

## 參考資料

- [Get started with Cloud Firestore](https://firebase.google.com/docs/firestore/quickstart)
- [Add the Firebase Admin SDK to your server](https://firebase.google.com/docs/admin/setup)
