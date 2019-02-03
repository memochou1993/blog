---
title: 在 Amazon Linux 2 上建立 Laradock 環境
permalink: 在-Amazon-Linux-2-上建立-Laradock-環境
date: 2019-02-01 10:44:19
tags: ["環境部署", "AWS", "Linux", "Docker", "Laradock", "Laravel"]
categories: ["環境部署", "Docker"]
---

## 安裝 Docker
使用 `amazon-linux-extras` 安裝 Docker。
```
$ sudo amazon-linux-extras install docker
```

查看 Docker 版本。
```
$ docker -v
Docker version 18.06.1-ce
```

將目前使用者加進 `docker` 群組。
```
$ sudo gpasswd -a ${USER} docker
```

重新登入。
```
$ exit
$ ./ec2
```

重新啟動 Docker。
```
$ sudo service docker restart
```

## 安裝 Docker Compose
下載 Docker Compose。
```
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
修改執行檔權限。
```
$ sudo chmod +x /usr/local/bin/docker-compose
```
建立執行檔軟連結。
```
$ sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```
查看 Docker Compose 版本。
```
$ docker-compose -v
docker-compose version 1.23.2
```

## 安裝 Git
使用 YUM 安裝 Git。
```
$ sudo yum install git
```

查看 Git 版本。
```
$ git --version
git version 2.17.2
```

## 安裝 Laradock
從 GitHub 上將 Laradock 下載下來。
```
$ git clone https://github.com/Laradock/laradock.git Laradock
```

複製範本 `env-example` 檔作為設定檔。
```
$ cd ~/Laradock && cp env-example .env
```

修改 `.env` 檔的 `APP_CODE_PATH_HOST` 參數到指定的映射路徑：
```ENV
APP_CODE_PATH_HOST=~/Projects
```

使用 `docker-compose` 啟動 Laradock。
```
$ cd ~/Laradock && docker-compose up -d nginx workspace
```

## 安裝 PHP
使用 `amazon-linux-extras` 安裝 PHP。
```
$ sudo amazon-linux-extras install php7.2
```

## 安裝 Composer
安裝 Composer。
```
$ php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
$ HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
$ php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
Installer verified
$ sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
```

建立執行檔軟連結。
```
$ ln -s /usr/local/bin/composer /usr/bin/composer
```

查看 Composer 版本。
```
$ composer -v
Composer version 1.8.3
```

修改 `~/.bash_profile` 檔，以建立環境變數：
```
# User specific environment and startup programs

PATH=$PATH:$HOME/.config/composer/vendor/bin:$PATH

export PATH
```

重新登入。
```
$ exit
$ ./ec2
```

## 安裝 Laravel 安裝器
安裝 `php-pecl-zip` 套件。
```
$ sudo yum install php-pecl-zip
```

安裝 Laravel 安裝器。
```
$ composer global require laravel/installer
```

## 新增專案
建立專案根目錄。
```
$ mkdir ~/Projects
```

安裝 `php-mbstring` 和 `php-xml` 擴充套件。
```
$ sudo yum install php-mbstring php-xml
```

建立 Laravel 專案。
```
$ cd ~/Projects && laravel new laravel
```

## 設定 Nginx
複製範本 `laravel.conf.example` 檔作為設定檔。
```
$ cd ~/Laradock/nginx/sites && cp laravel.conf.example laravel.conf
```

修改 `laravel.conf` 檔的 `server_name` 和 `root` 參數：
```CONF
server_name *.amazonaws.com;
root /var/www/laravel/public;
```

重新啟動 Nginx。
```
$ cd ~/Laradock && docker-compose restart nginx
```

## 瀏覽
前往 xxx.compute.amazonaws.com
