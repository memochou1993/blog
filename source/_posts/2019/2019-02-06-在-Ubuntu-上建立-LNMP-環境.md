---
title: 在 Ubuntu 上建立 LNMP 環境
permalink: 在-Ubuntu-上建立-LNMP-環境
date: 2019-02-06 23:44:04
tags: ["環境部署", "Linux", "Ubuntu", "Nginx", "MySQL", "PHP"]
categories: ["環境部署", "Linux"]
---

## 環境
- Ubuntu 18.04.1 LTS

## 安裝 PHP
更新 APT 套件工具。
```
$ sudo apt-get update
```

安裝 PHP 及擴充套件。
```
$ sudo apt-get install -y php php7.2-fpm php-mysql php-zip php-cli php-mbstring php-xml php-curl
```

查看 PHP 版本
```
$ php --version
```

查看 PHP-FPM 版本
```
$ php-fpm7.2 --version
```

## 安裝相關套件
安裝 Git 及相關套件。
```
$ sudo apt-get install -y curl git unzip
```

查看 Git 版本
```
$ git --version
```

## 安裝 Composer
下載 Composer 並安裝。
```
$ cd ~
$ curl -sS https://getcomposer.org/installer -o composer-setup.php
$ HASH=48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5
$ php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
Installer verified
$ sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
```
- 正確 `HASH` 值，見 https://composer.github.io/pubkeys.html

查看 Composer 版本。
```
$ composer --version
```

修改權限。
```
$ sudo chown -R ${USER}:${USER} ~/.composer
```

將套件執行檔路徑寫進環境變數。
```
$ echo 'export PATH="$PATH:$HOME/.composer/vendor/bin"' >> ~/.bashrc
$ source ~/.bashrc
```

## 安裝 Laravel 安裝器
使用 Composer 安裝。
```
$ composer global require laravel/installer
```

查看 Laravel 安裝器版本。
```
$ laravel --version
```

## 安裝 Nginx
安裝 Nginx。
```
$ sudo apt-get install -y nginx
```

查看 Nginx 版本。
```
$ nginx -v
```

在 `/etc/nginx/sites-availabl` 資料夾新增 `laravel.xxx.com.conf` 檔：
```
server {
	listen 80;
	listen [::]:80;

	root /var/www/laravel/public;

	index index.html index.htm index.php;

	server_name laravel.xxx.com;

	location / {
		try_files $uri $uri/ =404;
	}
    
	location ~ \.php$ {
		fastcgi_pass   unix:/run/php/php7.2-fpm.sock;
		fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
		include        fastcgi_params;
	}
}
```

建立設定檔軟連結。
```
$ sudo ln -s /etc/nginx/sites-available/laravel.xxx.com.conf /etc/nginx/sites-enabled/laravel.xxx.com.conf
```

重啟 Nginx 服務。
```
$ sudo nginx -s reload
```

## 設定 DNS
新增子網域：laravel.xxx.com，並指向主機的 IP。

## 安裝 MySQL
安裝 MySQL。
```
$ sudo apt-get install -y mysql-server
```

查看 MySQL 版本。
```
$ mysql --version
```

進行安全設定。
```
$ sudo mysql_secure_installation
```

使用 `root` 使用者進入資料庫。
```
$ sudo mysql
```

查看所有使用者。
```
> SELECT user,authentication_string,plugin,host FROM mysql.user;
```

修改 `root` 使用者的認證套件為 `mysql_native_password`。
```
> ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
> FLUSH PRIVILEGES;
```

新增 `ubuntu` 使用者，並設定權限。
```
> CREATE USER 'ubuntu'@'localhost' IDENTIFIED BY 'password';
> GRANT ALL PRIVILEGES ON *.* TO 'ubuntu'@'localhost';
> FLUSH PRIVILEGES;
> quit;
```

使用 `ubuntu` 使用者進入資料庫。
```
$ mysql -u ubuntu -p
```

新增 `homestead` 資料庫。
```
> CREATE DATABASE `homestead`;
> quit;
```

## 新增專案
修改 `/var/www` 資料夾的權限。
```
$ sudo chown -R ${USER}:${USER} /var/www
```

新增專案。
```
$ cd /var/www
$ laravel new laravel
```

修改 `.env` 檔。
```
DB_USERNAME=ubuntu
DB_PASSWORD=password
```

執行遷移。
```
$ php artisan migrate --seed
```

修改權限，讓 Nginx 使用者可以存取 `storage` 和 `bootstrap/cache` 資料夾。
```
$ sudo setfacl -R -m u:www-data:rwx /var/www/laravel/storage /var/www/laravel/bootstrap/cache
```

## 瀏覽網頁
前往：laravel.xxx.com

## 參考資料
[How To Install Linux, Apache, MySQL, PHP (LAMP) stack on Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-ubuntu-18-04)