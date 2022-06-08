---
title: 使用 Solidity 和 Hardhat 在 Ethereum 區塊鏈開發智能合約（三）：在 Etherscan 上提交認證
permalink: 使用-Solidity-和-Hardhat-在-Ethereum-區塊鏈開發智能合約（三）：在-Etherscan-上提交認證
date: 2022-02-27 00:36:18
tags: ["區塊鏈", "Ethereum", "Web3", "JavaScript", "Node", "Solidity", "Hardhat", "Smart Contract", "DApp", "Alchemy"]
categories: ["區塊鏈", "Ethereum"]
---

## 前言

本文參考 Alchemy 的[範例](https://docs.alchemy.com/alchemy/)進行實作，Alchemy 是一個區塊鏈開發者平台，能夠讓開發者訪問以太坊區塊鏈上的 API 端點，並且可以讀寫交易。

本文採用的區塊鏈測試網路與範例文章不同，使用的是 `rinkeby` 測試網路。

## 前置作業

為了讓所有人都能夠查看智能合約的原始碼並且與智能合約互動，因此需要在 Etherscan 上驗證此智能合約屬於自己，並且把智能合約的 ABI 和原始碼公開。

首先，註冊 [Etherscan](https://etherscan.io/) 服務，並且新增一個 API Key。

## 驗證

修改 `.env` 檔。

```ENV
API_URL=https://eth-rinkeby.alchemyapi.io/v2/your-api-key
API_KEY=your-api-key
PRIVATE_KEY=your-private-key
CONTRACT_ADDRESS=your-contract-address
ETHERSCAN_API_KEY=your-etherscan-key
```

安裝 `@nomiclabs/hardhat-etherscan` 套件。

```BASH
npm install --save-dev @nomiclabs/hardhat-etherscan
```

更新 `hardhat.config.js` 檔。

```JS
/**
 * @type import('hardhat/config').HardhatUserConfig
 */

require('dotenv').config();
require('@nomiclabs/hardhat-ethers');
require('@nomiclabs/hardhat-etherscan');

const { API_URL, PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;

module.exports = {
  solidity: '0.7.3',
  defaultNetwork: 'rinkeby',
  networks: {
    hardhat: {},
    rinkeby: {
      url: API_URL,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};
```

在 Etherscan 上驗證此智能合約，確保網路是 `rinkeby` 測試網路，以及 `CONTRACT_ADDRESS` 是此智能合約的地址，且初始訊息與部署腳本的初始訊息一致。

```BASH
npx hardhat verify --network rinkeby CONTRACT_ADDRESS 'Hello World!'
```

顯示結果如下：

```BASH
Nothing to compile
Successfully submitted source code for contract
contracts/HelloWorld.sol:HelloWorld at 0x6839691078Ef669589F65Fca9968f6430D509812
for verification on the block explorer. Waiting for verification result...

Successfully verified contract HelloWorld on Etherscan.
https://rinkeby.etherscan.io/address/0x6839691078Ef669589F65Fca9968f6430D509812#code
```

再次查看[合約](https://rinkeby.etherscan.io/address/0x6839691078Ef669589F65Fca9968f6430D509812#code)，可以看到合約的 ABI 和原始碼皆已被公開，而且顯示已驗證的符號。

## 程式碼

- [smart-contract-example](https://github.com/memochou1993/smart-contract-example)
- [smart-contract-client-example](https://github.com/memochou1993/smart-contract-client-example)

## 參考資料

- [Alchemy - Interacting with a Smart Contract](https://docs.alchemy.com/alchemy/tutorials/hello-world-smart-contract/interacting-with-a-smart-contract)
