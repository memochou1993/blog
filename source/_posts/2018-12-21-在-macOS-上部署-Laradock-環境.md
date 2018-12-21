---
title: 在 macOS 上部署 Laradock 環境
date: 2018-12-21 16:16:18
tags: ["環境部署", "macOS", "Docker", "Laradock", "Laravel"]
categories: ["環境部署", "Docker", "Laradock"]
---

## 環境
- macOS High Sierra

## 安裝 Laradock
從 GitHub 上下載 Laradock 到根目錄。
```
$ cd ~/
$ git clone https://github.com/laradock/laradock.git Laradock
$ cd Laradock
$ cp env-example .env
```

修改 `.env` 檔：
```
APP_CODE_PATH_HOST=~/Projects
```

## 啟動 Laradock
建立 `laravel.test.conf` 檔。
```
$ cd ~/Laradock/nginx/sites
$ cp laravel.conf.example laravel.test.conf
```

啟動 Nginx、MySQL 和 PhpMyAdmin。
```
$ docker-compose up -d nginx mysql mysql
```
- 被 Nginx 依賴的 PHP-FPM 會自動啟動。

## 建立專案
在容器外建立專案。
```
$ cd ~/Projects
$ laravel new laravel
```

修改 Laravel 專案的 `.env` 檔：
```
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=default
DB_USERNAME=default
DB_PASSWORD=secret
```

## 進入 MySQL
修改一般使用者的認證方式。
```
$ docker-compose exec mysql bash
/var/www# mysql --user="root" --password="root"
mysql> ALTER USER 'default' IDENTIFIED WITH mysql_native_password BY 'secret';
mysql> exit
```
使用一般使用者身分進入。
```
/var/www# mysql --user="default" --password="secret"
```
建立資料庫。
```
mysql> CREATE DATABASE `default`;
```

## 進入容器
進入容器。
```
$ cd ~/Laradock
$ docker-compose exec workspace bash
```
執行遷移。
```
/var/www# cd laravel
/var/www# php artisan migrate
```

## 註冊虛擬主機別名
```
127.0.0.1 laravel.test
```

## 測試
專案首頁：http://laravel.test/
phpMyAdmin 登入畫面：http://localhost:8080/
