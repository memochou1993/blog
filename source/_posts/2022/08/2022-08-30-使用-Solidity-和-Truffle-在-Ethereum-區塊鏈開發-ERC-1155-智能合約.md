---
title: 使用 Solidity 和 Truffle 在 Ethereum 區塊鏈開發 ERC-1155 智能合約
permalink: 使用-Solidity-和-Truffle-在-Ethereum-區塊鏈開發-ERC-1155-智能合約
date: 2022-08-30 20:25:22
tags: ["區塊鏈", "Ethereum", "Solidity", "ERC-1155", "JavaScript", "Node", "Ethers", "Smart Contract", "DApp", "Truffle", "NFT"]
categories: ["區塊鏈", "Ethereum"]
---

## 做法

建立專案。

```BASH
mkdir eth-erc-1155
cd eth-erc-1155
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

新增 `ERC1155NFT.sol` 檔。

```SOL
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ERC1155NFT is ERC1155URIStorage, Ownable {
    mapping(address => uint8) balances;

    uint256 tokenCount = 0;

    constructor() ERC1155("") {}

    function mintNFT(string memory _tokenURI)
        public
        returns (uint256)
    {
        require(balances[msg.sender] < 100);
        balances[msg.sender]++;
        tokenCount++;
        _mint(msg.sender, tokenCount, 10, "");
        _setURI(tokenCount, string(abi.encodePacked(_tokenURI, Strings.toString(tokenCount))));
        return tokenCount;
    }
}
```

新增 `migrations/2_deploy_contracts.js` 檔。

```JS
const ERC1155NFT = artifacts.require("ERC1155NFT");

module.exports = (deployer) => {
  deployer.deploy(ERC1155NFT);
};
```

執行部署。

```BASH
truffle migrate
```
