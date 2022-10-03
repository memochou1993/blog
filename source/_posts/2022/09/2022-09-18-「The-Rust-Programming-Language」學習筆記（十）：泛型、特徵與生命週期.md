---
title: 「The Rust Programming Language」學習筆記（十）：泛型、特徵與生命週期
date: 2022-09-18 14:21:15
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

### 透過生命週期預防迷途引用

生命週期最主要的目的就是要預防迷途引用（dangling references），其會導致程式引用到其他資料，而非它原本想要的引用。以下程式，它有一個外部作用域與內部作用域。

```RS
{
    let r;

    {
        let x = 5;
        r = &x;
    }

    println!("r: {}", r);
}
```

在內部作用域中，嘗試將 `x` 的引用賦值給 `r`。然後內部作用域結束後，嘗試印出 `r`。此程式碼不會編譯成功，因為數值 `r` 指向的數值在我們嘗試使用它時已經離開作用域。

### 借用檢查器

Rust 編譯器有個借用檢查器（borrow checker），會比較作用域來檢測所有的借用是否有效。

```RS
{
    let r;                // ---------+-- 'a
                          //          |
    {                     //          |
        let x = 5;        // -+-- 'b  |
        r = &x;           //  |       |
    }                     // -+       |
                          //          |
    println!("r: {}", r); //          |
}
```

以下修正了此程式碼讓它不會存在迷途引用，並能夠正確編譯。

```RS
{
    let x = 5;            // ----------+-- 'b
                          //           |
    let r = &x;           // --+-- 'a  |
                          //   |       |
    println!("r: {}", r); //   |       |
                          // --+       |
}                         // ----------+
```

### 函式中的泛型生命週期

以下寫個回傳兩個字串切片中較長者的函式。此函式會接收兩個字串切片並回傳一個字串切片。在實作 `longest` 函式後，程式碼應該要印出最長的字串為 `abcd`。

```RS
fn main() {
    let string1 = String::from("abcd");
    let string2 = "xyz";

    let result = longest(string1.as_str(), string2);
    println!("最長的字串為 {}", result);
}
```

如果我們嘗試實作 `longest` 函式時，如以下所示，它不會編譯過。因為 Rust 無法辨別出回傳的引用指的是 `x` 還是 `y`。

```RS
fn longest(x: &str, y: &str) -> &str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

要修正此錯誤，要加上泛型生命週期參數來定義引用之間的關係，讓借用檢查器能夠進行分析。

### 生命週期詮釋語法

生命週期詮釋不會改變引用能存活多久。就像當函式簽名指定了一個泛型型別參數時，函式便能夠接受任意型別一樣。函式可以指定一個泛型生命週期參數，這樣函式就能接受任何生命週期。生命週期詮釋描述了數個引用的生命週期之間互相的關係，而不會影響其生命週期。

生命週期詮釋的語法有一點不一樣：生命週期參數的名稱必須以撇號（`'`）作為開頭，通常全是小寫且很短，就像泛型型別一樣。大多數的人會使用名稱 `'a`。我們將生命週期參數置於引用的 `&` 之後，並使用空格區隔詮釋與引用的型別。

```RS
&i32        // 一個引用
&'a i32     // 一個有顯式生命週期的引用
&'a mut i32 // 一個有顯式生命週期的可變引用
```

只有自己一個生命週期本身沒有多少意義，因為該詮釋是為了告訴 Rust 數個引用的泛型生命週期參數之間互相的關係。舉例來說，我們有個函式其參數 `first` 是個 `i32` 的引用而生命週期為 `'a`。此函式還有另一個參數 `second` 是另一個 `i32` 的引用而且生命週期也是 `'a`。生命週期詮釋意味著引用 `first` 與 `second` 必須與此泛型生命週期存活的一樣久。

### 函式簽名中的生命週期詮釋

如同泛型型別參數，需要在函式名稱與參數列表之間的尖括號內宣告泛型生命週期參數。我們想在此簽名表達的是參數的生命週期與回傳引用的生命週期是相關的，所有參數都要是有效的，那麼回傳的引用才也會是有效的。以下會將生命週期命名為 `'a` 然後將它加到每個引用。

