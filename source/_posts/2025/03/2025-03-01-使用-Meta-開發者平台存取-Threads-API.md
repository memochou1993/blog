---
title: 使用 Python 透過 GraphQL API 發布 Threads 串文
date: 2025-03-01 22:23:39
tags: ["Programming", "Python", "Meta", "GraphQL", "Threads"]
categories: ["Programming", "Python", "Others"]
---

## 前置作業

前往 [Threads API](https://developers.facebook.com/docs/threads/overview) 文件，了解 API 的存取方法以及相關限制。

### 建立應用程式

前往 [Meta 開發者平台](https://developers.facebook.com/apps)，建立一個應用程式。例如：

- 應用程式名稱：`post-bot`
- 新增使用案例：「存取 Threads API」
- 商家：「我還不想連結商家資產管理組合」

完成後，點選「建立應用程式」按鈕。

### 新增測試人員

點選「應用程式角色」頁籤，點選「新增用戶」，點選「Threads 測試人員」，輸入自己的 Threads 帳號用戶名稱，最後點選「新增」。

### 設定 Threads 存取權限

進到 [Threads](https://www.threads.net/) 平台，點選「設定」，點選「帳號」，點選「網站權限」，點選「邀請」，接受來自應用程式 `post-bot` 的存取請求。

## 測試

回到 Meta 開發者平台，點選「測試」頁籤，點選「開啟 GraphQL API 測試工具」按鈕。

將 Meta 應用程式指定為 `post-bot`，點選「Generate Threads Access Token」按鈕，即可取得一個暫時性的存取令牌。

點選提交，響應如下：

```json
{
  "id": "29361808173406421",
  "name": "Memo Chou"
}
```

## 實作

### 取得使用者資訊

使用 GraphQL API 測試工具，設定請求參數：

- HTTP Method：`GET`
- API Endpoint：`graph.threads.net/v1.0/me?fields=id,name`

提交後，響應如下：

```json
{
  "id": "29361808173406421",
  "name": "Memo Chou"
}
```

使用 cURL 測試：

```bash
curl -i -X GET \
 "https://graph.threads.net/v1.0/me?fields=id%2Cname&access_token=your-access-token"
```

使用 Python 腳本測試：

```python
import http.client
import urllib.parse

host = "graph.threads.net"
endpoint = "/v1.0/me"
params = {
  "fields": "id,name",
  "access_token": "your-access-token"
}

url = f"{"/v1.0/me"}?{urllib.parse.urlencode(params)}"

conn = http.client.HTTPSConnection("graph.threads.net")
conn.request("GET", url)

response = conn.getresponse()

body = response.read().decode()
print(body)

conn.close()
```

### 建立貼文草稿

使用 GraphQL API 測試工具，設定請求參數：

- HTTP Method：`POST`
- API Endpoint：`graph.threads.net/v1.0/me/threads`

設定請求內容：

```json
{
  "media_type": "TEXT",
  "text": "Hello"
}
```

提交後，響應如下：

```json
{
  "id": "18050739080235480"
}
```

使用 cURL 測試：

```bash
curl -i -X POST \
  "https://graph.threads.net/v1.0/me/threads?media_type=TEXT&text=Hello&access_token=your-access-token"
```

使用 Python 腳本測試：

```python
import http.client
import json

host = "graph.threads.net"
endpoint = "/v1.0/me/threads"
headers = {"Content-Type": "application/json"}

payload = {
  "media_type": "TEXT",
  "text": "Hello",
  "access_token": "your-access-token"
}

conn = http.client.HTTPSConnection(host)
conn.request("POST", endpoint, body=json.dumps(payload), headers=headers)

response = conn.getresponse()
body = response.read().decode()
print(body)

conn.close()
```

### 發布貼文

使用 GraphQL API 測試工具，設定請求參數：

- HTTP Method：`POST`
- API Endpoint：`graph.threads.net/v1.0/me/threads_publish`

設定請求內容：

```json
{
  "creation_id": "18050739080235480"
}
```

提交後，響應如下：

```json
{
  "id": "18286053724221534"
}
```

使用 cURL 測試：

```bash
curl -i -X POST \
"https://graph.threads.net/v1.0/me/threads_publish?creation_id=18051387608469145&access_token=your-access-token"
```

使用 Python 腳本測試：

```python
import http.client
import json

host = "graph.threads.net"
endpoint = "/v1.0/me/threads_publish"
headers = {"Content-Type": "application/json"}

payload = {
  "creation_id": "your-creation-id",
  "access_token": "your-access-token"
}

conn = http.client.HTTPSConnection(host)
conn.request("POST", endpoint, body=json.dumps(payload), headers=headers)

response = conn.getresponse()
body = response.read().decode()
print(body)

conn.close()
```

## 參考資料

- [Meta - Threads API](https://developers.facebook.com/docs/threads)
