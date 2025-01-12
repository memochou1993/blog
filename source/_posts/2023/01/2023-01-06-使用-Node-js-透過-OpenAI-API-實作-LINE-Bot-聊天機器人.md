---
title: 使用 Node.js 透過 OpenAI API 實作 LINE Bot 聊天機器人
date: 2023-01-06 22:41:52
tags: ["Programming", "JavaScript", "Node.js", "GPT", "AI", "OpenAI", "LINE", "chatbot"]
categories: ["Programming", "JavaScript", "Node.js"]
---

## 前言

ChatGPT 在 2022 年 11 月推出，是由 OpenAI 開發的一個人工智慧聊天機器人程式。而 OpenAI 提供了 GPT-3 模型的 API 讓開發者可以串接。雖然不是 ChatGPT 使用的 GPT-3.5 模型，但仍然很強大。

為了跟上這波風潮，藉此把 OpenAI 的 Completion API 串接到 LINE 應用程式上，讓使用者可以直接透過 LINE 與 AI 進行互動。

## 原理

可以先使用 [Playground](https://beta.openai.com/playground) 進行測試，大概知道 Completion API 的運作方式。也就是只要給 AI 提示詞，讓 AI 把文字補全即可。

例如，使用以下提示詞：

```tet
AI: 我是 AI 助理，我可以怎麼幫你？
Human: 你好嗎？
```

Completion API 就會將文字補全。

```tet
AI: 我是 AI 助理，我可以怎麼幫你？
Human: 你好嗎？
AI: 嗨！很高興為你服務！
```

### API

呼叫 API 的方式非常簡單，以使用 curl 為例：

```bash
curl https://api.openai.com/v1/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{
  "model": "text-davinci-003",
  "prompt": "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly.\n\nAI: 我是 AI 助理，我可以怎麼幫你？\nHuman: 你好嗎？ 嗨！很高興為你服務！",
  "temperature": 0.9,
  "max_tokens": 150,
  "top_p": 1,
  "frequency_penalty": 0,
  "presence_penalty": 0.6,
  "stop": [" Human:", " AI:"]
}'
```

### 常用參數

- `model`：使用的語言模型，最新的是 `text-davinci-003` 模型，但費用較貴。
- `temperature`：決定回應的創意和多樣性，越高代表越活潑，越低代表越保守。
- `max_tokens`：決定最多回應的字詞數量。
- `stop`：決定停止繼續生成文字的停止符。

## 架構

專案 [gpt-ai-assistant](https://github.com/memochou1993/gpt-ai-assistant) 的架構，主要分成路由、主要處理器、兩個核心模組，和一個持久化儲存。

### 路由

路由的部分主要就是兩個：

- `/`：檢查端點，檢查是否部署成功。
- `/webhook`：回呼端點，用來接收 LINE 事件，並處理訊息回覆。

### 主要處理器

主要處理器在接收 LINE 事件後，會被 `handleEvents` 方法接收，再被 `handleContext` 方法接收，一路傳遞至指定的子處理器，最終變成 LINE 的回應格式，被送至 LINE 伺服器。

### 兩個核心模組

- `Prompt` 模組：用來儲存人類與 AI 的對話，這是被送到 Completion API 的提示詞，儲存的內容會以使用者分群。
- `History` 模組：也是用來儲存人類與 AI 的對話，但是包括群組對話，這是被送到 Completion API 的分析文本，會被夾帶在提示詞之中。

### 持久化儲存

持久化儲存用來儲存設定檔，是把 Vercel 的環境變數當作鍵值對資料庫的特殊實作。

## 路由

整個程式的進入點在 `api/index.js` 檔。這裡是放置路由的地方。

```js
// api/index.js
// ...

const app = express();

// 這裡先使用 json 中介層，並設置 rawBody 給後續的 validateLineSignature 中介層使用
app.use(express.json({
  verify: (req, res, buf) => {
    req.rawBody = buf.toString();
  },
}));

// 這是一個檢查用的端點，如果部署成功，應該要看到 OK 回應
app.get('/', (req, res) => {
  // 如果有設置 APP_URL 環境變數，會導頁到指定的網址
  if (config.APP_URL) {
    res.redirect(config.APP_URL);
    return;
  }
  res.sendStatus(200);
});

// 這是要設置到 LINE 的 Webhook URL 的端點
app.post(config.APP_WEBHOOK_PATH, validateLineSignature, async (req, res) => {
  try {
    // 首先，要將 storage 初始化，所謂 storage 就是從 Vercel 取得環境變數的值
    await storage.initialize();
    // 再來，處理來自 LINE 的事件
    await handleEvents(req.body.events);
    // 最終，送出 OK 回應
    res.sendStatus(200);
  } catch (err) {
    console.error(err.message);
    if (err.response?.data) console.error(err.response.data);
    res.sendStatus(500);
  }
  // 如果有設置 APP_URL 環境變數，可以在標準輸出看到對話紀錄
  if (config.APP_DEBUG) printHistories();
});

// 如果有設置 APP_PORT 環境變數，就啟動一個伺服器，通常是在本機時使用
if (config.APP_PORT) {
  app.listen(config.APP_PORT);
}

// 匯出整個函式，做為 Serverless Functions 給 Vercel 調用
export default app;
```

## 主要處理器

主要處理器在 `app/app.js` 檔。這裡是處理 LINE 事件，將其形變、一路傳遞至指定子處理器，然後最終送出回應的地方。

```js
// app/app.js
// ...

/**
 * @param {Context} context
 * @returns {Promise<Context>}
 */
const handleContext = async (context) => (
  // 檢查是否為 activate 指令，是的話就執行
  activateCommand(context)
  // 檢查是否為 command 指令，是的話就執行
  || commandCommand(context)
  // 檢查是否為 continue 指令，是的話就執行
  || continueCommand(context)
  // 檢查是否為 deactivate 指令，是的話就執行
  || deactivateCommand(context)
  // 檢查是否為 deploy 指令，是的話就執行
  || deployCommand(context)
  // 檢查是否為 doc 指令，是的話就執行
  || docCommand(context)
  // 檢查是否為 draw 指令，是的話就執行
  || drawCommand(context)
  // 檢查是否為 enquire 指令，是的話就執行
  || enquireCommand(context)
  // 檢查是否為 report 指令，是的話就執行
  || reportCommand(context)
  // 檢查是否為 version 指令，是的話就執行
  || versionCommand(context)
  // 檢查是否為 talk 指令，是的話就執行
  || talkCommand(context)
  || context
);

const handleEvents = async (events = []) => (
  // 等待第三層執行完畢
  (Promise.all(
    // 等待第二層執行完畢
    (await Promise.all(
      // 等待第一層執行完畢
      (await Promise.all(
        events
          // 首先，將 event 鑄型成 Event 類別
          .map((event) => new Event(event))
          // 只接受 message 類型的訊息
          .filter((event) => event.isMessage)
          // 將 Event 注入至 Context 類別
          .map((event) => new Context(event))
          // 執行 Context 類別的 initialize 方法
          .map((context) => context.initialize()),
      ))
        // 開始處理 Context 類別
        .map((context) => (!context.error ? handleContext(context) : context)),
    ))
      // 只接受有 message 內容的 Context 類別
      .filter((context) => context.messages.length > 0)
      // 將 Context 類別注入至 replyMessage 方法，完成回覆訊息
      .map((context) => replyMessage(context)),
  ))
);

export default handleEvents;
```

## 核心模組

### Prompt 模組

Prompt 模組的進入點在 `app/prompt/index.js` 檔。這裡放置了以每個人為單位的提示詞。

```js
// app/prompt/index.js
// ...

// 使用 Map 結構來儲存，用 userId 當作 key，用 Prompt 類別當作 value
const prompts = new Map();

/**
 * @param {string} userId
 * @returns {Prompt}
 */
const getPrompt = (userId) => prompts.get(userId) || new Prompt();

/**
 * @param {string} userId
 * @param {Prompt} prompt
 */
const setPrompt = (userId, prompt) => {
  prompts.set(userId, prompt);
};

/**
 * @param {string} userId
 */
const removePrompt = (userId) => {
  prompts.delete(userId);
};

const printPrompts = () => {
  if (Array.from(prompts.keys()).length < 1) return;
  const content = Array.from(prompts.keys()).map((userId) => `\n=== ${userId.slice(0, 6)} ===\n${getPrompt(userId)}`).join('\n');
  console.info(content);
};

export {
  getPrompt,
  setPrompt,
  removePrompt,
  printPrompts,
};

export default prompts;
```

每一個 Prompt 類別，儲存了 AI 和人類所說的每一句話。

```js
// app/prompt/prompt.js
// ...

// 為了控制字詞數量，設定上下文最多 16 句話
const MAX_LINE_COUNT = 16;

class Prompt {
  sentences = [];

  constructor() {
    // 設置一個 AI 的問候語，可以決定後續回應為中文、英文，或是日文
    this.write(PARTICIPANT_AI, t('__COMPLETION_INIT_MESSAGE'));
  }

  /**
   * @returns {Sentence}
   */
  get lastSentence() {
    return this.sentences.length > 0 ? this.sentences[this.sentences.length - 1] : null;
  }

  /**
   * @param {string} title
   * @param {string} text
   */
  write(title, text = '') {
    if (this.sentences.length >= MAX_LINE_COUNT) {
      this.sentences.shift();
    }
    this.sentences.push(new Sentence({ type: SENTENCE_PROMPTING, title, text }));
    return this;
  }

  /**
   * @param {string} text
   */
  patch(text) {
    this.sentences[this.sentences.length - 1].text += text;
  }

  toString() {
    return this.sentences.map((sentence) => sentence.toString()).join('');
  }
}

export default Prompt;
```

### 實際應用

Prompt 文本會像是以下內容：

```bash
AI: 我是 AI 助理，我可以怎麼幫你？
Human: 你好嗎？
AI: 嗨！很高興為你服務！
```

### History 模組

History 模組的進入點在 `app/history/index.js` 檔。這裡放置了以每個人或群組為單位的聊天歷史紀錄。與 Prompt 模組不同的地方在於，History 所儲存的內容，是被當成分析文本，最終會被夾帶在提示詞之中送出。

```js
// app/history/index.js
// ...

// 使用 Map 結構來儲存，用 groupId 或 userId 當作 key，用 History 類別當作 value
const histories = new Map();

/**
 * @param {string} contextId
 * @returns {History}
 */
const getHistory = (contextId) => histories.get(contextId) || new History();

/**
 * @param {string} contextId
 * @param {History} history
 * @returns {History}
 */
const setHistory = (contextId, history) => histories.set(contextId, history);

/**
 * @param {string} contextId
 * @param {function(History)} callback
 */
const updateHistory = (contextId, callback) => {
  const history = getHistory(contextId);
  callback(history);
  setHistory(contextId, history);
};

const printHistories = () => {
  const records = Array.from(histories.keys())
    .filter((contextId) => getHistory(contextId).records.length > 0)
    .map((contextId) => `\n=== ${contextId.slice(0, 6)} ===\n\n${getHistory(contextId).toString()}`);
  if (records.length < 1) return;
  console.info(records.join('\n'));
};

export {
  getHistory,
  updateHistory,
  printHistories,
};

export default histories;
```

每一個 Record 類別，同樣儲存了 AI 和人類所說的每一句話，但是 AI 針對分析文本所回覆的內容並不會被記錄，否則會形成鏡像效應。

```js
// app/history/history.js
// ...

// 為了控制字詞數量，設定上下文最多 8 句話
const MAX_RECORD_COUNT = 8;

class History {
  records = [];

  /**
   * @param {string} title
   * @param {string} text
   */
  write(title, text) {
    if (this.records.length >= MAX_RECORD_COUNT) {
      this.records.shift();
    }
    this.records.push(new Record({ title, text }));
    return this;
  }

  /**
   * @param {string} text
   */
  patch(text) {
    if (this.records.length < 1) return;
    this.records[this.records.length - 1].text += text;
  }

  toString() {
    return this.records.map((record) => record.toString()).join('\n');
  }
}

export default History;
```

## 持久化儲存

持久化儲存的進入點在 `storage/index.js` 檔。這是把 Vercel 環境變數當作鍵值對資料庫的特殊實作。

```js
// ...

// 將存放在環境變數中的 key 取名為 APP_STORAGE
const ENV_KEY = 'APP_STORAGE';

class Storage {
  env;

  data = {};

  // 初始化儲存庫
  async initialize() {
    if (!config.VERCEL_ACCESS_TOKEN) return;
    // 先試著取得 APP_STORAGE 的值
    this.env = await fetchEnvironment(ENV_KEY);
    // 如果沒有的話，就要創建環境變數
    if (!this.env) {
      const { data } = await createEnvironment({
        key: ENV_KEY,
        value: JSON.stringify(this.data),
        type: ENV_TYPE_PLAIN,
      });
      this.env = data.created;
    }
    // 把值反序列化放到 data 中
    this.data = JSON.parse(this.env.value);
  }

  /**
   * @param {string} key
   * @returns {string}
   */
  getItem(key) {
    // 直接從 data 取得指定資料
    return this.data[key];
  }

  /**
   * @param {string} key
   * @param {string} value
   */
  async setItem(key, value) {
    // 更新 data 指定資料
    this.data[key] = value;
    if (!config.VERCEL_ACCESS_TOKEN) return;
    // 呼叫 Vercel API 以更新 APP_STORAGE 的值
    await updateEnvironment({
      id: this.env.id,
      value: JSON.stringify(this.data, null, config.VERCEL_ENV ? 0 : 2),
      type: ENV_TYPE_PLAIN,
    });
  }
}

const storage = new Storage();

export default storage;
```

### 實際應用

History 文本會像是以下內容，稱謂使用的是 AI 的暱稱和使用者的暱稱：

```bash
助理: 我是 AI 助理，我可以怎麼幫你？
Memo: 你好嗎？
助理: 嗨！很高興為你服務！
```

Prompt 文本則會像是以下內容，稱謂使用的是停止符：

```bash
AI: 我是 AI 助理，我可以怎麼幫你？
Human: 你好嗎？
AI: 嗨！很高興為你服務！
Human: 請幫我總結以下內容。
「
助理: 我是 AI 助理，我可以怎麼幫你？
Memo: 你好嗎？
助理: 嗨！很高興為你服務！
」
AI: 好的！
```

## 子處理器

所謂子處理器就是當接受某一種指令時，可以透過它來判斷是否處理，以及處理的方式。以 `doc` 這個指令為例，在 `app/commands/doc.js` 檔被定義。

```js
// app/commands/doc.js
// ...

// 判斷是否接收到指定字串
const check = (context) => context.isCommand(COMMAND_SYS_DOC);

// 執行 command 指令所需要執行的內容
const exec = (context) => check(context) && (
  async () => {
    // 把使用者送出 command 指令的記錄從 History 模組中消除
    updateHistory(context.id, (history) => history.records.pop());
    // 將文字訊息推送至佇列
    context.pushText('https://github.com/memochou1993/gpt-ai-assistant', formatCommand(GENERAL_COMMANDS));
    return context;
  }
)();

export default exec;
```

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

在另一個終端機使用以下指令，啟動一個代理伺服器。

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
