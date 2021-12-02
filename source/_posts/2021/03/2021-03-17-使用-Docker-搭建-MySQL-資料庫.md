---
title: 使用 Docker 搭建 MySQL 資料庫
permalink: 使用-Docker-搭建-MySQL-資料庫
date: 2021-03-17 23:11:26
tags: ["資料庫", "MySQL", "SQL", "資料庫", "Docker"]
categories: ["資料庫", "MySQL"]
---

## 環境

- macOS (M1)
- Docker Desktop preview

## 做法

下載並啟動 `mysql/mysql-server` 映像檔。

```BASH
docker run --name=mysql -d -p 3306:3306 mysql/mysql-server
```

等待 `health` 狀態從 `starting` 變成 `healthy` 後，使用以下指令取得初始密碼。

```BASH
docker logs mysql 2>&1 | grep GENERATED
```

使用初始密碼進入容器。

```BASH
docker exec -it mysql mysql -uroot -p
```

修改使用者密碼。

```MYSQL
mysql> ALTER user 'root'@'localhost' identified by 'root';
mysql> UPDATE mysql.user SET Host='%' WHERE Host='localhost' AND User='root';
mysql> FLUSH PRIVILEGES;
```

## 參考資料

[mysql/mysql-server](https://hub.docker.com/r/mysql/mysql-server/)
