---
title: 在 macOS 上安裝 Nginx 網頁伺服器
permalink: 在-macOS-上安裝-Nginx-網頁伺服器
date: 2019-01-24 10:35:48
tags: ["環境部署", "PHP", "Nginx", "macOS", "Laravel"]
categories: ["環境部署", "Nginx"]
---

## 環境
- Homebrew 1.9.2

## 安裝
使用 `brew` 指令安裝。
```
$ brew install nginx
```
啟動。
```
nginx
```
停止。
```
nginx -s stop
```

## 瀏覽
前往：http://localhost:8080

## 設定
```
$ vi /usr/local/etc/nginx/nginx.conf
```

修改 `nginx.conf` 檔的 `root` 到專案目錄：
```CONF
# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
#
location ~ \.php$ {
    root           /Users/william/Projects;
    fastcgi_pass   127.0.0.1:9000;
    fastcgi_index  index.php;
    fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
    include        fastcgi_params;
}

# deny access to .htaccess files, if Apache's document root
# concurs with nginx's one
#
#location ~ /\.ht {
#    deny  all;
#}
```
