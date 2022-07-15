---
title: 使用 abigen 產生與 Ethereum 智能合約互動的 Go 程式碼
permalink: 使用-abigen-產生與-Ethereum-智能合約互動的-Go-程式碼
date: 2022-07-15 23:43:54
tags: ["區塊鏈", "Ethereum", "Solidity", "Smart Contract", "Go"]
categories: ["區塊鏈", "Ethereum"]
---

## 做法

安裝依賴套件。

```BASH
brew update
brew tap ethereum/ethereum
brew install ethereum
brew install solidity
brew install protobuf
```

安裝 `abigen` 工具。

```BASH
git clone https://github.com/ethereum/go-ethereum.git
cd go-ethereum
make devtools
```

查看 `abigen` 工具的版本。

```BASH
abigen --version
```

使用 `abigen` 指令產生 Go 程式碼。

```BASH
abigen --abi="MyContract.abi" --type="MyContract" --pkg="contract" --out="my_contract.go"
```
