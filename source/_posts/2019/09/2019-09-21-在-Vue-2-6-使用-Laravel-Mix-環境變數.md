---
title: 在 Vue 2.6 使用 Laravel Mix 環境變數
date: 2019-09-21 12:05:19
tags: ["Programming", "PHP", "Laravel", "JavaScript", "Vue", "Mix"]
categories: ["Programming", "PHP", "Laravel"]
---

## 做法

修改 Laravel 專案的 `.env` 檔：

```env
APP_URL=http://127.0.0.1:8000

MIX_APP_URL="${APP_URL}"
```

在 Vue 專案中使用：

```js
console.log(process.env.MIX_APP_URL);
```

## 參考資料

- [Laravel Mix](https://laravel.com/docs/6.x/mix#environment-variables)
