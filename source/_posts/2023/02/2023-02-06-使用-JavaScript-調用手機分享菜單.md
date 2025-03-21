---
title: 使用 JavaScript 調用手機分享菜單
date: 2023-02-06 23:01:04
tags: ["Programming", "JavaScript"]
categories: ["Programming", "JavaScript", "Others"]
---

## 做法

新增 `index.html` 檔。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
  <button onclick="share()">Share</button>
  <script>
    const share = async () => {
      if (navigator.share) {
        try {
          await navigator.share({
            title: document.title,
            text: 'Hello, World!',
            url: window.location.href,
          });
        } catch (err) {
          console.error(err);
        }
      }
    };
  </script>
</body>
</html>
```

啟動伺服器。

```bash
live-server
```

使用 `ngrok` 指令，啟動一個 HTTP 代理伺服器，將本地埠映射到外部網址。

```bash
ngrok http 8080
```

使用手機複製結果如下：

```bash
Hello, World!
```

## 參考資料

- [Web Share API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Share_API)
