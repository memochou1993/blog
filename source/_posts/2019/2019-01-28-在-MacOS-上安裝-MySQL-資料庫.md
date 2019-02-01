---
title: 在 MacOS 上安裝 MySQL 資料庫
permalink: 在-MacOS-上安裝-MySQL-資料庫
date: 2019-01-28 15:43:46
tags: ["環境部署", "PHP", "MySQL", "macOS", "Laravel"]
categories: ["環境部署", "MySQL"]
---

## 安裝
使用 `brew` 指令安裝 MySQL。
```
$ brew install mysql
```

使用 `brew services` 啟動 MySQL。
```
$ brew services start mysql
```

或使用以下指令：
```
$ mysql.server start
```

使用 `brew services` 停止 MySQL。
```
$ brew services stop mysql
```

或使用以下指令：
```
$ mysql.server stop
```

使用 `brew services` 重新啟動 MySQL。
```
$ brew services restart mysql
```

或使用以下指令：
```
$ mysql.server restart
```

## 連線
設定 `root` 使用者密碼。
```
$ mysqladmin -u root password
```

使用 `root` 使用者進入資料庫。
```
$ mysql -u root -p
```

建立使用者。
```
> CREATE USER 'admin'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
```

設定權限。
```
> GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost';
> FLUSH PRIVILEGES;
> quit;
```

使用 `admin` 進入資料庫。
```
$ mysql -u admin -p
```
