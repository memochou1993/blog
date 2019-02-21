---
title: 在 Laravel 5.7 使用 Horizon 隊列管理工具
permalink: 在-Laravel-5-7-使用-Horizon-隊列管理工具
date: 2019-02-22 00:24:59
tags: ["程式寫作", "PHP", "Laravel", "Horizon"]
categories: ["程式寫作", "PHP", "Laravel"]
---

## 環境
- Laradock

## 步驟
啟動 Laradock。
```
$ docker-compose up -d nginx redis phpmyadmin
```

建立專案。
```
$ laravel new horizon
$ cd horizon
```

修改 `.env` 檔。
```
BROADCAST_DRIVER=redis #改為 redis
CACHE_DRIVER=file
QUEUE_CONNECTION=redis #改為 redis
SESSION_DRIVER=file
SESSION_LIFETIME=120

REDIS_HOST=redis #改為 redis（Laradock 環境）
REDIS_PASSWORD=null
REDIS_PORT=6379
```

安裝 `laravel/horizon` 套件。
```
$ composer require laravel/horizon
```

執行安裝。
```
$ php artisan horizon:install
```

建立 `failed-table` 遷移檔。
```
$ php artisan queue:failed-table
```

執行遷移。
```
$ php artisan migrate
```

啟動 Horizon。
```
php artisan horizon
```

前往：http://echo.test/horizon
