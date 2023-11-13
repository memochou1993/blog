---
title: 「The Rust Programming Language」學習筆記（一）：開始入門
date: 2022-04-17 21:09:25
tags: ["Programming", "Rust"]
categories: ["Programming", "Rust", "「The Rust Programming Language」Study Notes"]
---

## 前言

本文為「[The Rust Programming Language](https://doc.rust-lang.org/stable/book/)」語言指南的學習筆記。

## 介紹

Rust 程式設計語言能寫出更快更可靠的軟體。高層的易讀易用性與底層的掌控性常常是程式設計語言之間的取捨，Rust 試圖挑戰這項矛盾。透過平衡強大的技術能力以及優秀的開發體驗，Rust 使開發者能控制底層的實作細節（比如記憶體使用）的同時，免於以往這樣的控制所帶來的相關麻煩。

## 安裝

使用以下指令安裝 Rust 語言。

```bash
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
```

查看版本。

```bash
rustc --version
rustc 1.60.0 (7737e0b5c 2022-04-04)
```

## 開始入門

建立專案。

```bash
mkdir rust-example
cd rust-example
```

新增 `main.rs` 檔。

```rs
fn main() {
    println!("Hello, world!")
}
```

使用 `rustc` 指令進行編譯。

```bash
rustc main.rs
```

運行執行檔。

```bash
./main
```

輸出結果如下。

```bash
Hello, world!
```

### 解析

Rust 程式中的 `main` 是一個特別的函式：它是每個可執行的 Rust 程式中，第一個被執行的程式碼。第一行宣告了一個函式 `main`，它沒有參數也不回傳任何東西。如果有參數的話，它們會被加進括號 `()` 內。

首先，Rust 的排版風格是 4 個空格而非一個 tab。

第二，`println!` 會呼叫一支 Rust 巨集（macro）。如果是呼叫函式的話，那則會是 `println`（去掉 `!`）。在後面會討論更多巨集的細節。目前只需要知道使用 `!` 代表呼叫一支巨集而非一個正常的函式，且該巨集遵守的規則不全都和函式一樣。

第三，`Hello, world!` 是一個字串，我們將此字串作為引數傳遞給 `println!`，然後該字串就會被顯示到終端機上。

第四，我們用分號（`;`）作為該行結尾，代表此表達式的結束和下一個表達式的開始。多數的 Rust 程式碼都以分號做結尾。

Rust 是一門預先編譯（ahead-of-time compiled）的語言，代表可以編譯完成後，將執行檔送到其他地方，然後他們就算沒有安裝 Rust 一樣也可以執行起來。

### Cargo

Cargo 是 Rust 的建構系統與套件管理工具。使用以下指令查看 Cargo 版本。

```bash
cargo --version
cargo 1.60.0 (d1fd9fe2c 2022-03-01)
```

使用 Cargo 建立專案。

```bash
cargo new hello_cargo
```

專案中的 `Cargo.toml` 檔是 Cargo 配置文件的格式，用的是 TOML 格式。

```toml
[package]
name = "hello_cargo"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
```

第一行的 `[package]` 是一個段落（section）標題，說明以下的陳述式（statement）會配置這個套件。接下來三行就是 Cargo 編譯程式所需的配置資訊：名稱、版本以及哪個 Rust edition 會用到。

最後一行 `[dependencies]` 是用來列出專案會用到哪些依賴的段落。在 Rust 中，程式碼套件會被稱為 crates。

查看專案中的 `src/main.rs` 檔。

```rs
fn main() {
    println!("Hello, world!");
}
```

Cargo 預設會產生一個「Hello, world!」程式。專案的根目錄是用來放 `README` 檔案、授權條款、配置檔案以及其他與程式碼不相關的檔案。

使用 `cargo` 指令進行編譯。

```bash
cargo build
```

運行執行檔。

```bash
./target/debug/hello_cargo
```

其中 `Cargo.lock` 檔是用來追蹤依賴函式庫的確切版本。

如果要編譯執行檔並且直接運行，可以使用以下指令。

```bash
cargo run
```

如果要檢查程式碼，確保它能編譯通過但不會產生執行檔，可以使用以下指令。

```bash
cargo check
```

Cargo 會儲存建構結果在 `target/debug` 目錄底下。

可以使用 `cargo build --release` 來最佳化編譯結果。此命令會產生執行檔到 `target/release` 而不是 `target/debug` 目錄。最佳化可以讓你的 Rust 程式碼跑得更快，不過也會讓編譯的時間變得更久。

Cargo 提供兩種不同的設定檔（profile）：一個用來作為開發使用，可以快速並經常重新建構；另一個用來產生最終要給使用者運行的程式用，它通常不會需要重新建構且能盡所能地跑得越快越好。

## 參考資料

- [The Rust Programming Language](https://doc.rust-lang.org/stable/book/)
