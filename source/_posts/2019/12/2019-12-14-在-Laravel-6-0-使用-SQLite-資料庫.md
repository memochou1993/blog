---
title: 在 Laravel 6.0 使用 SQLite 資料庫
date: 2019-12-14 21:46:33
tags: ["Programming", "PHP", "Laravel", "SQLite", "Database"]
categories: ["Programming", "PHP", "Laravel"]
---

## 新增資料庫

在 `database` 資料夾新增 `database.sqlite` 檔。

## 修改環境變數

修改 `.env` 檔：

```env
DB_CONNECTION=sqlite
# DB_HOST=127.0.0.1
# DB_PORT=3306
DB_DATABASE=/absolute/path/to/database.sqlite
# DB_USERNAME=root
# DB_PASSWORD=
```
