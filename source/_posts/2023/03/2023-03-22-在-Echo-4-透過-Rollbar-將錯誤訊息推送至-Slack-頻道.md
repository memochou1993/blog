---
title: 在 Echo 4 透過 Rollbar 將錯誤訊息推送至 Slack 頻道
date: 2023-03-22 17:13:38
tags: ["Programming", "Go", "Echo", "Rollbar"]
categories: ["Programming", "Go", "Echo"]
---

## 前置作業

1. 註冊 Rollbar 後，新增專案。
2. 在專案頁面，點選「Add to Slack」按鈕，取得管理員授權。
3. 將 Rollbar 機器人加入至頻道中。
4. 在 Notifications 頁面，啟用 Slack 通知，並設定頻道名稱。
5. 設定推送條件。

## 實作

建立專案。

```bash
mkdir go-rollbar-example
cd go-rollbar-example
```

初始化 Go Modules。

```bash
go mod init github.com/memochou1993/go-rollbar-example
```

安裝依賴套件。

```bash
go get github.com/labstack/echo/v4
go get github.com/labstack/echo/v4/middleware
go get github.com/joho/godotenv/autoload
go get github.com/rollbar/rollbar-go
```

新增 `.env` 檔。

```env
ROLLBAR_TOKEN=
```

新增 `.gitignore` 檔。

```bash
.env
```

新增 `logger/logger.go` 檔。

```go
package logger

import (
	"log"
	"os"

	"github.com/rollbar/rollbar-go"
)

func InitRollbar() {
	rollbar.SetToken(os.Getenv("ROLLBAR_TOKEN"))
	rollbar.SetEnvironment(os.Getenv("APP_ENV"))
}

func Error(message string) {
	log.Println(message)
	if os.Getenv("ROLLBAR_TOKEN") != "" {
		go rollbar.Error(message)
	}
}
```

```go
package main

import (
	"fmt"
	"os"

	_ "github.com/joho/godotenv/autoload"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/memochou1993/go-rollbar-example/logger"
)

func init() {
	logger.InitRollbar()
}

func main() {
	r := echo.New()
	r.Use(middleware.RecoverWithConfig(middleware.RecoverConfig{
		LogErrorFunc: func(c echo.Context, err error, stack []byte) error {
			go logger.Error(err.Error())
			return err
		},
	}))

	logger.Error("Hello")

	r.Logger.Fatal(r.Start(fmt.Sprintf(":%s", os.Getenv("APP_PORT"))))
}
```

## 程式碼

- [go-rollbar-example](https://github.com/memochou1993/go-rollbar-example)

## 參考文件

- [Rollbar - Slack](https://docs.rollbar.com/docs/slack)
