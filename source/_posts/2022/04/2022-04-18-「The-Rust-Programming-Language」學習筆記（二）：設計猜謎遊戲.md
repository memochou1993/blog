---
title: 「The Rust Programming Language」學習筆記（二）：設計猜謎遊戲
date: 2022-04-18 15:06:33
tags: ["Programming", "Rust"]
categories: ["Programming", "Rust", "「The Rust Programming Language」Study Notes"]
---

## 前言

本文為「[The Rust Programming Language](https://doc.rust-lang.org/stable/book/)」語言指南的學習筆記。

## 做法

建立專案。

```bash
cargo new rust-guessing-game
cd rust-guessing-game
```

執行程式。

```bash
cargo run
Hello, world!
```

修改 `src/main.rs` 檔。

```rs
use std::io;

fn main() {
    println!("請猜測一個數字！");

    let mut guess = String::new();

    io::stdin().read_line(&mut guess).expect("讀取失敗");

    println!("你的猜測為：{}", guess);
}
```

修改 `Cargo.toml` 檔，引入 `rand` 套件。

```toml
[dependencies]
rand = "0.8.3"
```

使用 `cargo doc` 指令開啟文件，查看 `rand` 套件的使用方法。

```bash
cargo doc --open
```

可以引用 `rand::Rng` 特徵，並使用 `rand::thread_rng().gen_range()` 方法來產生隨機的數字。

```rs
use rand::Rng;
use std::cmp::Ordering;
use std::io;

fn main() {
    println!("請猜測一個數字！");

    let secret_number = rand::thread_rng().gen_range(1..101); // 產生祕密數字

    // ...
}
```

加上 `loop` 關鍵字，讓使用者重複猜測。

```rs
loop {
    let mut guess = String::new(); // 可變變數

    // ...
}
```

處理將字串解析為數字時發生的錯誤。

```rs
let guess: u32 = match guess
    .trim() // 去除換行符號
    .parse() // 解析成數字
{
    Ok(num) => num, // 如果接收到的 Result 是 Ok 的話，就回傳數值
    Err(_) => continue, // 如果接收到的 Result 是 Err 的話，就繼續猜測
};
```

最後引入 `std::cmp::Ordering` 枚舉，比較大小。

```rs
use rand::Rng;
use std::cmp::Ordering;
use std::io;

fn main() {
    println!("請猜測一個數字！");

    let secret_number = rand::thread_rng().gen_range(1..101); // 產生祕密數字

    println!("祕密數字為：{}", secret_number);

    loop {
        let mut guess = String::new(); // 可變變數

        io::stdin()
            .read_line(&mut guess) // 取得使用者輸入
            .expect("讀取失敗"); // 如果接收到的 Result 是 Err 的話，就讓程式當機

        let guess: u32 = match guess
            .trim() // 去除換行符號
            .parse() // 解析成數字
        {
            Ok(num) => num, // 如果接收到的 Result 是 Ok 的話，就回傳數值
            Err(_) => continue, // 如果接收到的 Result 是 Err 的話，就繼續猜測
        };

        println!("你的猜測為：{}", guess);

        match guess.cmp(&secret_number) {
            Ordering::Less => println!("太小了！"),
            Ordering::Greater => println!("太大了！"),
            Ordering::Equal => {
                println!("獲勝！");
                break;
            }
        }
    }
}
```

執行程式。

```bash
cargo run
```

## 程式碼

- [rust-guessing-game](https://github.com/memochou1993/rust-guessing-game)

## 參考資料

- [The Rust Programming Language](https://doc.rust-lang.org/stable/book/)
