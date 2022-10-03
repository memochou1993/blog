---
title: 使用 Solidity 和 Hardhat 在 Ethereum 區塊鏈開發智能合約（一）：開發與部署智能合約
date: 2022-02-25 20:34:03
tags: ["區塊鏈", "Ethereum", "Solidity", "JavaScript", "Node", "Hardhat", "Smart Contract", "DApp", "Alchemy"]
categories: ["區塊鏈", "Ethereum"]
---

## 前言

本文參考 Alchemy 的[範例](https://docs.alchemy.com/alchemy/)進行實作，Alchemy 是一個區塊鏈開發者平台，能夠讓開發者訪問以太坊區塊鏈上的 API 端點，並且可以讀寫交易。

本文採用的區塊鏈測試網路與範例文章不同，使用的是 `rinkeby` 測試網路。

## 前置作業

1. 首先，在 [Alchemy](https://dashboard.alchemyapi.io/) 註冊，並新建應用程式，選擇 Rinkeby 測試網路。
1. 下載 [MetaMask](https://metamask.io/download/) 到擴充套件，創建錢包後，將「Show test networks」選項開啟。
2. 到 [Alchemy Rinkeby faucet](https://www.rinkebyfaucet.com/) 充值 Rinkeby 測試網路的 ETH 幣到自己的錢包地址。

## 開發

建立專案。

```BASH
mkdir smart-contract-example
cd smart-contract-example
```

初始化專案。

```BASH
npm init
```

安裝 `hardhat` 套件。Hardhat 是一個自動化構建智能合約的環境和工具。

```BASH
npm install --save-dev hardhat
```

使用 `npx` 執行 hardhat 指令，並選擇「Create an empty hardhat.config.js」選項。

```BASH
npx hardhat
```

新增 `contracts` 資料夾，用來放置智能合約。

```BASH
mkdir contracts
```

新增 `scripts` 資料夾，用來放置部署腳本，以及與智能合約互動的腳本。

```BASH
mkdir scripts
```

在 `contracts` 資料夾新增 `HelloWorld.sol` 檔。需要使用 Solidity 語言撰寫。

```SOL
// SPDX-License-Identifier: MIT
pragma solidity >=0.7.3;

// 定義一個合約，合約是各種方法和資料的集合，一旦合約被部署，就會被放置到區塊鏈上的特定地址
contract HelloWorld {
    // 定義一個事件，在某些情況下被觸發，可以用來讓客戶端監聽並採取一些行動
    event UpdatedMessages(string oldStr, string newStr);

    // 定義一個型別為字串的變數，此變數會被永久儲存在合約裡，公開的變數可以被外部的合約或客戶端存取
    string public message;

    // 定義一個建構子，在合約被創建時觸發，用來初始化合約的資料
    constructor(string memory initMsg) {
        // 修改 message 變數
        message = initMsg;
    }

    // 定義一個公開方法，接受一個字串來修改 message 變數
    function update(string memory newMsg) public {
        string memory oldMsg = message;
        message = newMsg;
        emit UpdatedMessages(oldMsg, newMsg);
    }
}
```

安裝 `dot-env` 套件。

```BASH
npm install dotenv --save
```

新增 `.env` 檔。

```ENV
API_URL=https://eth-rinkeby.alchemyapi.io/v2/your-api-key
PRIVATE_KEY=your-private-key
```

安裝 `@nomiclabs/hardhat-ethers` 和 `ethers` 套件。

```BASH
npm install --save-dev @nomiclabs/hardhat-ethers "ethers@^5.0.0"
```

將 `hardhat.config.js` 檔修改如下：

```JS
/**
 * @type import('hardhat/config').HardhatUserConfig
 */

require('dotenv').config();
require("@nomiclabs/hardhat-ethers");

const { API_URL, PRIVATE_KEY } = process.env;

module.exports = {
  solidity: "0.7.3",
  defaultNetwork: "rinkeby",
  networks: {
    hardhat: {},
    rinkeby: {
      url: API_URL,
      accounts: [PRIVATE_KEY],
    },
  },
};
```

使用以下指令編譯智能合約。

```BASH
npx hardhat compile
```

在 `scripts` 資料夾新增 `deploy.js` 檔。

```JS
async function main() {
  // 實例化一個 HelloWorld 合約工廠
  const HelloWorld = await ethers.getContractFactory('HelloWorld');

  // 使用合約工廠的 deploy 方法來進行部署
  const hello_world = await HelloWorld.deploy('Hello World!');
  
  // 印出合約地址
  console.log('Contract deployed to address:', hello_world.address);
};

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
```

## 部署

使用以下指令，將智能合約部署在 `rinkeby` 測試網路。

```BASH
npx hardhat run scripts/deploy.js --network rinkeby
```

顯示結果如下：

```BASH
Contract deployed to address: 0x6839691078Ef669589F65Fca9968f6430D509812
```

到 Rinkeby 測試網路的 [Etherscan](https://rinkeby.etherscan.io/) 查看[合約](https://rinkeby.etherscan.io/address/0x6839691078Ef669589F65Fca9968f6430D509812)。

## 程式碼

- [smart-contract-example](https://github.com/memochou1993/smart-contract-example)
- [smart-contract-client-example](https://github.com/memochou1993/smart-contract-client-example)

## 參考資料

- [Alchemy - Hello World Smart Contract](https://docs.alchemy.com/alchemy/tutorials/hello-world-smart-contract)
