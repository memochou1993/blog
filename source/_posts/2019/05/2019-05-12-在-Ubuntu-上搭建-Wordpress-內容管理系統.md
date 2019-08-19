---
title: 在 Ubuntu 上搭建 Wordpress 內容管理系統
permalink: 在-Ubuntu-上搭建-Wordpress-內容管理系統
date: 2019-05-12 01:16:39
tags: ["環境部署", "Linux", "Ubuntu", "PHP", "Wordpress"]
categories: ["環境部署", "Wordpress"]
---

## 環境

- Ubuntu 18.04 LTS
- Laradock

## 做法

啟動容器

```BASH
cd ~/Laradock
$ docker-compose up -d nginx mysql
```

建立資料庫。

```BASH
docker-compose exec mysql bash
# mysql -u root -p
> CREATE DATABASE `wordpress`
```

下載 Wordpress。

```BASH
cd /var/www/
$ wget http://wordpress.org/latest.tar.gz
$ tar xvf latest.tar.gz
$ rm latest.tar.gz
```

設定權限。

```BASH
cd ~/Laradock
$ docker-compose exec workspace bash
# cd wordpress
# chown -R laradock:www-data ./
```

在 `~/Laradock/nginx/sites` 資料夾新增 `wordpress.epoch.tw.conf` 檔。

```CONF
server {
  listen 80;
  listen [::]:80;

  # For https
  # listen 443 ssl;
  # listen [::]:443 ssl ipv6only=on;
  # ssl_certificate /etc/nginx/ssl/default.crt;
  # ssl_certificate_key /etc/nginx/ssl/default.key;

  server_name wordpress.xxx.com;
  root /var/www/wordpress;
  index index.php index.html index.htm;

  location / {
     try_files $uri $uri/ /index.php$is_args$args;
  }

  location ~ \.php$ {
    try_files $uri /index.php =404;
    fastcgi_pass php-upstream;
    fastcgi_index index.php;
    fastcgi_buffers 16 16k;
    fastcgi_buffer_size 32k;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    #fixes timeouts
    fastcgi_read_timeout 600;
    include fastcgi_params;
  }

  location ~ /\.ht {
    deny all;
  }

  location /.well-known/acme-challenge/ {
    root /var/www/letsencrypt/;
    log_not_found off;
  }

  error_log /var/log/nginx/wordpress_error.log;
  access_log /var/log/nginx/wordpress_access.log;
}
```

重新啟動 Nginx 容器。

```BASH
docker-compose restart nginx
```

前往 http://wordpress.xxx.com

## 補充

如果為 Laradock 環境，資料庫的 `host` 欄位應設為 `mysql`。
