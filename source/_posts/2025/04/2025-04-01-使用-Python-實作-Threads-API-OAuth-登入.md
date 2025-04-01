---
title: 使用 Python 實作 Threads API OAuth 登入
date: 2025-04-01 00:02:53
tags: ["Programming", "Python", "Meta", "GraphQL", "Threads", "OAuth"]
categories: ["Programming", "Python", "Others"]
---

## 前置作業

首先，前往 [Meta 開發者平台](https://developers.facebook.com/apps)，建立一個應用程式。例如：

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

## 建立專案

建立專案。

```bash
mkdir threads-api-oauth-example
cd threads-api-oauth-example
```

## 建立虛擬環境

建立虛擬環境。

```bash
python -m venv .venv
```

啟動虛擬環境。

```bash
source .venv/bin/activate
```

## 初始化版本控制

建立 `.gitignore` 檔。

```env
.venv/
__pycache__/
.env
```

初始化版本控制。

```bash
git init
```

將所有修改添加到暫存區。

```bash
git add .
```

提交修改。

```bash
git commit -m "Initial commit"
```

指定遠端儲存庫位址。

```bash
git remote add origin git@github.com:memochou1993/threads-api-oauth-example.git
```

推送程式碼到遠端儲存庫。

```bash
git push -u origin main
```

## 安裝 Ruff 格式化工具

新增 `requirements.txt` 檔。

```bash
touch requirements.txt
```

修改 `requirements.txt` 檔，添加 `ruff` 依賴套件。

```txt
ruff
```

安裝依賴套件。

```bash
pip install -r requirements.txt
```

新增 `ruff.toml` 檔。

```toml
line-length = 120
indent-width = 4

[format]
quote-style = "double"
```

新增 `.vscode/settings.json` 檔。

```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": "explicit",
    "source.organizeImports": "explicit"
  },
  "editor.defaultFormatter": "charliermarsh.ruff"
}
```

提交修改。

```bash
git add .
git commit -m "Add ruff dependency"
```

## 實作

修改 `requirements.txt` 檔，添加 `fastapi[standard]` 和 `requests` 依賴套件。

```txt
ruff
fastapi[standard]
requests
dotenv
```

安裝依賴套件。

```bash
pip install -r requirements.txt
```

新增 `.env.example` 檔。

```env
THREADS_API_URL=https://graph.threads.net
THREADS_CLIENT_SECRET=
THREADS_APP_ID=
THREADS_APP_SECRET=
```

新增 `.env` 檔。

```env
THREADS_API_URL=https://graph.threads.net
THREADS_CLIENT_SECRET=your-threads-client-secret
THREADS_APP_ID=your-threads-app-id
THREADS_APP_SECRET=your-threads-app-secret
```

新增 `main.py` 檔。

```py
import os

import requests
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

load_dotenv(override=True)

THREADS_CLIENT_SECRET = os.getenv("THREADS_CLIENT_SECRET")
THREADS_APP_ID = os.getenv("THREADS_APP_ID")
THREADS_APP_SECRET = os.getenv("THREADS_APP_SECRET")
THREADS_API_URL = os.getenv("THREADS_API_URL")

app = FastAPI()

app.mount("/static", StaticFiles(directory="static"), name="static")


@app.get("/auth", response_class=HTMLResponse)
def read_index():
    with open(os.path.join("static", "index.html")) as f:
        return HTMLResponse(content=f.read())


@app.get("/auth/callback", response_class=HTMLResponse)
def read_callback():
    with open(os.path.join("static", "index.html")) as f:
        return HTMLResponse(content=f.read())


@app.get("/")
def read_root():
    return {"Hello": "World"}


class TokenRequest(BaseModel):
    code: str
    redirect_uri: str


@app.post("/access-token")
def get_token(request: TokenRequest):
    payload = {
        "client_id": THREADS_APP_ID,
        "client_secret": THREADS_APP_SECRET,
        "redirect_uri": request.redirect_uri,
        "code": request.code,
        "grant_type": "authorization_code",
    }

    try:
        response = requests.post(f"{THREADS_API_URL}/oauth/access_token", data=payload)
        response.raise_for_status()
        return JSONResponse(content=response.json())
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/long-lived-access-token")
def get_long_lived_token(access_token: str):
    params = {
        "grant_type": "th_exchange_token",
        "client_secret": THREADS_CLIENT_SECRET,
        "access_token": access_token,
    }

    try:
        response = requests.get(f"{THREADS_API_URL}/access_token", params=params)
        response.raise_for_status()
        return JSONResponse(content=response.json())
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=400, detail=str(e))
```

新增 `static/index.html` 檔。

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Threads OAuth</title>
  <link rel="stylesheet" href="/static/app.css">
</head>
<body>
  <h1>Threads OAuth</h1>
  <button onclick="getAccessToken()">Get Access Token</button>
  <button onclick="getLongLivedAccessToken()">Get Long-Lived Access Token</button>
  <div>
    Message: <br>
    <div id="message"></div>
    Access Token: <br>
    <div id="access-token"></div>
    Long-Lived Access Token: <br>
    <div id="long-lived-access-token"></div>
  </div>
  <script src="/static/app.js"></script>
</body>
</html>
```

新增 `app.css` 檔。

```css
div {
  margin: 20px 0;
  word-break: break-all;
}
```

新增 `app.js` 檔。

```js
const THREADS_APP_ID = '9030817430362187';
const THREADS_AUTH_URL = 'https://threads.net/oauth/authorize';

const messageElement = document.getElementById('message');
const accessTokenElement = document.getElementById('access-token');
const longLivedAccessTokenElement = document.getElementById('long-lived-access-token');

const getAccessToken = () => {
  const url = new URL(THREADS_AUTH_URL);

  url.search = new URLSearchParams({
    client_id: THREADS_APP_ID,
    redirect_uri: `${window.location.origin}/auth/callback`,
    scope: 'threads_basic,threads_content_publish',
    response_type: 'code',
  }).toString();

  window.location.href = url.toString();
};

const getLongLivedAccessToken = async () => {
  messageElement.innerText = 'Retrieving long-lived access token...';
  try {
    const response = await fetch(`/long-lived-access-token?access_token=${accessTokenElement.innerText}`);
    const data = await response.json();
    if (data.access_token) {
      longLivedAccessTokenElement.innerText = data.access_token;
    }
    messageElement.innerText = data.detail || 'Retrieved long-lived access token successfully!';
  } catch (error) {
    messageElement.innerText = error.message;
  }
};

window.onload = async () => {
  const urlParams = new URLSearchParams(window.location.search);
  const code = urlParams.get('code');
  if (code) {
    messageElement.innerText = 'Retrieving access token...';
    try {
      const response = await fetch('/access-token', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          code,
          redirect_uri: `${window.location.origin}/auth/callback`,
        }),
      });
      const data = await response.json();
      if (data.access_token) {
        accessTokenElement.innerText = data.access_token;
      }
      messageElement.innerText = data.detail || 'Retrieved access token successfully!';
    } catch (error) {
      messageElement.innerText = error.message;
    }
  }
};
```

啟動伺服器。

```bash
fastapi dev main.py
```

使用 `ngrok` 指令，啟動一個 HTTP 代理伺服器，將本地埠映射到外部網址。

```bash
ngrok http 8000
```

## 設定回呼網址

進到 Meta 開發者平台，進到「自訂使用案例」頁面，點選「設定」頁籤，完成以下設定：

- 重新導向回呼網址：<https://random.ngrok-free.app/auth/callback>

## 測試前端

前往 <https://random.ngrok-free.app/auth> 瀏覽，並點選「Login with Threads」按鈕，完成登入。

## 程式碼

- [threads-api-oauth-example](https://github.com/memochou1993/threads-api-oauth-example)

## 參考資料

- [Meta - Threads API](https://developers.facebook.com/docs/threads)
