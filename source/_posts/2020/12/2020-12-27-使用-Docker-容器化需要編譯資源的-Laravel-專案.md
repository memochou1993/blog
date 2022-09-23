---
title: 使用 Docker 容器化需要編譯資源的 Laravel 專案
permalink: 使用-Docker-容器化需要編譯資源的-Laravel-專案
date: 2020-12-27 15:15:37
tags: ["環境部署", "Docker", "PHP", "Laravel", "Mix"]
categories: ["程式設計", "PHP", "環境部署"]
---

## 前言

最近把 [JSON Editor](https://json.epoch.tw/) 專案容器化。此專案是一個前後端合併在一起的 SPA 專案，並且利用 Laravel Mix 整合 Vue CLI 專案，最後生成 Blade 檔和靜態檔案。

在容器化的過程中，發現使用 volume 掛載 public 資料夾到 Nginx 容器的話，永遠都會是空的，因為 Docker 在文件掛載的行為上，是將本機上的資料夾覆蓋至容器中的資料夾內容。因此最後決定將 Nginx 直接安裝在 PHP-FPM 映像檔中使用，而不是分成兩個容器。

## 做法

新增 `Dockerfile` 檔：

```YAML
version: "3"

services:
  app:
    container_name: json-editor
    build: .
    restart: always
    env_file: .env
    ports:
      - "80:80"
    networks:
      - backend

  mysql:
    image: mysql:5.7.32
    container_name: json-editor-mysql
    restart: always
    volumes:
      - mysql:/var/lib/mysql
    environment:
      - MYSQL_DATABASE=${DB_DATABASE}
      - MYSQL_USER=${DB_USERNAME}
      - MYSQL_PASSWORD=${DB_PASSWORD}
      - MYSQL_ROOT_PASSWORD=${DB_PASSWORD}
    ports:
      - "3306:3306"
    networks:
      - backend

networks:
  backend:

volumes:
  mysql:
```

新增 `docker-compose.yaml` 檔：

```DOCKERFILE
# 使用 Composer 映像檔下載依賴套件
FROM composer:2.0 as vendor

WORKDIR /app

COPY database database
COPY composer.json composer.lock  ./

# 下載依賴套件並更新
RUN composer install --optimize-autoloader --no-dev --no-scripts
RUN composer update --no-scripts

# 使用 Node 映像檔下載依賴套件
FROM node:lts-alpine as node

WORKDIR /app

# 必須全部複製，否則 Mix 生成的靜態資源檔會找不到對應的輸出路徑
COPY . .

# 下載依賴套件並執行編譯
RUN npm install \
    && npm run production

# 使用 PHP-FPM 映像檔當作環境
FROM php:7.2-fpm

WORKDIR /var/www

# 安裝需要的 PHP 擴展
RUN docker-php-ext-install pdo_mysql
RUN apt-get update \
    && apt-get install -y libgmp-dev re2c libmhash-dev libmcrypt-dev file \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/ \
    && docker-php-ext-configure gmp \
    && docker-php-ext-install gmp

# 直接將 Nginx 安裝在環境裡
RUN apt-get update \
    && apt-get install -y nginx

# 刪除預設的頁面
RUN rm -rf /var/www/html \
    && rm /etc/nginx/sites-enabled/default

# 複製所有檔案到環境
COPY . .
# 複製 Nginx 設定檔
COPY docker/nginx/conf.d /etc/nginx/conf.d
# 複製依賴套件
COPY --from=vendor /app/vendor vendor
# 複製靜態檔案
COPY --from=node /app/public public
# 複製啟動腳本
COPY docker/entrypoint.sh /etc/entrypoint.sh

# 設定權限
RUN chown -R www-data:www-data \
    /var/www/storage \
    /var/www/bootstrap/cache

# 暴露 80 埠號
EXPOSE 80

# 執行啟動腳本
ENTRYPOINT ["sh", "/etc/entrypoint.sh"]
```

新增 `docker/nginx/conf.d/default.conf` 檔：

```CONF
server {
    listen 80;

    index index.php index.html;

    root /var/www/public;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    location / {
        try_files $uri /index.php?$args;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```

新增 `docker/entrypoint.sh` 檔：

```BASH
#!/usr/bin/env bash

service nginx start
php-fpm
```

新增 `.dockerignore` 檔：

```ENV
.git
tests
vendor
*/node_modules
```

執行編譯並啟動。

```ENV
docker-compose up -d --build
```

## 瀏覽網頁

前往：<http://127.0.0.1:80>

## 後記

後來想到更簡單的方式是在本地端將打包好的靜態資源檔直接上版控，這樣在打包映像檔的時候就不需要再編譯一次靜態檔案。

## 程式碼

- [json-editor](https://github.com/memochou1993/json-editor/)

## 參考資料

- [Docker volume 掛載時文件或文件夾不存在](https://segmentfault.com/a/1190000015684472)
