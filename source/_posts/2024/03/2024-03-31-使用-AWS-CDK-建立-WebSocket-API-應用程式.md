---
title: 使用 AWS CDK 和 Node 建立 WebSocket API 應用程式
date: 2024-03-31 15:58:07
tags: ["Deployment", "AWS", "CDK", "Lambda", "Serverless", "IaC", "Node", "WebSocket"]
categories: ["Cloud Computing Service", "AWS"]
---

## 建立專案

建立專案。

```bash
mkdir polly-api
cd polly-api
```

初始化專案。

```bash
cdk init app --language typescript
```

安裝依賴套件。

```bash
npm i aws-sdk
npm i -D @types/aws-sdk @types/aws-lambda
```

## 建立函式

建立 `lambda` 資料夾。

```bash
mkdir lambda
```

建立 `lambda/connect-handler.ts` 檔，處理建立連線的行為。

```ts
import { APIGatewayProxyWebsocketHandlerV2 } from 'aws-lambda';
import * as AWS from 'aws-sdk';

const ddb = new AWS.DynamoDB.DocumentClient();

export const handler: APIGatewayProxyWebsocketHandlerV2 = async (event) => {
  return await ddb
    .put({
      TableName: process.env.TABLE_NAME as string,
      Item: {
        connectionId: event.requestContext.connectionId,
      },
    })
    .promise()
    .then(() => ({
      statusCode: 200,
    }))
    .catch((e) => {
      console.error(e);
      return {
        statusCode: 500,
      };
    });
};
```

建立 `lambda/disconnect-handler.ts` 檔，處理斷開連線的行為。

```ts
import { APIGatewayProxyWebsocketHandlerV2 } from 'aws-lambda';
import * as AWS from 'aws-sdk';

const ddb = new AWS.DynamoDB.DocumentClient();

export const handler: APIGatewayProxyWebsocketHandlerV2 = async (event) => {
  return await ddb
    .delete({
      TableName: process.env.TABLE_NAME as string,
      Key: {
        connectionId: event.requestContext.connectionId,
      },
    })
    .promise()
    .then(() => ({
      statusCode: 200,
    }))
    .catch((e) => {
      console.log(e);
      return {
        statusCode: 500,
      };
    });
};
```

建立 `lambda/default-handler.ts` 檔，處理預設路由的行為。

```ts
import { APIGatewayProxyWebsocketHandlerV2 } from 'aws-lambda';
import * as AWS from 'aws-sdk';

export const handler: APIGatewayProxyWebsocketHandlerV2 = async (event) => {
  let connectionId = event.requestContext.connectionId;

  const callbackAPI = new AWS.ApiGatewayManagementApi({
    apiVersion: '2018-11-29',
    endpoint: event.requestContext.domainName + '/' + event.requestContext.stage,
  });

  let connectionInfo: AWS.ApiGatewayManagementApi.GetConnectionResponse;
  try {
    connectionInfo = await callbackAPI
      .getConnection({
        ConnectionId: event.requestContext.connectionId,
      })
      .promise();
  } catch (e) {
    console.log(e);
  }

  const info = {
    ...connectionInfo!,
    connectionId,
  };
  await callbackAPI.postToConnection({
    ConnectionId: event.requestContext.connectionId,
    Data: `Use the send-message route to send a message. Your info: ${JSON.stringify(info)}`,
  }).promise();

  return {
    statusCode: 200,
  };
};
```

建立 `lambda/send-handler.ts` 檔，處理傳送訊息的行為。

```ts
import { APIGatewayProxyWebsocketHandlerV2 } from 'aws-lambda';
import * as AWS from 'aws-sdk';

const ddb = new AWS.DynamoDB.DocumentClient();

export const handler: APIGatewayProxyWebsocketHandlerV2 = async (event) => {
  let connections;
  try {
    connections = (
      await ddb
        .scan({ TableName: process.env.TABLE_NAME as string })
        .promise()
    ).Items as { connectionId: string }[];
  } catch (err) {
    return {
      statusCode: 500,
    };
  }

  const callbackAPI = new AWS.ApiGatewayManagementApi({
    apiVersion: '2018-11-29',
    endpoint: event.requestContext.domainName + '/' + event.requestContext.stage,
  });

  const message = JSON.parse(event.body ?? '{}').message;

  const requests = connections.map(async ({ connectionId }) => {
    if (connectionId === event.requestContext.connectionId) return;

    await callbackAPI
      .postToConnection({ ConnectionId: connectionId, Data: message })
      .promise()
      .catch(e => console.error(e));
  });

  return await Promise
    .all(requests)
    .then(() => ({
      statusCode: 200,
    }))
    .catch((e) => {
      console.error(e);
      return {
        statusCode: 500,
      };
    });
};
```

## 建立堆疊

修改 `lib/polly-api-stack.ts` 檔。

