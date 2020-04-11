---
title: 使用 GitLab CI/CD 和 Envoy 為 Laravel 專案建立自動化部署
permalink: 使用-GitLab-CI-CD-和-Envoy-為-Laravel-專案建立自動化部署
date: 2019-02-07 01:51:29
tags: ["環境部署", "CI/CD", "Linux", "Ubuntu", "Laravel", "GitLab"]
categories: ["環境部署", "CI/CD"]
---

## 環境

- Ubuntu（遠端伺服器）
- macOS（本機）

## 建立專案

在本機新增 Laravel 專案，並推送至 GitLab 儲存庫。

```BASH
laravel new laravel-envoy
cd laravel-envoy
git init
git add .
git commit -m "Initial Commit"
git remote add origin ssh://git@xxx/laravel-envoy.git
git push -u origin master
```

## 遠端伺服器

### 新增使用者

新增 `deployer` 使用者。

```BASH
sudo adduser deployer --disabled-password
```

### 設定權限

讓 `deployer` 使用者可以存取 `/var/www` 資料夾。

```BASH
sudo setfacl -R -m u:deployer:rwx /var/www
```

為 `deployer` 使用者添加 sudo 權限。

```BASH
sudo vi /etc/sudoers
```

修改 `sudoers` 檔：

```BASH
# User privilege specification
root    ALL=(ALL:ALL) ALL
deployer ALL=(ALL) NOPASSWD: ALL
```

### 連線設定

登入 `deployer` 使用者，新增 `~/.ssh` 資料夾，並設定權限。

```BASH
sudo su - deployer
mkdir ~/.ssh
chmod 700 ~/.ssh
```

新增 `authorized_keys` 檔。

```BASH
vi ~/.ssh/authorized_keys
```

將遠端伺服器的公有金鑰的內容複製到 `authorized_keys` 檔。

```TEXT
ssh-rsa ...
```

設定金鑰權限。

```BASH
chmod 600 ~/.ssh/authorized_keys
```

### 建立儲存庫連線金鑰

新增 `id_rsa` 檔。

```BASH
vi ~/.ssh/id_rsa
```

將本機的私有金鑰 `aws.pem` 檔的內容複製到 `~/.ssh/id_rsa` 檔。

```TEXT
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
```

新增 `id_rsa.pub` 檔。

```BASH
touch ~/.ssh/id_rsa.pub
```

將 `authorized_keys` 檔的內容複製到 `~/.ssh/id_rsa.pub` 檔。

```BASH
cat ~/.ssh/authorized_keys >> ~/.ssh/id_rsa.pub
```

設定金鑰權限。

```BASH
chmod 600 ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
```

### 設定 Nginx

新增 `laravel-envoy.xxx.com.conf` 檔：

```CONF
server {
  listen 80;
  listen [::]:80;

  root /var/www/laravel-envoy/current/public;

  index index.html index.htm index.php;

  server_name laravel-envoy.xxx.com;

  location / {
    try_files $uri $uri/ /index.php?$query_string;
  }

  location ~ \.php$ {
    fastcgi_pass   unix:/run/php/php7.2-fpm.sock;
    fastcgi_param  SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
    fastcgi_param  DOCUMENT_ROOT $realpath_root;
    include        fastcgi_params;
  }
}
```

- 為了讓 Nginx 可以透過軟連結找到文件，`document_root` 需改為 `realpath_root`。

建立軟連結。

```BASH
sudo ln -s /etc/nginx/sites-available/laravel-envoy.xxx.com.conf /etc/nginx/sites-enabled/laravel-envoy.xxx.com.conf
```

重啟 Nginx 服務。

```BASH
sudo nginx -s reload
```

### 設定專案目錄

建立專案目錄。

```BASH
mkdir /var/www/laravel-envoy
```

複製一個 Laravel 專案的 `.env` 檔，或複製 `.env.production` 檔。

```BASH
cp /var/www/laravel/.env /var/www/laravel-envoy/.env
```

複製一個 Laravel 專案的 `storage` 資料夾。

```BASH
cp -r /var/www/laravel/storage /var/www/laravel-envoy/storage
```

建立 `releases` 資料夾並初始化 Git。

```BASH
mkdir /var/www/laravel-envoy/releases
cd /var/www/laravel-envoy/releases
git init
```

## 設定 GitLab 連線

### 新增變數

在「Settings」的「CI/CD」新增一組變數。

| KEY | VALUE |
| --- | --- |
| SSH_PRIVATE_KEY | 私有金鑰`id_rsa` 檔的內容 |

### 儲存庫 SSH 設定

將 `id_rsa.pub` 檔的內容複製到儲存庫 SSH 設定。

```BASH
cat ~/.ssh/id_rsa.pub
```

### 測試

登入 `deployer` 使用者，下載儲存庫的專案。

```BASH
cd /var/www
git clone ssh://git@xxx/laravel-envoy.git
```

## 安裝 Envoy

