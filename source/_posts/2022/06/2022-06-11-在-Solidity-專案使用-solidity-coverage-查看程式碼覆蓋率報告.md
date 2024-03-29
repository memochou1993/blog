---
title: 在 Solidity 專案使用 solidity-coverage 查看程式碼覆蓋率報告
date: 2022-06-11 01:37:22
tags: ["Blockchain", "Ethereum", "Solidity", "Smart Contract", "Truffle", "Testing", "Code Coverage"]
categories: ["Blockchain", "Ethereum"]
---

## 環境

- Truffle

## 做法

安裝依賴。

```bash
npm i solidity-coverage@beta -D
```

新增 `.solcover.js` 檔。

```js
module.exports = {
  client: require('ganache-cli'),
  providerOptions: {},
};
```

修改 `truffle-config.js` 檔。

```js
module.exports = {
  // ...
  plugins: [
    'solidity-coverage',
  ],
};
```

修改 `package.json` 檔，添加 `coverage` 指令。

```json
{
  "scripts": {
    "coverage": "truffle run coverage"
  }
}
```

執行測試，並產生程式碼覆蓋率報告。

```bash
npm run coverage
```

查看報告。

```bash
live-server ./coverage
```

## 參考資料

-[solidity-coverage](https://github.com/sc-forks/solidity-coverage)
