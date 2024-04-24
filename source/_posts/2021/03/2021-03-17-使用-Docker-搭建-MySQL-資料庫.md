---
title: 使用 Docker 搭建 MySQL 資料庫
date: 2021-03-17 23:11:26
tags: ["Database", "MySQL", "SQL", "Docker"]
categories: ["Database", "MySQL"]
---

## 做法

下載並啟動 `mysql` 映像檔。

```bash
docker run -p 3306:3306 --name mysql -e MYSQL_ROOT_PASSWORD=root -d mysql:latest
```

進入容器，並使用初始密碼進行連線。

```bash
docker exec -it mysql_36 mysql -uroot -proot
```

查看使用者。

```sql
mysql> SELECT host, user, plugin, authentication_string FROM mysql.user;
```

修改初始密碼。

```sql
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';
mysql> FLUSH PRIVILEGES;
```

## 參考資料

- [Docker Hub - mysql](https://hub.docker.com/_/mysql)
