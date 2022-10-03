---
title: 在 JavaScript 專案使用 Mock Service Worker 模擬 API 回應
date: 2022-09-20 23:04:49
tags: ["程式設計", "JavaScript", "Testing", "Mocking"]
categories: ["程式設計", "JavaScript", "其他"]
---

## 建立專案

建立專案。

```BASH
npm create vite@latest msw-example -- --template vanilla
cd msw-example
```

安裝依賴套件。

```BASH
npm install
```

安裝 `msw` 套件。

```BASH
npm install msw --save-dev
```

## 模擬端點

修改 `main.js` 檔，呼叫一個不存在的 API 端點。

```JS
const res = await fetch('/posts')
  .then((r) => r.json())
  .then((r) => r);

console.log(res); // Uncaught SyntaxError
```

新增 `mocks/handlers.js` 檔，模擬要呼叫的 API 端點。

```JS
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

```BASH
npx msw init public/ --save
```

新增 `mocks/browser.js` 檔。

```JS
import { setupWorker } from 'msw';
import { handlers } from './handlers';

export const worker = setupWorker(...handlers);
```

修改 `main.js` 檔，在開發環境下引入 Worker 並啟動。

```JS
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

```BASH
npm run dev
```

## 參考資料

- [Mock Service Worker](https://mswjs.io/docs/)
