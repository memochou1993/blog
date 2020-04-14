---
title: 使用 Docker 搭建 Drone 自動化部署平台
permalink: 使用-Docker-搭建-Drone-自動化部署平台
date: 2020-04-13 21:15:41
tags: ["環境部署", "Docker", "Drone", "GitHub", "CI/CD"]
categories: ["環境部署", "Docker"]
---

## 環境

- Ubuntu 18.04 LTS

## 註冊應用程式

首先到 GitHub 的 [Developer settings](https://github.com/settings/developers) 頁面建立一個 OAuth 應用程式，輸入以下設定：

- Application name: Drone CI
- Homepage URL: <https://drone.domain.com>
- Authorization callback URL: <https://drone.domain.com/login>

儲存後，獲得一組 Client ID 和 Client Secret。

## 部署應用程式

打開終端機，建立一個 Drone 的 server 和 agent 共享的 secret。

```BASH
openssl rand -hex 16
```

在伺服器上建立一個 Drone 的工作目錄。

```BASH
mkdir drone
cd drone
```

建立 `docker-compose.yml` 檔：

```YML
version: "3.5"

services:
  drone-server:
    image: drone/drone:latest
    ports:
      - 8000:80
      - 8443:443
    networks:
      - drone
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./:/data
    env_file:
      - ./.env
    restart: always

  drone-agent:
    image: drone/agent:latest
    command: agent
    depends_on:
      - drone-server
    networks:
      - drone
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    env_file:
      - ./.env
    restart: always

networks:
  drone:
    name: drone_network
```

建立 `.env` 檔：

```BASH
DRONE_GITHUB_CLIENT_ID=xxxxx # GitHub Client ID
DRONE_GITHUB_CLIENT_SECRET=xxxxx # GitHub Client Secret
DRONE_SERVER_PROTO=https # http 或 https
DRONE_SERVER_HOST=drone.domain.com # Drone 應用程式網址
DRONE_RPC_PROTO=https # http 或 https
DRONE_RPC_HOST=drone.domain.com # Drone 應用程式網址
DRONE_RPC_SECRET=xxxxx # server 和 agent 共享的 secret
```

建立 `.gitignore` 檔：

```BASH
database.sqlite
.env
```

啟動 Drone 服務：

```BASH
docker-compose up -d
```

前往：<https://drone.domain.com/>

## 程式碼

- [drone-example](https://github.com/memochou1993/drone-example)

## 參考資料

- [Drone Documentation - GitHub](https://docs.drone.io/server/provider/github/)
