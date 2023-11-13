---
title: 使用 Docker 搭建 phpMyAdmin 資料庫管理工具
date: 2022-11-17 03:11:35
tags: ["Database", "MySQL", "SQL", "Docker", "phpMyAdmin"]
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

下載並啟動 `phpmyadmin` 映像檔。

```bash
docker run --name phpmyadmin -d --link mysql:db -p 8080:80 phpmyadmin
```

前往 <http://localhost:8080> 瀏覽。

## 參考資料

- [phpmyadmin](https://hub.docker.com/_/phpmyadmin)
