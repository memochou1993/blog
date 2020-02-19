---
title: 在 macOS 上安裝 PHP 和 Nginx 網頁伺服器
permalink: 在-macOS-上安裝-PHP-和-Nginx-網頁伺服器
date: 2019-01-24 10:35:48
tags: ["程式寫作", "PHP", "Nginx", "macOS", "Laravel"]
categories: ["程式寫作", "PHP", "環境安裝"]
---

## 安裝 PHP

使用 `brew` 指令安裝 PHP。

```BASH
brew install php@7.2
```

啟動 PHP 服務。

```BASH
brew services start php@7.2
```

關閉 PHP 服務。

```BASH
brew services stop php@7.2
```

## 安裝 Nginx

使用 `brew` 指令安裝 Nginx。

```BASH
brew install nginx
```

啟動 Nginx 服務。

```BASH
sudo nginx
```

停止 Nginx 服務。

```BASH
sudo nginx -s stop
```

重啟 Nginx 服務。

```BASH
sudo nginx -s reload
```

修改 `/usr/local/etc/nginx/nginx.conf` 檔的 `fastcgi_param` 參數：

```CONF
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

```PHP
phpinfo();
```

## 瀏覽網頁

前往：<http://localhost:8080/index.php>
