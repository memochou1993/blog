---
title: 在 Go 專案使用 ethclient 取得 Ethereum 區塊鏈交易
date: 2022-07-03 12:30:43
tags: ["區塊鏈", "Ethereum", "Etherscan"]
categories: ["區塊鏈", "Ethereum"]
---

## 做法

新增 `.env` 檔。

```env
PROVIDER_URL=https://eth-goerli.alchemyapi.io/v2/your-api-key
```

新增 `ethereum/ethereum.go` 檔。

```go
package ethereum

import (
	"context"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethclient"
	"log"
	"math/big"
	"os"
)

var (
	client *ethclient.Client
)

func init() {
	var err error
	if client, err = ethclient.Dial(os.Getenv("PROVIDER_URL")); err != nil {
		log.Fatal(err)
	}
}

// 取得交易回條
func FetchTransactionReceipt(txHash common.Hash) (*types.Receipt, error) {
	receipt, err := client.TransactionReceipt(context.Background(), txHash)
	if err != nil {
		return nil, err
	}
	log.Printf("Fetching transaction receipt: %s", txHash)
	return receipt, nil
}
```

## 解析

解析 `Receipt` 交易回條中的 `Log` 資料，可以使用 `abi.ABI` 的 `UnpackIntoMap` 或 `UnpackIntoInterface` 方法。

```go
func decodeTransactionLogs(receipt *types.Receipt, contractABI *abi.ABI) error {
	for _, receiptLog := range receipt.Logs {
		for _, topic := range receiptLog.Topics {
			event, err := contractABI.EventByID(topic)
			if err != nil {
				continue
			}
			if event.Name == "StakeCreated" {
				e := StakeEvent{}
				if err = contractABI.UnpackIntoInterface(&e, event.Name, receiptLog.Data); err != nil {
					log.Fatal(err)
				}
				// do something
				break
			}
			if event.Name == "StakeRemoved" {
				e := StakeEvent{}
				if err = contractABI.UnpackIntoInterface(&e, event.Name, receiptLog.Data); err != nil {
					log.Fatal(err)
				}
				// do something
			}
		}
	}
	return nil
}

// 交易回條中 Log 的參數結構體
type StakeEvent struct {
	Stake struct {
		Index           *big.Int
		Amount          *big.Int
		RewardPlanIndex *big.Int
		CreatedAt       *big.Int
	}
}
```

如果 `Log` 中的參數是一個物件，可以使用以下方法查看其結構體的定義。

```go
v := make(map[string]interface{})
if err = contractABI.UnpackIntoMap(v, event.Name, receiptLog.Data); err != nil {
	log.Fatal(err)
}
log.Print(reflect.TypeOf(v["stake"]))
```

## 參考資料

- [ethereum/go-ethereum](https://pkg.go.dev/github.com/ethereum/go-ethereum/accounts)
- [crazygit/parseTransaction.go](https://gist.github.com/crazygit/9279a3b26461d7cb03e807a6362ec855)
