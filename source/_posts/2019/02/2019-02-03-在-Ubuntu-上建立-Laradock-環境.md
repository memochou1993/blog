---
title: 在 Ubuntu 上建立 Laradock 環境
date: 2019-02-03 19:13:17
tags: ["Deployment", "Linux", "Ubuntu", "Docker", "Laradock", "Laravel"]
categories: ["Deployment", "Laradock"]
---

## 環境

- Ubuntu 18.04.1 LTS

## 安裝 Docker

更新 apt 套件工具。

```bash
sudo apt-get update
```

安裝以下套件讓 apt 可以透過 HTTPS 使用倉庫。

```bash
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
```

加入 Docker 的公開金鑰。

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
OK
```

進行驗證。

```bash
sudo apt-key fingerprint 0EBFCD88
pub   rsa4096 2017-02-22 [SCEA]
      9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
sub   rsa4096 2017-02-22 [S]
```

添加 `stable` 倉庫。

```bash
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

安裝 Docker CE

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

查看 Docker 版本。

```bash
docker -v
Docker version 18.09.1
```

將目前使用者加進 `docker` 群組。

```bash
sudo gpasswd -a ${USER} docker
```

- 需要重新登入。

## 安裝 Docker Compose

下載執行檔。

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

設定權限。

```bash
sudo chmod +x /usr/local/bin/docker-compose
```

- 參數 `+x` 代表給予所有人執行的權限。

查看 Docker Compose 版本。

```bash
docker-compose -v
docker-compose version 1.25.5
```

## 安裝 PHP

安裝 PHP 及擴充套件。

```bash
sudo apt-get install php php-cli php-mbstring php-xml
```

查看 PHP 版本

```bash
php --version
```

## 安裝相關套件

安裝 Git 及相關套件。

```bash
sudo apt-get install curl git unzip
```

查看 Git 版本

```bash
git --version
```

## 安裝 Laradock

從 GitHub 上將 Laradock 下載下來。

```bash
git clone https://github.com/Laradock/laradock.git Laradock
```

複製範本 `env-example` 檔作為設定檔。

```bash
cd ~/Laradock && cp env-example .env
```

修改 `.env` 檔的 `APP_CODE_PATH_HOST` 參數到指定的映射路徑：

```env
APP_CODE_PATH_HOST=~/Projects
```

使用 `docker-compose` 啟動 Laradock。

```bash
cd ~/Laradock && docker-compose up -d nginx mysql phpmyadmin
```

## 安裝 Composer

下載 Composer 並安裝。

```bash
cd ~
curl -sS https://getcomposer.org/installer -o composer-setup.php
HASH=48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5
php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
Installer verified
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
```

- 正確 `HASH` 值，見 <https://composer.github.io/pubkeys.html>

查看 Composer 版本。

```bash
composer --version
```

## 安裝 Laravel 安裝器

使用 Composer 安裝。

```bash
composer global require laravel/installer
```

查看 Laravel 安裝器版本。

```bash
laravel --version
```

## 建立專案

建立專案根目錄。

```bash
mkdir ~/Projects
```

建立 Laravel 專案。

```bash
cd ~/Projects && laravel new laravel
```

## 設定 Nginx

複製範本 `laravel.conf.example` 檔作為設定檔。

```bash
cd ~/Laradock/nginx/sites && cp laravel.conf.example laravel.conf
```

修改 `laravel.conf` 檔的 `server_name` 和 `root` 參數：

```conf
server_name *.amazonaws.com;
root /var/www/laravel/public;
```

重啟 Nginx 服務。

```bash
cd ~/Laradock && docker-compose restart nginx
```

## 設定 MySQL

修改 `mysql\my.cnf` 檔：

```cnf
[mysqld]
default_authentication_plugin=mysql_native_password
```

重新建立 MySQL 容器：

```bash
docker-compose build --no-cache mysql
```

進入 MySQL 容器。

```bash
docker-compose exec mysql bash
```

使用 `root` 使用者進入資料庫。

```sql
# mysql -uroot -proot
```

查看所有使用者。

```sql
> SELECT user,authentication_string,plugin,host FROM mysql.user;
```

刪除預設使用者。

```bash
DROP USER 'default'@'%';
```

新增使用者，並設定權限。

```sql
> CREATE USER 'ubuntu'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
> GRANT ALL PRIVILEGES ON *.* TO 'ubuntu'@'%';
> FLUSH PRIVILEGES;
> quit;
```

使用 `ubuntu` 使用者進入資料庫。

```bash
mysql -u ubuntu -p
```

新增 `homestead` 資料庫。

```sql
> CREATE DATABASE `homestead`;
> quit;
```

## 瀏覽網頁

前往 <https://xxx.compute.amazonaws.com> 瀏覽。

## 設定相關權限

進到 workspace 容器。

```bash
docker-compose exec workspace bash
```

修改 `storage` 資料夾的權限。

```bash
chown -R laradock:www-data storage
```

## 正式環境

複製範本 `docker-compose.yml` 檔作為設定檔，刪減內容並移除資料庫的 `port`。

```bash
cp docker-compose.yml production-docker-compose.yml
```

使用 `docker-compose` 啟動 Laradock。

```bash
docker-compose -f production-docker-compose.yml up -d nginx mysql phpmyadmin
```
