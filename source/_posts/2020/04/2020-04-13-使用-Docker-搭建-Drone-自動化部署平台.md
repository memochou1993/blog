---
title: 使用 Docker 搭建 Drone 自動化部署平台
date: 2020-04-13 21:15:41
tags: ["Deployment", "Docker", "Drone", "GitHub", "CI/CD"]
categories: ["Deployment", "Docker", "Others"]
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

```bash
openssl rand -hex 16
```

在伺服器上建立一個 Drone 的工作目錄。

```bash
mkdir drone
cd drone
```

建立 `docker-compose.yml` 檔：

```yaml
version: "3.5"

services:
  drone-server:
    image: drone/drone:1
    ports:
      - 8000:80
    volumes:
      - ./data:/data
    restart: always
    environment:
      - DRONE_SERVER_HOST=${DRONE_SERVER_HOST}
      - DRONE_SERVER_PROTO=${DRONE_SERVER_PROTO}
      - DRONE_GITHUB_CLIENT_ID=${DRONE_GITHUB_CLIENT_ID}
      - DRONE_GITHUB_CLIENT_SECRET=${DRONE_GITHUB_CLIENT_SECRET}
      - DRONE_RPC_SECRET=${DRONE_RPC_SECRET}
      - DRONE_LOGS_COLOR=true
      - DRONE_LOGS_PRETTY=true

  drone-agent:
    image: drone/drone-runner-docker:1
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    restart: always
    depends_on:
      - drone-server
    environment:
      - DRONE_RPC_HOST=${DRONE_RPC_HOST}
      - DRONE_RPC_PROTO=${DRONE_RPC_PROTO}
      - DRONE_RPC_SECRET=${DRONE_RPC_SECRET}
```

建立 `.env` 檔：

```bash
DRONE_SERVER_HOST=drone.domain.com
DRONE_SERVER_PROTO=https
DRONE_GITHUB_CLIENT_ID=xxxxx
DRONE_GITHUB_CLIENT_SECRET=xxxxx
DRONE_RPC_HOST=drone-server
DRONE_RPC_PROTO=http
DRONE_RPC_SECRET=xxxxx
```

建立 `.gitignore` 檔：

```bash
data
.env
```

啟動 Drone 服務：

```bash
docker-compose up -d
```

前往 <https://drone.domain.com/> 瀏覽。

## 環境變數

- Server 的環境變數參考 [Reference](https://docs.drone.io/server/reference/) 頁面。
- Docker Runner 的環境變數參考 [Reference](https://docs.drone.io/server/reference/) 頁面。

## 程式碼

- [drone-example](https://github.com/memochou1993/drone-example)

## 參考資料

- [Drone Documentation - GitHub](https://docs.drone.io/server/provider/github/)
