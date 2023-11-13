---
title: 使用 JavaScript 透過 MediaStream API 取得影音串流
date: 2023-09-27 14:54:43
tags: ["Programming", "JavaScript", "WebRTC"]
categories: ["Programming", "JavaScript", "Others"]
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
  rules: {
    'no-new': 'off',
  },
};
```

## 實作

修改 `main.js` 檔。

```js
import './style.css';

class Meeting {
  constructor() {
    this.streamButton = document.querySelector('#stream-button');
    this.videoButton = document.querySelector('#video-button');
    this.audioButton = document.querySelector('#audio-button');
    this.mainVideo = document.querySelector('#main-video');

    this.isVideoEnabled = true;
    this.isAudioEnabled = true;

    this.videoTracks = [];
    this.audioTracks = [];

    this.streamButton.addEventListener('click', this.toggleStream.bind(this));
    this.videoButton.addEventListener('click', this.toggleVideo.bind(this));
    this.audioButton.addEventListener('click', this.toggleAudio.bind(this));
  }

  async toggleStream() {
    let stream = this.mainVideo.srcObject;

    this.streamButton.textContent = stream ? '開始' : '結束';

    if (stream) {
      stream.getTracks().forEach((track) => track.stop());
      this.mainVideo.srcObject = null;
      return;
    }

    stream = await navigator.mediaDevices.getUserMedia({
      audio: true,
      video: { width: { ideal: 4096 }, height: { ideal: 2160 } },
    });

    this.videoTracks = stream.getVideoTracks();
    this.audioTracks = stream.getAudioTracks();

    this.videoTracks[0].enabled = this.isVideoEnabled;
    this.audioTracks[0].enabled = this.isAudioEnabled;

    this.mainVideo.srcObject = stream;
  }

  toggleVideo() {
    this.isVideoEnabled = !this.isVideoEnabled;
    this.videoButton.textContent = this.isVideoEnabled ? '關閉視訊' : '開啟視訊';

    if (this.videoTracks.length > 0) {
      this.videoTracks[0].enabled = this.isVideoEnabled;
    }
  }

  toggleAudio() {
    this.isAudioEnabled = !this.isAudioEnabled;
    this.audioButton.textContent = this.isAudioEnabled ? '關閉音訊' : '開啟音訊';

    if (this.audioTracks.length > 0) {
      this.audioTracks[0].enabled = this.isAudioEnabled;
    }
  }
}

new Meeting();
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
      <button id="stream-button">開始</button>
      <button id="video-button">關閉視訊</button>
      <button id="audio-button">關閉音訊</button>
      <video id="main-video" width="100%" height="100%" autoplay playsinline></video>
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
