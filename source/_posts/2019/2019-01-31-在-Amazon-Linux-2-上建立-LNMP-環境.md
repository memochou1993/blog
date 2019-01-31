---
title: 在 Amazon Linux 2 上建立 LNMP 環境
permalink: 在-Amazon-Linux-2-上建立-LNMP-環境
date: 2019-01-31 13:28:26
tags: ["環境部署", "AWS", "Linux", "Nginx", "MariaDB", "PHP"]
categories: ["環境部署", "AWS"]
---

## 環境
- Amazon Linux 2

## 切換使用者
連線到執行個體，切換到 `root` 使用者。
```
$ sudo -s
```

## 安裝 Nginx
使用 `amazon-linux-extras` 安裝。
```
$ amazon-linux-extras install nginx1.12
```

或使用 `yum` 安裝。
```
$ yum install nginx
```

查看版本。
```
$ nginx -v
nginx version: nginx/1.12.2
```

複製範本 `nginx.conf.default` 檔作為設定檔。
```
$ rm /etc/nginx/nginx.conf
$ cp /etc/nginx/nginx.conf.default /etc/nginx/nginx.conf
```

修改 `nginx.conf` 檔的 `root`、`fastcgi_pass` 和 `fastcgi_param` 參數：
```CONF
location ~ \.php$ {
    root           /home/www;
    fastcgi_pass   unix:/var/run/php-fpm/www.sock;
    fastcgi_index  index.php;
    fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
    include        fastcgi_params;
}
```

啟動 Nginx。
```
$ nginx
```

查看日誌。
```
$ tail /var/log/nginx/access.log
$ tail /var/log/nginx/error.log
```

## 安裝 PHP
使用 `amazon-linux-extras` 安裝。
```
$ amazon-linux-extras install php7.2
```

或使用 `yum` 安裝。
```
$ yum php72 php72-fpm
```

查看版本。
```
$ php -v
PHP 7.2.13 (cli)
$ php-fpm -v
PHP 7.2.13 (fpm-fcgi)
```

啟動 PHP-FPM。
```
$ php-fpm
```

## 建立專案根目錄
新增資料夾。
```
$ mkdir /home/www
```

查看 Nginx 使用者與群組。
```
$ ps -eo user,comm | grep nginx
root     nginx
nginx    nginx
```

修改資料夾擁有者與群組。
```
$ chown -R nginx:nginx /home/www
```
- 參數 `-R` 讓目錄下的所有次目錄或檔案同時更改擁有者與群組。

在專案根目錄新增 `index.php` 檔。
```
$ echo "<?php phpinfo(); ?>" > /home/www/index.php
```

## 瀏覽
前往：http://xxx.compute.amazonaws.com/index.php

## 安裝 MariaDB
使用 `yum` 安裝。
```
$ yum install mariadb-server
```

啟動 MariaDB。
```
$ systemctl start mariadb
```

關閉 MariaDB。
```
$ systemctl stop mariadb
```

如果要在開機後啟動 MariaDB，使用以下指令：
```
$ systemctl enable mariadb
Created symlink from /etc/systemd/system/multi-user.target.wants/mariadb.service to /usr/lib/systemd/system/mariadb.service.
```

初始化 MariaDB 的環境。
```
$ mysql_secure_installation
Set root password? [Y/n] Y ＃ 是否要為 root 使用者設定密碼
Remove anonymous users? [Y/n] Y ＃ 是否要移除 anonymous users 的資料
Disallow root login remotely? [Y/n]  Y ＃ 設定是否讓 root 使用者只能從 localhost 登入
Remove test database and access to it? [Y/n] Y ＃ 是否要移除 test 資料庫
Reload privilege tables now? [Y/n]  Y ＃ 是否要重新載入權限資料表
```

使用 `root` 進入資料庫。
```
$ mysql -u root -p
```

建立使用者。
```
> CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';
> quit;
```

使用 `admin` 進入資料庫。
```
$ mysql -u admin -p
```
