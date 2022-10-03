---
title: 在 Laradock 中使用 Guzzle Http 請求套件
date: 2019-03-12 23:01:28
tags: ["環境部署", "Nginx", "Laravel", "Laradock", "Guzzle"]
categories: ["環境部署", "Laradock"]
---

## 安裝套件

```BASH
composer require guzzlehttp/guzzle
```

## 使用

```PHP
use GuzzleHttp\Client;

$client = new Client([
    'base_uri' => 'http://laravel.test',
]);

$response = $client->post('/oauth/token', [
    'form_params' => $this->request->all(),
]);

return $response->getBody();
```

## 連線錯誤

在 Laradock 中，專案之間使用 Guzzsle 發出 HTTP 請求時，會出現以下錯誤：

```TEXT
cURL error 7: Failed to connect to laravel.test port 80: Connection refused
```

此時，需要修改 `Laradock` 資料夾的 `docker-compose.yml` 檔，在 `nginx` 的 `networks` 參數下設置別名，當 Nginx 容器啟動時，配置會自動生效：

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
      ports:
        - "${NGINX_HOST_HTTP_PORT}:80"
        - "${NGINX_HOST_HTTPS_PORT}:443"
      depends_on:
        - php-fpm
      networks:
        frontend:
          aliases:
            - laravel.test
        backend:
          aliases:
            - laravel.test
```
