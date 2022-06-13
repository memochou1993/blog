---
title: 使用 Solidity 和 Hardhat 在 Ethereum 區塊鏈開發智能合約（二）：建立互動腳本
permalink: 使用-Solidity-和-Hardhat-在-Ethereum-區塊鏈開發智能合約（二）：建立互動腳本
date: 2022-02-26 00:36:18
tags: ["區塊鏈", "Ethereum", "Solidity", "JavaScript", "Node", "Hardhat", "Smart Contract", "DApp", "Alchemy"]
categories: ["區塊鏈", "Ethereum"]
---

## 前言

本文參考 Alchemy 的[範例](https://docs.alchemy.com/alchemy/)進行實作，Alchemy 是一個區塊鏈開發者平台，能夠讓開發者訪問以太坊區塊鏈上的 API 端點，並且可以讀寫交易。

本文採用的區塊鏈測試網路與範例文章不同，使用的是 `rinkeby` 測試網路。

## 互動

在 `scripts` 資料夾新增 `interact.js` 檔。

```JS
const { API_KEY, PRIVATE_KEY, CONTRACT_ADDRESS } = process.env;
```

修改 `.env` 檔。

```ENV
API_URL=https://eth-rinkeby.alchemyapi.io/v2/your-api-key
API_KEY=your-api-key
PRIVATE_KEY=your-private-key
CONTRACT_ADDRESS=your-contract-address
```

引入合約的 ABI（Application Binary Interface），ABI 是被生成用來與合約互動的介面，以下將 ABI 印出來觀察。

```JS
const contract = require("../artifacts/contracts/HelloWorld.sol/HelloWorld.json");

console.log(JSON.stringify(contract.abi));
```

執行 `interact.js` 檔。

```BASH
npx hardhat run scripts/interact.js
```

輸出結果如下：

```BASH
Compiling 1 file with 0.7.3
Solidity compilation finished successfully
[{"inputs":[{"internalType":"string","name":"initMsg","type":"string"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"oldStr","type":"string"},{"indexed":false,"internalType":"string","name":"newStr","type":"string"}],"name":"UpdatedMessages","type":"event"},{"inputs":[],"name":"message","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"newMsg","type":"string"}],"name":"update","outputs":[],"stateMutability":"nonpayable","type":"function"}]
```

修改 `interact.js` 檔，將智能合約實例化：

```JS
const { API_KEY, PRIVATE_KEY, CONTRACT_ADDRESS } = process.env;

const contract = require('../artifacts/contracts/HelloWorld.sol/HelloWorld.json');

// 提供者：是一個可以用來存取區塊鏈的節點
const alchemyProvider = new ethers.providers.AlchemyProvider(network='rinkeby', API_KEY);

// 簽名者：代表一個可以為交易簽名的以太坊用戶
const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);

// 合約：表示一個被部署在區塊鏈上的特定合約
const helloWorldContract = new ethers.Contract(CONTRACT_ADDRESS, contract.abi, signer);
```

繼續修改 `interact.js` 檔，呼叫 `message()` 方法以讀取智能合約中的原始訊息。

```JS
// ...

async function main() {
  const message = await helloWorldContract.message();
  console.log('The message is:', message);
};

main();
```

執行 `interact.js` 檔。

```BASH
npx hardhat run scripts/interact.js
```

輸出結果如下：

```BASH
The message is: Hello World!
```

修改 `interact.js` 檔，呼叫 `update()` 方法以更新智能合約中的原始訊息。

```JS
async function main() {
  const message = await helloWorldContract.message();
  console.log('The message is:', message);

  console.log('Updating the message...');
  const tx = await helloWorldContract.update('This is the new message.');
  await tx.wait(); // 等待礦工核對並執行

  const newMessage = await helloWorldContract.message();
  console.log('The new message is:', newMessage); 
};

main();
```

輸出結果如下：

```BASH
The message is: Hello World!
Updating the message...
The new message is: This is the new message.
```

## 程式碼

- [smart-contract-example](https://github.com/memochou1993/smart-contract-example)
- [smart-contract-client-example](https://github.com/memochou1993/smart-contract-client-example)

## 參考資料

- [Alchemy - Interacting with a Smart Contract](https://docs.alchemy.com/alchemy/tutorials/hello-world-smart-contract/interacting-with-a-smart-contract)
