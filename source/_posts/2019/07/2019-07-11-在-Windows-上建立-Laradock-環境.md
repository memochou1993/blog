---
title: 在 Windows 上建立 Laradock 環境
date: 2019-07-11 17:36:20
tags: ["環境部署", "Windows", "Docker", "Laradock", "Laravel"]
categories: ["環境部署", "Laradock"]
---

## 環境

- Windows 10
- Docker for Windows 2.0.0.3

## 前言

以下採用單一專案的方式建立環境。

## 安裝 Laradock

從 GitHub 上將 Laradock 下載下來。

```bash
git clone https://github.com/Laradock/laradock.git Laradock
```

複製範本 `env-example` 檔作為設定檔。

```bash
cd Laradock
cp env-example .env
```

修改 `.env` 檔的 `APP_CODE_PATH_HOST` 參數到指定的映射路徑：

```env
APP_CODE_PATH_HOST=../Projects/laravel
```

使用 docker-compose 指令啟動 Laradock。

```bash
cd Laradock
docker-compose up -d nginx mysql phpmyadmin
```

## 設定 MySQL

修改 `mysql\my.cnf` 檔：

```cnf
[mysqld]
default_authentication_plugin=mysql_native_password
```

重新建立 MySQL 容器：

```bash
docker-compose build --no-cache mysql
```

進入 MySQL 容器。

```bash
docker-compose exec mysql bash
```

使用 root 使用者進入資料庫。

```bash
mysql -uroot -proot
```

查看所有使用者。

```sql
> SELECT user,authentication_string,plugin,host FROM mysql.user;
```

## 建立專案

建立專案資料夾。

```bash
cd Projects
mkdir laravel
```

使用 laradock 使用者進入 workspace 容器。

```bash
cd Laradock
docker-compose exec --user=laradock workspace bash
```

安裝 Laravel 安裝器。

```bash
laradock@107a4945c6fe:/var/www$ composer global require laravel/installer
```

建立專案。

```env
laradock@107a4945c6fe:/var/www$ laravel new
```

修改 `.env` 檔。

```env
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=default
DB_USERNAME=default
DB_PASSWORD=secret
```

執行遷移。

```bash
laradock@107a4945c6fe:/var/www$ php artisan migrate
```
