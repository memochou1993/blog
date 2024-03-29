---
title: 在 elementary OS 上建立 Laradock 環境
date: 2018-04-26 10:16:18
tags: ["Deployment", "Linux", "elementary OS", "Docker", "Laradock", "Laravel"]
categories: ["Deployment", "Laradock"]
---

## 前言

本文基於《[簡潔高效的 PHP & Laravel 工作術：從 elementary OS 下手的聰明改造提案](https://shengyou.gitbooks.io/elementary-os-for-php-developer/)》一書，記錄在 elementary OS 上部署 Laradock 環境時遇到的問題與解決辦法。

## 環境

- elementary OS 0.4.1

## 安裝相關軟體

安裝 Google Chrome 瀏覽器。

```bash
cd Downloads
sudo apt install ./google-chrome-stable_current_amd64.deb
```

安裝 `software-properties-common` 套件。

```bash
sudo apt install software-properties-common
```

安裝 Git。

```bash
sudo add-apt-repository ppa:git-core/ppa
sudo apt update
sudo apt install git
```

## 安裝 Docker

```bash
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh
docker -v // 檢查是否安裝成功並查看版本
```

## 安裝 Docker Compose

這是第一個與原書有所出入的部分，直接使用 `apt-get` 安裝，會發現 Docker Compose 的版本過舊。

這裡採取的做法是：

- 使用 `curl` 安裝 `1.21.0` 版本到根目錄
- 調整權限
- 把資料夾移回使用者可執行程式目錄

```bash
sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o ~/docker-compose
sudo chmod +x ~/docker-compose
sudo mv ~/docker-compose /usr/local/bin/docker-compose
docker-compose -v // 檢查是否安裝成功並查看版本
```

## 新增使用者到群組

新增完必須重新開機。

```bash
sudo usermod -aG docker <USERNAME>
```

## 安裝 Laradock

從 GitHub 上下載 Laradock 到根目錄。

```bash
cd ~/
git clone https://github.com/laradock/laradock.git Laradock
cd Laradock
cp env-example .env
```

## 修改環境變數

這是第二個與原書有所出入的部分，專案資料夾的路徑參數名稱由 `APPLICATION` 變成了 `APP_CODE_PATH_HOST`。

修改 `.env` 檔為以下：

```env
# Point to the path of your applications code on your host
APP_CODE_PATH_HOST=~/Projects/
```

在根目錄新增一個專案資料夾，但這個做法在之後會遇到權限問題。

```bash
cd ~/
mkdir Projects
```

可以考慮在其他磁碟手動建立專案資料夾。則修改 `.env` 檔為以下：

```env
# Point to the path of your applications code on your host
APP_CODE_PATH_HOST=/media/<USERNAME>/[volumn name]/Projects/
```

這裡最好再重新開機一次。

## 啟動 Docker

這是第三個和原書有所出入的部分，容器 `workspace` 必須由使用者自行增加，否則會出現找不到容器 `workspace` 的警告。

```bash
docker-compose up -d nginx mysql workspace
```

等待 5 分鐘安裝後，進入容器。

```bash
docker-compose exec workspace bash
```

在容器根目錄 `/var/www` 裡安裝 Laravel。

```bash
composer create-project laravel/laravel --prefer-dist
```

會有 1 分鐘沒有動靜才開始安裝，等待 5 分鐘安裝後離開容器。

這裡要建立一個 `laravel.test.conf` 檔。

```bash
cd ~/Laradock/nginx/sites
cp laravel.conf.example laravel.test.conf
```

## 註冊虛擬主機別名

先安裝 gedit 文字編輯器。

```bash
sudo apt install gedit
```

建立一個虛擬主機路徑。

```bash
sudo gedit /etc/hosts
```

增加以下路徑。

```env
127.0.0.1 laravel.test
```

## 重啟 Docker

```bash
cd ~/Laradock
docker-compose down
docker-compose up -d nginx mysql workspace
```

## 測試

如果專案資料夾不是放在其他磁碟，使用瀏覽器測試 <http://laravel.test> 後，可能會出現錯誤。

```env
The stream or file "/var/www/laravel/storage/logs/laravel.log" could not be opened: failed to open stream: Permission denied
```

進到專案資料夾修改專案權限。

```bash
~/Projects
sudo chmod -R 777 laravel
```

再使用瀏覽器測試後，可以看到 Laravel 的歡迎頁面了。
