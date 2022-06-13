---
title: 在 Solidity 專案使用 solidity-coverage 查看程式碼覆蓋率報告
permalink: 在-Solidity-專案使用-solidity-coverage-查看程式碼覆蓋率報告
date: 2022-06-11 01:37:22
tags: ["區塊鏈", "Ethereum", "Solidity", "Smart Contract", "Truffle", "測試", "Code Coverage"]
categories: ["區塊鏈", "Ethereum"]
---

## 環境

- Truffle

## 做法

安裝依賴。

```BASH
npm i solidity-coverage@beta -D
```

新增 `.solcover.js` 檔。

```JS
module.exports = {
  client: require('ganache-cli'),
  providerOptions: {},
};
```

修改 `truffle-config.js` 檔。

```JS
module.exports = {
  // ...
  plugins: [
    'solidity-coverage',
  ],
};
```

修改 `package.json` 檔，添加 `coverage` 指令。

```JSON
{
  "scripts": {
    "coverage": "truffle run coverage"
  }
}
```

執行測試，並產生程式碼覆蓋率報告。

```BASH
npm run coverage
```

查看報告。

```BASH
live-server ./coverage
```

## 參考資料

-[solidity-coverage](https://github.com/sc-forks/solidity-coverage)