```RS
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

此函式簽名告訴 Rust 它有個生命週期 `'a`，函式的兩個參數都是字串切片，並且會有生命週期 `'a`。此函式簽名還告訴了 Rust 從函式回傳的字串切片也會和生命週期 `'a` 存活的一樣久。實際上它代表 longest 函式回傳引用的生命週期與傳入時字串長度較短的引用的生命週期一樣。這樣的關係正是我們想讓 Rust 知道以便分析這段程式碼。

注意當我們在此函式簽名指定生命週期參數時，我們不會變更任何傳入或傳出數值的生命週期。我們只是告訴借用檢查器應該要拒絕任何沒有服從這些約束的數值。注意到 `longest` 函式不需要知道 `x` 和 `y` 實際上會活多久，只需要知道有某個作用域會用 `'a` 取代來滿足此簽名。

當要在函式詮釋生命週期時，詮釋會位於函式簽名中，而不是函式本體。就像型別會寫在簽名中一樣，生命週期詮釋會成為函式的一部份。在函式簽名加上生命週期能讓 Rust 編譯器的分析工作變得更輕鬆。如果當函式的詮釋或呼叫的方式出問題時，編譯器錯誤就能限縮到我們的程式碼中指出來。如果都改讓 Rust 編譯器去推到可能的生命週期關係的話，編譯器可能會指到程式碼真正出錯之後的好幾步之後。

當我們向 `longest` 傳入實際引用時，`'a` 實際替代的生命週期為 x 作用域與 y 作用域重疊的部分。換句話說，泛型生命週期 `'a` 取得的生命週期會等於 `x` 與 `y` 的生命週期中較短的。因為我們將回傳引用詮釋了相同的生命週期參數 `'a`，回傳引用的生命週期也會保證在 `x` 和 `y 的生命週期較短的結束前有效。

來看看如何透過傳入不同實際生命週期的引用來使生命週期詮釋能約束 `longest` 函式。

```RS
fn main() {
    let string1 = String::from("很長的長字串");

    {
        let string2 = String::from("xyz");
        let result = longest(string1.as_str(), string2.as_str());
        println!("最長的字串為 {}", result);
    }
}
```

以下寫一個範例能要求 `result` 生命週期的引用必須是兩個引數中較短的才行。

```RS
fn main() {
    let string1 = String::from("很長的長字串");
    let result;
    {
        let string2 = String::from("xyz");
        result = longest(string1.as_str(), string2.as_str());
    }
    println!("最長的字串為 {}", result);
}
```

嘗試編譯此程式碼，會看到以下錯誤。

```RS
$ cargo run
   Compiling chapter10 v0.1.0 (file:///projects/chapter10)
error[E0597]: `string2` does not live long enough
 --> src/main.rs:6:44
  |
6 |         result = longest(string1.as_str(), string2.as_str());
  |                                            ^^^^^^^^^^^^^^^^ borrowed value does not live long enough
7 |     }
  |     - `string2` dropped here while still borrowed
8 |     println!("最長的字串為 {}", result);
  |                               ------ borrow later used here

For more information about this error, try `rustc --explain E0597`.
error: could not compile `chapter10` due to previous error
```

錯誤訊息表示要讓 `result` 在 `println!` 陳述式有效的話，`string2` 必須在外部作用域結束前都是有效的。Rust 會知道是因為我們在函式的參數與回傳值使用相同的生命週期 `'a` 來詮釋。