在本機使用 Composer 安裝 Envoy。

```BASH
composer global require laravel/envoy
```

在 `~/.ssh` 資料夾新增 `config` 檔。

```ENV
Host xxx.com
    HostName xx.xxx.xxx.xxx
    User deployer
    IdentityFile ~/.ssh/aws.pem
```

在專案根目錄新增 `Envoy.blade.php` 檔。

```PHP
@servers(['web' => 'deployer@xx.xxx.xxx.xxx'])

@setup
    $repository = 'ssh://git@xxx/laravel-envoy.git';
    $app_dir = '/var/www/laravel-envoy';
    $releases_dir = '/var/www/laravel-envoy/releases';
    $release = date('YmdHis');
    $new_release_dir = $releases_dir.'/'.$release;
@endsetup

@story('deploy')
    clone_repository
    run_composer
    update_symlinks
    update_permissions
@endstory

@task('clone_repository')
    echo 'Cloning repository...'
    [ -d {{ $releases_dir }} ] || mkdir {{ $releases_dir }}
    git clone --depth 1 {{ $repository }} {{ $new_release_dir }}
@endtask

@task('run_composer')
    echo 'Starting deployment ({{ $release }})...'
    cd {{ $new_release_dir }}
    composer install --prefer-dist --no-dev  --no-scripts --no-suggest --optimize-autoloader
@endtask

@task('update_symlinks')
    echo 'Linking storage directory...'
    rm -rf {{ $new_release_dir }}/storage
    ln -nfs {{ $app_dir }}/storage storage.tmp
    mv -fT storage.tmp {{ $new_release_dir }}/storage

    echo 'Linking .env file...'
    ln -nfs {{ $app_dir }}/.env .env.tmp
    mv -fT .env.tmp {{ $new_release_dir }}/.env

    echo 'Linking current release...'
    ln -nfs {{ $new_release_dir }} current.tmp
    mv -fT current.tmp {{ $app_dir }}/current
@endtask

@task('update_permissions')
    sudo setfacl -R -m u:www-data:rwx {{ $new_release_dir }}/storage {{ $new_release_dir }}/bootstrap/cache
@endtask
```

推送至 GitLab 儲存庫。

```BASH
git add Envoy.blade.php
git commit -m "Add Envoy"
git push origin master
```

## 設定 GitLab CI/CD

### 建立 Docker 映像檔

在專案根目錄新增 `Dockerfile` 檔。

```Dockerfile
# Set the base image for subsequent instructions
FROM php:7.2

# Update packages
RUN apt-get update

# Install PHP and composer dependencies
RUN apt-get install -qq git curl libmcrypt-dev libjpeg-dev libpng-dev libfreetype6-dev libbz2-dev

# Clear out the local repository of retrieved package files
RUN apt-get clean

# Install needed extensions
# Here you can install any other extension that you need during the test and deployment process
RUN docker-php-ext-install pdo_mysql zip

# Install Composer
RUN curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Laravel Envoy
RUN composer global require "laravel/envoy=~1.0"
```

登入 Docker。

```BASH
docker login
```

建立 Docker 映像檔。

```BASH
docker build -t <USERNAME>/laravel-envoy:latest .
```

推送至 Docker Hub。

```BASH
docker push <USERNAME>/laravel-envoy:latest
```

推送至 GitLab 儲存庫。

```BASH
git add Dockerfile
git commit -m "Add Dockerfile"
git push origin master
```

### 建立 CI/CD 設定檔

在專案根目錄新增 `.gitlab-ci.yml` 檔。

```YML
image: registry.hub.docker.com/<USERNAME>/laravel-envoy:latest

services:
  - mysql:5.7

variables:
  MYSQL_DATABASE: homestead
  MYSQL_ROOT_PASSWORD: secret
  DB_HOST: mysql
  DB_USERNAME: root

stages:
  - test
  - deploy

unit_test:
  stage: test
  script:
    - cp .env.example .env
    - composer install
    - php artisan key:generate
    - php artisan migrate
    - vendor/bin/phpunit

deploy_production:
  stage: deploy
  script:
    - 'which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )'
    - eval $(ssh-agent -s)
    - ssh-add <(echo "$SSH_PRIVATE_KEY")
    - mkdir -p ~/.ssh
    - '[[ -f /.dockerenv ]] && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config'
    - ~/.composer/vendor/bin/envoy run deploy
  environment:
    name: production
    url: http://laravel-envoy.xxx.com
  when: manual
  only:
    - master
```

推送至 GitLab 儲存庫。

```BASH
git add .gitlab-ci.yml
git commit -m "Add gitlab-ci"
git push origin master
```

GitLab 將會開始執行自動化測試與部署。

## 參考資料

- [Test and deploy Laravel applications with GitLab CI/CD and Envoy](https://docs.gitlab.com/ee/ci/examples/laravel_with_gitlab_and_envoy/)
- [如何正确发布 PHP 代码](https://huoding.com/2016/05/27/515)
