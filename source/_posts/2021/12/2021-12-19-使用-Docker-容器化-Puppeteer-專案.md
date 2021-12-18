---
title: 使用 Docker 容器化 Puppeteer 專案
permalink: 使用-Docker-容器化-Puppeteer-專案
date: 2021-12-19 00:14:10
tags: ["環境部署", "Docker", "JavaScript", "Node", "爬蟲"]
categories: ["環境部署", "Docker"]
---

## 做法

在程式碼中，使用 `--no-sandbox` 參數啟動瀏覽器。

```JS
await puppeteer.launch({
  args: [
    '--no-sandbox'
  ],
});
```

新增 `Dockerfile` 檔：

```DOCKERFILE
FROM node:12-slim

WORKDIR /app

RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# 安裝 Puppeteer 套件
RUN npm i puppeteer

COPY . .

# 安裝其他依賴套件
RUN npm i

CMD [ "node", "main.js" ]
```

新增 `docker-compose.yaml` 檔：

```YAML
version: "3"

services:
  app:
    container_name: lyricist-screenshot
    build: .
    ports:
      - "80:80"
```

啟動專案。

```BASH
docker compose up -d
```

## 參考資料

- [Puppeteer: Running Puppeteer in Docker](https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md#running-puppeteer-in-docker)
