---
title: 在 Laradock 使用 Certbot 為網站設置 HTTPS 連線
date: 2019-09-27 21:49:02
tags: ["環境部署", "Laradock", "SSL", "HTTPS", "Nginx"]
categories: ["環境部署", "Laradock"]
---

## 安裝套件

更新 apt 套件工具。

```BASH
sudo apt update && sudo apt upgrade
```

新增套件儲存庫。

```BASH
sudo add-apt-repository ppa:certbot/certbot
```

安裝 `certbot` 套件。

```BASH
sudo apt install certbot
```

新增使用萬用字元的網域憑證。

```BASH
sudo certbot -d *.epoch.tw --manual --preferred-challenges dns certonly --server https://acme-v02.api.letsencrypt.org/directory
```

第一次會出現類似以下訊息：

```BASH
lease deploy a DNS TXT record under the name
_acme-challenge.frdm.info with the following value:

xxxxxxxxxxxxxxxxxx
```

將內容複製起來，在 DNS 新增一筆 TEXT 紀錄：

| Hostname | Value |
| --- | --- |
| _acme-challenge | xxxxxxxxxxxxxxxxxx |

使用 [DNS Lookup Text Record](https://mxtoolbox.com/TXTLookup.aspx) 工具查看紀錄是否已生效；生效後，按下 Enter。

將 `/etc/letsencrypt/live` 資料夾的 `epoch.tw` 資料夾改名為 `*.epoch.tw`。

## 設定 Nginx

修改 `Laradock` 資料夾的 `docker-compose.yml` 檔。

```BASH
cd Laradock
vi docker-compose.yml
```

設定 `nginx` 的 `volumes` 參數，新增一個 `letsencrypt` 映射目錄：

```YML
### NGINX Server #########################################
    nginx:
      build:
        context: ./nginx
        args:
          - PHP_UPSTREAM_CONTAINER=${NGINX_PHP_UPSTREAM_CONTAINER}
          - PHP_UPSTREAM_PORT=${NGINX_PHP_UPSTREAM_PORT}
          - CHANGE_SOURCE=${CHANGE_SOURCE}
      volumes:
        - ${APP_CODE_PATH_HOST}:${APP_CODE_PATH_CONTAINER}${APP_CODE_CONTAINER_FLAG}
        - ${NGINX_HOST_LOG_PATH}:/var/log/nginx
        - ${NGINX_SITES_PATH}:/etc/nginx/sites-available
        - ${NGINX_SSL_PATH}:/etc/nginx/ssl
        - /etc/letsencrypt/:/var/letsencrypt # 新增此行
      ports:
        - "${NGINX_HOST_HTTP_PORT}:80"
        - "${NGINX_HOST_HTTPS_PORT}:443"
      depends_on:
        - php-fpm
      networks:
        - frontend
```

將要安裝 SSL 憑證的 Nginx 設定檔改為：

```CONF
server {
    listen 80;
    listen [::]:80;
    server_name json.epoch.tw;
    return 301 https://$server_name$request_uri;
}

server {

    # For https
    listen 443 ssl;
    listen [::]:443 ssl;
    ssl_certificate /var/letsencrypt/live/*.epoch.tw/fullchain.pem;
    ssl_certificate_key /var/letsencrypt/live/*.epoch.tw/privkey.pem;

    server_name json.epoch.tw;
    root /var/www/json-editor/public;
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

    error_log /var/log/nginx/json_error.log;
    access_log /var/log/nginx/json_access.log;
}
```

- 監聽 443 埠號的區段，若有 `ipv6only=on` 的設定的話，需要刪除。

重啟 Nginx。

```BASH
docker-compose restart nginx
```
