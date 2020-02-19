---
title: 在 MacOS 上安裝 MySQL 資料庫
permalink: 在-MacOS-上安裝-MySQL-資料庫
date: 2019-01-28 15:43:46
tags: ["資料庫", "MySQL", "macOS"]
categories: ["資料庫", "MySQL"]
---

## 安裝

使用 `brew` 指令安裝 MySQL。

```BASH
brew install mysql
```

使用 `brew services` 啟動 MySQL。

```BASH
brew services start mysql
```

或使用以下指令：

```BASH
mysql.server start
```

使用 `brew services` 停止 MySQL。

```BASH
brew services stop mysql
```

或使用以下指令：

```BASH
mysql.server stop
```

使用 `brew services` 重新啟動 MySQL。

```BASH
brew services restart mysql
```

或使用以下指令：

```BASH
mysql.server restart
```

## 連線

設定 `root` 使用者密碼。

```BASH
mysqladmin -u root password
```

使用 `root` 使用者進入資料庫。

```BASH
mysql -u root -p
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

使用 `admin` 使用者進入資料庫。

```BASH
mysql -u admin -p
```
