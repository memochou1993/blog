---
title: 使用 Go 建立 Line Notify 推播服務
date: 2020-11-29 21:44:12
tags: ["程式設計", "Go", "Line"]
categories: ["程式設計", "Go", "其他"]
---

## 登陸服務

登入 [LINE Notify](https://notify-bot.line.me/)，並註冊一個服務。

## 流程

1. 設計一個 `auth` 頁，並提供一個按鈕，此按鈕會將使用者導向 LINE Notify 的 OAuth 授權頁面。
2. 使用者同意授權後，Line Notify 會導回指定的 callback URL，並附帶一個 `code`。
3. 程式收到 `code` 後，帶著 `code` 向 Line Notify 申請一個 Access Token。
4. 程式收到 Access Token 後，帶著 Access Token 向 Line Notify API 發送訊息。
5. Line Notify API 收到訊息後，向與服務連動的使用者發送訊息。

## 實作

主程式如下：

```go
package main

import (
	"fmt"
	_ "github.com/joho/godotenv/autoload"
	"github.com/memochou1993/line-notify/app"
	"os"

	"html/template"
	"log"
	"math/rand"
	"net/http"
	"net/url"
)

var (
	clientID     string
	clientSecret string
	callbackURL  string
	token        string
)

func main() {
	clientID = os.Getenv("CLIENT_ID")
	clientSecret = os.Getenv("CLIENT_SECRET")
	callbackURL = os.Getenv("CALLBACK_URL")

	http.HandleFunc("/callback", callbackHandler)
	http.HandleFunc("/notify", notifyHandler)
	http.HandleFunc("/auth", authHandler)

	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", os.Getenv("APP_PORT")), nil))
}

// 接收 LINE Notify 的 code，並向 LINE Notify API 申請 Access Token
func callbackHandler(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		log.Println(err.Error())
	}

	data := url.Values{}
	data.Add("grant_type", "authorization_code")
	data.Add("code", r.Form.Get("code"))
	data.Add("redirect_uri", callbackURL)
	data.Add("client_id", clientID)
	data.Add("client_secret", clientSecret)

	payload, err := app.Call("POST", "https://notify-bot.line.me/oauth/token", data, "")

	if err != nil {
		log.Println(err.Error())
	}

	res := app.Parse(payload)

	token = res.AccessToken

	if _, err := w.Write(payload); err != nil {
		log.Println(err.Error())
	}
}

// 向 LINE Notify API 發送訊息
func notifyHandler(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		log.Println(err.Error())
	}

	data := url.Values{}
	data.Add("message", r.Form.Get("message"))

	payload, err := app.Call("POST", "https://notify-api.line.me/api/notify", data, token)

	if err != nil {
		log.Println(err.Error())
	}

	res := app.Parse(payload)

	token = res.AccessToken

	if _, err := w.Write(payload); err != nil {
		log.Println(err.Error())
	}
}

// 提供導向授權頁面的按鈕
func authHandler(w http.ResponseWriter, r *http.Request) {
	var tmpl = template.Must(template.ParseFiles("templates/auth.html"))

	err := tmpl.Execute(w, struct {
		ClientID    string
		CallbackURL string
		State       int
	}{
		ClientID:    clientID,
		CallbackURL: callbackURL,
		State:       rand.Int(),
	})

	if err != nil {
		log.Println(err.Error())
	}
}
```

新增 `.env` 檔：

```env
APP_PORT=
CLIENT_ID=
CLIENT_SECRET=
CALLBACK_URL=
```

- `CLIENT_ID` 環境變數填入此服務的 `Client ID`。
- `CHANNEL_ACCESS_TOKEN` 環境變數填入此服務的 `Client Secret`。

最後，將專案部署到主機。

## 發送訊息

由於 Access Token 是存在記憶體中，因此在授權後要馬上進行測試。

```bash
curl https://line-notify.xxx.com/notify\?message\=test
```

## 使用存取權杖

若使用個人存取權杖，不須登錄網站服務，即可設定通知。

```bash
curl -H "Authorization: Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -d "message=Hello World" https://notify-api.line.me/api/notify
```

## 程式碼

- [line-notify](https://github.com/memochou1993/line-notify)

## 參考資料

- [如何快速建置一個 LINE Notify 的服務](https://www.evanlin.com/go-line-notify/)
