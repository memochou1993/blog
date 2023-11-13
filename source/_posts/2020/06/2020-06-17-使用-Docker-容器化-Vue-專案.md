---
title: 使用 Docker 容器化 Vue 專案
date: 2020-06-17 22:52:56
tags: ["Deployment", "Docker", "JavaScript", "Vue"]
categories: ["Programming", "JavaScript", "Deployment"]
---

## 做法

新增 `docker-compose.yaml` 檔：

```yaml
version: "3"

services:
  app:
    container_name: vue-docker-example
    build: .
    ports:
      - "8080:80"
    restart: always
```

新增 `Dockerfile` 檔：

```dockerfile
# build stage
FROM node:lts-alpine as build-stage

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

# production stage
FROM nginx:stable-alpine as production-stage

COPY --from=build-stage /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

編譯並啟動容器：

```bash
docker-compose up -d --build
```

## 瀏覽網頁

前往 <http://127.0.0.1:8080> 瀏覽。

## 程式碼

- [vue-docker-example](https://github.com/memochou1993/vue-docker-example)

## 參考資料

- [Dockerize Vue.js App](https://vuejs.org/v2/cookbook/dockerize-vuejs-app.html)
