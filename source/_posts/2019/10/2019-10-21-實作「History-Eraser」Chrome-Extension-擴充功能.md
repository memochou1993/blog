---
title: 實作「History Eraser」Chrome Extension 擴充功能
permalink: 實作「History-Eraser」Chrome-Extension-擴充功能
date: 2019-10-21 22:59:11
tags: ["程式設計", "Chrome", "Chrome Extension"]
categories: ["程式設計", "Chrome Extension"]
---

## 前言

目標是製作一個能夠在一般視窗下，藉由指定關鍵字或網域名稱，使特定網址不被記錄的擴充功能。

## 建立專案

目錄結構如下：

```BASH
|- src/
  |- css/
  |- html/
  |- images/
  |- js/
  |- manifest.json
```

## manifest.json

在 `src` 資料夾建立 `manifest.json` 檔：

```JSON
{
  "manifest_version": 2,
  "name": "History Eraser",
  "description": "Clear browsing history by keywords or domain name.",
  "version": "1.0",
  "browser_action": {
    "default_title": "History Eraser",
    "default_icon": "images/icon.png"
  },
  "background": {
    "scripts": [
      "js/main.js"
    ]
  },
  "options_ui": {
    "page": "html/options.html",
    "open_in_tab": false
  },
  "permissions": [
    "history",
    "storage"
  ]
}
```

## 擴充功能選項

選項表單的樣式採用 [Material Design Lite](https://getmdl.io/) 框架，下載後將 `material.min.css` 檔放在 `css` 資料夾，將 `material.min.js` 檔放在 `js` 資料夾。

在 `html` 資料夾建立 `options.html` 檔：

```HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link rel="stylesheet" href="../css/material.min.css">
    <title>Options</title>
</head>
<body>
    <div class="mdl-grid">
        <div class="mdl-cell mdl-cell--12-col">
            <div class="mdl-card">
                <div class="mdl-card__supporting-text">
                    <div>
                        <label for="keywords">Keywords (one per line)</label>
                    </div>
                    <div>
                        <div class="mdl-textfield mdl-js-textfield">
                            <textarea name="keywords" rows="10" class="mdl-textfield__input" id="keywords"></textarea>
                            <label class="mdl-textfield__label"></label>
                        </div>
                    </div>
                    <div>
                        <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="history.onVisited">
                            <input type="radio" name="event" value="history.onVisited" class="mdl-radio__button" id="history.onVisited" checked>
                            <span class="mdl-radio__label">Delete when page is visited</span>
                        </label>
                        <label class="mdl-radio mdl-js-radio mdl-js-ripple-effect" for="windows.onRemoved">
                            <input type="radio" name="event" value="windows.onRemoved" class="mdl-radio__button" id="windows.onRemoved">
                            <span class="mdl-radio__label">Delete when window is closed</span>
                        </label>
                    </div>
                </div>
                <div class="mdl-card__actions mdl-card--border">
                    <button class="mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect" id="save">
                        Save
                    </button>
                </div>
            </div>
        </div>
    </div>
    <script src="../js/options.js"></script>
    <script defer src="../js/material.min.js"></script>
</body>
</html>

<style type="text/css">
    .mdl-card {
        width: 100%;
    }
    div {
        padding: 8px;
    }
    textarea {
        width: 100px;
    }
</style>
```

在 `js` 資料夾建立選項程式 `options.js` 檔：

```JS
// 儲存選項
const saveOptions = () => {
  const keywords = document.querySelector('textarea[name="keywords"]').value;
  const event = document.querySelector('input[name="event"]:checked').value;

  chrome.storage.sync.set({
    keywords,
    event,
  }, () => {
    window.close();
  });
};

// 回填選項
const restoreOptions = () => {
  chrome.storage.sync.get({
    keywords: '',
    event: 'history.onVisited',
  }, (items) => {
    document.querySelector('textarea[name="keywords"]').value = items.keywords;
    document.querySelector(`input[value="${items.event}"]`).checked = true;
  });
};

document.addEventListener('DOMContentLoaded', restoreOptions);
document.getElementById('save').addEventListener('click', saveOptions);
```

## 主要程式

在 `js` 資料夾建立主要程式 `main.js` 檔：

```JS
const execute = () => {
  // 從 storage 獲得使用者希望刪除的關鍵字選項
  chrome.storage.sync.get({
    keywords: '',
  }, (items) => {
    const keywords = items.keywords.split('\n');

    keywords.forEach((keyword) => {
      // 利用 search 方法搜尋歷史紀錄
      chrome.history.search({
        text: keyword,
      }, (records) => {
        records.forEach((record) => {
          // 利用 deleteUrl 方法刪除歷史紀錄
          chrome.history.deleteUrl({
            url: record.url,
          }, () => {
            console.info(`Deleted record: ${record.url}`);
          });
        });
      });
    });
  });
};

const handle = () => {
  // 從 storage 獲得使用者希望觸發的事件選項
  chrome.storage.sync.get({
    event: '',
  }, (items) => {
    switch (items.event) {
      // 在進入頁面時觸發
      case 'history.onVisited': {
        chrome.history.onVisited.addListener(execute);
        break;
      }
  
      // 在關閉視窗時觸發
      case 'windows.onRemoved': {
        chrome.windows.onRemoved.addListener(execute);
        break;
      }
  
      default: {
        break;
      }
    }
  });
};

// 在選項變更時觸發
chrome.storage.onChanged.addListener(handle);

handle();
```

新增 `icon.png` 檔。

前往[擴充功能](chrome://extensions/)打開「開發人員模式」，點選「載入未封裝項目」。
