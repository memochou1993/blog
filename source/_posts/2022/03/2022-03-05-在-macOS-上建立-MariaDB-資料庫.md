---
title: 在 macOS 上建立 MariaDB 資料庫
permalink: 在-macOS-上建立-MariaDB-資料庫
date: 2022-03-05 23:17:44
tags: ["資料庫", "MySQL", "MariaDB", "SQL", "資料庫", "Docker"]
categories: ["資料庫", "MySQL"]
---

## 安裝

下載並啟動 `mariadb` 映像檔。由於 `root` 為預設使用者，因此 `MARIADB_USER` 和 `MARIADB_PASSWORD` 參數可以為空。

```BASH
docker run -d --name mariadb -p 3306:3306 -e MARIADB_USER= -e MARIADB_PASSWORD= -e MARIADB_ROOT_PASSWORD=root mariadb
```

使用初始密碼進入容器。

```BASH
docker exec -it mariadb mysql -uroot -proot
```

## 參考資料

[mariadb](https://hub.docker.com/_/mariadb)
