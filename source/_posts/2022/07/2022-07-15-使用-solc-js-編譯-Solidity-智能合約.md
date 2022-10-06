---
title: 使用 solc-js 編譯 Solidity 智能合約
date: 2022-07-15 23:34:43
tags: ["區塊鏈", "Ethereum", "Solidity", "Smart Contract"]
categories: ["區塊鏈", "Ethereum"]
---

## 做法

安裝 `solc-js` 套件。

```bash
npm install solc --save-dev
```

新增 `scripts/compile.sh` 檔。

```bash
#!/bin/bash

mkdir -p build/abi/json
solc contracts/MyContract.sol --abi --include-path="node_modules" --base-path="." --output-dir="build/abi/json" --overwrite
```

修改 `package.json` 檔。

```json
{
  "scripts": {
    "compile": "bash scripts/compile.sh"
  }
}
```

## 參考資料

- [solc-js](https://github.com/ethereum/solc-js)
