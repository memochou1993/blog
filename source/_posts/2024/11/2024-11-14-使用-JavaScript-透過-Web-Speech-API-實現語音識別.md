---
title: 使用 JavaScript 透過 Web Speech API 實現語音識別
date: 2024-11-14 22:42:18
tags: ["Programming", "JavaScript", "Web Speech API", "SpeechRecognition"]
categories: ["Programming", "JavaScript", "Others"]
---

## 建立專案

建立 `index.html` 檔。

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Web Speech API</title>
</head>
<body>
  <h1>Speech Recognition</h1>
  <button id="startButton">Start</button>
  <button id="stopButton">Stop</button>
  <p>
    Result: <span id="result"></span>
  </p>
  <script>
    if ('SpeechRecognition' in window || 'webkitSpeechRecognition' in window) {
      // 取得語音辨識物件
      const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
      // 實例化語音辨識物件
      const recognition = new SpeechRecognition();
      // 設定語言
      recognition.lang = 'zh-TW';
      // 持續辨識
      recognition.continuous = true;
      // 返回臨時結果
      recognition.interimResults = true;
      // 辨識結果
      recognition.onresult = (event) => {
        let transcript = '';
        for (let i = 0; i < event.results.length; i++) {
          transcript += event.results[i][0].transcript;
        }
        document.getElementById('result').innerText = transcript;
      };
      // 開始辨識
      document.getElementById('startButton').onclick = () => {
        recognition.start();
        document.getElementById('result').innerText = 'Listening...';
      };
      // 停止辨識
      document.getElementById('stopButton').onclick = () => {
        recognition.stop();
      };
    } else {
      alert('Web Speech API is not supported.');
    }
  </script>
</body>
</html>
```

啟動網頁。

```bash
live-server
```

## 參考資料

- [Web Speech API - SpeechRecognition](https://developer.mozilla.org/en-US/docs/Web/API/SpeechRecognition)
