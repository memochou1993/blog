---
title: 在 macOS 上建立 MariaDB 資料庫
date: 2022-03-05 23:17:44
tags: ["Database", "MariaDB", "SQL", "MySQL", "Docker"]
categories: ["Database", "MySQL"]
---

## 安裝

下載並啟動 `mariadb` 映像檔。由於 `root` 為預設使用者，因此 `MARIADB_USER` 和 `MARIADB_PASSWORD` 參數可以為空。

```bash
docker run -d --name mariadb -p 3306:3306 -e MARIADB_USER= -e MARIADB_PASSWORD= -e MARIADB_ROOT_PASSWORD=root mariadb
```

使用初始密碼進入容器。

```bash
docker exec -it mariadb mysql -uroot -proot
```

## 參考資料

- [mariadb](https://hub.docker.com/_/mariadb)
