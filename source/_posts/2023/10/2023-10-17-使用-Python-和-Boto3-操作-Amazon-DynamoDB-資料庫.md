---
title: 使用 Python 和 Boto3 操作 Amazon DynamoDB 資料庫
date: 2023-10-17 16:23:04
tags: ["Programming", "Python", "Boto3", "ORM", "AWS", "DynamoDB"]
categories: ["Programming", "Python", "Others"]
---

## 建立專案

建立專案。

```bash
mkdir dynamodb-python-example
cd dynamodb-python-example
```

建立虛擬環境。

```bash
pyenv virtualenv 3.11.4 dynamodb-python-example
pyenv local dynamodb-python-example
```

新增 `requirements.txt` 檔。

```txt
boto3
```

安裝依賴套件。

```bash
pip install -r requirements.txt
```

新增 `.gitignore` 檔。

```env
__pycache__/
```

### 查詢

新增 `query.py` 檔。

```py
import boto3

session = boto3.Session()

dynamodb_client = session.client('dynamodb')

table_name = 'MyTable'
term = 'Apple1'

response = dynamodb_client.query(
    TableName=table_name,
    KeyConditionExpression='term = :value',
    ExpressionAttributeValues={
        ':value': {
            'S': term,
        },
    },
)

print(response)
```

執行。

```
AWS_PROFILE=my-profile python3 query.py
```

### 寫入物件

新增 `put_item.py` 檔。

```py
import boto3

session = boto3.Session()

dynamodb_client = session.client('dynamodb')

table_name = 'MyTable'
term = 'Apple0'

response = dynamodb_client.put_item(
    TableName=table_name,
    Item={
        'term': {
            'S': term,
        },
    }
)

print(response)
```

執行。

```
AWS_PROFILE=my-profile python3 put_item.py
```

### 批量寫入物件

新增 `batch_write_item.py` 檔。

```py
import boto3
import time

def batch_write_item(dynamodb_client, table_name, batch_items: list):
    request_items = {
        table_name: batch_items
    }

    response = dynamodb_client.batch_write_item(
        RequestItems=request_items
    )

    max_retries = 5
    retry_count = 0
    backoff = 2
    unprocessed_items = response.get('UnprocessedItems', {})
    while unprocessed_items and retry_count < max_retries:
        response = dynamodb_client.batch_write_item(
            RequestItems=unprocessed_items
        )
        unprocessed_items = response.get('UnprocessedItems', {})

        time.sleep(backoff**retry_count)  # exponential backoff
        retry_count += 1

    failed_items = unprocessed_items.get(table_name, [])

    return dict(
        succeed_count=len(batch_items) - len(failed_items),
        failed_items=failed_items
    )

session = boto3.Session()

dynamodb_client = session.client('dynamodb')

table_name = 'MyTable'

items = [{'term': {'S': 'Apple' + str(i)}} for i in range(1, 100)]

batch_size = 25
batches = [items[i:i + batch_size] for i in range(0, len(items), batch_size)]

succeeded_items = []
failed_items = []

for batch in batches:
    try:
        request_items = [{'PutRequest': {'Item': item}} for item in batch]
        res = batch_write_item(dynamodb_client, table_name, request_items)
        # If there are "failed_items" in the result, consider it a batch failure.
        if res['failed_items']:
            failed_items.extend(batch)
        else:
            succeeded_items.extend(batch)
    except Exception as e:
        print('e', e)
        failed_items.extend(batch)

print('succeeded_items:', succeeded_items)
print('failed_items:', failed_items)
```

執行。

```
AWS_PROFILE=my-profile python3 batch_write_item.py
```

## 程式碼

- [dynamodb-python-example](https://github.com/memochou1993/dynamodb-python-example)

## 參考資料

- [Boto3 - DynamoDB](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb.html)