身為人類我們能看出此程式碼，因為 `string1` 尚未離開作用域，所以 `string1` 的引用在 `println!` 陳述式中仍然是有效的才對。然而編譯器在此情形會無法看出引用是有效的。所以我們才告訴 Rust `longest` 函式回傳引用的生命週期等同於傳入引用中較短的生命週期。這樣一來借用檢查器就會否決程式碼，因為它可能會有無效的引用。

### 深入理解生命週期

指定生命週期參數的方式取決於函式的行為。舉例來說如果我們改變函式 `longest` 的實作為永遠只回傳第一個參數而不是最長的字串切片，我們就不需要在參數 y 指定生命週期。

在此例中，我們指定生命週期參數 `'a` 給參數 `x` 與回傳型別，但參數 `y` 則沒有，因為 `y` 的生命週期與 `x` 和回傳型別的生命週期之間沒有任何關係。

```RS
fn longest<'a>(x: &'a str, y: &str) -> &'a str {
    x
}
```

當函式回傳引用時，回傳型別的生命週期參數必須符合其中一個參數的生命週期參數。如果回傳引用沒有和任何參數有關聯的話，代表它引用的是函式本體中的數值。但這會是迷途引用，因為該數值會在函式結尾離開作用域。

```RS
fn longest<'a>(x: &str, y: &str) -> &'a str {
    let result = String::from("超長的字串");
    result.as_str()
}
```

總結來說，生命週期語法是用來連接函式中不同參數與回傳值的生命週期。一旦連結起來，Rust 就可以獲得足夠的資訊來確保記憶體安全的運算並防止會產生迷途指標或違反記憶體安全的操作。

### 結構體定義中的生命週期詮釋

目前為止，我們只定義過擁有所有權的結構體。結構體其實也能持有引用，不過我們會需要在結構體定義中每個引用加上生命週期詮釋。以下範例有個持有字串切片的結構體 `ImportantExcerpt`。

```RS
struct ImportantExcerpt<'a> {
    part: &'a str,
}

fn main() {
    let novel = String::from("叫我以實瑪利。多年以前...");
    let first_sentence = novel.split('.').next().expect("找不到'.'");
    let i = ImportantExcerpt {
        part: first_sentence,
    };
}
```

此結構體有個欄位 `part` 並擁有字串切片引用。如同泛型資料型別，我們在結構體名稱之後的尖括號內宣告泛型生命週期參數，所以我們就可以在結構體定義的本體中使用生命週期參數。此詮釋代表 `ImportantExcerpt` 的實例不能比它持有的欄位 `part` 活得還久。

`main` 函式在此產生一個結構體 `ImportantExcerpt` 的實例並持有一個引用，其為變數 `novel` 所擁有的 `String` 中的第一個句子的引用。`novel` 的資料是在 `ImportantExcerpt` 實例之前建立的。除此之外，`novel` 在 `ImportantExcerpt` 離開作用域之前不會離開作用域，所以 `ImportantExcerpt` 實例中的引用是有效的。

### 生命週期省略

每個引用都有個生命週期，而且需要在有使用引用的函式與結構體中指定生命週期參數。然而在以下範例，可以不詮釋生命週期並照樣編譯成功。

```RS
fn first_word(s: &str) -> &str {
    let bytes = s.as_bytes();

    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[0..i];
        }
    }

    &s[..]
}
```

Rust 團隊發現 Rust 開發者會在特定情況反覆輸入同樣的生命週期詮釋。這些情形都是可預期的，而且可以遵循一些明確的模式。開發者將這些模式加入編譯器的程式碼中，所以借用檢查器可以依據這些情況自行推導生命週期，而讓我們不必顯式詮釋。這樣的歷史值得提起的原因是因為很可能會有更多明確的模式被找出來並加到編譯器中，意味著未來對於生命週期詮釋的要求會更少。

被寫進 Rust 引用分析的模式被稱作生命週期省略規則（lifetime elision rules）。這些不是程式設計師要遵守的規則，而是一系列編譯器能去考慮的情形。而如果你的程式碼符合這些情形時，你就不必顯式寫出生命週期。

