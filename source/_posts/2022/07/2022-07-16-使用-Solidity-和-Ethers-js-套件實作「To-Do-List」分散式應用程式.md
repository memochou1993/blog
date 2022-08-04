---
title: 使用 Solidity 和 Ethers.js 套件實作「To-Do List」分散式應用程式
permalink: 使用-Solidity-和-Ethers-js-套件實作「To-Do-List」分散式應用程式
date: 2022-07-16 01:15:30
tags: ["區塊鏈", "Ethereum", "Solidity", "Ethers", "Smart Contract", "DApp", "Truffle"]
categories: ["區塊鏈", "Ethereum"]
---

## 前置作業

1. 安裝 [Ganache](https://trufflesuite.com/ganache/) 工具，並啟動應用程式，建立一個本地區塊鏈。
2. 安裝 [MetaMask](https://metamask.io/download/) 錢包。

## 安裝依賴

安裝 Truffle 命令列工具。

```BASH
npm install -g truffle@5.0.2
```

## 建立專案

使用 `truffle` 指令初始化專案。

```BASH
truffle init eth-todo-list
cd eth-todo-list
```

新增 `.gitignore` 檔。

```ENV
/node_modules
/build
/dist
```

## 合約實作

新增 `contracts/TodoList.sol` 檔。

```SOL
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TodoList {
    uint256 public taskCount = 0;

    struct Task {
        uint256 idx;
        string content;
        bool completed;
    }

    Task[] public tasks;

    constructor() {
        createTask("Check out https://github.com/memochou1993");
    }

    function getTasks()
        external
        view
        returns (Task[] memory)
    {
        return tasks;
    }

    function createTask(string memory _content) public {
        uint256 _idx = taskCount;
        tasks.push(Task(_idx, _content, false));
        taskCount++;
        emit TaskCreated(_idx, tasks[_idx]);
    }

    function updateTask(uint256 _idx, bool _completed) public {
        tasks[_idx].completed = _completed;
        emit TaskUpdated(_idx, tasks[_idx]);
    }

    event TaskCreated(uint256 idx, Task task);
    event TaskUpdated(uint256 idx, Task task);
}
```

修改 `truffle-config.js` 檔，將網路指向 Ganache 的端點。

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
      version: '0.8.14',
      settings: {
        optimizer: {
          enabled: false,
          runs: 200,
        },
      },
    },
  },
};
```

新增 `migrations/2_deploy_contracts.js` 檔。

```JS
const TodoList = artifacts.require('TodoList');

module.exports = function(deployer) {
  deployer.deploy(TodoList);
};
```

部署至 Ganache 本地區塊鏈。

```BASH
truffle migrate --reset
```

## 設置錢包

在 MetaMask 錢包新增一個測試網路：

- 網路名稱：Localhost 7545
- RPC URL：<http://localhost:7545>
- 鏈 ID：1337
- Currency Symbol：ETH

將 Ganache 中帳戶的私鑰匯入至 MetaMask 錢包。

## 前端實作

安裝套件。

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
    <input id="content"><button>Create</button>
    <ul id="list"></ul>
    <script type="module" src="/src/main.js"></script>
</body>
</html>
```

新增 `src/main.js` 檔。

```JS
import { ethers } from 'ethers';
import { abi } from '../build/contracts/TodoList.json';

const { VITE_CONTRACT_ADDRESS } = import.meta.env;

class App {
  constructor() {
    this.init();
  }

  async init() {
    await this.loadContract();
    await this.renderTasks();

    document.querySelector('button').addEventListener('click', (e) => this.createTask(e));
  }

  async loadContract() {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send('eth_requestAccounts');
    const signer = provider.getSigner();
    this.contract = new ethers.Contract(VITE_CONTRACT_ADDRESS, abi, signer);
  }

  async renderTasks() {
    const tasks = await this.contract.getTasks();
    const list = document.getElementById('list');
    list.textContent = '';
    tasks.forEach((task) => {
      const [idx, content, completed] = task;
      const checkbox = document.createElement('input');
      checkbox.type = 'checkbox';
      checkbox.name = idx;
      checkbox.checked = completed;
      checkbox.addEventListener('click', (e) => this.updateTask(e));
      const item = document.createElement('li');
      item.textContent = content;
      item.prepend(checkbox);
      list.append(item);
    });
  }

  async createTask() {
    try {
      const content = document.getElementById('content');
      const res = await this.contract.createTask(content.value);
      await res.wait();
      await this.renderTasks();
      content.value = '';
    } catch (err) {
      alert(err.message);
    }
  }

  async updateTask(e) {
    try {
      const res = await this.contract.updateTask(e.target.name, e.target.checked);
      await res.wait();
    } catch (err) {
      alert(err.message);
      e.target.checked = !e.target.checked;
    }
  }
}

window.onload = () => new App();
```

啟動網頁。

```BASH
npm run dev
```

## 部署

安裝套件。

```BASH
npm i @truffle/hdwallet-provider truffle-plugin-verify --save-dev
```

修改 `.env` 檔。

```ENV
PROVIDER_URL=wss://eth-goerli.g.alchemy.com/v2/your-api-key
PRIVATE_KEY=your-private-key
ETHERSCAN_API_KEY=your-api-key
```

修改 `truffle-config.js` 檔。

```JS
const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();

const { PROVIDER_URL, PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;

module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 7545,
      network_id: '*',
    },
    goerli: {
      provider: () => new HDWalletProvider(PRIVATE_KEY, PROVIDER_URL),
      network_id: 5,
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
    etherscan: ETHERSCAN_API_KEY,
  },
};
```

部署到 Goerli 測試網路。

```BASH
truffle migrate --network goerli
```

## 提交認證

在 Etherscan 提交認證。

```BASH
truffle run verify TodoList --network goerli
```

## 程式碼

- [eth-todo-list](https://github.com/memochou1993/eth-todo-list)
