---
title: 使用 Solidity 和 Truffle 在 Ethereum 區塊鏈開發 NFT 智能合約
permalink: 使用-Solidity-和-Truffle-在-Ethereum-區塊鏈開發-NFT-智能合約
date: 2022-08-30 20:25:22
tags: ["區塊鏈", "Ethereum", "Solidity", "JavaScript", "Node", "Ethers", "Smart Contract", "DApp", "Truffle", "NFT"]
categories: ["區塊鏈", "Ethereum"]
---

## 建立專案

建立專案。

```BASH
mkdir eth-nft-minter
cd eth-nft-minter
```

初始化 Truffle 專案。

```BASH
truffle init
```

修改 `truffle-config.js` 檔。

```JS
module.exports = {
  networks: {
    development: {
     host: '127.0.0.1',
     port: 7545,
     network_id: '*',
    },
  },
  compilers: {
    solc: {
      version: '0.8.13',
    },
  },
};
```

新增 `.gitignore` 檔。

```ENV
/node_modules
/build
.env
```

## 合約實作

新增 `ERC721NFT.sol` 檔。

```SOL
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721NFT is ERC721URIStorage, Ownable {
    mapping(address => uint8) recipients;

    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;

    constructor() ERC721("ERC721NFT", "NFT") {}

    function mintNFT(address _recipient, string memory _tokenURI)
        onlyOwner
        public
        returns (uint256)
    {
        require(recipients[_recipient] < 100);

        recipients[_recipient]++;

        tokenIds.increment();

        uint256 _newItemId = tokenIds.current();

        _mint(_recipient, _newItemId);

        _setTokenURI(_newItemId, _tokenURI);

        return _newItemId;
    }
}
```

## 前端實作

安裝依賴套件。

```BASH
npm i vite ethers dotenv --save
```

新增 `.env` 檔。

```ENV
VITE_CONTRACT_ADDRESS=your-contract-address
```

修改 `package.json` 檔。

```JSON
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  // ...
}
```

在根目錄新增 `index.html` 檔。

```HTML
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <button id="mint-nft">Mint NFT</button>
    <script type="module" src="/src/main.js"></script>
</body>
</html>
```

新增 `src/main.js` 檔。

```JS
// TODO
document.getElementById('mint-nft').addEventListener('click', () => {
  console.log('Mint NFT');
});
```

TODO
