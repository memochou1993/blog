---
title: 使用 Go 與 Ethereum 智能合約互動
permalink: 使用-Go-與-Ethereum-智能合約互動
date: 2022-07-17 23:43:54
tags: ["區塊鏈", "Ethereum", "Solidity", "Smart Contract", "Go"]
categories: ["區塊鏈", "Ethereum"]
---

## 建立專案

建立專案。

```BASH
mkdir eth-go-binding-example
cd eth-go-binding-example
```

初始化 Go Modules。

```BASH
go mod init github.com/memochou1993/eth-go-binding-example
```

新增 `.env` 檔。

```BASH
CONTRACT_ADDRESS=your-contract-address
PROVIDER_URL=wss://eth-goerli.g.alchemy.com/v2/your-api-key
```

新增 `.gitignore` 檔。

```ENV
.env
```

將 JSON 格式的 ABI 從 Truffle 專案複製到 `abi/TodoList.json` 檔。

```JSON
[
  {
    "inputs": [],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  // ...
]
```

使用 `abigen` 工具產生 Go 程式碼。

```BASH
abigen --abi="abi/TodoList.json" --type="TodoList" --pkg="contract" --out="contract/todo_list.go"
```

新增 `main.go` 檔。

```GO
package main

import (
	"log"
	"math/big"
	"os"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
	_ "github.com/joho/godotenv/autoload"
	"github.com/memochou1993/eth-go-binding-example/contract"
)

func main() {
	conn, err := ethclient.Dial(os.Getenv("PROVIDER_URL"))
	if err != nil {
		log.Fatal(err)
	}

	todoList, err := contract.NewTodoList(common.HexToAddress(os.Getenv("CONTRACT_ADDRESS")), conn)
	if err != nil {
		log.Fatal(err)
	}

	task, err := todoList.Tasks(&bind.CallOpts{}, new(big.Int))
	if err != nil {
		log.Fatal(err)
	}

	log.Print(task)
}
```

執行程式碼。

```BASH
go run main.go
```

輸出如下：

```BASH
{0 Check out https://github.com/memochou1993 false}
```

## 程式碼

- [eth-go-binding-example](https://github.com/memochou1993/eth-go-binding-example)

## 參考資料

- [Go Contract Bindings](https://geth.ethereum.org/docs/dapp/native-bindings)
