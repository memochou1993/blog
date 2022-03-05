---
title: 使用 JavaScript 建立簡單的 Web3 腳本
permalink: 使用-JavaScript-建立簡單的-Web3-腳本
date: 2022-02-23 00:37:10
tags: ["區塊鏈", "Ethereum", "Web3", "JavaScript", "Node"]
categories: ["區塊鏈"]
---

## 前言

本文參考 Alchemy 的[範例](https://docs.alchemy.com/alchemy/)進行實作，Alchemy 是一個區塊鏈開發者平台，能夠讓開發者訪問以太坊區塊鏈上的 API 端點，並且可以讀寫交易。

## 前置作業

### 註冊

首先到 [Alchemy](https://dashboard.alchemyapi.io/signup/) 註冊，並選擇 Ethereum 生態系。

### 創建應用程式

完成表單以創建應用程式，例如：

- 團隊名稱：Memo's Team
- 應用程式名稱：Memo's App
- 網路：選擇 Rinkeby 網路（為 OpenSea 所使用的測試網路）

點選「VIEW KEY」按鈕，並將 API Key 複製起來。

### 發送請求

可以使用 JSON-RPC 和 curl 透過 Alchemy 與以太坊區塊鏈互動，以下範例用於查詢當前燃氣價格：

```BASH
curl https://eth-mainnet.alchemyapi.io/v2/your-api-key \
-X POST \
-H "Content-Type: application/json" \
-d '{"jsonrpc":"2.0","method":"eth_gasPrice","params":[],"id":73}'
```

- 將 API 端點中的 `your-api-key` 改為應用程式的 API Key。
- `id` 是請求 ID，會在響應時返回，用來追蹤響應屬於哪一個請求。

結果如下：

```BASH
{"jsonrpc":"2.0","id":73,"result":"0x1840d93ad1"}
```

## 實作

建立專案。

```BASH
mkdir web3-example
cd web3-example
```

安裝 `@alch/alchemy-web3` 套件。

```BASH
npm install @alch/alchemy-web3
```

安裝 `dot-env` 套件。

```BASH
npm install dotenv --save
```

新增 `.env` 檔。

```ENV
API_URL=https://eth-mainnet.alchemyapi.io/v2/your-private-key
```

新增 `index.js` 檔。

```JS
require('dotenv').config();

async function main() {
  const { API_URL } = process.env;
  const { createAlchemyWeb3 } = require('@alch/alchemy-web3');
  const web3 = createAlchemyWeb3(API_URL);
  const blockNumber = await web3.eth.getBlockNumber();
  console.log('The latest block number is ' + blockNumber);
};

main();
```

執行腳本。

```JS
node index.js
```

結果如下：

```BASH
The latest block number is 14257180
```

## 程式碼

- [web3-example](https://github.com/memochou1993/web3-example)

## 參考資料

- [Alchemy - Simple Web3 Script](https://docs.alchemy.com/alchemy/tutorials/simple-web3-script)
