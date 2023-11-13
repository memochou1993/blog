---
title: 使用 Google Custom Search JSON API 查詢客製化搜尋引擎
date: 2023-02-17 02:33:18
tags: ["Programming", "JavaScript", "Google APIs"]
categories: ["Programming", "JavaScript", "Others"]
---

## 做法

首頁，在 [Programmable Search Engine](https://programmablesearchengine.google.com/controlpanel/create?hl=zh-tw) 建立一個客製化搜尋引擎，將搜尋引擎 ID 複製起來。

在 [Google Cloud](https://console.cloud.google.com/getting-started) 新增一個專案，並且建立憑證，將 API 金鑰複製起來。

最後，啟用 [Custom Search API](https://console.cloud.google.com/apis/library/customsearch.googleapis.com) 產品。

### 發送請求

使用 `fetch` 發送請求。

```js
await (await fetch('https://customsearch.googleapis.com/customsearch/v1?key=your-api-key&cx=your-search-engine-id&lr=lang_zh-TW&q=台灣')).json()
```

## 參考資料

- [Programmable Search Engine](https://developers.google.com/custom-search)
- [Custom Search JSON API](https://developers.google.com/custom-search/v1/introduction)
