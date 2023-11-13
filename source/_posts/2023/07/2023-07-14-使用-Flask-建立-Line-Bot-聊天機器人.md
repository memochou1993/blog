---
title: 使用 Flask 建立 Line Bot 聊天機器人
date: 2023-07-14 00:07:11
tags: ["Programming", "Python", "Flask", "LINE", "chatbot"]
categories: ["Programming", "Python", "Flask"]
---

## 建立專案

建立專案。

```bash
mkdir flask-line-bot
cd flask-line-bot
```

建立環境。

```bash
pyenv virtualenv 3.11.4 flask-line-bot
pyenv local flask-line-bot
```

## 建立頻道

登入 [LINE Developers](https://developers.line.biz/) 頁面，選擇 [Messaging API](https://developers.line.biz/en/services/messaging-api/) 產品，建立一個 Channel。

## 實作

新增 `.gitignore` 檔。

```env
__pycache__
.vscode
.vercel
.env
```

新增 `requirements.txt` 檔

```txt
Flask==2.2.2
line-bot-sdk
python-dotenv
```

安裝依賴套件。

```bash
pip install -r requirements.txt
```

新增 `.env` 檔。

```env
LINE_CHANNEL_ACCESS_TOKEN=
LINE_CHANNEL_SECRET=
```

新增 `api/index.py` 檔。

```py
from flask import Flask, request, abort
from dotenv import load_dotenv
from linebot.v3 import (
    WebhookHandler
)
from linebot.v3.exceptions import (
    InvalidSignatureError
)
from linebot.v3.messaging import (
    Configuration,
    ApiClient,
    MessagingApi,
    ReplyMessageRequest,
    TextMessage
)
from linebot.v3.webhooks import (
    MessageEvent,
    TextMessageContent
)

import os

load_dotenv()

app = Flask(__name__)

configuration = Configuration(access_token=os.getenv('LINE_CHANNEL_ACCESS_TOKEN'))
webhook_handler = WebhookHandler(os.getenv('LINE_CHANNEL_SECRET'))

@app.route('/')
def home():
    return 'OK'

@app.route("/webhook", methods=['POST'])
def webhook():
    signature = request.headers['X-Line-Signature']
    body = request.get_data(as_text=True)
    app.logger.info("Request body: " + body)
    try:
        webhook_handler.handle(body, signature)
    except InvalidSignatureError:
        app.logger.info("Invalid signature. Please check your channel access token or channel secret.")
        abort(400)
    return 'OK'

@webhook_handler.add(MessageEvent, message=TextMessageContent)
def handle_message(event):
    with ApiClient(configuration) as api_client:
        line_bot_api = MessagingApi(api_client)
        line_bot_api.reply_message_with_http_info(
            ReplyMessageRequest(
                reply_token=event.reply_token,
                messages=[TextMessage(text=event.message.text)]
            )
        )
```

啟動服務。

```bash
flask --app api/index run
```

## 部署

新增 `vercel.json` 檔。

```json
{
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/api/index"
    }
  ]
}
```

推送程式碼到儲存庫。

## 部署

在 [Vercel](https://vercel.com/) 平台註冊帳號，並且連結儲存庫。

然後在設定頁面，新增相關環境變數。

將 Function 區域改為東京或新加坡。

## 設定

1. 進到「Messaging API」頁面，設置應用程式的「Webhook URL」。

```env
https://line-bot-flask.vercel.app/webhook
```

2. 點選「Verify」按鈕。

3. 將「Use webhook」功能開啟。

4. 將「Auto-reply messages」和「Greeting messages」功能關閉。

## 程式碼

- [line-bot-flask](https://github.com/memochou1993/line-bot-flask)

## 參考資料

- [line/line-bot-sdk-python](https://github.com/line/line-bot-sdk-python)
