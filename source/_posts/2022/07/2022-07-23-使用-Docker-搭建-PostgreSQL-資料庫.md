---
title: 使用 Docker 搭建 PostgreSQL 資料庫
date: 2022-07-23 21:49:58
tags: ["資料庫", "PostgreSQL", "SQL", "Docker"]
categories: ["資料庫", "PostgreSQL"]
---

## 做法

下載並啟動 `postgres` 映像檔。

```bash
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=root postgres
```

進入容器。

```bash
docker exec -it postgres bash
```

或使用 `psql` 指令直接進入 PostgreSQL 互動介面。

```bash
docker exec -it postgres psql -U postgres
```

建立使用者。

```bash
postgres> create role root with login password 'root';
```

查看使用者列表。

```bash
\du
```

建立資料庫。

```bash
postgres> create database test owner root;
```

查看資料庫列表。

```bash
postgres> \l
```

離開互動介面。

```bash
postgres> \q
```

## 連線

如果要在沒有暴露通訊埠的情況下使用，可以先建立一個網路。

```bash
docker network create my_network
```

啟動容器。

```bash
docker run -d --name postgres-container --network my_network -e POSTGRES_PASSWORD=mysecretpassword postgres:latest
```

啟動臨時容器，在該容器中使用 `psql` 連線工具。

```bash
docker run -it --rm --name postgres-client --network my_network postgres:latest psql -h postgres-container -U postgres
```

## 參考資料

- [postgres](https://hub.docker.com/_/postgres)
