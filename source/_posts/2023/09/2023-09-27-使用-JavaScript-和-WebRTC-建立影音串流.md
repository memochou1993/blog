---
title: 使用 JavaScript 和 WebRTC 建立影音串流
date: 2023-09-27 14:54:43
tags: ["程式設計", "JavaScript", "WebRTC"]
categories: ["程式設計", "JavaScript", "其他"]
---

## 建立專案

建立專案。

```bash
npm create vite@latest
cd webrtc-example
```

安裝 ESLint 套件。

```bash
npm i eslint eslint-config-airbnb -D
```

在專案根目錄新增 `.eslintrc.cjs` 檔：

```js
module.exports = {
  extends: 'airbnb',
  env: {
    browser: true,
    node: true,
  },
};
```

## 實作

修改 `main.js` 檔。

```js
import './style.css';

(async () => {
  const videoEl = document.querySelector('#video');

  const constraints = {
    audio: true,
    video: { width: { ideal: 4096 }, height: { ideal: 2160 } },
  };
  const stream = await navigator.mediaDevices.getUserMedia(constraints);

  videoEl.srcObject = stream;
})();
```

修改 `index.html` 檔。

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Vite App</title>
  </head>
  <body>
    <div id="app">
      <video id="video" width="100%" height="100%" autoplay playsinline></video>
    </div>
    <script type="module" src="/main.js"></script>
  </body>
</html>
```

修改 `style.css` 檔。

```css
:root {
  background-color: #242424;
}

body {
  margin: 0;
}

#video {
  transform: scaleX(-1);
}
```

## 程式碼

- [webrtc-example](https://github.com/memochou1993/webrtc-example)

## 參考資料

- [WebRTC samples](https://webrtc.github.io/samples/)
