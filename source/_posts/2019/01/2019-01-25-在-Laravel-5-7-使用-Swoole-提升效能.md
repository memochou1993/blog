---
title: 在 Laravel 5.7 使用 Swoole 提升效能
permalink: 在-Laravel-5-7-使用-Swoole-提升效能
date: 2019-01-25 14:18:31
tags: ["程式設計", "PHP", "Laravel", "Swoole"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 環境

- macOS
- PHP 7.2
- Nginx 1.15.8
- Swoole 4.2.12

## 建立專案

```BASH
laravel new swoole
```

## 安裝套件

```BASH
composer require swooletw/laravel-swoole
```

## 啟動伺服器

```BASH
php artisan swoole:http start
```

## 設置 Nginx 反向代理

在 `/usr/local/etc/nginx/servers` 資料夾新增 `swoole.test.conf` 檔：

```CONF
server {
  listen       80;
  server_name  swoole.test;

  location / {
    proxy_pass http://127.0.0.1:1215;
  }
}
```

在 `/private/etc/hosts` 檔新增以下內容：

```ENV
127.0.0.1 swoole.test
```

## 瀏覽網頁

前往 <http://swoole.test/>

## 參考資料

- [透過 Swoole 加速 Laravel 效能](https://blog.albert-chen.com/speed-up-laravel-with-swoole/)
