---
title: 使用 Truffle 部署智能合約到 BSC 區塊鏈並在 BscScan 上提交認證
date: 2022-06-21 01:55:31
tags: ["Blockchain", "Ethereum", "Solidity", "Truffle", "Smart Contract", "BSC"]
categories: ["Blockchain", "Ethereum"]
---

## 做法

新增 `.env` 檔，填入 BscScan 的 API KEY 以及錢包私鑰。

```env
BSCSCAN_API_KEY=
PRIVATE_KEY=
```

修改 `.gitignore` 檔。

```bash
.env
```

安裝依賴套件。

```bash
npm i dotenv @truffle/hdwallet-provider truffle-plugin-verify --save
```

修改 `truffle-config.js` 檔。

```js
const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();

const { BSCSCAN_API_KEY, PRIVATE_KEY } = process.env;

module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 7545,
      network_id: '*',
    },
    bsc: {
      provider: () => new HDWalletProvider(PRIVATE_KEY, 'https://bscrpc.com'),
      network_id: 56,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
  },
  compilers: {
    solc: {
      version: '0.8.14',
      settings: {
        optimizer: {
          enabled: false,
          runs: 200,
        },
      },
    },
  },
  plugins: [
    'truffle-plugin-verify',
  ],
  api_keys: {
    bscscan: BSCSCAN_API_KEY,
  },
};
```

執行部署。

```bash
truffle migrate --network bsc
```

提交認證。

```bash
truffle run verify MyContract --network bsc
```
