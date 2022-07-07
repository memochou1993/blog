---
title: 使用 Solidity 在 BNB 區塊鏈實作 Staking 智能合約
permalink: 使用-Solidity-在-BNB-區塊鏈實作-Staking-智能合約
date: 2022-07-08 00:40:05
tags: ["區塊鏈", "Ethereum", "Solidity", "Smart Contract", "DApp", "Truffle", "BNB"]
categories: ["區塊鏈", "Ethereum"]
---

## 建立專案

建立專案。

```BASH
mkdir eth-staking
cd eth-staking
```

使用 `truffle` 指令初始化專案。

```BASH
truffle init
```

新增 `.gitignore` 檔。

```ENV
/node_modules
.env
```

安裝依賴套件。

```BASH
npm install @openzeppelin/contracts
```

## 實作

建立 `contracts/Staking.sol` 檔，實作質押合約。

```SOL
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Staking is Ownable, ReentrancyGuard {
    address private _owner;
    uint256 constant REWARD_RATE = 365 * 8;
    uint256 public stakeholderCount;
    mapping(address => Stakeholder) public stakeholders;

    struct Stakeholder {
        address addr;
        Stake[] stakes;
    }

    struct Stake {
        uint256 amount;
        uint256 claimed;
        uint256 createdAt;
    }

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyStakeholder() {
        require(isStakeholder(msg.sender), "Staking: caller is not the stakeholder");
        _;
    }

    function contractBalance()
        external
        view
        returns (uint256)
    {
        return address(this).balance;
    }

    function stakesOf(address _stakeholder)
        external
        view
        onlyStakeholder
        returns (Stake[] memory)
    {
        return stakeholders[_stakeholder].stakes;
    }

    function isStakeholder(address _stakeholder)
        public
        view
        returns (bool)
    {
        return stakeholders[_stakeholder].addr != address(0);
    }

    function stake()
        public
        payable
        nonReentrant
    {
        if (!isStakeholder(msg.sender)) {
            stakeholders[msg.sender].addr = msg.sender;
            stakeholderCount++;
        }
        uint256 _fee = calculateFee(msg.value);
        uint256 _amount = msg.value - _fee;
        uint256 _createdAt = block.timestamp;
        stakeholders[msg.sender].stakes.push(Stake({
            amount: _amount,
            claimed: 0,
            createdAt: _createdAt
        }));
        payable(_owner).transfer(_fee);
    }

    function claim()
        public
        payable
        nonReentrant
        onlyStakeholder
    {
        uint256 _totalRewards;
        uint256 _totalFees;
        for (uint256 i = 0; i < stakeholders[msg.sender].stakes.length; i++) {
            uint256 _reward = calculateReward(stakeholders[msg.sender].stakes[i]);
            uint256 _fee = calculateFee(_reward);
            stakeholders[msg.sender].stakes[i].claimed += _reward - _fee;
            _totalRewards += _reward;
            _totalFees += _fee;
        }
        uint256 _amount = _totalRewards - _totalFees;
        payable(_owner).transfer(_totalFees);
        payable(msg.sender).transfer(_amount);
    }

    function calculateReward(Stake memory _stake)
        private
        view
        returns (uint256)
    {
        return (block.timestamp - _stake.createdAt) * _stake.amount * REWARD_RATE / 100 / 365 days - _stake.claimed;
    }

    function calculateFee(uint256 _amount)
        private
        pure
        returns (uint256)
    {
        return _amount * 3 / 100;
    }
}
```

## 部署

新增 `2_deploy_contracts.js` 檔。

```JS
const Staking = artifacts.require("Staking");

module.exports = function (deployer) {
  deployer.deploy(Staking);
};
```

安裝依賴套件。

```BASH
npm i dotenv @truffle/hdwallet-provider truffle-plugin-verify --save
```

新增 `.env` 檔。

```ENV
BSCSCAN_API_KEY=
PRIVATE_KEY=
```

修改 `truffle-config.js` 檔。

```JS
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

## 提交認證

在 BscScan 提交認證。

```BASH
truffle run verify Staking --network bsc
```

## 程式碼

- [eth-staking](https://github.com/memochou1993/eth-staking)
