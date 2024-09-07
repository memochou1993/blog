---
title: 使用 Vue 3 和 Express 實作內容管理系統（十）：實作後端日誌功能
date: 2024-08-07 20:36:31
tags: ["Programming", "JavaScript", "Vue", "Bootstrap", "Node", "Express", "Firebase", "Firestore", "CMS"]
categories: ["Programming", "JavaScript", "Vue"]
---

## 前言

本文是前端工作坊的教學文件，介紹如何使用 Vue 3 和 Express 實作內容管理系統，並搭配 Firebase 實現持久化和認證。

## 安裝依賴套件

> Ref: <https://github.com/expressjs/morgan>

安裝 `morgan` 套件，用來記錄 HTTP 請求。

```bash
npm install morgan
```

建立 `logging.js` 檔，實作日誌中介層。

```js
import fs from 'fs';
import morgan from 'morgan';
import path from 'path';

const logStream = fs.createWriteStream(path.join(import.meta.dirname, 'access.log'), { flags: 'a' });

const setupLogging = (toFile = false) => {
  if (toFile) {
    return morgan('combined', { stream: logStream });
  }
  return morgan('dev');
};

export default setupLogging;
```

修改 `index.js` 檔，啟用日誌中介層。

```js
// ...
import setupLogging from './logging.js';

// 啟用日誌
app.use(setupLogging(true));

// ...
```

建立一個 HTTP 請求。

```bash
curl http://localhost:3000/api
```

產生日誌如下：

```bash
::1 - - [07/Sep/2024:17:58:28 +0000] "GET /api HTTP/1.1" 200 27 "-" "curl/8.4.0"
```

提交修改。

```bash
git add .
git commit -m "Add logging middleware"
git push
```

## 程式碼

- [simple-cms-ui](https://github.com/memochou1993/simple-cms-ui)
- [simple-cms-api](https://github.com/memochou1993/simple-cms-api)
