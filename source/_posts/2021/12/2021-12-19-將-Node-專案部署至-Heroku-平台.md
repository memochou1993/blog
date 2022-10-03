---
title: 將 Node 專案部署至 Heroku 平台
date: 2021-12-19 21:47:09
tags: ["程式設計", "JavaScript", "Node", "Heroku"]
categories: ["程式設計", "JavaScript", "環境部署"]
---

## 做法

安裝 `heroku` 指令。

```BASH
brew install heroku/brew/heroku
```

登入 Heroku CLI。

```BASH
heroku login
```

進入專案目錄。

```BASH
cd my-project
```

在 Heroku 建立應用程式，同時會建立一個名叫 `heroku` 的遠端儲存庫。

```BASH
heroku create
```

將程式碼推送到 `heroku` 遠端儲存庫。

```BASH
git push heroku master
```

確保至少有一個應用程式實體正在運行。

```BASH
heroku ps:scale web=1
```

開啟應用程式。

```BASH
heroku open
```

查看日誌。

```BASH
heroku logs --tail
```

如果要刪除應用程式，執行以下指令。

```BASH
heroku apps:destroy
```

## 參考資料

- [Getting Started on Heroku with Node.js](https://devcenter.heroku.com/articles/getting-started-with-nodejs)
