---
title: 使用 Docker 為 Laravel 專案建立映像檔
permalink: 使用-Docker-為-Laravel-專案建立映像檔
date: 2019-02-11 16:13:50
tags: ["環境部署", "Docker", "PHP", "Laravel"]
categories: ["環境部署", "Docker"]
---

## 環境
- macOS

## 做法
建立專案。
```
$ laravel new laravel-example
$ cd laravel-example
```

在專案根目錄新增 `Dockerfile` 檔。
```Dockerfile
FROM php:7
RUN apt-get update -y && apt-get install -y openssl zip unzip git
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN docker-php-ext-install pdo mbstring
WORKDIR /app
COPY . /app
RUN composer install

CMD php artisan serve --host=0.0.0.0 --port=8181
EXPOSE 8181
```

建立映像檔。
```
$ docker build -t <USERNAME>/laravel-example:latest .
```

啟動服務。
```
$ docker run -d -p 8181:8181 <USERNAME>/laravel-example:latest
```

推送映像檔。
```
$ docker push <USERNAME>/laravel-example:latest
```

## 參考資料
[Laravel in Docker](https://buddy.works/guides/laravel-in-docker)
