---
title: 使用 Fetch 和 async/await 語法發送 HTTP 請求
date: 2020-10-23 10:48:51
tags: ["Programming", "JavaScript"]
categories: ["Programming", "JavaScript", "Others"]
---

## 做法

使用 `async/await` 的方式，有順序性地等待 `Fetch` 回應。

```js
async function fetchData(url, defer) {
  // 使用 await 語法取得 response
  const response = await fetch(url);

  // 模擬回應時間
  await (() => new Promise((resolve) => setTimeout(() => resolve(), defer)))();

  // 使用 await 語法取得 data
  return await response.json();
}

(async () => {
  // 等待第一個請求回應，耗時 1 秒
  console.log(await fetchData('url_1', 1000));

  // 等待第二個請求回應，耗時 0.5 秒
  console.log(await fetchData('url_2', 500));

  // 等待第三個請求回應，耗時 0 秒
  console.log(await fetchData('url_3', 0));
})();
```

## 參考資料

- [How to Use Fetch with async/await](https://dmitripavlutin.com/javascript-fetch-async-await/)
