---
title: 使用 Node.js 建立 gRPC 服務端與客戶端
date: 2022-11-01 22:54:57
tags: ["Programming", "JavaScript", "Node.js", "gRPC", "RPC"]
categories: ["Programming", "JavaScript", "Node.js"]
---

## 前言

gRPC 是 Google 發起的一個高效能的、開源的遠端程序呼叫（Remote Procedure Call）框架。此框架基於 HTTP/2 協定傳輸，使用 Protocol Buffers 作為介面描述語言。

一個簡單的 Protocol Buffers 語法如下：

```proto
message Person {
  required string name = 1;
  required int32 id = 2;
  optional string email = 3;
}
```

## 做法

建立專案。

```bash
mkdir grpc-node-example
cd grpc-node-example
```

初始化專案。

```bash
npm init -y
```

### 安裝套件

安裝依賴套件。

```bash
npm install @grpc/grpc-js @grpc/proto-loader
```

### 定義服務

建立 `src/service.proto` 檔。

```proto
syntax = "proto3";

service UserService {
    rpc GetUser (Empty) returns (User) {}
}

message Empty {}

message User {
    string name = 1;
    int32 age = 2;
}
```

### 實作服務端

建立 `src/server.js` 檔。

```js
const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');

const PROTO_FILE = './service.proto';

const options = {
  keepCase: true,
  longs: String,
  enums: String,
  defaults: true,
  oneofs: true,
};

const packageDefinition = protoLoader.loadSync(PROTO_FILE, options);

const { UserService } = grpc.loadPackageDefinition(packageDefinition);

const server = new grpc.Server();

server.addService(UserService.service, {
  GetUser: (input, callback) => {
    try {
      callback(null, { name: 'Memo Chou', age: 18 });
    } catch (error) {
      callback(error, null);
    }
  },
});

server.bindAsync('localhost:5000', grpc.ServerCredentials.createInsecure(), (error, port) => {
  if (error) {
    console.log(error);
    return;
  }
  server.start();
});
```

使用終端機執行服務端程式：

```bash
cd src
node server.js
```

### 實作客戶端

建立 `src/client.js` 檔。

```js
const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');

const PROTO_FILE = './service.proto';

const options = {
  keepCase: true,
  longs: String,
  enums: String,
  defaults: true,
  oneofs: true,
};

const packageDefinition = protoLoader.loadSync(PROTO_FILE, options);

const { UserService } = grpc.loadPackageDefinition(packageDefinition);

const client = new UserService(
  'localhost:5000',
  grpc.credentials.createInsecure(),
);

client.GetUser({}, (error, user) => {
  if (error) {
    console.log(error);
    return;
  }
  console.log(user);
});
```

使用終端機執行客戶端程式：

```bash
cd src
node client.js
{ name: 'Memo Chou', age: 18 }
```

## 程式碼

- [grpc-node-example](https://github.com/memochou1993/grpc-node-example)

## 參考資料

- [How to Create an API Using gRPC and Node.js](https://nordicapis.com/how-to-create-an-api-using-grpc-and-node-js/)
