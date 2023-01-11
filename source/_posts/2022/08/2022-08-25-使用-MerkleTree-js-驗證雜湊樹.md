---
title: 使用 MerkleTree.js 驗證雜湊樹
date: 2022-08-25 00:21:43
tags: ["程式設計", "JavaScript", "演算法", "Merkle Tree"]
categories: ["程式設計", "JavaScript", "演算法"]
---

## 前言

雜湊樹（Merkle Tree）是一種樹狀資料結構，每個葉節點都以資料塊的雜湊做為標籤，而除了葉節點以外的節點，則以其子節點標籤的雜湊做為標籤。

雜湊樹能夠高效地、安全地驗證大型資料結構的內容，是雜湊鏈的推廣形式。

## 做法

安裝依賴套件

```bash
npm install merkletreejs crypto-js
```

新增 `index.js` 檔。

```js
const { MerkleTree } = require('merkletreejs');
const SHA256 = require('crypto-js/sha256');

const leaves = ['a', 'b', 'c'].map(x => SHA256(x));

const tree = new MerkleTree(leaves, SHA256);

console.log(tree.toString());

const root = tree.getRoot().toString('hex');

const leaf = SHA256('a');

const proof = tree.getProof(leaf);

console.log(tree.verify(proof, leaf, root)); // true
```

執行驗證。

```bash
node index.js
```

輸出如下。

```bash
└─ 7075152d03a5cd92104887b476862778ec0c87be5c2fa1c0a90f87c49fad6eff
   ├─ e5a01fee14e0ed5c48714f22180f25ad8365b53f9779f79dc4a3d7e93963f94a
   │  ├─ ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb
   │  └─ 3e23e8160039594a33894f6564e1b1348bbd7a0088d42c4acb73eeaed59c009d
   └─ 2e7d2c03a9507ae265ecf5b5356885a53393a2029d241394997265a1a25aefc6
      └─ 2e7d2c03a9507ae265ecf5b5356885a53393a2029d241394997265a1a25aefc6

true
```

## 參考資料

- [miguelmota/merkletreejs](https://github.com/miguelmota/merkletreejs)
