---
title: 使用 Solidity 和 Truffle 開發 Ethereum 智能合約
permalink: 使用-Solidity-和-Truffle-開發-Ethereum-智能合約
date: 2022-05-07 15:37:55
tags: ["區塊鏈", "Ethereum", "Web3", "Solidity", "Smart Contract", "DApp", "Truffle"]
categories: ["區塊鏈", "Ethereum"]
---

## 前言

本文使用 Ethereum 智能合約實作一個「To-Do List」應用程式。

## 前置作業

1. 安裝 [Ganache](https://trufflesuite.com/ganache/) 測試工具，並啟動應用程式。
2. 安裝 [MetaMask](https://metamask.io/download/) 錢包。

## 安裝依賴

安裝 Truffle 命令列工具。

```BASH
npm install -g truffle@5.0.2
```

查看版本。

```BASH
truffle version
Truffle v5.0.2 (core: 5.0.2)
Solidity v0.5.0 (solc-js)
Node v14.17.3
```

## 建立專案

建立專案。

```BASH
mkdir eth-todo-list
cd eth-todo-list
```

新增 `.gitignore` 檔。

```ENV
/node_modules
```

新增 `package.json` 檔。

```JSON
{
  "name": "eth-todo-list",
  "version": "0.1.0",
  "description": "",
  "main": "truffle-config.js",
  "directories": {
    "test": "test"
  },
  "scripts": {
    "dev": "lite-server",
    "test": "echo \"Error: no test specified\" && sexit 1"
  },
  "author": "",
  "license": "ISC",
  "devDependencies": {
    "bootstrap": "4.1.3",
    "chai": "^4.1.2",
    "chai-as-promised": "^7.1.1",
    "chai-bignumber": "^2.0.2",
    "lite-server": "^2.3.0",
    "nodemon": "^1.17.3",
    "truffle": "5.0.2",
    "truffle-contract": "3.0.6",
    "web3": "^0.20.0"
  }
}
```

安裝依賴套件。

```BASH
npm install
```

## 建立合約

使用 `truffle` 指令初始化專案。

```BASH
truffle init
```

新增 `contracts/TodoList.sol` 檔。

```SOL
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract TodoList {
    uint public taskCount = 0;
}
```

修改 `truffle-config.js` 檔，將網路指向 Ganache 的端點。

```JS
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
    },
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
};
```

新增 `migrations/2_deploy_contracts.js` 檔。

```JS
const TodoList = artifacts.require("TodoList");

module.exports = function(deployer) {
  deployer.deploy(TodoList);
};
```

編譯智能合約。

```BASH
truffle compile
```

執行部署腳本，將合約部署到本地測試鏈上。

```BASH
truffle migrate
```

## 互動介面

進入 Truffle 互動介面，與合約進行互動。

```BASH
truffle console
```

取得 `TodoList` 合約的內容。

```BASH
> todoList = await TodoList.deployed()
```

取得 `TodoList` 合約的地址。

```BASH
> todoList.address
'0x21875AacaeDbE8F9CF0ce0a72cEF4665BF25e058'
```

取得 `TodoList` 合約中，變數 `taskCount` 的值。

```BASH
> (await todoList.taskCount()).toNumber()
0
```

離開互動介面。

```BASH
> .exit
```

## 實作合約

修改 `contracts/TodoList.sol` 檔。

```SOL
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract TodoList {
    uint public taskCount = 0;

    struct Task {
        uint id;
        string content;
        bool completed;
    }

    mapping(uint => Task) public tasks;

    event TaskCreated(
        uint id,
        string content,
        bool completed
    );

    event TaskCompleted(
        uint id,
        bool completed
    );

    constructor() public {
        createTask("Check out https://github.com/memochou1993");
    }

    function createTask(string memory _content) public {
        taskCount++;
        uint id = taskCount;
        tasks[id] = Task(id, _content, false);
        emit TaskCreated(id, _content, false);
    }

    function toggleCompleted(uint _id) public {
        Task memory _task = tasks[_id];
        _task.completed = !_task.completed;
        tasks[_id] = _task;
        emit TaskCompleted(_id, _task.completed);
    }
}
```

編譯智能合約。

```BASH
truffle compile
```

重新執行部署腳本。

```BASH
truffle migrate --reset
```

## 匯入錢包

在 MetaMask 錢包新增一個測試網路：

- 網路名稱：localhost 7545
- RPC URL：<http://localhost:7545>
- 鏈 ID：1337
- Currency Symbol：ETH

將 Ganache 中帳戶的私鑰匯入至 MetaMask 錢包。

## 實作介面

新增 `bs-config.json` 檔，用來配置 `lite-server` 伺服器。

```JSON
{
  "server": {
    "baseDir": [
      "./src",
      "./build/contracts"
    ],
    "routes": {
      "/vendor": "./node_modules"
    }
  }
}
```

新增 `src/index.html` 檔。

```HTML
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>To-Do List</title>
    <link href="vendor/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
      main {
        margin-top: 60px;
      }
      #content {
        display: none;
      }
      form {
        width: 350px;
        margin-bottom: 10px;
      }
      ul {
        margin-bottom: 0px;
      }
      #completedTaskList .content {
        color: grey;
        text-decoration: line-through;
      }
    </style>
  </head>
  <body>
    <nav class="navbar navbar-dark fixed-top bg-dark flex-md-nowrap p-0 shadow">
      <a class="navbar-brand col-sm-3 col-md-2 mr-0" href="https://github.com/memochou1993" target="_blank">To-Do List</a>
      <ul class="navbar-nav px-3">
        <li class="nav-item text-nowrap d-none d-sm-none d-sm-block">
          <small><a class="nav-link" href="#"><span id="account"></span></a></small>
        </li>
      </ul>
    </nav>
    <div class="container-fluid">
      <div class="row">
        <main role="main" class="col-lg-12 d-flex justify-content-center">
          <div id="loader" class="text-center">
            <p class="text-center">Loading...</p>
          </div>
          <div id="content">
            <form onSubmit="App.createTask(); return false;">
              <input id="newTask" type="text" class="form-control" placeholder="Add task..." required>
              <input type="submit" hidden="">
            </form>
            <ul id="taskList" class="list-unstyled">
              <div class="taskTemplate" class="checkbox" style="display: none">
                <label>
                  <input type="checkbox" />
                  <span class="content">Task content goes here...</span>
                </label>
              </div>
            </ul>
            <ul id="completedTaskList" class="list-unstyled">
            </ul>
          </div>
        </main>
      </div>
    </div>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
    <script src="vendor/bootstrap/dist/js/bootstrap.min.js"></script>
    <script src="vendor/web3/dist/web3.min.js"></script>
    <script src="vendor/truffle-contract/dist/truffle-contract.js"></script>
    <script src="app.js"></script>
  </body>
</html>
```

新增 `src/app.js` 檔。

```JS
App = {
  loading: false,
  contracts: {},

  load: async () => {
    await App.loadWeb3()
    await App.loadAccount()
    await App.loadContract()
    await App.render()
  },

  loadWeb3: async () => {
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider
      web3 = new Web3(web3.currentProvider)
    } else {
      window.alert("Please connect to Metamask.")
    }
    // Modern dapp browsers...
    if (window.ethereum) {
      window.web3 = new Web3(ethereum)
      try {
        // Request account access if needed
        await ethereum.enable()
        // Acccounts now exposed
        web3.eth.sendTransaction({/* ... */})
      } catch (error) {
        // User denied account access...
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = web3.currentProvider
      window.web3 = new Web3(web3.currentProvider)
      // Acccounts always exposed
      web3.eth.sendTransaction({/* ... */})
    }
    // Non-dapp browsers...
    else {
      console.log('Non-Ethereum browser detected. You should consider trying MetaMask!')
    }
  },

  loadAccount: async () => {
    App.account = web3.eth.accounts[0]
    web3.eth.defaultAccount = App.account;
  },

  loadContract: async () => {
    const todoList = await $.getJSON('TodoList.json')
    App.contracts.TodoList = TruffleContract(todoList)
    App.contracts.TodoList.setProvider(App.web3Provider)
    App.todoList = await App.contracts.TodoList.deployed()
  },

  render: async () => {
    if (App.loading) {
      return
    }

    App.setLoading(true)

    $('#account').html(App.account)

    await App.renderTasks()

    App.setLoading(false)
  },

  renderTasks: async () => {
    const taskCount = await App.todoList.taskCount()
    const $taskTemplate = $('.taskTemplate')

    for (var i = 1; i <= taskCount; i++) {
      const task = await App.todoList.tasks(i)
      const taskId = task[0].toNumber()
      const taskContent = task[1]
      const taskCompleted = task[2]

      const $newTaskTemplate = $taskTemplate.clone()
      $newTaskTemplate.find('.content').html(taskContent)
      $newTaskTemplate.find('input')
                      .prop('name', taskId)
                      .prop('checked', taskCompleted)
                      .on('click', App.toggleCompleted)

      if (taskCompleted) {
        $('#completedTaskList').append($newTaskTemplate)
      } else {
        $('#taskList').append($newTaskTemplate)
      }

      $newTaskTemplate.show()
    }
  },

  createTask: async () => {
    App.setLoading(true)
    const content = $('#newTask').val()
    await App.todoList.createTask(content)
    window.location.reload()
  },

  toggleCompleted: async (e) => {
    App.setLoading(true)
    const taskId = e.target.name
    await App.todoList.toggleCompleted(taskId)
    window.location.reload()
  },

  setLoading: (boolean) => {
    App.loading = boolean
    const loader = $('#loader')
    const content = $('#content')
    if (boolean) {
      loader.show()
      content.hide()
    } else {
      loader.hide()
      content.show()
    }
  }
}

$(() => {
  $(window).load(() => {
    App.load()
  })
})
```

啟動介面。

```BASH
npm run dev
```

## 撰寫測試

新增 `test/TodoList.test.js` 檔。

```JS
const { assert } = require("chai")

const TodoList = artifacts.require('./TodoList.sol')

contract('TodoList', (accouts) => {
  before(async () => {
    this.todoList = await TodoList.deployed()
  })

  it('deploys successfully', async () => {
    const address = this.todoList.address
    assert.notEqual(address, 0x0)
    assert.notEqual(address, '')
    assert.notEqual(address, null)
    assert.notEqual(address, undefined)
  })

  it('lists tasks', async () => {
    const taskCount = await this.todoList.taskCount()
    const task = await this.todoList.tasks(taskCount)
    assert.equal(task.id.toNumber(), taskCount.toNumber())
    assert.equal(task.content, 'Check out https://github.com/memochou1993')
    assert.equal(task.completed, false)
    assert.equal(taskCount.toNumber(), 1)
  })

  it('creates tasks', async () => {
    const result = await this.todoList.createTask('A new task')
    const taskCount = await this.todoList.taskCount()
    assert.equal(taskCount.toNumber(), 2)
    const event = result.logs[0].args
    assert.equal(event.id.toNumber(), 2)
    assert.equal(event.content, 'A new task')
    assert.equal(event.completed, false)
  })

  it('toggles task completion', async () => {
    const result = await this.todoList.toggleCompleted(1)
    const task = await this.todoList.tasks(1)
    assert.equal(task.completed, true)
    const event = result.logs[0].args
    assert.equal(event.id.toNumber(), 1)
    assert.equal(event.completed, true)
  })
})
```

執行測試。

```BASH
truffle test
```

## 程式碼

- [eth-todo-list](https://github.com/memochou1993/eth-todo-list)

## 參考資料

- [Build Your First Blockchain App Using Ethereum Smart Contracts and Solidity](https://youtu.be/coQ5dg8wM2o)
