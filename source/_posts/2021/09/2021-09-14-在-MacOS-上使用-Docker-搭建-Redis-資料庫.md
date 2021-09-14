---
title: 在 MacOS 上使用 Docker 搭建 Redis 資料庫
permalink: 在-MacOS-上使用-Docker-搭建-Redis-資料庫
date: 2021-09-14 17:06:31
tags: ["環境部署", "Docker", "macOS", "Redis"]
categories: ["環境部署", "Docker"]
---

## 環境

- macOS (M1)
- Docker Desktop preview

## 做法

下載並啟動 `redis` 映像檔。

```BASH
docker run --name redis -d redis
```

進入容器。

```BASH
docker exec -it redis redis-cli
```

## 參考資料

[redis](https://hub.docker.com/_/redis)
