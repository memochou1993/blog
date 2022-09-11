---
title: 「The Rust Programming Language」學習筆記（八）：泛型型別、特徵與生命週期
permalink: 「The-Rust-Programming-Language」學習筆記（八）：泛型型別、特徵與生命週期
date: 2022-09-11 14:21:15
tags: ["程式設計", "Rust"]
categories: ["程式設計", "Rust", "「The Rust Programming Language」學習筆記"]
---

## 前言

本文為「[The Rust Programming Language](https://doc.rust-lang.org/stable/book/)」語言指南的學習筆記。

## 簡介

每個程式語言都有能夠高效處理概念複製的工具。在 Rust 此工具就是泛型（generics）。泛型是實際型別或其他屬性的抽象替代。類似於函式有辦法能接收多種未知數值作為參數來執行相同程式碼，函式也可以接受一些泛型型別參數，而不是實際型別像是 `i32` 或 `String`。

## 泛型資料型別

我們可以使用泛型（generics）來建立項目的定義，像是函式簽名或結構體，讓我們在之後可以使用在不同的實際資料型別。

### 在函式中定義

當要使用泛型定義函數時，我們通常會將泛型置於函式簽名中指定參數與回傳值資料型別的位置。這樣做能讓我們的程式碼更具彈性並向呼叫者提供更多功能，同時還能防止重複程式碼。

以下展示了兩個都在切片上尋找最大值的函式。

```RS
fn largest_i32(list: &[i32]) -> i32 {
    let mut largest = list[0];

    for &item in list {
        if item > largest {
            largest = item;
        }
    }

    largest
}

fn largest_char(list: &[char]) -> char {
    let mut largest = list[0];

    for &item in list {
        if item > largest {
            largest = item;
        }
    }

    largest
}

fn main() {
    let number_list = vec![34, 50, 25, 100, 65];

    let result = largest_i32(&number_list);
    println!("最大數字為 {}", result);

    let char_list = vec!['y', 'm', 'a', 'q'];

    let result = largest_char(&char_list);
    println!("最大字元為 {}", result);
}
```

由於函式本體都擁有相同的程式碼，因此可以用泛型型別參數來消除重複的部分，轉變成只有一個函式。要在新定義的函式中參數化型別的話，需要為參數型別命名，就和在函式中的參數數值所做的一樣。可以用任何標識符來命名型別參數名稱。但習慣上會用 `T`，因為 Rust 的參數名稱都盡量很短，常常只會有一個字母，而且 Rust 對於型別命名的慣用規則是駝峰式大小寫（CamelCase）。所以 `T` 作為「type」的簡稱是大多數 Rust 程式設計師的選擇。

要定義泛型 `largest` 函式的話，在函式名稱與參數列表之間加上尖括號，其內就是型別名稱的宣告，如以下所示：

```RS
fn largest<T>(list: &[T]) -> T {}
```

可以這樣理解定義：函式 `largest` 有泛型型別 `T`，此函式有一個參數叫做 `list`，它的型別為數值 `T` 的切片。`largest` 函式會回傳與型別 `T` 相同型別的值。

```RS
fn largest<T>(list: &[T]) -> T {
    let mut largest = list[0];

    for &item in list {
        if item > largest {
            largest = item;
        }
    }

    largest
}

fn main() {
    let number_list = vec![34, 50, 25, 100, 65];

    let result = largest(&number_list);
    println!("最大數字為 {}", result);

    let char_list = vec!['y', 'm', 'a', 'q'];

    let result = largest(&char_list);
    println!("最大字元為 {}", result);
}
```

編譯後會得到以下錯誤：

```BASH
$ cargo run
   Compiling chapter10 v0.1.0 (file:///projects/chapter10)
error[E0369]: binary operation `>` cannot be applied to type `T`
 --> src/main.rs:5:17
  |
5 |         if item > largest {
  |            ---- ^ ------- T
  |            |
  |            T
  |
help: consider restricting type parameter `T`
  |
1 | fn largest<T: std::cmp::PartialOrd>(list: &[T]) -> T {
  |             ++++++++++++++++++++++

For more information about this error, try `rustc --explain E0369`.
error: could not compile `chapter10` due to previous error
```

註釋中提到了 `std::cmp::PartialOrd` 這個特徵（trait）。現在此錯誤告訴我們 `largest` 本體無法適用於所有可能的 T 型別，因為想要在本體中比較型別 `T` 的數值，我們只能在能夠排序的型別中做比較。要能夠比較的話，標準函式庫有提供 `std::cmp::PartialOrd` 特徵可以針對不同型別來實作。

在「特徵作為參數」的段落會學習到如何指定特定泛型型別擁有特定特徵。先來探索其他泛型型別參數使用的方式。

### 在結構體中定義

以 `<>` 語法來對結構體中一或多個欄位使用泛型型別參數。以下範例顯示了如何定義 `Point<T>` 結構體並讓 `x` 與 `y` 可以是任意型別數值。

```RS
struct Point<T> {
    x: T,
    y: T,
}

fn main() {
    let integer = Point { x: 5, y: 10 };
    let float = Point { x: 1.0, y: 4.0 };
}
```

要將結構體 `Point` 的 `x` 與 `y` 定義成擁有不同型別卻仍然是泛型的話，可以使用多個泛型型別參數。

```RS
struct Point<T, U> {
    x: T,
    y: U,
}

fn main() {
    let both_integer = Point { x: 5, y: 10 };
    let both_float = Point { x: 1.0, y: 4.0 };
    let integer_and_float = Point { x: 5, y: 4.0 };
}
```

### 在枚舉中定義

如同結構體一樣，可以定義枚舉讓它們的變體擁有泛型資料型別。

```RS
enum Option<T> {
    Some(T),
    None,
}
```

枚舉也能有數個泛型型別。

```RS
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

### 在方法中定義

可以對結構體或枚舉定義方法，並也可以使用泛型型別來定義。

```RS
struct Point<T> {
    x: T,
    y: T,
}

impl<T> Point<T> {
    fn x(&self) -> &T {
        &self.x
    }
}

fn main() {
    let p = Point { x: 5, y: 10 };

    println!("p.x = {}", p.x());
}
```

另一種選項是在定義方法時，可以對泛型型別加上些限制。舉例來說，可以只針對 `Point<f32>` 的實例來實作方法，而非適用於任何泛型型別的 `Point<T>` 實例。

```RS
impl Point<f32> {
    fn distance_from_origin(&self) -> f32 {
        (self.x.powi(2) + self.y.powi(2)).sqrt()
    }
}
```

### 使用泛型的程式碼效能

Rust 在編譯時對使用泛型的程式碼進行單態化（monomorphization）。單態化是個讓泛型程式碼轉換成特定程式碼的過程，在編譯時填入實際的型別。在此過程中，編譯器會檢查所有泛型程式碼被呼叫的地方，並依據泛型程式碼被呼叫的情況產生實際型別的程式碼。

這在標準函式庫的枚舉 `Option<T>` 中是怎麼做到的：

```RS
let integer = Some(5);
let float = Some(5.0);
```

當 Rust 編譯此程式碼時中，他會進行單態化。在此過程中，會讀取 `Option<T>` 實例中使用的數值並識別出兩種 `Option<T>`：一種是 `i32` 而另一種是 `f64`。接著它就會將 `Option<T>` 的泛型定義展開為 `Option_i32` 和 `Option_f64`，以此替換函式定義為特定型別。

單態化的版本看起來會像這樣，泛型 `Option<T>` 會被替換成編譯器定義的特定定義：

```RS
enum Option_i32 {
    Some(i32),
    None,
}

enum Option_f64 {
    Some(f64),
    None,
}

fn main() {
    let integer = Option_i32::Some(5);
    let float = Option_f64::Some(5.0);
}
```

因為 Rust 會編譯泛型程式碼成個別實例的特定型別，我們使用泛型就不會造成任何執行時消耗。當程式執行時，它就會和我們親自寫重複定義的版本一樣。單態化的過程讓 Rust 的泛型在執行時十分有效率。

## 特徵

特徵（trait）會告訴 Rust 編譯器特定型別與其他型別共享的功能。我們可以使用特徵定義來抽象出共同行為。我們可以使用特徵界限（trait bounds）來指定泛型型別為擁有特定行為的任意型別。

### 定義特徵

一個型別的行為包含我們對該型別可以呼叫的方法。如果我們可以對不同型別呼叫相同的方法，這些型別就能定義共同行為了。特徵定義是一個將方法簽名統整起來，來達成一些目的而定義一系列行為的方法。

舉例來說，如果有數個結構體各自擁有不同種類與不同數量的文字：結構體 `NewsArticle` 儲存特定地點的新聞故事，然後 `Tweet` 則有最多 280 字元的內容，且有個欄位來判斷是全新的推文、轉推或其他推文的回覆。

我們想要建立個多媒體資料庫來顯示可能存在 `NewsArticle` 或 `Tweet` 實例的資料總結。要達成此目的的話，需要每個型別的總結，且會呼叫該實例的 `summarize` 方法來索取總結。以下範例顯示了表達此行為的 `Summary` 特徵定義。

```RS
pub trait Summary {
    fn summarize(&self) -> String;
}
```

在方法簽名之後，我們並沒有加上大括號提供實作細節，而是使用分號。每個有實作此特徵的型別必須提供其自訂行為的方法本體。編譯器會強制要求任何有 `Summary` 特徵的型別都要有定義相同簽名的 `summarize` 方法。

特徵本體中可以有多個方法，每行會有一個方法簽名並都以分號做結尾。

### 為型別實作特徵

現在已經用 `Summary` 特徵定義了所需的方法簽名。以下顯示了 `NewsArticle` 結構體實作 `Summary` 特徵的方式，其使用頭條、作者、位置來建立 `summerize` 的回傳值。至於結構體 `Tweet`，我們使用使用者名稱加上整個推文的文字來定義 `summarize` 方法。

```RS
pub struct NewsArticle {
    pub headline: String,
    pub location: String,
    pub author: String,
    pub content: String,
}

impl Summary for NewsArticle {
    fn summarize(&self) -> String {
        format!("{} {} 著 ({})", self.headline, self.author, self.location)
    }
}

pub struct Tweet {
    pub username: String,
    pub content: String,
    pub reply: bool,
    pub retweet: bool,
}

impl Summary for Tweet {
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
}
```

為一個型別實作一個特徵類似於實作一般的方法。不同的地方在於在 `impl` 之後我們加上的是想要實作的特徵，然後在用 `for` 關鍵字加上我們想要實作特徵的型別名稱。在 `impl` 的區塊內我們置入該特徵所定義的方法簽名，我們使用大括號並填入方法本體來為對特定型別實作出特徵方法的指定行為。

以下的範例展示執行檔 `crate` 如何使用我們的 `aggregator` 函式庫 crate。

```RS
use aggregator::{self, Summary, Tweet};

fn main() {
    let tweet = Tweet {
        username: String::from("horse_ebooks"),
        content: String::from(
            "of course, as you probably already know, people",
        ),
        reply: false,
        retweet: false,
    };

    println!("1 則新推文：{}", tweet.summarize());
}
```

### 預設實作

有時候對特徵內的一些或所有方法定義預設行為是很實用的，而不必要求每個型別都實作所有方法。然後當對特定型別實作特徵時，可以保留或覆蓋每個方法的預設行為。

以下展示如何在 `Summary` 特徵內指定 `summarize` 方法的預設字串。

```RS
pub trait Summary {
    fn summarize(&self) -> String {
        String::from("(閱讀更多...)")
    }
}
```

要使用預設實作來總結 `NewsArticle` 而不是定義自訂實作的話，我們可以指定一個空的 `impl` 區塊。

```RS
impl Summary for NewsArticle {}
```

最後仍然能在 `NewsArticle` 實例中呼叫 `summarize`。

```RS
let article = NewsArticle {
    headline: String::from("Penguins win the Stanley Cup Championship!"),
    location: String::from("Pittsburgh, PA, USA"),
    author: String::from("Iceburgh"),
    content: String::from(
        "The Pittsburgh Penguins once again are the best \
            hockey team in the NHL.",
    ),
};

println!("有新文章發佈！{}", article.summarize());
```

預設實作也能呼叫同特徵中的其他方法，就算那些方法沒有預設實作。這樣一來，特徵就可以提供一堆實用的功能，並要求實作者只需處理一小部分就好。

```RS
pub trait Summary {
    fn summarize_author(&self) -> String;

    fn summarize(&self) -> String {
        format!("(從 {} 閱讀更多...)", self.summarize_author())
    }
}
```

要使用這個版本的 `Summary`，我們只需要在對型別實作特徵時定義 `summarize_author` 就好。

```RS
impl Summary for Tweet {
    fn summarize_author(&self) -> String {
        format!("@{}", self.username)
    }
}
```

注意要是對相同方法覆寫實作的話，就無法呼叫預設實作。

### 特徵作為參數

可以定義一個函式 `notify` 使用它自己的參數 `item` 來呼叫 `summarize` 方法，所以此參數的型別預期有實作 `Summary` 特徵。 為此我們可以使用 `impl Trait` 語法，如以下所示：

```RS
pub fn notify(item: &impl Summary) {
    println!("頭條新聞！{}", item.summarize());
}
```

與其在 `item` 參數指定實際型別，這裡用的是 `impl` 關鍵字並加上特徵名稱。這樣此參數就會接受任何有實作指定特徵的型別。在 `notify` 本體中我們就可以用 `item` 呼叫 `Summary` 特徵的任何方法，像是 `summarize`。

#### 特徵界限語法

語法 `impl Trait` 看起來很直觀，不過它其實是一個更長格式的語法糖，這個格式稱之為「特徵界限（trait bound）」，它長得會像以下。

```RS
pub fn notify<T: Summary>(item: &T) {
    println!("頭條新聞！{}", item.summarize());
}
```

特徵界限語法則適合用於其他比較複雜的案例。舉例來說，有兩個有實作 `Summary` 的參數，使用 `impl Trait` 語法看起來會像以下。

```RS
pub fn notify(item1: &impl Summary, item2: &impl Summary) {}
```

如果想要此函式允許 `item1` 和 `item2` 是不同型別的話，使用 `impl Trait` 的確是正確的（只要它們都有實作 `Summary`）。不過如果希望兩個參數都是同一型別的話，就得使用特徵界限來表達，如以下。

```RS
pub fn notify<T: Summary>(item1: &T, item2: &T) {}
```

#### 透過 + 語法來指定多個特徵界限

假設還想要 `notify` 中的 `item` 不只能夠呼叫 `summarize` 方法，還能顯示格式化訊息的話，可以在 `notify` 定義中指定 `item` 必須同時要有 `Display` 和 `Summary`。這可以使用 `+` 語法來達成：

```RS
pub fn notify(item: &(impl Summary + Display)) {}
```

這也能用在泛型型別的特徵界限中：

```RS
pub fn notify<T: Summary + Display>(item: &T) {}
```

#### 透過 where 來使特徵界限更清楚

使用太多特徵界限也會帶來壞處。每個泛型都有自己的特徵界限，所以有數個泛型型別的函式可以在函式名稱與參數列表之間包含大量的特徵界限資訊，讓函式簽名難以閱讀。因此 Rust 有提供另一個在函式簽名之後指定特徵界限的語法 `where`。所以與其這樣寫：

```RS
fn some_function<T: Display + Clone, U: Clone + Debug>(t: &T, u: &U) -> i32 {}
```

可以這樣寫 `where` 的語法，如以下所示：

```RS
fn some_function<T, U>(t: &T, u: &U) -> i32
    where T: Display + Clone,
          U: Clone + Debug
{}
```

### 返回有實作特徵的型別

也能在回傳的位置使用 `impl Trait` 語法來回傳某個有實作特徵的型別數值。

```RS
fn returns_summarizable() -> impl Summary {
    Tweet {
        username: String::from("horse_ebooks"),
        content: String::from(
            "of course, as you probably already know, people",
        ),
        reply: false,
        retweet: false,
    }
}
```

回傳一個只有指定所需實作特徵的型別在閉包（closures）與疊代器（iterators）中非常有用。閉包與疊代器能建立只有編譯器知道的型別，或是太長而難以指定的型別。`impl Trait` 語法能夠不寫出很長的型別，而是只要指定函數會回傳有實作 `Iterator` 特徵的型別就好。

### 透過特徵界限修正 largest 函式

在 `largest` 方法，想要用大於（>）運算子比較兩個型別為 `T` 的數值。由於該運算子是從標準函式庫中的特徵 `std::cmp::PartialOrd` 的預設方法所定義的，我們希望在 `T` 中加上 `PartialOrd` 的特徵界限，讓函式可以比較任意型別的切片。我們不需要將 `PartialOrd` 引入作用域因為它由 `prelude` 提供。

```RS
fn largest<T: PartialOrd>(list: &[T]) -> T {}
```

這次編譯程式碼時，會得到不同的錯誤：

```BASH
$ cargo run
   Compiling chapter10 v0.1.0 (file:///projects/chapter10)
error[E0508]: cannot move out of type `[T]`, a non-copy slice
 --> src/main.rs:2:23
  |
2 |     let mut largest = list[0];
  |                       ^^^^^^^
  |                       |
  |                       cannot move out of here
  |                       move occurs because `list[_]` has type `T`, which does not implement the `Copy` trait
  |                       help: consider borrowing here: `&list[0]`

error[E0507]: cannot move out of a shared reference
 --> src/main.rs:4:18
  |
4 |     for &item in list {
  |         -----    ^^^^
  |         ||
  |         |data moved here
  |         |move occurs because `item` has type `T`, which does not implement the `Copy` trait
  |         help: consider removing the `&`: `item`

Some errors have detailed explanations: E0507, E0508.
For more information about an error, try `rustc --explain E0507`.
error: could not compile `chapter10` due to 2 previous errors
```

由於像 `i32` 和 `char` 這樣的型別是已知大小可以存在堆疊上，所以它們有實作 `Copy` 特徵。但當我們建立泛型函式 `largest` 時，`list` 參數就有可能拿到沒有實作 `Copy` 特徵的型別。隨後導致我們無法將 `list[0]` 移出給變數 `largest`，最後產生錯誤。

要限制此程式碼只允許有實作 `Copy` 特徵的型別，可以在 `T` 的特徵界限中加上 `Copy`。

```RS
fn largest<T: PartialOrd + Copy>(list: &[T]) -> T {
    let mut largest = list[0];

    for &item in list {
        if item > largest {
            largest = item;
        }
    }

    largest
}

fn main() {
    let number_list = vec![34, 50, 25, 100, 65];

    let result = largest(&number_list);
    println!("最大數字為 {}", result);

    let char_list = vec!['y', 'm', 'a', 'q'];

    let result = largest(&char_list);
    println!("最大字元為 {}", result);
}
```

#### 透過特徵界限來選擇性實作方法

在有使用泛型型別參數 `impl` 區塊中使用特徵界限，可以選擇性地對有實作特定特徵的型別來實作方法。

在以下第二個 `impl` 區塊中，只有在其內部型別 `T` 有實作能夠做比較的 `PartialOrd` 特徵以及能夠顯示在螢幕的 `Display` 特徵的話，才會實作 `cmp_display` 方法。

```RS
use std::fmt::Display;

struct Pair<T> {
    x: T,
    y: T,
}

impl<T> Pair<T> {
    fn new(x: T, y: T) -> Self {
        Self { x, y }
    }
}

impl<T: Display + PartialOrd> Pair<T> {
    fn cmp_display(&self) {
        if self.x >= self.y {
            println!("最大的是 x = {}", self.x);
        } else {
            println!("最大的是 y = {}", self.y);
        }
    }
}
```

還可以對有實作其他特徵的型別選擇性地來實作特徵。對滿足特徵界限的型別實作特徵會稱之為「毯子實作」（blanket implementations），這被廣泛地用在 Rust 標準函式庫中。舉例來說，標準函式庫會對任何有實作 `Display` 特徵的型別實作 `ToString`。標準函式庫中的 `impl` 區塊會有類似這樣的程式碼：

```RS
impl<T: Display> ToString for T {
    // ...
}
```

因為標準函式庫有此毯子實作，所以可以在任何有實作 `Display` 特徵的型別呼叫 `ToString` 特徵的 `to_string` 方法。舉例來說，可以像這樣將整數轉變成對應的 `String` 數值，因為整數有實作 `Display`：

```RS
let s = 3.to_string();
```

毯子實作在特徵技術文件的「Implementors」段落有做說明。

特徵與特徵界限讓我們能使用泛型型別參數來減少重複的程式碼的同時，告訴編譯器該泛型型別該擁有何種行為。編譯器可以利用特徵界限資訊來檢查程式碼提供的實際型別有沒有符合特定行為。在動態語言中，我們要是呼叫一個該型別沒有的方法的話，我們會在執行時才發生錯誤。但是 Rust 將此錯誤移到編譯期間，讓我們必須在程式能夠執行之前確保有修正此問題。除此之外，我們還不用寫在執行時檢查此行為的程式碼，因為我們已經在編譯時就檢查了。這麼做我們可以在不失去泛型彈性的情況下，提升效能。

## 生命週期

Rust 中的每個引用都有個生命週期（lifetime），這是決定該引用是否有效的作用域。大多情況下生命週期是隱式且可推導出來的，就像大多情況下型別是可推導出來的。當多種型別都有可能時，就得詮釋型別。同樣地，當生命週期的引用能以不同方式關聯的話，就得詮釋生命週期。Rust 要求使用泛型生命週期參數來詮釋引用之間的關係，以確保實際在執行時的引用絕對是有效的。

```RS
```

TODO

## 參考資料

- [The Rust Programming Language](https://doc.rust-lang.org/stable/book/)
