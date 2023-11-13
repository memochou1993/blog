---
title: 在 Go 專案使用 Etherscan API 取得 Ethereum 區塊鏈交易
date: 2022-07-02 12:30:43
tags: ["Blockchain", "Ethereum", "Etherscan"]
categories: ["Blockchain", "Ethereum"]
---

## 做法

新增 `.env` 檔。

```env
ETHERSCAN_URL=https://api-goerli.etherscan.io
ETHERSCAN_API_KEY=
```

新增 `etherscan/client.go` 檔：

```go
package etherscan

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"log"
	"net/url"
	"os"
	"strings"
)

// 取得交易列表
func GetTransactionList(address, startBlock string, endBlock string) ([]*Transaction, error) {
	txsResponse, err := fetchTransactionList(context.Background(), address, startBlock, endBlock)
	if err != nil {
		return nil, err
	}
	return txsResponse.Result, nil
}

// 取得合約介面
func GetContractABI(address string) (*abi.ABI, error) {
	contractABIResponse, err := fetchContractABI(context.Background(), address)
	if err != nil {
		return nil, err
	}
	contractABI, err := abi.JSON(strings.NewReader(*contractABIResponse.Result))
	if err != nil {
		return nil, err
	}
	return &contractABI, nil
}

// 送出取得交易列表的請求
func fetchTransactionList(ctx context.Context, address, startBlock string, endBlock string) (*TransactionListResponse, error) {
	data, err := fetch(ctx, map[string]string{
		"module":     "account",
		"action":     "txlist",
		"address":    address,
		"startblock": startBlock,
		"endblock":   endBlock,
		"apikey":     os.Getenv("ETHERSCAN_API_KEY"),
	})
	if err != nil {
		return nil, err
	}
	resp := TransactionListResponse{}
	if err := json.Unmarshal(data, &resp); err != nil {
		return nil, fmt.Errorf("fetch transaction list failed: %s", string(data))
	}
	log.Printf("Fetching transaction list from %s to %s", startBlock, endBlock)
	return &resp, err
}

// 送出取得合約介面的請求
func fetchContractABI(ctx context.Context, address string) (*ContractABIResponse, error) {
	b, err := fetch(ctx, map[string]string{
		"module":  "contract",
		"action":  "getabi",
		"address": address,
		"apikey":  os.Getenv("ETHERSCAN_API_KEY"),
	})
	if err != nil {
		return nil, err
	}
	resp := ContractABIResponse{}
	if err := json.Unmarshal(b, &resp); err != nil {
		return nil, fmt.Errorf("fetch contract ABI failed: %s", string(b))
	}
	log.Printf("Fetching contract ABI: %s", address)
	return &resp, nil
}

// 送出請求
func fetch(ctx context.Context, params map[string]string) ([]byte, error) {
	ref, err := url.Parse("/api/")
	if err != nil {
		log.Fatal(err)
	}
	q := ref.Query()
	for k, v := range params {
		q.Set(k, v)
	}
	ref.RawQuery = q.Encode()
	base, err := url.Parse(os.Getenv("ETHERSCAN_URL"))
	if err != nil {
		log.Fatal(err)
	}
	target := base.ResolveReference(ref).String()
	return client.Get(ctx, target)
}

type ContractABIResponse struct {
	Status  *string `json:"status"`
	Message *string `json:"message"`
	Result  *string `json:"result"`
}

type TransactionListResponse struct {
	Status  *string        `json:"status"`
	Message *string        `json:"message"`
	Result  []*Transaction `json:"result"`
}

type Transaction struct {
	BlockNumber       string `json:"blockNumber"`
	TimeStamp         string `json:"timeStamp"`
	Hash              string `json:"hash"`
	Nonce             string `json:"nonce"`
	BlockHash         string `json:"blockHash"`
	TransactionIndex  string `json:"transactionIndex"`
	From              string `json:"from"`
	To                string `json:"to"`
	Value             string `json:"value"`
	Gas               string `json:"gas"`
	GasPrice          string `json:"gasPrice"`
	IsError           string `json:"isError"`
	TxreceiptStatus   string `json:"txreceipt_status"`
	Input             string `json:"input"`
	ContractAddress   string `json:"contractAddress"`
	CumulativeGasUsed string `json:"cumulativeGasUsed"`
	GasUsed           string `json:"gasUsed"`
	Confirmations     string `json:"confirmations"`
}
```

## 參考資料

- [Etherscan APIs documentation](https://docs.etherscan.io/)
