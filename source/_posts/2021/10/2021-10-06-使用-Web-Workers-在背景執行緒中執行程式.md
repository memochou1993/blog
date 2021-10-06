---
title: 使用 Web Workers 在背景執行緒中執行程式
permalink: 使用-Web-Workers-在背景執行緒中執行程式
date: 2021-10-06 11:52:45
tags: ["程式設計", "JavaScript"]
categories: ["程式設計", "JavaScript"]
---

## 範例

新增 `worker.js` 檔，可以在裡面處理複雜的運算。使用 `postMessage` 方法可以將內容傳送至主執行緒。

```JS
let i = 0;

setInterval(() => {
  i++;
  postMessage(i);
}, 1000);
```

在主執行緒，可以透過 `onmessage` 接收 worker 傳過來的內容。

```HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <script>
    if (typeof(Worker) !== 'undefined') {
        const w = new Worker('worker.js');

        w.onmessage = (event) => {
            console.log(event);
        };

        setTimeout(() => {
            // 終止
            w.terminate();
        }, 1000 * 10);
    }
    </script>
</body>
</html>
```

## 參考資料

- [使用 Web Workers](https://developer.mozilla.org/zh-TW/docs/Web/API/Web_Workers_API/Using_web_workers)
