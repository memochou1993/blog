---
title: 使用 Docker 搭建 Redis 資料庫
permalink: 使用-Docker-搭建-Redis-資料庫
date: 2021-09-14 17:06:31
tags: ["資料庫", "Redis", "NoSQL", "資料庫", "Docker"]
categories: ["資料庫", "Redis"]
---

## 環境

- macOS (M1)
- Docker Desktop preview

## 做法

下載並啟動 `redis` 映像檔。

```BASH
docker run --name redis -d -p 6379:6379 redis --requirepass my-password
```

進入容器。

```BASH
docker exec -it redis redis-cli -a my-password
```

檢查連線。

```BASH
127.0.0.1:6379> PING
PONG
```

## 參考資料

[redis](https://hub.docker.com/_/redis)
