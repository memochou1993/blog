---
title: 使用 AWS Lambda 和 DynamoDB 建立 WebSocket API 無伺服器應用程式
date: 2024-02-13 21:33:58
tags: ["Deployment", "AWS", "API Gateway", "Lambda", "DynamoDB", "Serverless", "WebSocket"]
categories: ["Cloud Computing Service", "AWS"]
---

## 建立函式和資料表

首先，下載 [CloudFormation template](https://docs.aws.amazon.com/apigateway/latest/developerguide/samples/ws-chat-app-starter.zip) 範例檔案。

到 [CloudFormation](https://console.aws.amazon.com/cloudformation) 建立堆疊：

- 選擇 `With new resources` 選項
- 上傳樣板
- Stack name: `websocket-api-chat-app-tutorial`

此堆疊會建立 Lambda 函式和 DynamoDB 資料表。

## 建立 API

到 [API Gateway](https://console.aws.amazon.com/apigateway) 建立一個 WebSocket API。

- API name: `websocket-chat-app-tutorial`
- Route selection expression: `request.body.action`
- 選擇 `Add $connect`、`Add $disconnect`、`Add $default` 選項
- 選擇 `Add custom route` 選項
  - Route key: `sendmessage`

為每個路由建立 integration 並配對 Lambda 函式。

點選 `Create and deploy` 按鈕。

## 測試

安裝 `wscat` 指令。

```bash
npm i -g wscat
```

開啟終端機，建立連線。

```bash
wscat -c wss://xxx.execute-api.ap-northeast-1.amazonaws.com/production
```

開啟另一個終端機，建立連線。

```bash
wscat -c wss://xxx.execute-api.ap-northeast-1.amazonaws.com/production
```

發送訊息：

```bash
> {"action": "sendmessage", "message": "hello, everyone!"}
```

接收訊息：

```bash
< hello, everyone!
```

## 參考資料

- [Amazon API Gateway - Tutorial: Building a serverless chat app with a WebSocket API, Lambda and DynamoDB](https://docs.aws.amazon.com/apigateway/latest/developerguide/websocket-api-chat-app.html)
