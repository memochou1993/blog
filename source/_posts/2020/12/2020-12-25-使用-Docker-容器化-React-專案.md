---
title: 使用 Docker 容器化 React 專案
date: 2020-12-25 17:18:22
tags: ["環境部署", "Docker", "JavaScript", "React"]
categories: ["程式設計", "JavaScript", "環境部署"]
---

## 做法

新增 `.env` 檔：

```ENV
APP_PORT=8080
```

新增 `docker-compose.yaml` 檔：

```YAML
version: "3"

services:
  app:
    container_name: react-app
    build: .
    restart: always
    ports:
      - "${APP_PORT}:80"
```

新增 `Dockerfile` 檔：

```DOCKERFILE
# build stage
FROM node:lts-alpine as builder

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build

# final stage
FROM nginx:stable-alpine

COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

新增 `.dockerignore` 檔。

```ENV
/node_modules
```

編譯並啟動容器：

```BASH
docker-compose up -d --build
```

## 瀏覽網頁

前往：<http://127.0.0.1:8080>
