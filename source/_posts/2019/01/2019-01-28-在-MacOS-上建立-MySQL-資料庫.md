---
title: 在 macOS 上建立 MySQL 資料庫
date: 2019-01-28 15:43:46
tags: ["Database", "MySQL", "macOS"]
categories: ["Database", "MySQL"]
---

## 安裝

使用 `brew` 安裝 MySQL。

```bash
brew install mysql
```

使用 `brew services` 啟動 MySQL。

```bash
brew services start mysql
```

或使用以下指令：

```bash
mysql.server start
```

使用 `brew services` 停止 MySQL。

```bash
brew services stop mysql
```

或使用以下指令：

```bash
mysql.server stop
```

使用 `brew services` 重新啟動 MySQL。

```bash
brew services restart mysql
```

或使用以下指令：

```bash
mysql.server restart
```

## 連線

設定 `root` 使用者密碼。

```bash
mysqladmin -u root password
```

使用 `root` 使用者進入資料庫。

```bash
mysql -u root -p
```

建立使用者。

```sql
> CREATE USER 'admin'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
```

設定權限。

```sql
> GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost';
> FLUSH PRIVILEGES;
> quit;
```

使用 `admin` 使用者進入資料庫。

```bash
mysql -u admin -p
```
