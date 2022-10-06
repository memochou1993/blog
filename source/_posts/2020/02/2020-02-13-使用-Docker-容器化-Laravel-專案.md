---
title: 使用 Docker 容器化 Laravel 專案
date: 2020-02-13 02:13:08
tags: ["環境部署", "Docker", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "環境部署"]
---

## 建立專案

建立專案。

```bash
laravel new laravel
```

修改 `.env` 檔：

```env
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=root
```

## 容器化

新增 `docker-compose.yaml` 檔：

```yaml
version: "3"

services:
  app:
    container_name: laravel
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - ./:/var/www
    env_file: .env
    depends_on:
      - database
    networks:
      - backend

  web:
    image: nginx:alpine
    container_name: nginx
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
    depends_on:
      - app
    ports:
      - "8990:80"
    networks:
      - backend

  database:
    image: mysql:latest
    container_name: mysql
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

新增 `Dockerfile` 檔：

```dockerfile
FROM php:7.2-fpm

RUN apt-get update \
    && apt-get -y install zip

WORKDIR /var/www

COPY . /var/www

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer install --optimize-autoloader --no-dev --no-scripts

RUN chown -R www-data:www-data \
    /var/www/storage \
    /var/www/bootstrap/cache

RUN apt-get install -y libmcrypt-dev \
    libmagickwand-dev --no-install-recommends \
    && pecl install mcrypt-1.0.2 \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-enable mcrypt
```

新增 `.dockerignore` 檔：

```env
.git
.gitignore
.env.*
node_modules
vendor
```

新增一個 `nginx` 資料夾，並新增 `default.conf` 檔：

```conf
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

編譯並啟動容器：

```bash
docker-compose up -d --build
```

前往 <http://localhost:8990/> 瀏覽。

## 程式碼

- [laravel-docker-example](https://github.com/memochou1993/laravel-docker-example)

## 參考資料

- [Deploying Your Laravel App on Docker, With NGINX and MySQL](https://dev.to/baliachbryan/deploying-your-laravel-app-on-docker-with-nginx-and-mysql-56ni)
