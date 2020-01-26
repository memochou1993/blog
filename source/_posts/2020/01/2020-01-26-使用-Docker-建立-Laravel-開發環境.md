---
title: 使用 Docker 建立 Laravel 開發環境
permalink: 使用-Docker-建立-Laravel-開發環境
date: 2020-01-26 16:53:29
tags: ["環境部署", "Docker", "PHP", "Laravel"]
categories: ["環境部署", "Docker"]
---

## 建立專案

建立專案。

```BASH
laravel new dockerize-laravel-example
```

修改 `routes/api.php` 檔，避免使用預設的閉包路由：

```PHP
//
```

修改 `routes/web.php` 檔，避免使用預設的閉包路由：

```PHP
Route::get('/', 'Controller@welcome');
```

修改 `app/Http/Controllers/Controller.php` 檔：

```PHP
namespace App\Http\Controllers;

use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Bus\DispatchesJobs;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Routing\Controller as BaseController;

class Controller extends BaseController
{
    use AuthorizesRequests, DispatchesJobs, ValidatesRequests;

    public function welcome()
    {
        return view('welcome');
    }
}
```

## 建立設定檔

在根目錄新增 `docker-compose.yml` 檔：

```YML
docker-compose.yml
version: "3"

services:
  app:
    container_name: laravel
    build:
      context: ./
      dockerfile: docker/app.dockerfile
    volumes:
      - ./storage:/var/www/storage
    env_file: '.env.prod'
    environment:
      - "DB_HOST=database"
      - "REDIS_HOST=cache"

  web:
    container_name: laravel_nginx
    build:
      context: ./
      dockerfile: docker/web.dockerfile
    volumes:
      - ./storage/logs/:/var/log/nginx
    ports:
      - 8990:80

  database:
    container_name: laravel_mysql
    image: mysql:5.7
    volumes:
      - dbdata:/var/lib/mysql
    environment:
      - "MYSQL_DATABASE=laravel"
      - "MYSQL_USER=root"
      - "MYSQL_PASSWORD=root"
      - "MYSQL_ROOT_PASSWORD=root"
    ports:
      - 8991:3306

  cache:
    container_name: laravel_redis
    image: redis:3.0-alpine

volumes:
  dbdata:
```

複製 `.env` 到 `.env.prod`，並修改相關參數：

```ENV
DB_CONNECTION=mysql
DB_HOST=laravel_mysql
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=root
```

將 `.env.prod` 加進 `.gitignore` 檔中。

```ENV
/node_modules
/public/hot
/public/storage
/storage/*.key
/vendor
.env
.env.backup
.env.prod
.phpunit.result.cache
Homestead.json
Homestead.yaml
npm-debug.log
yarn-error.log
```

在根目錄新增 `docker` 資料夾。

在 `docker` 資料夾中新增 `app.dockerfile` 檔：

```DOCKERFILE
FROM php:7.2-fpm

COPY composer.lock composer.json /var/www/

COPY database /var/www/database

WORKDIR /var/www

RUN apt-get update \
    && apt-get -y install git \
    && apt-get -y install zip

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === 'c5b9b6d368201a9db6f74e2611495f369991b72d9c8cbd3ffbc63edff210eb73d46ffbfce88669ad33695ef77dc76976') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && php composer.phar install --optimize-autoloader --no-dev --no-scripts \
    && rm composer.phar

COPY . /var/www

RUN chown -R www-data:www-data \
    /var/www/storage \
    /var/www/bootstrap/cache

RUN  apt-get install -y libmcrypt-dev \
    libmagickwand-dev --no-install-recommends \
    && pecl install mcrypt-1.0.2 \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-enable mcrypt

RUN mv .env.prod .env

RUN php artisan config:cache
```

在 `docker` 資料夾中新增 `web.dockerfile` 檔：

```DOCKERFILE
FROM nginx:1.10-alpine

ADD docker/default.conf /etc/nginx/conf.d/default.conf

COPY public /var/www/public
```

在 `docker` 資料夾中新增 `default.conf` 檔：

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
        fastcgi_pass app:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```

在 `docker` 資料夾中新增 `.dockerignore` 檔：

```ENV
.git
.idea
.env
node_modules
vendor
storage/framework/cache/**
storage/framework/sessions/**
storage/framework/testing/**
storage/framework/views/**
docker
```

執行指令：

```BASH
docker-compose up -d --build database && docker-compose up -d --build app && docker-compose up -d --build web
```

前往：<http://localhost:8990/>

進入容器：

```BASH
docker exec -it laravel bash
```

## 程式碼

[GitHub](https://github.com/memochou1993/docker-laravel-nginx)

## 參考資料

- [Deploying Your Laravel App on Docker, With NGINX and MySQL](https://dev.to/baliachbryan/deploying-your-laravel-app-on-docker-with-nginx-and-mysql-56ni)
