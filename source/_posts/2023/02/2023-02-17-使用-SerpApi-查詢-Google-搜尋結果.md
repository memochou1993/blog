---
title: 使用 SerpApi 查詢 Google 搜尋結果
date: 2023-02-17 03:14:01
tags: ["程式設計", "JavaScript"]
categories: ["程式設計", "JavaScript", "其他"]
---

## 做法

首先，到 [SerpApi](https://serpapi.com/) 註冊帳號，選擇一個方案，將 API Key 複製起來。

### 發送請求

使用 `fetch` 發送請求。

```js
await (await fetch('https://serpapi.com/search?key=your-api-key&lr=lang_zh-TW&q=台灣')).json()
```

## 參考資料

- [SerpApi - Google Search Engine Results API](https://serpapi.com/search-api)
