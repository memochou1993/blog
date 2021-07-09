---
title: 使用 Dart 建立 WebSocket 連線
permalink: 使用-Dart-建立-WebSocket-連線
date: 2021-07-09 14:30:08
tags: ["程式設計", "Dart", "WebSocket"]
categories: ["程式設計", "Dart", "其他"]
---

## 伺服端

新增 `server.dart` 檔。

```DART
import 'dart:io' show HttpRequest, HttpServer, WebSocket, WebSocketTransformer;
import 'dart:convert' show json;

void main() {
  // 建立服務
  HttpServer.bind('localhost', 8000).then((HttpServer server) {
    print('WebSocket listening on ws://localhost:8000/');
    server.listen((HttpRequest request) {
      // 升級協定
      WebSocketTransformer.upgrade(request).then((WebSocket ws) {
        ws.listen(
          (data) {
            // 檢查狀態
            if (ws.readyState == WebSocket.open) {
              print('Recieved from client: ${json.decode(data)}');
              // 發送消息
              ws.add(data);
            }
          },
          onDone: () => print('Done'),
          onError: (err) => print(err),
          cancelOnError: true,
        );
      }, onError: (err) => print(err));
    }, onError: (err) => print(err));
  }, onError: (err) => print(err));
}
```

執行。

```BASH
dart server.dart
```

## 客戶端

新增 `client.dart` 檔。

```DART
import 'dart:io' show WebSocket;
import 'dart:convert' show json;
import 'dart:async' show Timer;

main() {
  // 建立連線
  WebSocket.connect('ws://localhost:8000').then((WebSocket ws) {
    // 檢查狀態
    if (ws.readyState == WebSocket.open) {
      // 發送消息
      ws.add(json.encode({
        'data': 'Hello',
      }));
    }
    ws.listen(
      (data) {
        // 檢查狀態
        if (ws.readyState == WebSocket.open) {
          print('Recieved from server: ${json.decode(data)}');
          // 發送消息
          Timer(Duration(seconds: 1), () {
            ws.add(data);
          });
        }
      },
      onDone: () => print('Done'),
      onError: (err) => print(err),
      cancelOnError: true,
    );
  }, onError: (err) => print(err));
}
```

執行。

```BASH
dart client.dart
```

## 程式碼

- [dart-websocket-example](https://github.com/memochou1993/dart-websocket-example)

## 參考資料

- [Working with WebSocket](https://dev.to/itzmeanjan/working-with-websocket-10gh)
