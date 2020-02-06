---
title: 在 CentOS 上建立 Laradock 環境
permalink: 在-CentOS-上建立-Laradock-環境
date: 2020-02-06 09:56:48
tags: ["環境部署", "Linux", "CentOS", "Docker", "Laradock", "Laravel"]
categories: ["環境部署", "Laradock"]
---

## 環境

- CentOS 7

## 安裝 Docker

更新 yum 套件工具。

```BASH
sudo yum update
```

安裝以下套件。

```BASH
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
```

添加倉庫。

```BASH
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

安裝最新版本的 Docker 引擎。

```BASH
sudo yum install docker-ce docker-ce-cli containerd.io
```

啟動 Docker 服務。

```BASH
sudo systemctl start docker
```

查看 Docker 版本。

```BASH
docker -v
Docker version 19.03.5
```

將目前使用者加進 `docker` 群組。

```BASH
sudo gpasswd -a ${USER} docker
```

- 需要重新登入。

## 安裝 Docker Compose

下載執行檔。

```BASH
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

設定權限。

```BASH
sudo chmod +x /usr/local/bin/docker-compose
```

建立軟連結。

```BASH
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

查看 Docker Compose 版本。

```BASH
docker-compose -v
docker-compose version 1.25.3
```

## 安裝 Laradock

從 GitHub 上將 Laradock 下載下來。

```BASH
git clone https://github.com/Laradock/laradock.git Laradock
```

複製範本 `env-example` 檔作為設定檔。

```BASH
cd ~/Laradock && cp env-example .env
```

修改 `.env` 檔的 `APP_CODE_PATH_HOST` 參數到指定的映射路徑：

```ENV
APP_CODE_PATH_HOST=/var/www
```

使用 `docker-compose` 啟動 Laradock。

```BASH
cd ~/Laradock && docker-compose up -d nginx mysql phpmyadmin
```
