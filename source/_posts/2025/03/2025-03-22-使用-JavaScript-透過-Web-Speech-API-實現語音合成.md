---
title: 使用 JavaScript 透過 Web Speech API 實現語音合成
date: 2025-03-22 01:23:17
tags: ["Programming", "JavaScript", "Web Speech API", "SpeechSynthesis"]
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
  <h1>Speech Synthesis</h1>
  <textarea>你好，世界！</textarea>
  <br />
  <button id="speakButton">Speak</button>
  <button id="stopButton">Stop</button>
  <script>
    if ('speechSynthesis' in window) {
      // 取得語音合成物件
      const synth = window.speechSynthesis;

      document.getElementById('speakButton').addEventListener('click', () => {
        // 取得文字
        const text = document.querySelector('textarea').value;
        // 停止先前的朗讀
        synth.cancel();
        // 實例化朗讀物件
        const utterance = new SpeechSynthesisUtterance(text);
        // 設定語言
        utterance.lang = 'zh-TW';
        // 設定語音
        utterance.voice = synth.getVoices().find(voice => voice.name === 'Google 國語（臺灣）');
        // 開始朗讀
        synth.speak(utterance);
      });

      document.getElementById('stopButton').addEventListener('click', () => {
        // 停止朗讀
        synth.cancel();
      });
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

- [Web Speech API - SpeechSynthesis](https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesis)
