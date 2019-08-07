---
title: 在 Homestead 中使用 PostgreSQL 資料庫
permalink: 在-Homestead-中使用-PostgreSQL-資料庫
date: 2018-10-19 22:04:22
tags: ["環境部署", "Homestead", "PostgreSQL", "資料庫"]
categories: ["環境部署", "Homestead"]
---

## 修改 .env 檔

```ENV
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=database
DB_USERNAME=homestead
DB_PASSWORD=secret
```

## 進入資料庫

```
vagrant@homestead:~$ psql -U homestead -h localhost -W database
```

## 相關指令

| 指令               | 說明                     |
| ------------------ | ------------------------ |
| \h                 | 顯示 SQL 指令的說明      |
| \?                 | 顯示 psql 指令的說明     |
| \l                 | 列出所有資料庫           |
| \c [database_name] | 連接資料庫               |
| \d                 | 列出當前資料庫的所有表格 |
| \d [table_name]    | 列出表格結構             |
| \conninfo          | 列出資料庫資訊           |
| \q                 | 退出                     |
