---
title: 在 macOS 上安裝 Nginx 網頁伺服器
permalink: 在-macOS-上安裝-Nginx-網頁伺服器
date: 2019-01-24 10:35:48
tags: ["環境部署", "PHP", "Nginx", "macOS", "Laravel"]
categories: ["環境部署", "Nginx"]
---

## 安裝
使用 `brew` 指令安裝 Nginx。
```
$ brew install nginx
```

啟動 Nginx。
```
$ sudo nginx
```

停止 Nginx。
```
$ sudo nginx -s stop
```

重新啟動 Nginx。
```
$ sudo nginx -s reload  
```

## 設定
修改 `/usr/local/etc/nginx/nginx.conf` 檔的 `root` 和 `fastcgi_param` 參數：
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
```

在專案根目錄新增 `index.php` 檔：
```PHP
phpinfo();
```

## 瀏覽
前往：http://localhost:8080/index.php
