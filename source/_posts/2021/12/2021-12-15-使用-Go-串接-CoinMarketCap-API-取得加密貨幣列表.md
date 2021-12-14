---
title: 使用 Go 串接 CoinMarketCap API 取得加密貨幣列表
permalink: 使用-Go-串接-CoinMarketCap-API-取得加密貨幣列表
date: 2021-12-15 00:10:06
tags: ["程式設計", "Go"]
categories: ["程式設計", "Go", "其他"]
---

## 前置作業

到 [CoinMarketCap](https://coinmarketcap.com/api/) 申請一個 API Key。

## 實作

建立新專案，並啟用 Go module。

```BASH
go mod init github.com/memochou1993/go-coinmarketcap-api-example
```

下載 `joho/godotenv` 套件。

```BASH
go get github.com/joho/godotenv
```

新增 `.env` 檔，將 API Key 填入：

```ENV
COINMARKETCAP_API_KEY=
```

新增 `.gitignore` 檔：

```ENV
.env
```

新增 `main.go` 檔：

```GO
package main

import (
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"time"

	_ "github.com/joho/godotenv/autoload"
)

var (
	API_KEY = os.Getenv("COINMARKETCAP_API_KEY")
)

func main() {
	client := &http.Client{
		Timeout: time.Second * 10,
	}
	req, err := http.NewRequest(http.MethodGet, "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest", nil)
	if err != nil {
		log.Println(err)
		return
	}
	req.Header.Add("X-CMC_PRO_API_KEY", API_KEY)
	resp, err := client.Do(req)
	if err != nil {
		log.Println(err)
		return
	}
	defer resp.Body.Close()
	res, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Println(err)
		return
	}
	log.Println(string(res))
}
```

執行程式。

```BASH
go run main.go
```
