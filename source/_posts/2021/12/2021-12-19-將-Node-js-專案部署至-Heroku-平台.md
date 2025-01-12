---
title: 將 Node.js 專案部署至 Heroku 平台
date: 2021-12-19 21:47:09
tags: ["Programming", "JavaScript", "Node.js", "Heroku"]
categories: ["Programming", "JavaScript", "Deployment"]
---

## 做法

安裝 `heroku` 指令。

```bash
brew install heroku/brew/heroku
```

登入 Heroku CLI。

```bash
heroku login
```

進入專案目錄。

```bash
cd my-project
```

在 Heroku 建立應用程式，同時會建立一個名叫 `heroku` 的遠端儲存庫。

```bash
heroku create
```

將程式碼推送到 `heroku` 遠端儲存庫。

```bash
git push heroku master
```

確保至少有一個應用程式實體正在運行。

```bash
heroku ps:scale web=1
```

開啟應用程式。

```bash
heroku open
```

查看日誌。

```bash
heroku logs --tail
```

如果要刪除應用程式，執行以下指令。

```bash
heroku apps:destroy
```

## 參考資料

- [Getting Started on Heroku with Node.js](https://devcenter.heroku.com/articles/getting-started-with-nodejs)
