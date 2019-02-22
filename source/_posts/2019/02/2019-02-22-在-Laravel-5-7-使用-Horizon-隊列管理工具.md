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
### 一般使用
啟動 Laradock。
```
$ cd ~/Laradock
$ docker-compose up -d nginx redis phpmyadmin laravel-horizon
```

建立專案。
```
$ laravel new horizon
$ cd horizon
```

修改 `.env` 檔。
```
DB_HOST=mysql #改為 mysql（Laradock 環境）

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

讓 Supervisord 在啟動時 Horizon。
```
php artisan horizon
```

前往：http://echo.test/horizon

### Supervisord
如果要讓 Laradock 自動啟動 Horizon，需要複製範本 `laravel-horizon.conf.example` 檔作為設定檔。
```
$ cd ~Laradock/laravel-horizon/supervisord.d
$ cp laravel-horizon.conf.example echo-horizon.conf
```

修改 `echo-horizon.conf` 檔。
```CONF
[program:echo-horizon]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/echo/artisan horizon
autostart=true
autorestart=true
redirect_stderr=true
```
- 參數 `command` 必須指向專案下的 `artisan` 腳本。

重新讀取設定檔。
```
$ docker-compose exec laravel-horizon ash
/etc/supervisor/conf.d # supervisorctl reread
/etc/supervisor/conf.d # supervisorctl update
```