```js
import * as cdk from 'aws-cdk-lib';
import { WebSocketApi, WebSocketStage } from 'aws-cdk-lib/aws-apigatewayv2';
import { WebSocketLambdaIntegration } from 'aws-cdk-lib/aws-apigatewayv2-integrations';
import { BillingMode, Table } from 'aws-cdk-lib/aws-dynamodb';
import { Architecture, Runtime } from 'aws-cdk-lib/aws-lambda';
import { Construct } from 'constructs';

export class PollyApiStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // 創建一個 DynamoDB 表格來存儲 WebSocket 連線的資訊
    const table = new cdk.aws_dynamodb.Table(this, 'ConnectionTable', {
      billingMode: BillingMode.PAY_PER_REQUEST,
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      partitionKey: {
        name: 'connectionId',
        type: cdk.aws_dynamodb.AttributeType.STRING,
      },
    });

    // 使用自定義方法建立處理 WebSocket 建立連線、斷開連線、發送訊息和預設行為的 Lambda 函數
    const connectHandler = this.connectHandlerBuilder(table);
    const disconnectHandler = this.disconnectHandlerBuilder(table);
    const sendMessageHandler = this.sendMessageHandlerBuilder(table);
    const defaultHandler = this.defaultHandlerBuilder();

    // 創建 WebSocket API 並設定路由選擇表達式和各路由的 Lambda 集成
    const webSocketApi = new WebSocketApi(this, 'PollyWebSocketApi', {
      // 路由選擇表達式
      routeSelectionExpression: '$request.body.action',
      // 建立連線時的路由選項
      connectRouteOptions: {
        integration: new WebSocketLambdaIntegration('ConnectIntegration', connectHandler),
      },
      // 斷開連線時的路由選項
      disconnectRouteOptions: {
        integration: new WebSocketLambdaIntegration('DisconnectIntegration', disconnectHandler),
      },
      // 預設行為的路由選項
      defaultRouteOptions: {
        integration: new WebSocketLambdaIntegration('DefaultIntegration', defaultHandler),
      },
    });

    // 為發送訊息添加專用路由
    webSocketApi.addRoute('send-message', {
      integration: new WebSocketLambdaIntegration('SendMessageIntegration', sendMessageHandler),
    });
    // 賦予發送訊息和預設行為的處理器管理 WebSocket 連線的權限
    webSocketApi.grantManageConnections(sendMessageHandler);
    webSocketApi.grantManageConnections(defaultHandler);

    // 創建 WebSocket API 的一個階段並自動部署
    new WebSocketStage(this, 'PollyProductionStage', {
      webSocketApi,
      stageName: 'production',
      autoDeploy: true,
    });
  }

  // 定義一個方法來構建處理 WebSocket 建立連線的 Lambda 函數
  connectHandlerBuilder(table: Table) {
    const handler = new cdk.aws_lambda_nodejs.NodejsFunction(this, 'ConnectHandler', {
      environment: {
        TABLE_NAME: table.tableName,
      },
      architecture: Architecture.ARM_64,
      runtime: Runtime.NODEJS_20_X,
      entry: 'lambda/connect-handler.ts',
    });

    // 賦予 Lambda 函數寫入 DynamoDB 表的權限
    table.grantWriteData(handler);

    return handler;
  }

  // 定義一個方法來構建處理 WebSocket 斷開連線的 Lambda 函數
  disconnectHandlerBuilder(table: Table) {
    const handler = new cdk.aws_lambda_nodejs.NodejsFunction(this, 'DisconnectHandler', {
      environment: {
        TABLE_NAME: table.tableName,
      },
      architecture: Architecture.ARM_64,
      runtime: Runtime.NODEJS_20_X,
      entry: 'lambda/disconnect-handler.ts',
    });

    // 賦予 Lambda 函數寫入 DynamoDB 表的權限
    table.grantWriteData(handler);

    return handler;
  }

  // 定義一個方法來構建處理發送 WebSocket 訊息的 Lambda 函數
  sendMessageHandlerBuilder(table: Table) {
    const handler = new cdk.aws_lambda_nodejs.NodejsFunction(this, 'SendMessageHandler', {
      environment: {
        TABLE_NAME: table.tableName,
      },
      architecture: Architecture.ARM_64,
      runtime: Runtime.NODEJS_20_X,
      entry: 'lambda/send-handler.ts',
    });

    // 賦予 Lambda 函數讀寫 DynamoDB 表的權限
    table.grantReadWriteData(handler);

    return handler;
  }

  // 定義一個方法來構建處理 WebSocket 預設行為的 Lambda 函數
  defaultHandlerBuilder() {
    return new cdk.aws_lambda_nodejs.NodejsFunction(this, 'DefaultHandler', {
      architecture: Architecture.ARM_64,
      runtime: Runtime.NODEJS_20_X,
      entry: 'lambda/default-handler.ts',
    });
  }
}
```

列出所有堆疊。

```bash
cdk ls
```

查看堆疊變化。

```bash
aws-vault exec your-profile -- cdk diff
```

## 部署

啟動初始化程序。

```bash
aws-vault exec your-profile -- cdk bootstrap
```

部署應用程式。

```bash
aws-vault exec your-profile -- cdk deploy
```

如果要清理的話，移除應用程式。

```bash
aws-vault exec your-profile -- cdk destroy
```

## 測試

安裝 `wscat` 指令。

```bash
npm i -g wscat
```

開啟終端機，建立連線。

```bash
wscat -c wss://xxx.execute-api.ap-northeast-1.amazonaws.com/prod
```

開啟另一個終端機，建立連線。

```bash
wscat -c wss://xxx.execute-api.ap-northeast-1.amazonaws.com/prod
```

發送訊息：

```bash
> {"action": "send-message", "message": "hello, everyone!"}
```

接收訊息：

```bash
< hello, everyone!
```

## 程式碼

- [polly-api](https://github.com/memochou1993/polly-api)

## 參考資料

- [AWS CDKでWebSocketを使ったサーバーレスチャットアプリを作る](https://www.fourier.jp/techblog/articles/building-chat-app-with-websocket-api-using-aws-cdk/)
