---
title: 在 macOS 上安裝 Nginx 網頁伺服器
date: 2019-01-24 10:35:48
tags: ["Deployment", "Web Server", "Nginx", "macOS"]
categories: ["Deployment", "Web Server"]
---

## 安裝

使用 `brew` 安裝 Nginx。

```bash
brew install nginx
```

啟動 Nginx 服務。

```bash
sudo nginx
```

停止 Nginx 服務。

```bash
sudo nginx -s stop
```

重啟 Nginx 服務。

```bash
sudo nginx -s reload
```

## 站點

修改 `/usr/local/etc/nginx/nginx.conf` 檔的 `fastcgi_param` 參數：

```conf
# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
#
location ~ \.php$ {
    root           html;
    fastcgi_pass   127.0.0.1:9000;
    fastcgi_index  index.php;
    fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
    include        fastcgi_params;
}
```

在 `/usr/local/var/www` 目錄新增 `index.php` 檔：

```php
phpinfo();
```

## 瀏覽網頁

前往 <http://localhost:8080/index.php> 瀏覽。
