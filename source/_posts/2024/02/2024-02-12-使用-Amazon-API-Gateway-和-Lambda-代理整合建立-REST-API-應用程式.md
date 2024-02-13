---
title: 使用 Amazon API Gateway 和 Lambda 代理整合建立 REST API 應用程式
date: 2024-02-12 21:42:28
tags: ["Deployment", "AWS", "API Gateway", "Lambda", "Serverless"]
categories: ["Cloud Computing Service", "AWS"]
---

## 建立函式

首先，在 [AWS Lambda]( https://console.aws.amazon.com/lambda) 建立一個函式。

- Function name: `GetStartedLambdaProxyIntegration`
- Runtime: Node.js
- Execution role name: `GetStartedLambdaBasicExecutionRole`

建立範例函式：

```js
export const handler = function(event, context, callback) {
    console.log('Received event:', JSON.stringify(event, null, 2));
    var res ={
        "statusCode": 200,
        "headers": {
            "Content-Type": "*/*"
        }
    };
    var greeter = 'World';
    if (event.greeter && event.greeter!=="") {
        greeter =  event.greeter;
    } else if (event.body && event.body !== "") {
        var body = JSON.parse(event.body);
        if (body.greeter && body.greeter !== "") {
            greeter = body.greeter;
        }
    } else if (event.queryStringParameters && event.queryStringParameters.greeter && event.queryStringParameters.greeter !== "") {
        greeter = event.queryStringParameters.greeter;
    } else if (event.multiValueHeaders && event.multiValueHeaders.greeter && event.multiValueHeaders.greeter != "") {
        greeter = event.multiValueHeaders.greeter.join(" and ");
    } else if (event.headers && event.headers.greeter && event.headers.greeter != "") {
        greeter = event.headers.greeter;
    } 
    
    res.body = "Hello, " + greeter + "!";
    callback(null, res);
};
```

點選 `Deploy` 按鈕。

## 建立 API

到 [API Gateway](https://console.aws.amazon.com/apigateway) 建立一個 REST API。

- API name: `LambdaProxyAPI`

建立 resource 如下：

- Resource path: `/`
- Resource name: `helloworld`

建立 method 如下：

- Method type: `ANY`
- 啟用 `Lambda proxy integration` 功能

## 部署

點選 Deploy API 按鈕，並建立 stage 如下：

- Stage name: `test`

## 測試

使用 curl 測試。

```bash
curl -X GET 'https://xxx.execute-api.ap-northeast-1.amazonaws.com/test/helloworld?greeter=Memo'
```

回應如下：

```bash
Hello, Memo!
```

## 參考資料

- [Amazon API Gateway - Tutorial: Build a Hello World REST API with Lambda proxy integration](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-api-as-simple-proxy-for-lambda.html)
