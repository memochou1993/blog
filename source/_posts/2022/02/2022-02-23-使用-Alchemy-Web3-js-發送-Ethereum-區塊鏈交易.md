---
title: 使用 Alchemy Web3.js 發送 Ethereum 區塊鏈交易
date: 2022-02-23 22:24:50
tags: ["Blockchain", "Ethereum", "Node.js", "JavaScript", "Web3", "Alchemy", "MetaMask"]
categories: ["Blockchain", "Ethereum"]
---

## 前言

本文參考 Alchemy 的[範例](https://docs.alchemy.com/alchemy/)進行實作，Alchemy 是一個區塊鏈開發者平台，能夠讓開發者訪問以太坊區塊鏈上的 API 端點，並且可以讀寫交易。

## 前置作業

1. 首先，在 [Alchemy](https://dashboard.alchemyapi.io/) 註冊，並新建應用程式，選擇 Rinkeby 測試網路。
2. 下載 [MetaMask](https://metamask.io/download/) 到擴充套件，創建錢包後，將「Show test networks」選項開啟。
3. 到 [Alchemy Rinkeby faucet](https://www.rinkebyfaucet.com/) 充值 Rinkeby 測試網路的 ETH 幣到自己的錢包地址。

## 實作

建立專案。

```bash
mkdir web3-sendtx-example
cd web3-sendtx-example
```

安裝 `@alch/alchemy-web3` 套件。

```bash
npm install @alch/alchemy-web3
```

安裝 `dot-env` 套件。

```bash
npm install dotenv --save
```

新增 `.env` 檔。

```env
API_URL=https://eth-rinkeby.alchemyapi.io/v2/your-api-key
PRIVATE_KEY=your-private-key
```

新增 `index.js` 檔。

```js
require('dotenv').config();

async function main() {
    const { API_URL, PRIVATE_KEY } = process.env;
    const { createAlchemyWeb3 } = require("@alch/alchemy-web3");
    const web3 = createAlchemyWeb3(API_URL);
    const myAddress = '0x72E6c9390ea3B34bFfD534128Cb86afD66B0ae02' // 轉出地址：個人錢包
  
    const nonce = await web3.eth.getTransactionCount(myAddress, 'latest'); // 交易次數，從 0 開始，避免雙重支付

    const transaction = {
      to: '0x31B98D14007bDEe637298086988A0bBd31184523', // 轉入地址：Rinkeby faucet
      value: 100, // 100 wei
      gas: 30000,
      maxFeePerGas: 2500000000,
      nonce: nonce,
    };
  
    const signedTx = await web3.eth.accounts.signTransaction(transaction, PRIVATE_KEY);
    
    web3.eth.sendSignedTransaction(signedTx.rawTransaction, function(error, hash) {
    if (!error) {
      console.log("🎉 The hash of your transaction is: ", hash, "\n Check Alchemy's Mempool to view the status of your transaction!");
    } else {
      console.log("❗Something went wrong while submitting your transaction:", error)
    }
  });
};

main();
```

執行腳本。

```js
node index.js
```

結果如下：

```bash
node index.js
🎉 The hash of your transaction is:  0x95c59fcbbb6823ceb205ab88bd23a94a2dfdca47f78c10e760a73dc3e4c3e9a5 
 Check Alchemy's Mempool to view the status of your transaction!
```

到 [Etherscan](https://rinkeby.etherscan.io/address/0x72e6c9390ea3b34bffd534128cb86afd66b0ae02) 可以查詢交易紀錄。

## 程式碼

- [web3-sendtx-example](https://github.com/memochou1993/web3-sendtx-example)

## 參考資料

- [Alchemy - Sending Transactions Using Web3](https://docs.alchemy.com/alchemy/tutorials/sending-txs)
