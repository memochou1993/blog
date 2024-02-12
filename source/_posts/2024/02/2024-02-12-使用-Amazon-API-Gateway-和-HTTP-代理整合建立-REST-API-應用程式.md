---
title: 使用 Amazon API Gateway 和 HTTP 代理整合建立 REST API 應用程式
date: 2024-02-12 22:02:21
tags: ["Deployment", "AWS", "API Gateway", "Serverless"]
categories: ["Cloud Computing Service", "AWS"]
---

## 建立 API

到 [API Gateway](https://console.aws.amazon.com/apigateway) 建立一個 REST API。

- API name: `HTTPProxyAPI`

建立 resource 如下：

- Resource path: `/`
- Resource name: `{proxy+}`

建立 method 如下：

- Method type: `ANY`
- 啟用 `HTTP proxy integration` 功能
- Endpoint URL: http://petstore-demo-endpoint.execute-api.com/{proxy}

## 部署

點選 Deploy API 按鈕，並建立 stage 如下：

- Stage name: `test`

## 測試

點選 `Test` 頁籤，進行測試：

- Method type: `GET`
- Path: `petstore/pets`
- Query strings: `type=fish`

點選 `Test` 按鈕。

或使用 curl 測試。

```bash
curl -X GET 'https://xxx.execute-api.ap-northeast-1.amazonaws.com/test/petstore/pets'
```

回應如下：

```bash
[
  {
    "id": 1,
    "type": "fish",
    "price": 249.99
  },
  {
    "id": 2,
    "type": "fish",
    "price": 124.99
  },
  {
    "id": 3,
    "type": "fish",
    "price": 0.99
  }
]
```

## 參考資料

- [Amazon API Gateway - Tutorial: Build a REST API with HTTP proxy integration](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-api-as-simple-proxy-for-http.html)
