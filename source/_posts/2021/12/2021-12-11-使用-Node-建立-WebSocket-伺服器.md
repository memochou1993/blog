---
title: 使用 Node 建立 WebSocket 伺服器
date: 2021-12-11 19:52:31
tags: ["程式設計", "JavaScript", "Node", "WebSocket"]
categories: ["程式設計", "JavaScript", "Node"]
---

## 做法

初始化專案。

```bash
npm init
```

安裝 `ws` 依賴套件。

```bash
npm install ws
```

新增 `main.js` 檔：

```js
const { WebSocketServer } = require('ws');

const wss = new WebSocketServer({ port: 8080 });

wss.on('connection', (ws) => {
  ws.on('message', (msg) => {
    console.log('received: %s', msg);
  });

  ws.send('Hello, world!');
});
```

在瀏覽器的 Console 進行測試：

```js
var ws = new WebSocket('ws://localhost:8080')
ws.onmessage = (e) => console.log('received:', e.data)
```

客戶端在 WebSocket 建立連線後，會馬上收到訊息：

```bash
received: Hello, world!
```

客戶端可以使用 `send()` 方法發送訊息：

```js
ws.send('Hi!')
```

服務端會馬上收到訊息：

```bash
received: Hi!
```

## 程式碼

- [node-websocket-example](https://github.com/memochou1993/node-websocket-example)

## 參考資料

- [websockets/ws](https://github.com/websockets/ws)
