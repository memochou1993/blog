---
title: 使用 Docker 搭建 PostgreSQL 資料庫
date: 2022-07-23 21:49:58
tags: ["資料庫", "PostgreSQL", "SQL", "Docker"]
categories: ["資料庫", "PostgreSQL"]
---

## 做法

下載並啟動 `postgres` 映像檔。

```BASH
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=root postgres
```

進入容器。

```BASH
docker exec -it postgres bash
```

或使用 `psql` 指令直接進入 PostgreSQL 互動介面。

```BASH
docker exec -it postgres psql -U postgres
```

建立使用者。

```BASH
postgres> create role root with login password 'root';
```

查看使用者列表。

```BASH
\du
```

建立資料庫。

```BASH
postgres> create database test owner root;
```

查看資料庫列表。

```BASH
postgres> \l
```

離開互動介面。

```BASH
postgres> \q
```

## 參考資料

- [postgres](https://hub.docker.com/_/postgres)
