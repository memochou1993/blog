---
title: 「The Rust Programming Language」學習筆記（一）
permalink: 「The-Rust-Programming-Language」學習筆記（一）
date: 2022-04-17 21:09:25
tags: ["程式設計", "Rust"]
categories: ["程式設計", "Rust", "「The Rust Programming Language」學習筆記"]
---

## 前言

本文為「[The Rust Programming Language](https://doc.rust-lang.org/stable/book/)」語言指南的學習筆記。

## 介紹

Rust 程式設計語言能寫出更快更可靠的軟體。高層的易讀易用性與底層的掌控性常常是程式設計語言之間的取捨，Rust 試圖挑戰這項矛盾。透過平衡強大的技術能力以及優秀的開發體驗，Rust 使開發者能控制底層的實作細節（比如記憶體使用）的同時，免於以往這樣的控制所帶來的相關麻煩。

## 安裝

使用以下指令安裝 Rust 語言。

```BASH
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
```

查看版本。

```BASH
rustc --version
rustc 1.60.0 (7737e0b5c 2022-04-04)
```

## 開始入門

建立專案。

```BASH
mkdir rust-example
cd rust-example
```

新增 `main.rs` 檔。

```RS
fn main() {
    println!("Hello, world!")
}
```

使用 `rustc` 指令進行編譯。

```BASH
rustc main.rs
```

運行執行檔。

```BASH
./main
```

輸出結果如下。

```BASH
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

```BASH
cargo --version
cargo 1.60.0 (d1fd9fe2c 2022-03-01)
```

使用 Cargo 建立專案。

```BASH
cargo new hello_cargo
```

專案中的 `Cargo.toml` 檔是 Cargo 配置文件的格式，用的是 TOML 格式。

```TOML
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

```RS
fn main() {
    println!("Hello, world!");
}
```

Cargo 預設會產生一個「Hello, world!」程式。專案的根目錄是用來放 `README` 檔案、授權條款、配置檔案以及其他與程式碼不相關的檔案。

使用 `cargo` 指令進行編譯。

```BASH
cargo build
```

運行執行檔。

```BASH
./target/debug/hello_cargo
```

其中 `Cargo.lock` 檔是用來追蹤依賴函式庫的確切版本。

如果要編譯執行檔並且直接運行，可以使用以下指令。

```BASH
cargo run
```

如果要檢查程式碼，確保它能編譯通過但不會產生執行檔，可以使用以下指令。

```BASH
cargo check
```

Cargo 會儲存建構結果在 `target/debug` 目錄底下。

可以使用 `cargo build --release` 來最佳化編譯結果。此命令會產生執行檔到 `target/release` 而不是 `target/debug` 目錄。最佳化可以讓你的 Rust 程式碼跑得更快，不過也會讓編譯的時間變得更久。

Cargo 提供兩種不同的設定檔（profile）：一個用來作為開發使用，可以快速並經常重新建構；另一個用來產生最終要給使用者運行的程式用，它通常不會需要重新建構且能盡所能地跑得越快越好。

## 基本語法

### 變數與可變性

#### 變數

執行以下程式，會收到一則錯誤訊息。

```RS
fn main() {
    let x = 5;
    println!("x 的數值為：{}", x);
    x = 6;
    println!("x 的數值為：{}", x);
}
```

可以在變數名稱前面加上 `mut` 讓它們可以成為可變的，加上 `mut` 也向未來的讀取者表明了其他部分的程式碼將會改變此變數的數值。

```RS
fn main() {
    let mut x = 5;
    println!("x 的數值為：{}", x);
    x = 6;
    println!("x 的數值為：{}", x);
}
```

執行後，會得到以下訊息。

```RS
cargo run
   Compiling hello_cargo v0.1.0 (/Users/memochou/Projects/hello_cargo)
    Finished dev [unoptimized + debuginfo] target(s) in 0.93s
     Running `target/debug/hello_cargo`
x 的數值為：5
x 的數值為：6
```

#### 常數

常數（constants）和不可變變數一樣，常數會讓數值與名稱綁定且不允許被改變，但是不可變變數與常數還是有些差異。

常數可以被定義在任一有效範圍，包含全域有效範圍。這讓它們非常有用，讓許多部分的程式碼都能夠知道它們。

最後一個差別是常數只能被常數表達式設置，不能用任一在運行時產生的其他數值設置。

```RS
const THREE_HOURS_IN_SECONDS: u32 = 60 * 60 * 3;
```

Rust 的常數命名規則為使用全部英文大寫並用底寫區隔每個單字。

#### 遮蔽（Shadowing）

我們可以用 `let` 關鍵字來重複宣告相同的變數名稱來遮蔽一個變數。

```RS
fn main() {
    let x = 5;

    let x = x + 1;

    {
        let x = x * 2;
        println!("x 在內部範圍的數值為：{}", x);
    }

    println!("x 的數值為：{}", x);
}
```

執行後，會得到以下訊息。

```BASH
cargo run
   Compiling variables v0.1.0 (file:///projects/variables)
    Finished dev [unoptimized + debuginfo] target(s) in 0.31s
     Running `target/debug/variables`
x 在內部範圍的數值為：12
x 的數值為：6
```

遮蔽與標記變數為 `mut` 是不一樣的，因為如果我們不小心重新賦值而沒有加上 `let` 關鍵字的話，是會產生編譯期錯誤的。使用 `let` 的話，我們可以作出一些改變，然後在這之後該變數仍然是不可變的。

另一個 `mut` 與遮蔽不同的地方是，我們能有效地再次運用 `let` 產生新的變數，可以在重新運用相同名稱時改變它的型別。

```RS
let spaces = "   ";
let spaces = spaces.len();
```

不過，可變變數仍然是無法變更變數型別的，如果這樣做的話我們就會拿到編譯期錯誤。

```RS
let mut spaces = "   ";
spaces = spaces.len();
```

執行後，會得到以下訊息。

```BASH
cargo run
   Compiling hello_cargo v0.1.0 (/Users/memochou/Projects/hello_cargo)
error[E0308]: mismatched types
 --> src/main.rs:3:14
  |
2 |     let mut spaces = "   ";
  |                      ----- expected due to this value
3 |     spaces = spaces.len();
  |              ^^^^^^^^^^^^ expected `&str`, found `usize`
```

### 資料型別

#### 整數型別

整數是沒有小數點的數字。在第二章用到了一個整數型別 `u32`，此型別表示其擁有的數值應該是一個佔 32 位元大小的非帶號整數（帶號整數的話則是用 `i` 起頭而非 `u`）。

每一帶號變體可以儲存的數字範圍包含從 `-(2^n - 1)` 到 `2^n - 1 - 1` 以內的數字，`n` 就是該變體佔用的位元大小。所以一個 `i8` 可以儲存的數字範圍就是從 `-(2^7)` 到 `2^7 - 1`，也就是 -128 到 127。而非帶號可以儲存的數字範圍則是從 `0` 到 `2^n - 1`，所以 `u8` 可以儲存的範圍是從 `0` 到 `2^8 - 1`，也就是 0 到 255。

#### 浮點數型別

Rust 還有針對有小數點的浮點數提供兩種基本型別：`f32` 和 `f64`，分別佔有 32 位元與 64 位元的大小。而預設的型別為 `f64`，因為現代的電腦處理的速度幾乎和 `f32` 一樣卻還能擁有更高的精準度。所有的浮點數型別都是帶號的（signed）。

```RS
fn main() {
    let x = 2.0; // f64

    let y: f32 = 3.0; // f32
}
```

#### 數值運算

Rust 支援所有想得到的數值型別基本運算：加法、減法、乘法、除法和取餘。整數除法會取最接進的下界數值。

```RS
fn main() {
    // 加法
    let sum = 5 + 10;

    // 減法
    let difference = 95.5 - 4.3;

    // 乘法
    let product = 4 * 30;

    // 除法
    let quotient = 56.7 / 32.2;
    let floored = 2 / 3; // 結果爲 0

    // 取餘
    let remainder = 43 % 5;
}
```

#### 布林型別

Rust 中的布林型別有兩個可能的值：`true` 和 `false`。布林值的大小為一個位元組。

```RS
fn main() {
    let t = true;

    let f: bool = false; // 型別詮釋的方式
}
```

#### 字元型別

Rust 的 char 型別是最基本的字母型別。

```RS
fn main() {
    let c = 'z';
    let z = 'ℤ';
    let heart_eyed_cat = '😻';
}
```

注意到 `char` 字面值是用單引號賦值，宣告字串字面值時才是用雙引號。Rust 的 `char` 型別大小為四個位元組並表示為一個 Unicode 純量數值，這代表它能擁有的字元比 ASCII 還來的多。舉凡標音字母（Accented letters）、中文、日文、韓文、表情符號以及零長度空格都是 `char` 的有效字元。

#### 元組型別

元組是個將許多不同型別的數值合成一個複合型別的常見方法。元組擁有固定長度：一旦宣告好後，它們就無法增長或縮減。

建立一個元組的方法是寫一個用括號囊括起來的數值列表，每個值再用逗號分隔開來。元組的每一格都是一個獨立型別，不同數值不必是相同型別。

```RS
fn main() {
    let tup: (i32, f64, u8) = (500, 6.4, 1);
}
```

此變數 `tup` 就是整個元組，因為一個元組就被視為單一複合元素。要拿到元組中的每個獨立數值的話，我們可以用模式配對（pattern matching）來解構一個元組的數值。

```RS
fn main() {
    let tup = (500, 6.4, 1);

    let (x, y, z) = tup;

    println!("y 的數值為：{}", y);
}
```

也可以直接用句號（`.`）再加上數值的索引來取得元組內的元素。

```RS
fn main() {
    let x: (i32, f64, u8) = (500, 6.4, 1);

    let five_hundred = x.0;

    let six_point_four = x.1;

    let one = x.2;
}
```

和多數程式語言一樣，元組的第一個索引是 0。

沒有任何數值的元組 `()` 會是個只有一種數值的特殊型別，其值也寫作 `()`。此型別稱爲「單元型別」而其數值稱爲「單元數值」。

#### 陣列型別

和元組不一樣的是，陣列中的每個型別必須是一樣的。和其他語言的陣列不同，Rust 的陣列是固定長度的。

```RS
fn main() {
    let a = [1, 2, 3, 4, 5];
}
```

如果希望資料被分配在堆疊（stack）而不是堆積（heap）的話，使用陣列是很好的選擇（在第四章會討論堆疊與堆積的內容）。

如果知道元素的多寡不會變的話，陣列就是個不錯的選擇。

```RS
let months = ["一月", "二月", "三月", "四月", "五月", "六月", "七月",
              "八月", "九月", "十月", "十一月", "十二月"];
```

要詮釋陣列型別的話，可以在中括號寫出型別和元素個數，並用分號區隔開來。

```RS
let a: [i32; 5] = [1, 2, 3, 4, 5];
```

如果想建立的陣列中每個元素數值都一樣的話，可以指定一個數值後加上分號，最後寫出元素個數。

```RS
let a = [3; 5]; // 和 let a = [3, 3, 3, 3, 3]; 一樣
```

一個陣列是被分配在堆疊上且已知固定大小的一整塊記憶體，可以使用索引來取得陣列的元素。

```RS
fn main() {
    let a = [1, 2, 3, 4, 5];

    let first = a[0];
    let second = a[1];
}
```

### 函式

TODO

## 參考資料

- [The Rust Programming Language](https://doc.rust-lang.org/stable/book/)
