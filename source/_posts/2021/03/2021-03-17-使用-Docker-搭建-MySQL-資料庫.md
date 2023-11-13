---
title: 使用 Docker 搭建 MySQL 資料庫
date: 2021-03-17 23:11:26
tags: ["Database", "MySQL", "SQL", "Docker"]
categories: ["Database", "MySQL"]
---

## 做法

下載並啟動 `mysql/mysql-server` 映像檔。

```bash
docker run -d --name=mysql -p 3306:3306 mysql/mysql-server
```

等待 `health` 狀態從 `starting` 變成 `healthy` 後，使用以下指令取得初始密碼。

```bash
docker logs mysql 2>&1 | grep GENERATED
```

使用初始密碼進入容器。

```bash
docker exec -it mysql mysql -uroot -p
```

修改使用者密碼。

```sql
mysql> ALTER user 'root'@'localhost' identified by 'root';
mysql> UPDATE mysql.user SET Host='%' WHERE Host='localhost' AND User='root';
mysql> FLUSH PRIVILEGES;
```

## 參考資料

- [mysql/mysql-server](https://hub.docker.com/r/mysql/mysql-server/)
