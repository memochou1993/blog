---
title: 在 Ubuntu 上安裝 Docker
permalink: 在-Ubuntu-上安裝-Docker
date: 2019-02-03 19:13:17
tags: ["環境部署", "Linux", "Ubuntu", "Docker"]
categories: ["環境部署", "Docker"]
---

## 安裝 Docker
更新 APT 套件。
```
$ sudo apt-get update
```

安裝以下套件讓 APT 可以透過 HTTPS 使用倉庫。
```
$ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
```

加入 Docker 的公開金鑰。
```
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
OK
```

進行驗證。
```
$ sudo apt-key fingerprint 0EBFCD88
pub   rsa4096 2017-02-22 [SCEA]
      9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
sub   rsa4096 2017-02-22 [S]
```

添加 `stable` 倉庫。
```
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

安裝 Docker CE
```
$ sudo apt-get install docker-ce docker-ce-cli containerd.io
```

查看 Docker 版本。
```
$ docker -v
Docker version 18.09.1
```

將目前使用者加進 `docker` 群組。
```
$ sudo gpasswd -a ${USER} docker
```
- 需要重新登入。

## 安裝 Docker Compose
下載 Docker Composer。
```
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

設定權限。
```
$ sudo chmod +x /usr/local/bin/docker-compose
```

查看 Docker Compose 版本。
```
$ docker-compose -v
docker-compose version 1.23.2
```
