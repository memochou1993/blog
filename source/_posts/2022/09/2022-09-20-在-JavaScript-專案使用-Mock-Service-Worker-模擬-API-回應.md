---
title: 在 JavaScript 專案使用 Mock Service Worker 模擬 API 回應
date: 2022-09-20 23:04:49
tags: ["Programming", "JavaScript", "Testing", "Mocking"]
categories: ["Programming", "JavaScript", "Others"]
---

## 建立專案

建立專案。

```bash
npm create vite@latest msw-example -- --template vanilla
cd msw-example
```

安裝依賴套件。

```bash
npm install
```

安裝 `msw` 套件。

```bash
npm install msw --save-dev
```

## 模擬端點

修改 `main.js` 檔，呼叫一個不存在的 API 端點。

```js
const res = await fetch('/posts')
  .then((r) => r.json())
  .then((r) => r);

console.log(res); // Uncaught SyntaxError
```

新增 `mocks/handlers.js` 檔，模擬要呼叫的 API 端點。

```js
import { rest } from 'msw';

export const handlers = [
  rest.get('/posts', (req, res, ctx) => {
    return res(
      ctx.status(200),
      ctx.json([
        {
          foo: 'bar',
        },
      ]),
    );
  }),
];
```

初始化 Worker 並透過 Mock Service Worker CLI 創建 `mockServiceWorker.js` 檔到 `public` 資料夾。

```bash
npx msw init public/ --save
```

新增 `mocks/browser.js` 檔。

```js
import { setupWorker } from 'msw';
import { handlers } from './handlers';

export const worker = setupWorker(...handlers);
```

修改 `main.js` 檔，在開發環境下引入 Worker 並啟動。

```js
if (process.env.NODE_ENV === 'development') {
  const { worker } = await import('./mocks/browser');
  worker.start();
}

const res = await fetch('/posts')
  .then((r) => r.json())
  .then((r) => r);

console.log(res);
```

啟動服務。

```bash
npm run dev
```

## 參考資料

- [Mock Service Worker](https://mswjs.io/docs/)
