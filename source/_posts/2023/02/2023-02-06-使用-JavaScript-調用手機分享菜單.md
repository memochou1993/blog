---
title: 使用 JavaScript 調用手機分享菜單
date: 2023-02-06 23:01:04
tags: ["程式設計", "JavaScript"]
categories: ["程式設計", "JavaScript", "其他"]
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

啟動代理伺服器。

```bash
ngrok http 8080
```

使用手機複製結果如下：

```bash
Hello, World!
```

## 參考資料

- [Web Share API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Share_API)
