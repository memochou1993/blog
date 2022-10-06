---
title: 使用 Docker 搭建 Rocket.Chat 聊天協作平台
date: 2019-02-08 18:55:08
tags: ["環境部署", "Docker", "Linux", "Ubuntu", "Rocket.Chat"]
categories: ["環境部署", "Docker", "其他"]
---

## 環境

- Ubuntu 18.04.1 LTS
- Docker 18.09.1
- docker-compose 1.23.2

## 安裝

在 `/home/rocketchat` 資料夾新增 `docker-compose.yml` 檔：

```yaml
version: '2'

services:
  rocketchat:
    image: rocketchat/rocket.chat:latest
    restart: unless-stopped
    volumes:
      - ./uploads:/app/uploads
    environment:
      - PORT=3000
      - ROOT_URL=http://xx.xxx.xxx.xxx:3000
      - MONGO_URL=mongodb://mongo:27017/rocketchat
      - MONGO_OPLOG_URL=mongodb://mongo:27017/local
      - MAIL_URL=smtp://smtp.email
#       - HTTP_PROXY=http://proxy.domain.com
#       - HTTPS_PROXY=http://proxy.domain.com
    depends_on:
      - mongo
    ports:
      - 3000:3000
    labels:
      - "traefik.backend=rocketchat"
      - "traefik.frontend.rule=Host: your.domain.tld"

  mongo:
    image: mongo:3.2
    restart: unless-stopped
    volumes:
     - ./data/db:/data/db
     #- ./data/dump:/dump
    command: mongod --smallfiles --oplogSize 128 --replSet rs0 --storageEngine=mmapv1
    labels:
      - "traefik.enable=false"

  # this container's job is just run the command to initialize the replica set.
  # it will run the command and remove himself (it will not stay running)
  mongo-init-replica:
    image: mongo:3.2
    command: 'mongo mongo/rocketchat --eval "rs.initiate({ _id: ''rs0'', members: [ { _id: 0, host: ''localhost:27017'' } ]})"'
    depends_on:
      - mongo

  # hubot, the popular chatbot (add the bot user first and change the password before starting this image)
  hubot:
    image: rocketchat/hubot-rocketchat:latest
    restart: unless-stopped
    environment:
      - ROCKETCHAT_URL=rocketchat:3000
      - ROCKETCHAT_ROOM=GENERAL
      - ROCKETCHAT_USER=bot
      - ROCKETCHAT_PASSWORD=botpassword
      - BOT_NAME=bot
  # you can add more scripts as you'd like here, they need to be installable by npm
      - EXTERNAL_SCRIPTS=hubot-help,hubot-seen,hubot-links,hubot-diagnostics
    depends_on:
      - rocketchat
    labels:
      - "traefik.enable=false"
    volumes:
      - ./scripts:/home/hubot/scripts
  # this is used to expose the hubot port for notifications on the host on port 3001, e.g. for hubot-jenkins-notifier
    ports:
      - 3001:8080

  #traefik:
  #  image: traefik:latest
  #  restart: unless-stopped
  #  command: traefik --docker --acme=true --acme.domains='your.domain.tld' --acme.email='your@email.tld' --acme.entrypoint=https --acme.storagefile=acme.json --defaultentrypoints=http --defaultentrypoints=https --entryPoints='Name:http Address::80 Redirect.EntryPoint:https' --entryPoints='Name:https Address::443 TLS.Certificates:'
  #  ports:
  #    - 80:80
  #    - 443:443
  #  volumes:
  #    - /var/run/docker.sock:/var/run/docker.sock
```

- 將參數 `ROOT_URL` 改為主機的 IP。

## 設定 DNS

新增子網域：rocketchat.xxx.com，並指向主機的 IP。

## 設定 Nginx 反向代理

在 `/etc/nginx/sites-available` 資料夾新增 `rocketchat.xxx.com.conf` 檔：

```conf
server {
  listen       80;
  server_name  rocketchat.xxx.com;
  error_log /var/log/nginx/rocketchat.access.log;
  location / {
    proxy_pass http://127.0.0.1:3000;
  }
}
```

建立軟連結。

```bash
sudo ln -s /etc/nginx/sites-available/rocketchat.xxx.com.conf /etc/nginx/sites-enabled/rocketchat.xxx.com.conf
```

重啟 Nginx 服務。

```bash
sudo nginx -s reload
```

## 啟動

啟動 MongoDB 服務。

```bash
docker-compose up -d mongo
```

啟動 MongoDB 初始化服務。

```bash
docker-compose up -d mongo-init-replica
```

啟動 Rocket.Chat 服務。

```bash
docker-compose up -d rocketchat
```

## 瀏覽網頁

前往 <http://rocketchat.xxx.com> 瀏覽。

## 參考資料

- [Rocket.Chat Documentation - Docker Compose](https://rocket.chat/docs/installation/docker-containers/available-images/)
