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

```sql
CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  published BOOLEAN NOT NULL DEFAULT FALSE
)
```

修改 `migrations/2022-10-10-082606_create_posts/down.sql` 檔。

```sql
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

新增 `src/lib.rs` 檔。

```rs
use diesel::pg::PgConnection;
use diesel::prelude::*;
use dotenvy::dotenv;
use std::env;

pub mod models;
pub mod schema;

pub fn establish_connection() -> PgConnection {
    dotenv().ok();

    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    PgConnection::establish(&database_url)
        .unwrap_or_else(|_| panic!("Error connecting to {}", database_url))
}
```

## 存取資料

### 讀取文章

新增 `src/models.rs` 檔。

```rs
use diesel::prelude::*;

#[derive(Queryable)]
pub struct Post {
    pub id: i32,
    pub title: String,
    pub body: String,
    pub published: bool,
}
```

新增 `src/bin/show_posts.rs` 檔。

```rs
use self::models::*;
use diesel::prelude::*;
use diesel_example::*;

fn main() {
    use self::schema::posts::dsl::*;

    let connection = &mut establish_connection();
    let results = posts
        .filter(published.eq(true))
        .limit(5)
        .load::<Post>(connection)
        .expect("Error loading posts");

    println!("Displaying {} posts", results.len());
    for post in results {
        println!("{}", post.title);
        println!("===\n");
        println!("{}", post.body);
    }
}
```

執行程式。

```bash
cargo run --bin show_posts
```

### 新增文章

修改 `src/models.rs` 檔。

```rs
use diesel::prelude::*;
use crate::schema::posts;

#[derive(Queryable)]
pub struct Post {
    pub id: i32,
    pub title: String,
    pub body: String,
    pub published: bool,
}

#[derive(Insertable)]
#[diesel(table_name = posts)]
pub struct NewPost<'a> {
    pub title: &'a str,
    pub body: &'a str,
}
```

修改 `src/lib.rs` 檔。

```rs
use self::models::{NewPost, Post};
use diesel::pg::PgConnection;
use diesel::prelude::*;
use dotenvy::dotenv;
use std::env;

pub mod models;
pub mod schema;

// ...

pub fn create_post(conn: &mut PgConnection, title: &str, body: &str) -> Post {
    use crate::schema::posts;

    let new_post = NewPost { title, body };

    diesel::insert_into(posts::table)
        .values(&new_post)
        .get_result(conn)
        .expect("Error saving new post")
}
```

新增 `src/bin/write_post.rs` 檔。

```rs
use diesel_example::*;
use std::io::{stdin, Read};

fn main() {
    let connection = &mut establish_connection();

    let mut title = String::new();
    let mut body = String::new();

    println!("What would you like your title to be?");
    stdin().read_line(&mut title).unwrap();
    let title = title.trim_end(); // Remove the trailing newline

    println!(
        "\nOk! Let's write {} (Press {} when finished)\n",
        title, EOF
    );
    stdin().read_to_string(&mut body).unwrap();

    let post = create_post(connection, title, &body);
    println!("\nSaved draft {} with id {}", title, post.id);
}

#[cfg(not(windows))]
const EOF: &str = "CTRL+D";

#[cfg(windows)]
const EOF: &str = "CTRL+Z";
```

### 發表文章

新增 `src/bin/publish_post.rs` 檔。

```rs
use self::models::Post;
use diesel::prelude::*;
use diesel_example::*;
use std::env::args;

fn main() {
    use self::schema::posts::dsl::{posts, published};

    let id = args()
        .nth(1)
        .expect("publish_post requires a post id")
        .parse::<i32>()
        .expect("Invalid ID");
    let connection = &mut establish_connection();

    let post = diesel::update(posts.find(id))
        .set(published.eq(true))
        .get_result::<Post>(connection)
        .unwrap();
    println!("Published post {}", post.title);
}
```

執行程式。

```bash
cargo run --bin publish_post 1
```

查看文章列表。

```bash
cargo run --bin show_posts
```

### 刪除文章

新增 `src/bin/delete_post.rs` 檔。

```rs
use diesel::prelude::*;
use diesel_example::*;
use std::env::args;

fn main() {
    use self::schema::posts::dsl::posts;

    let id = args()
        .nth(1)
        .expect("publish_post requires a post id")
        .parse::<i32>()
        .expect("Invalid ID");
    let connection = &mut establish_connection();

    let num_deleted = diesel::delete(posts.find(id))
        .execute(connection)
        .expect("Error deleting posts");

    println!("Deleted {} posts", num_deleted);
}
```

執行程式。

```bash
cargo run --bin delete_post 1
```

查看文章列表。

```bash
cargo run --bin show_posts
```

## 程式碼

- [diesel-example](https://github.com/memochou1993/diesel-example)

## 參考資料

- [Diesel](https://diesel.rs/guides/getting-started)
