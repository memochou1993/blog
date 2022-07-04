---
title: 在 Go 專案使用 Etherscan API 解析 Ethereum 區塊鏈交易
permalink: 在-Go-專案使用-Etherscan-API-解析-Ethereum-區塊鏈交易
date: 2022-07-02 12:30:43
tags: ["區塊鏈", "Ethereum", "Etherscan"]
categories: ["區塊鏈", "Ethereum"]
---

## 做法

新增 `.env` 檔。

```ENV
ETHERSCAN_URL=https://api-goerli.etherscan.io
ETHERSCAN_API_KEY=
ETHERSCAN_CONTRACT_ADDRESS=
```

新增 `etherscan/client.go` 檔，並初始化一個 `http.Client` 實例。

```GO
package app

import (
	"context"
	"fmt"
	"io"
	"log"
	"net/http"
	"time"
)

var (
	client *http.Client
)

func init() {
	client = &http.Client{
		Timeout: 10 * time.Second,
	}
}

func Get(ctx context.Context, url string) ([]byte, error) {
	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		return nil, err
	}
	resp, err := client.Do(req.WithContext(ctx))
	if err != nil {
		return nil, err
	}
	defer closeBody(resp.Body)
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("request failed: %s", resp.Status)
	}
	return io.ReadAll(resp.Body)
}

func closeBody(closer io.ReadCloser) {
	if err := closer.Close(); err != nil {
		log.Fatal(err)
	}
}
```

新增 `etherscan/etherscan.go` 檔。

```GO
package etherscan

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/url"
	"os"
)

// ...
```

新增 `RespTxs` 結構體，定義交易列表的響應結構。

```GO
type RespTxs struct {
	Status  string `json:"status"`
	Message string `json:"message"`
	Result  []struct {
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
	} `json:"result"`
}
```

新增 `RespTx` 結構體，定義單筆交易紀錄的響應結構。

```GO
type RespTx struct {
	Jsonrpc string `json:"jsonrpc"`
	ID      int    `json:"id"`
	Result  struct {
		BlockHash         string      `json:"blockHash"`
		BlockNumber       string      `json:"blockNumber"`
		ContractAddress   interface{} `json:"contractAddress"`
		CumulativeGasUsed string      `json:"cumulativeGasUsed"`
		EffectiveGasPrice string      `json:"effectiveGasPrice"`
		From              string      `json:"from"`
		GasUsed           string      `json:"gasUsed"`
		Logs              []struct {
			Address          string   `json:"address"`
			Topics           []string `json:"topics"`
			Data             string   `json:"data"`
			BlockNumber      string   `json:"blockNumber"`
			TransactionHash  string   `json:"transactionHash"`
			TransactionIndex string   `json:"transactionIndex"`
			BlockHash        string   `json:"blockHash"`
			LogIndex         string   `json:"logIndex"`
			Removed          bool     `json:"removed"`
		} `json:"logs"`
		LogsBloom        string `json:"logsBloom"`
		Status           string `json:"status"`
		To               string `json:"to"`
		TransactionHash  string `json:"transactionHash"`
		TransactionIndex string `json:"transactionIndex"`
		Type             string `json:"type"`
	} `json:"result"`
}
```

新增 `FetchTxs` 方法，取得交易列表。

```GO
func FetchTxs(ctx context.Context, startBlock string, endBlock string) (*RespTxs, error) {
	u, err := url.Parse("/api/")
	if err != nil {
		log.Fatal(err)
	}
	q := u.Query()
	q.Set("module", "account")
	q.Set("action", "txlist")
	q.Set("address", os.Getenv("ETHERSCAN_CONTRACT_ADDRESS"))
	q.Set("startblock", startBlock)
	q.Set("endblock", endBlock)
	q.Set("apikey", os.Getenv("ETHERSCAN_API_KEY"))
	u.RawQuery = q.Encode()
	base, err := url.Parse(os.Getenv("ETHERSCAN_URL"))
	if err != nil {
		log.Fatal(err)
	}
	resp := &RespTxs{}
	target := base.ResolveReference(u).String()
	b, err := app.Get(ctx, target)
	if err := json.Unmarshal(b, resp); err != nil {
		return nil, fmt.Errorf("unmarshal failed: %s", string(b))
	}
	log.Printf("Fetching transactions from %s to %s", startBlock, endBlock)
	return resp, err
}
```

新增 `FetchTx` 方法，取得單筆交易紀錄。

```GO
func FetchTx(ctx context.Context, txHash string) (*RespTx, error) {
	u, err := url.Parse("/api/")
	if err != nil {
		log.Fatal(err)
	}
	q := u.Query()
	q.Set("module", "proxy")
	q.Set("action", "eth_getTransactionReceipt")
	q.Set("txhash", txHash)
	q.Set("apikey", os.Getenv("ETHERSCAN_API_KEY"))
	u.RawQuery = q.Encode()
	base, err := url.Parse(os.Getenv("ETHERSCAN_URL"))
	if err != nil {
		log.Fatal(err)
	}
	resp := &RespTx{}
	target := base.ResolveReference(u).String()
	b, err := app.Get(ctx, target)
	if err := json.Unmarshal(b, resp); err != nil {
		return nil, fmt.Errorf("unmarshal failed: %s", string(b))
	}
	log.Printf("Fetching transaction: %s", txHash)
	return resp, err
}
```

## 參考資料

- [Etherscan APIs documentation](https://docs.etherscan.io/)
