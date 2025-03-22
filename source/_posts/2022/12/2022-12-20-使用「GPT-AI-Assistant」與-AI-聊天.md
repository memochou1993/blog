---
title: 使用「GPT AI Assistant」與 AI 聊天
date: 2022-12-20 23:19:54
tags: ["Programming", "JavaScript", "Node.js", "GPT", "AI", "OpenAI", "LINE", "chatbot"]
categories: ["Programming", "JavaScript", "Node.js"]
---

## 介紹

GPT AI Assistant 是基於 OpenAI API 與 LINE Messaging API 實作的應用程式，透過安裝步驟，可以使用 LINE 手機應用程式與專屬的 AI 助理聊天。

## 安裝步驟

- 登入 [OpenAI](https://platform.openai.com/) 平台，或註冊一個新的帳號。
  - 生成一個 OpenAI 的 [API key](/demo/openai-api-key.png)。
- 登入 [LINE](https://developers.line.biz/) 平台，或註冊一個新的帳號。
  - 新增一個提供者（Provider），例如「My Provider」。
  - 在「My Provider」新增一個類型為「Messaging API」的頻道（Channel），例如「My AI Assistant」。
  - 進到「My AI Assistant」頻道頁面，點選「Messaging API」頁籤，生成一個頻道的 [channel access token](/demo/line-channel-access-token.png)。
- 登入 [GitHub](https://github.com/) 平台，或註冊一個新的帳號。
  - 進到 `gpt-ai-assistant` 專案頁面。
  - 點選「Star」按鈕，支持這個專案與開發者。
  - 點選「Fork」按鈕，將原始碼複製到自己的儲存庫。
- 登入 [Vercel](https://vercel.com/) 平台，或註冊一個新的帳號。
  - 點選「Create a New Project」按鈕，建立一個新專案。
  - 點選「Import」按鈕，將 `gpt-ai-assistant` 專案匯入。
  - 點選「Environment Variables」頁籤，新增以下環境變數：
    - `OPENAI_API_KEY`：將值設置為 OpenAI 的 [API key](/demo/openai-api-key.png)。
    - `LINE_CHANNEL_ACCESS_TOKEN`：將值設置為 LINE 的 [channel access token](/demo/line-channel-access-token.png)。
    - `LINE_CHANNEL_SECRET`：將值設置為 LINE 的 [channel secret](/demo/line-channel-secret.png)。
  - 點選「Deploy」按鈕，等待部署完成。
  - 回到專案首頁，複製應用程式網址（Domains），例如「<https://gpt-ai-assistant.vercel.app/>」。
- 回到 [LINE](https://developers.line.biz/) 平台。
  - 進到「My AI Assistant」頻道頁面，點選「Messaging API」頁籤，設置「Webhook URL」，填入應用程式網址並加上「/webhook」路徑，例如「<https://gpt-ai-assistant.vercel.app/webhook>」，點選「Update」按鈕。
  - 點選「Verify」按鈕，驗證是否呼叫成功。
  - 將「Use webhook」功能打開。
  - 將「Auto-reply messages」功能關閉。
  - 將「Greeting messages」功能關閉。
  - 使用 LINE 手機應用程式掃描 QR code，加入好友。
- 開始與你專屬的 AI 助理聊天！

## 開發

下載專案。

```bash
git clone git@github.com:memochou1993/gpt-ai-assistant.git
```

進到專案目錄。

```bash
cd gpt-ai-assistant
```

安裝依賴套件。

```bash
npm ci
```

### 執行測試

建立 `.env.test` 檔。

```bash
cp .env.example .env.test
```

在終端機使用以下指令，運行測試。

```bash
npm run test
```

查看結果。

```bash
> gpt-ai-assistant@0.0.0 test
> jest

  console.info
    === 000001 ===

    Human: 嗨！
    AI: 好的！

Test Suites: 1 passed, 1 total
Tests:       1 passed, 1 total
Snapshots:   0 total
Time:        1 s
```

### 使用代理伺服器

建立 `.env` 檔。

```bash
cp .env.example .env
```

設置環境變數如下：

```env
APP_DEBUG=true
APP_PORT=3000

VERCEL_GIT_REPO_SLUG=gpt-ai-assistant
VERCEL_ACCESS_TOKEN=<your_vercel_access_token>

OPENAI_API_KEY=<your_openai_api_key>

LINE_CHANNEL_ACCESS_TOKEN=<your_line_channel_access_token>
LINE_CHANNEL_SECRET=<your_line_channel_secret>
```

在終端機使用以下指令，啟動一個本地伺服器。

```bash
npm run dev
```

在另一個終端機，使用 `ngrok` 指令，啟動一個 HTTP 代理伺服器，將本地埠映射到外部網址。

```bash
ngrok http 3000
```

回到 [LINE](https://developers.line.biz/) 平台，修改「Webhook URL」，例如「<https://0000-0000-0000.jp.ngrok.io/webhook>」，點選「Update」按鈕。

使用 LINE 手機應用程式發送訊息。

查看結果。

```bash
> gpt-ai-assistant@0.0.0 dev
> node api/index.js

=== 0x1234 ===

Memo: 嗨
AI: 你好嗎？
```

## 程式碼

- [gpt-ai-assistant](https://github.com/memochou1993/gpt-ai-assistant)
