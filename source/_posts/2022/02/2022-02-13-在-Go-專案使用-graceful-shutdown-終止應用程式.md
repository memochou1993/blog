---
title: 在 Go 專案使用 graceful shutdown 終止應用程式
permalink: 在-Go-專案使用-graceful-shutdown-終止應用程式
date: 2022-02-13 21:44:37
tags: ["程式設計", "Go"]
categories: ["程式設計", "Go", "其他"]
---

## 做法

新增 `main.go` 檔：

```GO
package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
)

func main() {
	var srv http.Server
	// 建立一個結束服務的通道
	quit := make(chan struct{})
	go func() {
		// 建立一個終止訊號的通道
		signals := make(chan os.Signal, 1)
		// 接收一個終止訊號
		signal.Notify(signals, os.Interrupt)
		// 阻塞，等待終止訊號的通道被填充
		<-signals
		// 結束服務
		log.Println("Shutting down server...")
		if err := srv.Shutdown(context.Background()); err != nil {
			log.Println(err)
		}
		// 關閉結束服務的通道
		close(quit)
	}()
	// 阻塞，等待服務被結束
	if err := srv.ListenAndServe(); err != http.ErrServerClosed {
		log.Println(err)
	}
	// 阻塞，等待結束服務的通道被關閉
	<-quit
}
```

## 參考資料

- [Go - net/http](https://pkg.go.dev/net/http#Server.Shutdown)
