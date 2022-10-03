---
title: 使用 Fetch 發送 HTTP 請求
date: 2020-04-08 20:52:46
tags: ["程式設計", "JavaScript"]
categories: ["程式設計", "JavaScript", "其他"]
---

## 發送請求

`fetch()` 方法的第一個參數是 URI，它回傳一個包含 `Body` 的 `Promise` 物件。

```JS
fetch('http://example.com/movies.json')
  .then(function(response) {
    return response.json();
  })
  .then(function(data) {
    console.log(data);
  });
```

`fetch()` 方法的第二個參數是選用的，可以傳送一個物件來設定請求。

```JS
fetch(url, {
    body: JSON.stringify(data),
    cache: 'no-cache',
    credentials: 'same-origin',
    headers: {
      'content-type': 'application/json'
    },
    method: 'POST',
    mode: 'cors',
    redirect: 'follow',
    referrer: 'no-referrer',
  })
  .then(response => response.json())
```

可以使用以下 `Body` 的不同方法輸出不同類型格式的內容：

- Body.arrayBuffer()
- Body.blob()
- Body.formData()
- Body.json()
- Body.text()

## 中斷請求

`AbortController` 是一個控制器物件，其 `signal` 屬性回傳一個 `AbortSignal` 物件，與 DOM 請求溝通，使用 `AbortController.abort()` 方法可以將請求中斷。

```JS
const timeout = 1;
const controller = new AbortController();
const { signal } = controller;

setTimeout(() => controller.abort(), timeout * 1000);

fetch('http://example.com/movies.json', { signal })
  .then(function(response) {
    return response.json();
  })
  .then(function(data) {
    console.log(data);
  })
  .catch(function(err) {
    if (err.name === 'AbortError') {
      console.log('Promise Aborted');
    }
  });
```

## 參考資料

- [Fetch API](https://developer.mozilla.org/zh-TW/docs/Web/API/Fetch_API)
- [AbortController](https://developer.mozilla.org/zh-TW/docs/Web/API/AbortController)
