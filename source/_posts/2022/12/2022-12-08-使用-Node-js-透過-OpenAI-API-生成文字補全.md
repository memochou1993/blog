---
title: 使用 Node.js 透過 OpenAI API 生成文字補全
date: 2022-12-08 00:16:47
tags: ["Programming", "JavaScript", "Node.js", "GPT", "AI", "OpenAI"]
categories: ["Programming", "JavaScript", "Node.js"]
---

## 前置作業

在 [OpenAI](https://openai.com/api/) 註冊一個帳號，並且在 [API keys](https://platform.openai.com/settings/organization/api-keys) 頁面產生一個 API 金鑰。

## 建立專案

建立專案。

```bash
mkdir openai-cli-node-example
cd openai-cli-node-example
```

初始化專案。

```bash
npm init
```

修改 `package.json` 檔。

```json
{
  "type": "module",
}
```

安裝依賴套件。

```bash
npm i openai dotenv
```

新增 `.env` 檔。

```env
OPENAI_API_KEY=
```

新增 `.gitignore` 檔。

```env
/node_modules
.env
```

## 實作

新增 `api.js` 檔。

```js
import dotenv from 'dotenv';
import { Configuration, OpenAIApi } from 'openai';

dotenv.config();

export const TITLE_AI = 'AI';
export const TITLE_HUMAN = 'Human';
export const FINISH_REASON_STOP = 'stop';
export const FINISH_REASON_LENGTH = 'length';

const configuration = new Configuration({
  apiKey: process.env.OPENAI_API_KEY,
});

const openai = new OpenAIApi(configuration);

// 發送請求
const prompt = (context) => openai.createCompletion({
  model: 'text-davinci-003',
  prompt: context,
  temperature: 0.9,
  max_tokens: 150,
  top_p: 1,
  frequency_penalty: 0,
  presence_penalty: 0.6,
  stop: [
    ` ${TITLE_AI}:`,
    ` ${TITLE_HUMAN}:`,
  ],
});

// 遞迴發送請求
export const chat = async ({ context, reply = '' }) => {
  const { data } = await prompt(context);
  const [choice] = data.choices;
  context += choice.text;
  reply += choice.text;
  const res = { context, reply };
  // 如果結束理由是停止，則可以回傳結果
  return choice.finish_reason === FINISH_REASON_STOP ? res : chat(res);
};

export default null;
```

新增 `index.js` 檔。

```js
import readline from 'readline';
import fs from 'fs';
import {
  chat,
  TITLE_AI,
  TITLE_HUMAN,
} from './api.js';

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

// 遞迴詢問
const start = (reply, context = reply) => {
  rl.question(`${reply}\n${TITLE_HUMAN}: `, async (content) => {
    if (content) context += `\n${TITLE_HUMAN}: ${content}`;
    const res = await chat({ context });
    context += res.reply;
    fs.writeFile('context.txt', context, () => {});
    start(res.reply, context);
  });
};

start(`${TITLE_AI}: 嗨！我可以怎麼幫助你？`);
```

執行程式。

```bash
node index.js
```

## 程式碼

- [openai-cli-node-example](https://github.com/memochou1993/openai-cli-node-example)

## 參考資料

- [OpenAI - Documentation](https://platform.openai.com/docs)
