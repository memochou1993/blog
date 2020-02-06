---
title: 在 macOS 上建立 Laradock 環境
permalink: 在-macOS-上建立-Laradock-環境
date: 2018-12-21 16:16:18
tags: ["環境部署", "macOS", "Docker", "Laradock", "Laravel"]
categories: ["環境部署", "Laradock"]
---

## 安裝 Docker

手動安裝 Docker，並註冊帳號。開啟終端機，登入 Docker。

```BASH
docker login
```

- 輸入使用者名稱（而非電子郵件）。

## 安裝 Laradock

從 GitHub 上下載 Laradock 到根目錄。

```BASH
cd ~/
git clone https://github.com/laradock/laradock.git Laradock
cd Laradock
cp env-example .env
```

修改 `.env` 檔：

```ENV
APP_CODE_PATH_HOST=~/Projects
```

## 啟動 Laradock

建立 `laravel.test.conf` 檔。

```BASH
cd ~/Laradock/nginx/sites
cp laravel.conf.example laravel.test.conf
```

啟動 Nginx、MySQL 和 PhpMyAdmin。

```BASH
docker-compose up -d nginx mysql phpmyadmin
```

- 被 Nginx 依賴的 PHP-FPM 會自動啟動。

## 建立專案

在容器外建立專案。

```BASH
cd ~/Projects
laravel new laravel
```

修改 Laravel 專案的 `.env` 檔：

```ENV
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=default
DB_USERNAME=default
DB_PASSWORD=secret
```

## 進入 MySQL

修改 `mysql\my.cnf` 檔：

```CNF
[mysqld]
default_authentication_plugin=mysql_native_password
```

重新建立 MySQL 容器：

```BASH
docker-compose build --no-cache mysql
```

修改一般使用者的認證方式。

```BASH
docker-compose exec mysql bash
/var/www# mysql --user="root" --password="root"
mysql> ALTER USER 'default' IDENTIFIED WITH mysql_native_password BY 'secret';
mysql> exit
```

使用一般使用者身分進入。

```BASH
/var/www# mysql --user="default" --password="secret"
```

建立資料庫。

```MYSQL
mysql> CREATE DATABASE `default`;
```

## 進入容器

進入容器。

```BASH
cd ~/Laradock
docker-compose exec workspace bash
```

執行遷移。

```BASH
/var/www# cd laravel
/var/www# php artisan migrate
```

## 設定相關權限

進到 workspace 容器。

```BASH
docker-compose exec workspace bash
```

修改 `storage` 資料夾的權限。

```BASH
chown -R laradock:www-data storage
```

## 註冊虛擬主機別名

```ENV
127.0.0.1 laravel.test
```

## 測試

專案首頁：<http://laravel.test/>
phpMyAdmin 登入畫面：<http://localhost:8080/>
