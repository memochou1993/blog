---
title: 將使用 Docker 容器化的專案部署至 Heroku 平台
date: 2021-12-19 22:04:39
tags: ["Deployment", "Heroku", "Cloud Computing Service", "Docker"]
categories: ["Cloud Computing Service", "Heroku"]
---

## 做法

登入 Heroku CLI。

```bash
heroku container:login
```

進入專案目錄。

```bash
cd my-project
```

在 Heroku 建立應用程式，同時會建立一個容器儲存庫。

```bash
heroku create
```

創建應用程式的映像檔，並推送到 Heroku 容器儲存庫。

```bash
heroku container:push web
```

釋出映像檔，並啟動應用程式。

```bash
heroku container:release web
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

- [Container Registry & Runtime (Docker Deploys)](https://devcenter.heroku.com/articles/container-registry-and-runtime)
