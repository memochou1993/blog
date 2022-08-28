---
title: 使用 Solidity 和 Hardhat 在 Ethereum 區塊鏈開發 NFT 智能合約
permalink: 使用-Solidity-和-Hardhat-在-Ethereum-區塊鏈開發-NFT-智能合約
date: 2022-08-28 22:00:37
tags: ["區塊鏈", "Ethereum", "Solidity", "JavaScript", "Node", "Hardhat", "Smart Contract", "DApp", "Alchemy", "NFT", "IPFS", "Pinata"]
categories: ["區塊鏈", "Ethereum"]
---

## 建立專案

建立專案。

```BASH
mkdir eth-nft-example
cd eth-nft-example
```

建立 `package.json` 檔。

```BASH
npm init -y
```

安裝 `hardhat` 依賴套件。

```BASH
npm install hardhat --save-dev
```

使用 Hardhat 初始化專案。

```BASH
npx hardhat
```

檢查專案配置是否正常。

```BASH
npx hardhat test
```

## 實作合約

安裝依賴。

```BASH
npm install @openzeppelin/contracts
```

刪除 `contracts/Lock.sol` 範例檔。

```BASH
rm contracts/Lock.sol
```

新增 `contracts/MyNFT.sol` 檔。

```SOL
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("MyNFT", "NFT") {}

    function mintNFT(address recipient, string memory tokenURI)
      public
      onlyOwner
      returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();

        _mint(recipient, newItemId);

        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}
```

## 部署合約

安裝依賴套件。

```BASH
npm install dotenv --save
```

建立 `.env` 檔。

```BASH
API_URL=https://eth-goerli.alchemyapi.io/v2/your-api-key
API_KEY=your-api-key
PRIVATE_KEY=your-metamask-private-key
```

更新 `hardhat.config.js` 檔。

```JS
/**
* @type import('hardhat/config').HardhatUserConfig
*/
require('dotenv').config();
require("@nomiclabs/hardhat-ethers");

const { API_URL, PRIVATE_KEY } = process.env;

module.exports = {
   solidity: "0.8.4",
   defaultNetwork: "goerli",
   networks: {
      hardhat: {},
      goerli: {
         url: API_URL,
         accounts: [`0x${PRIVATE_KEY}`],
      },
   },
};
```

修改 `scripts/deploy.js` 檔。

```JS
async function main() {
  // Grab the contract factory 
  const MyNFT = await ethers.getContractFactory("MyNFT");

  // Start deployment, returning a promise that resolves to a contract object
  const myNFT = await MyNFT.deploy(); // Instance of the contract 
  console.log("Contract deployed to address:", myNFT.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
```

執行部署。

```BASH
npx hardhat run scripts/deploy.js --network goerli
```

輸出訊息如下。

```BASH
Contract deployed to address: 0xAdEc9c114D4E094545E60E2e856Ab57552831c00
```

## 設定 NFT

到 [Pinata](https://app.pinata.cloud/) 註冊帳號，此服務能夠將圖片上傳到 IPFS 星際檔案系統。

註冊後，上傳一張圖片，將圖片的 CID 複製起來。

建立一個 `nft-metadata.json` 檔，做為 NFT 的描述檔，並修改 `image` 欄位，將其設置為圖片的 URI。

```JSON
{
  "attributes": [
    {
      "trait_type": "Breed",
      "value": "Maltipoo"
    },
    {
      "trait_type": "Eye color",
      "value": "Mocha"
    }
  ],
  "description": "The world's most adorable and sensitive pup.",
  "image": "https://gateway.pinata.cloud/ipfs/QmWCoZdz2tnv38dqWSD1Yd2sf41R1CHWpogkVpLaNoa3C9",
  "name": "My First NFT"
}
```

最後，上傳 `nft-metadata.json` 檔，並將 NFT 的描述檔的 CID 複製起來。

## 鑄造 NFT

建立 `src/mint.js` 檔，將 `tokenURI` 變數設定為 NFT 的描述檔的 URI。

```JS
require("dotenv").config();

const ethers = require("ethers");
const { abi } = require("../artifacts/contracts/MyNFT.sol/MyNFT.json");

const { API_KEY, PRIVATE_KEY } = process.env;

const provider = new ethers.providers.AlchemyProvider("goerli", API_KEY);

const signer = new ethers.Wallet(PRIVATE_KEY, provider);

const contractAddress = "0xAdEc9c114D4E094545E60E2e856Ab57552831c00";

const myNftContract = new ethers.Contract(contractAddress, abi, signer);

const tokenURI = "https://gateway.pinata.cloud/ipfs/QmPkfQpZAARb4ZoQVHyLfktvLS6x8WJ9w2yp1XRrZuEeqU";

const mintNFT = async () => {
    let nftTxn = await myNftContract.mintNFT(signer.address, tokenURI);
    await nftTxn.wait();
    console.log(`NFT Minted! Check it out at: https://goerli.etherscan.io/tx/${nftTxn.hash}`);
};

mintNFT()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

執行鑄造腳本。

```BASH
node scripts/mint.js
```

輸出訊息如下。

```BASH
NFT Minted! Check it out at: https://goerli.etherscan.io/tx/0xbba6d2d835fbe58dde91d04676b04a85a5bbf088e78bee7c6166a1155769f58a
```

## 程式碼

- [eth-nft-example](https://github.com/memochou1993/eth-nft-example)

## 參考資料

- [Alchemy - How to Create an NFT Tutorial](https://docs.alchemy.com/docs/how-to-create-an-nft)
