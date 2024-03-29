---
title: 使用 Go 建立 WebSocket 伺服器
date: 2020-02-19 00:26:38
tags: ["Programming", "Go", "WebSocket"]
categories: ["Programming", "Go", "Others"]
---

## 做法

建立專案。

```bash
mkdir go-websocket-example
cd go-websocket-example
```

新增 `main.go` 檔。

```bash
touch main.go
```

初始化 Go Modules。

```bash
go mod init github.com/memochou1993/go-websocket-example
```

下載 `gorilla/websocket` 套件。

```bash
go get github.com/gorilla/websocket
```

修改 `main.go` 檔：

```go
package main

import (
	"log"
	"net/http"

	"github.com/gorilla/websocket"
)

var (
	upgrader = websocket.Upgrader{
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
	}
)

func main() {
	http.HandleFunc("/", index)

	log.Fatal(http.ListenAndServe(":8080", nil))
}

func index(w http.ResponseWriter, r *http.Request) {
	upgrader.CheckOrigin = func(r *http.Request) bool {
		return true
	}

	// 伺服端接受客戶端連線的接口
	conn, err := upgrader.Upgrade(w, r, nil)

	if err != nil {
		log.Println(err.Error())
	}

	log.Println("Connected...")

	handle(conn)
}

func handle(conn *websocket.Conn) {
	for {
		// ReadMessage() 方法是一個輔助函式，其內部調用 NextReader() 方法
		messageType, p, err := conn.ReadMessage()

		if err != nil {
			log.Println(err.Error())
			return
		}

		log.Println(string(p))

		// WriteMessage() 方法是一個輔助函式，其內部調用 NextWriter() 方法
		if err := conn.WriteMessage(messageType, p); err != nil {
			log.Println(err.Error())
			return
		}
	}
}
```

新增 `index.html` 檔：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Document</title>
</head>
<body>
    <script>
    // 建立 WebSocket 實例
    const socket = new WebSocket('ws://localhost:8080');

    console.log('Attempting Connection...');

    // 當 WebSocket 連線的 readyState 切換至 OPEN 時呼叫的事件監聽器，表示連線已準備傳送、接收資料
    socket.onopen = (event) => {
        console.log('Connection Opened...', event);
        socket.send('Hi...');
    };

    // 當 WebSocket 連線的 readyState 切換至 CLOSED 時呼叫的事件監聽器
    socket.onclose = (event) => {
        console.log('Connection Closed...', event);
    };

    // 當瀏覽器接收伺服器的訊息時呼叫的事件監聽器
    socket.onmessage = (message) => {
        console.log(message);
    };

    // 當錯誤發生時呼叫的事件監聽器
    socket.onerror = (error) => {
        console.log('Connection Error: ', error);
    };
    </script>
</body>
</html>
```

## 程式碼

- [go-websocket-example](https://github.com/memochou1993/go-websocket-example)

## 參考資料

- [Go WebSocket Tutorial with the gorilla/websocket Package](https://www.youtube.com/watch?v=dniVs0xKYKk)
- [WebSocket](https://developer.mozilla.org/zh-TW/docs/WebSockets/WebSockets_reference/WebSocket)
- [WebSocket Go](https://blog.piasy.com/2018/06/10/WebSocket-Go/index.html)
- [Gorilla web toolkit - WebSocket](https://www.gorillatoolkit.org/pkg/websocket)
