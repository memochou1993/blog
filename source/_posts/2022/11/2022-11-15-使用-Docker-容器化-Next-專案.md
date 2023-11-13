---
title: 使用 Docker 容器化 Next 專案
date: 2022-11-15 14:36:25
tags: ["Deployment", "Docker", "JavaScript", "React", "Next"]
categories: ["Programming", "JavaScript", "Deployment"]
---

## 做法

新增 `.env` 檔：

```env
APP_PORT=8080
```

新增 `docker-compose.yaml` 檔：

```yaml
version: "3"

services:
  app:
    container_name: my-next-app
    build: .
    restart: always
    ports:
      - "${APP_PORT}:80"
```

新增 `Dockerfile` 檔：

```dockerfile
# build stage
FROM node:16 as builder

WORKDIR /app

COPY . .

RUN npm ci
RUN npm run build

RUN rm -rf node_modules
RUN npm ci --only=production

# final stage
FROM node:16-alpine

WORKDIR /app

COPY --from=builder /app .

ENV HOST 0.0.0.0
EXPOSE 3000

CMD [ "npm", "start" ]
```

新增 `.dockerignore` 檔。

```env
/node_modules
```

編譯並啟動容器：

```bash
docker-compose up -d --build
```

## 瀏覽網頁

前往 <http://127.0.0.1:8080> 瀏覽。