當引用沒有顯式詮釋生命週期時，編譯器會用三項規則來推導它們。

- 第一個規則是每個引用都會有自己的生命週期參數。

- 第二個規則是如果剛好只有一個輸入生命週期參數，該參數就會賦值給所有輸出生命週期參數。

- 第三個規則是如果有多個輸入生命週期參數，但其中一個是 `&self` 或 `&mut self``，由於這是方法，self` 的生命週期會賦值給所有輸出生命週期參數。

### 在方法定義中的生命週期詮釋

當我們在有生命週期的結構體上實作方法時，其語法類似於範例中泛型型別參數的語法。宣告並使用生命週期參數的地方會依據它們是否與結構體欄位或方法參數與回傳值相關。

結構體欄位的生命週期永遠需要宣告在 `impl` 關鍵字後方以及結構體名稱後方，因為這些生命週期是結構體型別的一部分。

在 `impl` 區塊中方法簽名的引用可能會與結構體欄位的引用生命週期綁定，或者它們可能是互相獨立的。除此之外，生命週期省略規則常常可以省略方法簽名中的生命週期詮釋。

首先，使用一個方法叫做 `level` 其參數只有 `self` 的引用而回傳值是 `i32`，這不是任何引用：

```RS
impl<'a> ImportantExcerpt<'a> {
    fn level(&self) -> i32 {
        3
    }
}
```

生命週期參數宣告在 `impl` 之後，而且也要在型別名稱之後加上。但是不必在 `self` 的引用加上生命週期詮釋，因為其適用於第一個省略規則。

以下是第三個生命週期省略規則適用的地方：

```RS
impl<'a> ImportantExcerpt<'a> {
    fn announce_and_return_part(&self, announcement: &str) -> &str {
        println!("請注意：{}", announcement);
        self.part
    }
}
```

這裡有兩個輸入生命週期，所以 Rust 用第一個生命週期省略規則給予 `&self` 和 `announcement` 它們自己的生命週期。然後因為其中一個參數是 `&self`，回傳型別會取得 `&self` 的生命週期，如此一來所有的生命週期都推導出來了。

### 靜態生命週期

其中有個特殊的生命週期 `'static` 需要進一步討論，這是指該引用可以存活在整個程式期間。所有的字串字面值都有 `'static` 生命週期，可以這樣詮釋：

```RS
let s: &'static str = "我有靜態生命週期。";
```

此字串的文字會直接儲存在程式的二進制檔案中，所以永遠有效。因此所有的字串字面值的生命週期都是 `'static`。

有時可能會看到錯誤訊息建議使用 `'static` 生命週期。但在對引用指明 `'static` 生命週期前，最好想一下該引用的生命週期是否真的會存在於整個程式期間。就算它可以，可能也得考慮是不是該活得這麼久。大多數的情況，程式問題都來自於嘗試建立迷途引用或可用的生命週期不符。這樣的情況下，應該是要實際嘗試解決問題，而不是指明 `'static` 生命週期。

## 組合

用一個函式來總結泛型型別參數、特徵界限與生命週期的語法！

```RS
use std::fmt::Display;

fn longest_with_an_announcement<'a, T>(
    x: &'a str,
    y: &'a str,
    ann: T,
) -> &'a str
where
    T: Display,
{
    println!("公告！{}", ann);
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

這是範例會回傳兩個字串切片較長者的 `longest` 函式。不過現在它有個額外的參數 `ann`，使用的是泛型型別 `T`，它可以是任何在 `where` 中所指定有實作 `Display` 特徵的型別。此額外參數會在 `{}` 的地方印出來，這正是為何 `Display` 的特徵界限是必須的。因為生命週期也是一種泛型，生命週期參數 `'a` 與泛型型別參數 `T` 都宣告在函式名稱後的尖括號內。

## 參考資料

- [The Rust Programming Language](https://doc.rust-lang.org/stable/book/)
