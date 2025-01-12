---
title: 在 Node.js 專案使用 Firebase SDK 操作 Firestore 資料庫
date: 2022-11-19 00:11:53
tags: ["Programming", "JavaScript", "Node.js", "Firebase", "Firestore"]
categories: ["Programming", "JavaScript", "Node.js"]
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
serviceAccountKey.json
```

## 實作

新增 `collection.js` 檔。

```js
import { cert, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import serviceAccount from './serviceAccountKey.json' assert { type: 'json' };

initializeApp({
  credential: cert(serviceAccount),
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

建立 `index.js` 檔。

```js
import Collection from './collection.js';

const collection = new Collection('customers');

(async () => {
  console.log('addItem', await collection.addItem({ name: 'Alice' }));
  console.log('updateItem', await collection.updateItem('HdSVo6LxuBlizdgY3jTd', { name: 'Bob' }));
  console.log('getItem', await collection.getItem('0vBJGiONCUaU9JZpShAA'));
  console.log('getItems', await collection.getItems());
  console.log('removeItem', await collection.removeItem('0vBJGiONCUaU9JZpShAA'));
  console.log('getCount:', await collection.getCount());
})();
```

## 程式碼

- [firebase-firestore-node-example](https://github.com/memochou1993/firebase-firestore-node-example)

## 參考資料

- [Get started with Cloud Firestore](https://firebase.google.com/docs/firestore/quickstart)
- [Add the Firebase Admin SDK to your server](https://firebase.google.com/docs/admin/setup)
