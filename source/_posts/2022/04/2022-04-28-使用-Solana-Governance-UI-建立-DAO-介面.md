---
title: 使用 Solana Governance UI 建立 DAO 介面
date: 2022-04-28 20:05:15
tags: ["Blockchain", "Solana", "Rust", "JavaScript", "Smart Contract", "NFT", "DAO"]
categories: ["Blockchain", "Solana"]
---

## 前言

本文為「Solana 開發者的入門指南」影片的學習筆記。

## 做法

使用 Proxyman 新增一條 Proxy 規則：

- Matching Rule: <https://api.testnet.solana.com>
- Map To Host: <https://rpc-mainnet-fork.epochs.studio>

下載 `solana-labs/governance-ui` 專案。

```bash
git clone git@github.com:solana-labs/governance-ui.git
cd governance-ui
```

安裝依賴。

```js
yarn
```

更新 `utils/connection.ts` 檔。

```js
// ...
import { Commitment, Connection } from '@solana/web3.js'
// ...

const ENDPOINTS: EndpointInfo[] = [
  {
    name: 'mainnet',
    url: process.env.MAINNET_RPC || 'https://rpc-mainnet-fork.epochs.studio/',
  },
  // ...
];

// ...

export function getConnectionContext(cluster: string): ConnectionContext {
  const ENDPOINT = ENDPOINTS.find((e) => e.name === cluster) || ENDPOINTS[0]
  const commitment: Commitment = 'processed'
  return {
    cluster: ENDPOINT!.name as EndpointTypes,
    current: new Connection('https://rpc-mainnet-fork.epochs.studio', {
      commitment,
      wsEndpoint: 'wss://rpc-mainnet-fork.epochs.studio/ws',
    }),
    endpoint: ENDPOINT!.url,
  }
}
```

啟動服務。

```bash
yarn dev
```

## 參考資料

- [A Complete Guide to Create a NFT DAO on Solana](https://book.solmeet.dev/notes/complete-guide-to-create-nft-dao)
