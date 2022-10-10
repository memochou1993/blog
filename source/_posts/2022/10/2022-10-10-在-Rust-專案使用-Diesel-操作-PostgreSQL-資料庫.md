---
title: 在 Rust 專案使用 Diesel 操作 PostgreSQL 資料庫
date: 2022-10-10 15:42:42
tags: ["程式設計", "Rust", "Diesel", "ORM", "PostgreSQL"]
categories: ["程式設計", "Rust", "Diesel"]
---

## 前置作業

### PostgreSQL CLI

安裝 `libpq` 工具。

```bash
brew install libpq
```

添加指令到環境變數。

```bash
echo 'export PATH="/usr/local/opt/libpq/bin:$PATH"' >> ~/.zshrc
```

### Diesel CLI

安裝 `diesel_cli` 工具。

```bash
cargo install diesel_cli --no-default-features --features postgres
```

## 建立專案

建立專案。

```bash
cargo new diesel-example
cd diesel-example
```

安裝依賴套件。

```bash
cargo add diesel --features postgres
cargo add dotenvy
```

新增 `.env` 檔。

```env
DATABASE_URL=postgres://postgres:root@127.0.0.1/posts
```

使用 `diesel` 指令初始化，以建立 `posts` 資料庫和空的遷移資料表。

```bash
diesel setup
```

## 建立遷移表

建立遷移表。

```bash
diesel migration generate create_posts
```

修改 `migrations/2022-10-10-082606_create_posts/up.sql` 檔。

```SQL
CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  published BOOLEAN NOT NULL DEFAULT FALSE
)
```

修改 `migrations/2022-10-10-082606_create_posts/down.sql` 檔。

```SQL
DROP TABLE posts
```

執行遷移。

```bash
diesel migration run
```

如果要回滾，可以執行以下指令。

```bash
diesel migration redo
```

## 建立連線

TODO

## 程式碼

- [diesel-example](https://github.com/memochou1993/diesel-example)

## 參考資料

- [Diesel](https://diesel.rs/guides/getting-started)
