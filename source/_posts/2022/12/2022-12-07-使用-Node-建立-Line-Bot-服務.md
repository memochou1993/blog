---
title: 使用 Node 建立 Line Bot 服務
date: 2022-12-07 00:32:23
tags: ["程式設計", "JavaScript", "Node", "Line"]
categories: ["程式設計", "JavaScript", "Node"]
---

## 建立頻道

首先，登入 [LINE Developers](https://developers.line.biz/) 頁面，選擇 [Messaging API](https://developers.line.biz/en/services/messaging-api/) 產品，建立一個 Channel。

## 建立專案

建立專案。

```bash
mkdir line-bot-node
cd line-bot-node
```

初始化專案。

```bash
npm init -y
```

安裝依賴套件。

```bash
npm install express
```

新增 `.gitignore` 檔。

```env
/node_modules
```

## 實作

新增 `api/index.js` 檔。

```js
const https = require('https');
const express = require('express');

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/api', (req, res) => {
  res.sendStatus(200);
});

app.post('/api/webhook', (req, res) => {
  res.send('HTTP POST request sent to the webhook URL!');

  if (req.body.events[0].type === 'message') {
    const headers = {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${process.env.LINE_ACCESS_TOKEN}`,
    };

    const body = JSON.stringify({
      replyToken: req.body.events[0].replyToken,
      messages: [
        {
          type: 'text',
          text: 'Hello',
        },
      ],
    });

    const webhookOptions = {
      hostname: 'api.line.me',
      path: '/v2/bot/message/reply',
      method: 'POST',
      headers,
      body,
    };

    const request = https.request(webhookOptions, (res) => {
      res.on('data', (d) => {
        process.stdout.write(d);
      });
    });

    request.on('error', (err) => {
      console.error(err);
    });

    request.write(body);

    request.end();
  }
});

module.exports = app;
```

## 部署

在 [Vercel](https://vercel.com/) 平台註冊帳號，並且連結儲存庫。

然後在設定頁面，新增一個 `LINE_ACCESS_TOKEN` 環境變數。

在專案根目錄新增 `vercel.json` 檔。

```json
{
  "rewrites": [{ "source": "/api/(.*)", "destination": "/api" }]
}
```

最後，將程式碼推送到儲存庫。

## 設定

1. 進到「Messaging API」頁面，設置應用程式的「Webhook URL」。

```env
https://line-bot-node.vercel.app/api/webhook
```

2. 點選「Verify」按鈕。

3. 將「Use webhook」功能開啟。

4. 將「Auto-reply messages」和「Greeting messages」功能關閉。

## 程式碼

- [line-bot-node](https://github.com/memochou1993/line-bot-node)

## 參考資料

- [Make a sample reply bot using Node.js](https://developers.line.biz/en/docs/messaging-api/nodejs-sample/)
- [Using Express.js with Vercel](https://vercel.com/guides/using-express-with-vercel)
