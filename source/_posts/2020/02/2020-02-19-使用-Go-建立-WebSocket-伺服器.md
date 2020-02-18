---
title: 使用 Go 建立 WebSocket 伺服器
permalink: 使用-Go-建立-WebSocket-伺服器
date: 2020-02-19 00:26:38
tags: ["程式寫作", "Go", "WebSocket"]
categories: ["程式寫作", "Go"]
---

## 做法

新增 `main.go` 檔。

```BASH
touch main.go
```

在專案目錄底下初始化。

```BASH
go mod init github.com/memochou1993/go-websocket-example
```

下載 `gorilla/websocket` 套件。

```BASH
go get github.com/gorilla/websocket
```

修改 `main.go` 檔：

```GO
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

	conn, err := upgrader.Upgrade(w, r, nil)

	if err != nil {
		log.Println(err.Error())
	}

	log.Println("Connected...")

	render(conn)
}

func render(conn *websocket.Conn) {
	for {
		messageType, p, err := conn.ReadMessage()

		if err != nil {
			log.Println(err.Error())
			return
		}

		log.Println(string(p))

		if err := conn.WriteMessage(messageType, p); err != nil {
			log.Println(err.Error())
			return
		}
	}
}
```

新增 `index.html` 檔：

```HTML
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
    const socket = new WebSocket('ws://localhost:8080');

    console.log('Attempting...');

    socket.onopen = () => {
        console.log('Opening...');
        socket.send('Hi...');
    };

    socket.onclose = (event) => {
        console.log('Closing...', event);
    };

    socket.onmessage = (message) => {
        console.log(message);
    };

    socket.onerror = (error) => {
        console.log('Error: ', error);
    };
    </script>
</body>
</html>
```

## 程式碼

- [GitHub](https://github.com/memochou1993/go-websocket-example)

## 參考資料

- [Go WebSocket Tutorial with the gorilla/websocket Package](https://www.youtube.com/watch?v=dniVs0xKYKk)
