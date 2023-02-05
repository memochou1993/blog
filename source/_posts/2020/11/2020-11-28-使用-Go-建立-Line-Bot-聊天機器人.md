---
title: 使用 Go 建立 Line Bot 聊天機器人
date: 2020-11-28 22:34:33
tags: ["程式設計", "Go", "Line"]
categories: ["程式設計", "Go", "其他"]
---

## 建立頻道

首先，登入 [LINE Developers](https://developers.line.biz/) 頁面，選擇 [Messaging API](https://developers.line.biz/en/services/messaging-api/) 產品，建立一個 Channel。

## 建立專案

建立專案。

```bash
mkdir line-bot-go
cd line-bot-go
```

啟用 Go Modules。

```bash
go mod init
```

下載 `linebot` 套件。

```bash
go get github.com/line/line-bot-sdk-go/linebot
```

新增 `main.go` 檔：

```go
package main

import (
	_ "github.com/joho/godotenv/autoload"
	"github.com/line/line-bot-sdk-go/linebot"
	"log"
	"net/http"
	"os"
)

var (
	client *linebot.Client
	err    error
)

func main() {
	// 建立客戶端
	client, err = linebot.New(os.Getenv("CHANNEL_SECRET"), os.Getenv("CHANNEL_ACCESS_TOKEN"))

	if err != nil {
		log.Println(err.Error())
	}

	http.HandleFunc("/callback", callbackHandler)

	log.Fatal(http.ListenAndServe(":84", nil))
}

func callbackHandler(w http.ResponseWriter, r *http.Request) {
	// 接收請求
	events, err := client.ParseRequest(r)

	if err != nil {
		if err == linebot.ErrInvalidSignature {
			w.WriteHeader(400)
		} else {
			w.WriteHeader(500)
		}

		return
	}

	for _, event := range events {
		if event.Type == linebot.EventTypeMessage {
			switch message := event.Message.(type) {
			case *linebot.TextMessage:
				// 回覆訊息
				if _, err = client.ReplyMessage(event.ReplyToken, linebot.NewTextMessage(message.Text)).Do(); err != nil {
					log.Println(err.Error())
				}
			}
		}
	}
}
```

新增 `.env` 檔：

```env
CHANNEL_SECRET=
CHANNEL_ACCESS_TOKEN=
```

- `CHANNEL_SECRET` 環境變數填入 `Basic settings` 頁面的 `Channel secret`。
- `CHANNEL_ACCESS_TOKEN` 環境變數填入 `Messaging API` 頁面的 `Channel access token`。

最後，將專案部署到主機。

## 設定

1. 進到「Messaging API」頁面，設置應用程式的「Webhook URL」。

```env
https://line-bot-go.xxx.com/callback
```

2. 點選「Verify」按鈕。

3. 將「Use webhook」功能開啟。

4. 將「Auto-reply messages」和「Greeting messages」功能關閉。

## 聊天

進到「主頁」，點選「加入好友」，使用行動條碼加入好友。

## 程式碼

- [line-bot-go](https://github.com/memochou1993/line-bot-go)

## 參考資料

- [在 Heroku 建立你自己的 LINE 機器人](http://www.evanlin.com/create-your-line-bot-golang/)
