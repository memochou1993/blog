---
title: 使用 AWS Lambda 和 DynamoDB 建立 REST API 應用程式
date: 2024-02-13 17:36:12
tags: ["Deployment", "AWS", "API Gateway", "Lambda", "DynamoDB", "Serverless"]
categories: ["Cloud Computing Service", "AWS"]
---

## 建立資料表

首先，在 [DynamoDB](https://console.aws.amazon.com/dynamodb/) 建立一個資料表。

- Table name: `http-crud-tutorial-items`
- Partition key: `id`
- 選擇 `On-demand` 模式

## 建立函式

在 [AWS Lambda]( https://console.aws.amazon.com/lambda) 建立一個函式。

- Function name: `http-crud-tutorial-function`
- Runtime: Node.js
- Execution role name: `http-crud-tutorial-role`
- Policy templates: `Simple microservice permissions`

建立範例函式：

```js
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  ScanCommand,
  PutCommand,
  GetCommand,
  DeleteCommand,
} from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});

const dynamo = DynamoDBDocumentClient.from(client);

const tableName = "http-crud-tutorial-items";

export const handler = async (event, context) => {
  let body;
  let statusCode = 200;
  const headers = {
    "Content-Type": "application/json",
  };

  try {
    switch (event.routeKey) {
      case "DELETE /items/{id}":
        await dynamo.send(
          new DeleteCommand({
            TableName: tableName,
            Key: {
              id: event.pathParameters.id,
            },
          })
        );
        body = `Deleted item ${event.pathParameters.id}`;
        break;
      case "GET /items/{id}":
        body = await dynamo.send(
          new GetCommand({
            TableName: tableName,
            Key: {
              id: event.pathParameters.id,
            },
          })
        );
        body = body.Item;
        break;
      case "GET /items":
        body = await dynamo.send(
          new ScanCommand({ TableName: tableName })
        );
        body = body.Items;
        break;
      case "PUT /items":
        let requestJSON = JSON.parse(event.body);
        await dynamo.send(
          new PutCommand({
            TableName: tableName,
            Item: {
              id: requestJSON.id,
              price: requestJSON.price,
              name: requestJSON.name,
            },
          })
        );
        body = `Put item ${requestJSON.id}`;
        break;
      default:
        throw new Error(`Unsupported route: "${event.routeKey}"`);
    }
  } catch (err) {
    statusCode = 400;
    body = err.message;
  } finally {
    body = JSON.stringify(body);
  }

  return {
    statusCode,
    body,
    headers,
  };
};
```

點選 `Deploy` 按鈕。

## 建立 API

到 [API Gateway](https://console.aws.amazon.com/apigateway) 建立一個 REST API。

- API name: `http-crud-tutorial-api`

建立 routes 如下：

- `GET /items/{id}`
- `GET /items`
- `PUT /items`
- `DELETE /items/{id}`

為每個路由建立 integration 如下：

- 選擇路由
- Integration type: `Lambda function`
- Choose an existing integration: `http-crud-tutorial-function`

## 測試

### 新增物件

使用 curl 進行呼叫。

```bash
curl -X "PUT" -H "Content-Type: application/json" -d "{\"id\": \"123\", \"price\": 12345, \"name\": \"myitem\"}" https://xxx.execute-api.ap-northeast-1.amazonaws.com/items
```

回應如下：

```bash
"Put item 123"
```

### 取得物件列表

```bash
curl https://xxx.execute-api.ap-northeast-1.amazonaws.com/items
```

回應如下：

```bash
[{"price":12345,"id":"123","name":"myitem"}]
```

### 取得指定物件

```bash
curl https://xxx.execute-api.ap-northeast-1.amazonaws.com/items/123
```

回應如下：

```bash
{"price":12345,"id":"123","name":"myitem"}
```

### 刪除物件

```bash
curl -X "DELETE" https://xxx.execute-api.ap-northeast-1.amazonaws.com/items/123
```

回應如下：

```bash
"Deleted item 123"
```

## 參考資料

- [Amazon API Gateway - Tutorial: Build a CRUD API with Lambda and DynamoDB](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-dynamo-db.html)
