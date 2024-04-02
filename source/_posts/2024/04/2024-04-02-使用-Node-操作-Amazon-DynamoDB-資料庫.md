---
title: 使用 Node 操作 Amazon DynamoDB 資料庫
date: 2024-04-02 14:32:13
tags: ["Programming", "Node", "ORM", "AWS", "DynamoDB"]
categories: ["Programming", "Node", "Others"]
---

## 建立專案

建立專案。

```bash
mkdir dynamodb-node-example
cd dynamodb-node-example
```

初始化專案。

```bash
npm init
```

修改 `package.json` 檔。

```json
{
  "type": "module",
  ...
}
```

安裝依賴套件。

```bash
npm i @aws-sdk/client-dynamodb
```

建立 `examples/create-table.js` 檔。

```js
import { CreateTableCommand, DynamoDBClient } from '@aws-sdk/client-dynamodb';

const client = new DynamoDBClient({
  endpoint: 'http://localhost:8000',
});

export const createTable = async () => {
  const command = new CreateTableCommand({
    TableName: "Drinks",
    AttributeDefinitions: [
      {
        AttributeName: "DrinkName",
        AttributeType: "S",
      },
    ],
    KeySchema: [
      {
        AttributeName: "DrinkName",
        KeyType: "HASH",
      },
    ],
    ProvisionedThroughput: {
      ReadCapacityUnits: 1,
      WriteCapacityUnits: 1,
    },
  });
  const response = await client.send(command);
  return response;
}
```

建立 `examples/list-tables.js` 檔。

```js
import { DynamoDBClient, ListTablesCommand } from '@aws-sdk/client-dynamodb';

const client = new DynamoDBClient({
  endpoint: 'http://localhost:8000',
});

export const listTables = async () => {
  const command = new ListTablesCommand({});
  const response = await client.send(command);
  console.log(response.TableNames.join('\n'));
  return response;
};
```

建立 `examples/delete-table.js` 檔。

```js
import { DeleteTableCommand, DynamoDBClient } from '@aws-sdk/client-dynamodb';

const client = new DynamoDBClient({
  endpoint: 'http://localhost:8000',
});

export const deleteTables = async () => {
  const command = new DeleteTableCommand({
    TableName: "Drinks",
  });
  const response = await client.send(command);
  return response;
};
```

建立 `index.js` 檔。

```js
import { createTable } from './examples/create-table.js';
import { deleteTables } from './examples/delete-table.js';
import { listTables } from './examples/list-tables.js';

await createTable();
await listTables();
await deleteTables();
```

執行腳本。

```bash
aws-vault exec your-profile node index.js
```

輸出如下：

```bash
Drinks
```

## 單元測試

新增 `test/connect-handler.test.ts` 檔。

```js
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';
import { mockClient } from 'aws-sdk-client-mock';
import { handler } from '../lambda/connect-handler';

const ddbMock = mockClient(DynamoDBDocumentClient);

beforeEach(() => {
  ddbMock.reset();
});

test('connect handler', async () => {
  const event = {
    requestContext: {
      connectionId: 'test',
    },
  };
  const result = await handler(event as any, {} as any, {} as any) as any;
  expect(result.statusCode as Number).toEqual(200);
  expect(ddbMock.calls()).toHaveLength(1);
  expect(ddbMock.commandCalls(PutCommand)[0].args[0].input).toEqual({
    TableName: process.env.TABLE_NAME,
    Item: {
      connectionId: 'test',
    },
  });
});
```

新增 `test/disconnect-handler.test.ts` 檔。

```js
import { DeleteCommand, DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';
import { mockClient } from 'aws-sdk-client-mock';
import { handler } from '../lambda/disconnect-handler';

const ddbMock = mockClient(DynamoDBDocumentClient);

beforeEach(() => {
  ddbMock.reset();
});

test('disconnect handler', async () => {
  const event = {
    requestContext: {
      connectionId: 'test',
    },
  };
  const result = await handler(event as any, {} as any, {} as any) as any;
  expect(result.statusCode as Number).toEqual(200);
  expect(ddbMock.calls()).toHaveLength(1);
  expect(ddbMock.commandCalls(DeleteCommand)[0].args[0].input).toEqual({
    TableName: process.env.TABLE_NAME,
    Key: {
      connectionId: 'test',
    },
  });
});
```

執行測試。

```bash
npm run test
```

## 程式碼

- [dynamodb-node-example](https://github.com/memochou1993/dynamodb-node-example)

## 參考資料

- [DynamoDB examples using SDK for JavaScript (v3)](https://docs.aws.amazon.com/sdk-for-javascript/v3/developer-guide/javascript_dynamodb_code_examples.html)
