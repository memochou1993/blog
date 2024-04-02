---
title: 在 MacOS 安裝並使用本機版 Amazon DynamoDB 資料庫
date: 2024-04-02 14:06:44
tags: ["Deployment", "AWS", "DynamoDB"]
categories: ["Cloud Computing Service", "AWS"]
---

## 啟動

新增 `docker-compose.yml` 檔。

```yaml
version: '3.8'
services:
 dynamodb-local:
   command: "-jar DynamoDBLocal.jar -sharedDb -dbPath ./data"
   image: "amazon/dynamodb-local:latest"
   container_name: dynamodb-local
   ports:
     - "8000:8000"
   volumes:
     - "./docker/dynamodb:/home/dynamodblocal/data"
   working_dir: /home/dynamodblocal
```

啟動服務。

```bash
docker compose up -d
```

## 連線

使用 SSO 登入。

```bash
aws sso login --profile your-profile
```

列出資料表。

```bash
aws dynamodb list-tables --endpoint-url http://localhost:8000 --profile your-profile
```

## 介面

安裝 DynamoDB Admin 套件。

```bash
npm install -g dynamodb-admin
```

指定端點。

```bash
export DYNAMO_ENDPOINT=http://localhost:8000
```

啟動介面。

```bash
dynamodb-admin
```

前往 <http://localhost:8001> 瀏覽。

## 參考資料

- [Amazon DynamoDB - Setting up DynamoDB local](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html)
