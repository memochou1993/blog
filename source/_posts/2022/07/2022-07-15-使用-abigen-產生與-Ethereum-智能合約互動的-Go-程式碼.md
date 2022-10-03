---
title: 使用 abigen 產生與 Ethereum 智能合約互動的 Go 程式碼
date: 2022-07-15 23:43:54
tags: ["區塊鏈", "Ethereum", "Solidity", "Smart Contract", "Go"]
categories: ["區塊鏈", "Ethereum"]
---

## 前言

在 Go 專案中，要與 Ethereum 智能合約互動，需要安裝 Ethereum 的 `abigen` 工具，產生與智能合約互動的 Go 程式碼。

## 做法

首先，使用 `brew` 指令安裝依賴套件。

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

- 參數 `abi` 指定智能合約的 ABI 檔，通常是 JSON 格式。
- 參數 `type` 指定 Go 程式碼的結構體（struct）名稱。
- 參數 `pkg` 指定 Go 程式碼的包（package）名稱。
- 參數 `out` 指定輸出資料夾。

## 參考資料

- [Go Contract Bindings](https://geth.ethereum.org/docs/dapp/native-bindings)
