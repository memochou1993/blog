---
title: 使用 Docker 容器化 Quasar 專案
date: 2020-02-10 22:00:57
tags: ["Deployment", "Docker", "JavaScript", "Node.js", "Quasar"]
categories: ["Programming", "JavaScript", "Deployment"]
---

## 做法

新增 `docker-compose.yaml` 檔：

```yaml
version: "3"

services:
  app:
    container_name: quasar
    build: .
    ports:
      - "3000:3000"
```

新增 `Dockerfile` 檔：

```dockerfile
# build stage
FROM node:alpine as builder

WORKDIR /app

COPY . .

RUN yarn global add @quasar/cli
RUN yarn install
RUN quasar build -m ssr

# final stage
FROM node:alpine

WORKDIR /root

COPY --from=builder /app/dist/ssr .

RUN yarn install

CMD [ "yarn", "start" ]
```

新增 `.dockerignore` 檔：

```env
.git
.gitignore
Dockerfile
docker-compose.yaml
node_modules
dist
.env.*.js
```

編譯並啟動容器：

```bash
docker-compose up -d --build
```

## 瀏覽網頁

前往 <http://127.0.0.1:3000> 瀏覽。
