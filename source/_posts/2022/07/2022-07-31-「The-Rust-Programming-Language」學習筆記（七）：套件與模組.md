---
title: 「The Rust Programming Language」學習筆記（七）：套件與模組
permalink: 「The-Rust-Programming-Language」學習筆記（七）：套件與模組
date: 2022-07-31 20:12:10
tags: ["程式設計", "Rust"]
categories: ["程式設計", "Rust", "「The Rust Programming Language」學習筆記"]
---

## 前言

本文為「[The Rust Programming Language](https://doc.rust-lang.org/stable/book/)」語言指南的學習筆記。

## 簡介

一個套件（package）可以包含數個二進制 crate 以及選擇性提供一個函式庫 crate。隨著套件增長，可以取出不同的部分作為獨立的 crate，成為對外的依賴函式庫。

除了組織功能以外，對實作細節進行封裝可以讓程式碼在頂層更好使用。一旦實作了某項功能，其他程式就可以用程式碼的公開介面呼叫該程式碼，而不必去知道它如何實作。

Rust 有一系列的功能能讓開發者管理程式碼組織，包含哪些細節能對外提供、哪些細節是私有的，以及程式中每個作用域的名稱為何。這些功能有時會統一稱作模組系統（module system），其中包含：

- 套件（Package）：建構、測試並分享 crate 的 Cargo 功能。
- Crates： 產生函式庫或執行檔的模組集合。
- 模組（Modules） 與 use：控制組織、作用域與路徑的隱私權。
- 路徑（Paths）: 對一個項目的命名方式，像是一個結構體、函式或模組。

## 套件與 Crates

首先，一個 crate 指的是一個二進制執行檔或函式庫。crate 的源頭會是一個原始檔案，讓 Rust 的編譯器可以作為起始點並組織 crate 模組的地方。套件（package）則是提供一系列功能的一或數個 crates。一個套件會包含一個 `Cargo.toml` 檔案來解釋如何建構那些 crates。

套件依據一些規則來組成。一個套件最多可以包含一個函式庫 crate。它可以包含多個二進制執行檔 crate，但一定得至少提供一個 crate（無論是函式庫或二進制執行檔）。

首先，輸入 cargo new 指令。

```BASH
cargo new my-project
```

當輸入命令時，Cargo 會建立一個 Cargo.toml 檔案並以此作為套件依據。查看 Cargo.toml 的內容時，你會發現沒有提到 `src/main.rs`，這是因為 Cargo 遵循一個常規，也就是 `src/main.rs` 就是與套件同名的 二進制 crate 的 crate 源頭。同樣地，Cargo 也會知道如果套件目錄包含 `src/lib.rs` 的話，則該套件就會包含與套件同名的函式庫 crate。Cargo 會將 crate 源頭檔案傳遞給 `rustc` 來建構函式庫或二進制執行檔。

我們在此的套件只有包含 `src/main.rs`，代表它只有一個同名的二進制 crate 叫做 `my-project`。如果套件包含 `src/main.rs` 與 `src/lib.rs` 的話，它就有兩個 crate：一個二進制執行檔與一個函式庫，兩者都與套件同名。一個套件可以有多個二進制 crates，只要將檔案放在 `src/bin` 目錄底下就好，每個檔案會被視為獨立的二進制 crate。

## 作用域與隱私權

模組（Modules）能讓我們在 crate 內組織程式碼成數個群組以便使用且增加閱讀性。模組也能控制項目的隱私權，也就是該項目能否被外部程式碼公開（public）使用，或者只作為內部私有（private）實作細節，對外是無法使用的。

要建立一個新的函式庫叫做 restaurant 的話，執行以下指令。

```BASH
cargo new --lib restaurant
```

修改 `src/lib.rs` 檔。

```RS
mod front_of_house {
    mod hosting {
        fn add_to_waitlist() {}

        fn seat_at_table() {}
    }

    mod serving {
        fn take_order() {}

        fn serve_order() {}

        fn take_payment() {}
    }
}
```

用 `mod` 關鍵字加上模組的名稱來定義一個模組，並用大括號涵蓋模組的本體。在模組中，我們可以再包含其他模組，在此例中包含了 `hosting` 和 `serving`。模組還能包含其他項目，像是結構體、枚舉、常數、特徵、或像是範例中的函式。

稍早提到 `src/main.rs` 和 `src/lib.rs` 屬於 crate 的源頭。之所以這樣命名的原因是因為這兩個文件的內容都會在 crate 源頭模組架構中組成一個模組叫做 crate，這樣的結構稱之為模組樹（module tree）。

```BASH
crate
 └── front_of_house
     ├── hosting
     │   ├── add_to_waitlist
     │   └── seat_at_table
     └── serving
         ├── take_order
         ├── serve_order
         └── take_payment
```

## 引用模組項目的路徑

要展示 Rust 如何從模組樹中找到一個項目，我們要使用和查閱檔案系統時一樣的路徑方法。如果我們想要呼叫函式，我們需要知道它的路徑。

路徑可以有兩種形式：

- 絕對路徑（absolute path）：是從 crate 的源頭開始找起，用 crate 的名稱或 crate 作為起頭。
- 相對路徑（relative path）：是從本身的模組開始，使用 self、super 或是當前模組的標識符（identifiers）。

以下展示兩種從 crate 源頭定義的 `eat_at_restaurant` 函式內呼叫 `add_to_waitlist` 的方法。

```RS
mod front_of_house {
    mod hosting {
        fn add_to_waitlist() {}
    }
}

pub fn eat_at_restaurant() {
    // 絕對路徑
    crate::front_of_house::hosting::add_to_waitlist();

    // 相對路徑
    front_of_house::hosting::add_to_waitlist();
}
```

由於 `add_to_waitlist` 函式和 `eat_at_restaurant` 都是在同一個 crate 底下，所以我們可以使用 `crate` 關鍵字來作為絕對路徑的開頭。

第二次在 `eat_at_restaurant` 呼叫 `add_to_waitlist` 的方式是使用相對路徑。路徑的起頭是 `front_of_house`，因為它和 `eat_at_restaurant` 都被定義在模組樹的同一層中。

何時該用相對或絕對路徑是在專案中要做的選擇。選擇的依據通常會看移動程式碼位置時，是會連帶它們一起移動，或是分開移動到不同地方。不過一般會傾向於指定絕對路徑，因為分別移動程式碼定義與項目呼叫的位置通常是比較常見的。

嘗試編譯範例，得到以下錯誤資訊。

```BASH
cargo build
   Compiling restaurant v0.1.0 (file:///projects/restaurant)
error[E0603]: module `hosting` is private
```

錯誤訊息表示 `hosting` 模組是私有的。換句話說，我們指定 `hosting` 模組與 `add_to_waitlist` 函式的路徑是正確的，但是因為它沒有私有部分的存取權，所以 Rust 不讓我們使用。

模組不僅用來組織你的程式碼，它們還定義了 Rust 的隱私界限（privacy boundary）：這是條封裝實作細節讓外部程式碼無法看到、呼叫或依賴的界限。所以想要建立私有的函式或結構體，可以將它們放入模組內。

### 使用 pub 關鍵字公開路徑

將 `hosting` 模組加上 `pub` 關鍵字。

```RS
mod front_of_house {
    pub mod hosting {
        fn add_to_waitlist() {}
    }
}

pub fn eat_at_restaurant() {
    // 絕對路徑
    crate::front_of_house::hosting::add_to_waitlist();

    // 相對路徑
    front_of_house::hosting::add_to_waitlist();
}
```

有了這項修改後，的確可以在取得 `front_of_house` 之後繼續進入 `hosting`。但是 hosting 的所有內容仍然是私有的。模組中的 `pub` 關鍵字只會讓該模組公開讓上層模組使用而已。

在 `add_to_waitlist` 的函式定義加上 `pub` 公開它。

```RS
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

pub fn eat_at_restaurant() {
    // 絕對路徑
    crate::front_of_house::hosting::add_to_waitlist();

    // 相對路徑
    front_of_house::hosting::add_to_waitlist();
}
```

現在程式碼就能成功編譯了。

### 使用 super 作為相對路徑的開頭

我們還可以在路徑開頭使用 `super` 來建構從上層模組出發的相對路徑。這就像在檔案系統中使用「`..`」作為路徑開頭一樣。

考慮以下程式碼，這模擬了一個主廚修正一個錯誤的訂單，並親自提供給顧客的場景。函式 `fix_incorrect_order` 呼叫了函式 `serve_order`，不過這次是使用 `super` 來指定 `serve_order` 的路徑。

```RS
fn serve_order() {}

mod back_of_house {
    fn fix_incorrect_order() {
        cook_order();
        super::serve_order();
    }

    fn cook_order() {}
}
```

`fix_incorrect_order` 函式在 `back_of_house` 模組中，所以我們可以使用 `super` 前往 `back_of_house` 的上層模組，在此例的話就是源頭 crate。我們認定 `back_of_house` 模組與 `serve_order` 函式應該會維持這樣的關係，在要組織 crate 的模組樹時，它們理當一起被移動。因此使用 `super` 讓我們在未來程式碼被移動到不同模組時，不用更新太多程式路徑。

### 公開結構體與枚舉

我們也可以使用 `pub` 來公開結構體與枚舉。

如果我們在結構體定義之前加上 `pub` 的話，我們的確能公開結構體，但是結構體內的欄位仍然會是私有的。我們可以視情況決定每個欄位要不要公開。

```RS
mod back_of_house {
    pub struct Breakfast {
        pub toast: String,
        seasonal_fruit: String,
    }

    impl Breakfast {
        pub fn summer(toast: &str) -> Breakfast {
            Breakfast {
                toast: String::from(toast),
                seasonal_fruit: String::from("桃子"),
            }
        }
    }
}

pub fn eat_at_restaurant() {
    // 點夏季早餐並選擇黑麥麵包
    let mut meal = back_of_house::Breakfast::summer("黑麥");
    // 我們想改成全麥麵包
    meal.toast = String::from("全麥");
    println!("我想要{}麵包，謝謝", meal.toast);

    // 接下來這行取消註解的話，我們就無法編譯通過
    // 我們無法擅自更改餐點搭配的季節水果
    // meal.seasonal_fruit = String::from("藍莓");
}
```

因為 `back_of_house::Breakfast` 結構體中的 `toast` 欄位是公開的，在 `eat_at_restaurant` 中我們可以加上句點來對 `toast` 欄位進行讀寫。注意我們不能在 `eat_at_restaurant` 使用 `seasonal_fruit` 欄位，因為它是私有的。

另外因為 `back_of_house::Breakfast` 擁有私有欄位，該結構體必須提供一個公開的關聯函式（associated function）才有辦法產生 `Breakfast` 的實例（在此例命名為 `summer`）。如果 `Breakfast` 沒有這樣的函式的話，我們就無法在 `eat_at_restaurant` 建立 `Breakfast` 的實例，因為我們無法在 `eat_at_restaurant` 設置私有欄位 `seasonal_fruit` 的數值。

如果公開枚舉的話，那它所有的變體也都會公開。我們只需要在 `enum` 關鍵字之前加上 `pub` 就好。

```RS
mod back_of_house {
    pub enum Appetizer {
        Soup,
        Salad,
    }
}

pub fn eat_at_restaurant() {
    let order1 = back_of_house::Appetizer::Soup;
    let order2 = back_of_house::Appetizer::Salad;
}
```

我們公開了 `Appetizer` 枚舉，我們可以在 `eat_at_restaurant` 使用 `Soup` 和 `Salad`。

枚舉的變體沒有全部都公開的話，通常會讓枚舉很不好用。要用 `pub` 標註所有的枚舉變體都公開的話又很麻煩。所以公開枚舉的話，預設就會公開其變體。相反地，結構體不讓它的欄位全部都公開的話，通常反而比較實用。因此結構體欄位的通用原則是預設為私有，除非有 `pub` 標註。

## 透過 use 引入

可以使用 `use` 關鍵字將路徑引入作用域，然後就像它們是本地項目一樣來呼叫它們。

在以下範例中，引入了 `crate::front_of_house::hosting` 模組進 `eat_at_restaurant` 函式的作用域中，所以我們要呼叫函式 `add_to_waitlist` 的話，只需要指明 hosting::`add_to_waitlist`。

```RS
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
}
```

使用 `use` 將路徑引入作用域就像是在檔案系統中產生符號連結一樣（symbolic link）。在 crate 源頭加上 `use crate::front_of_house::hosting` 後，`hosting` 在作用域內就是個有效的名稱了。使用 `use` 的路徑也會檢查隱私權，就像其他路徑一樣。

也可以使用 `use` 加上相對路徑來引入項目。

```RS
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

use self::front_of_house::hosting;

pub fn eat_at_restaurant() {
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
}
```

使用 `use` 將函式的上層模組引入作用域，讓我們必須在呼叫函式時得指明對應模組。在呼叫函式時指定上層模組能清楚地知道該函式並非本地定義的，同時一樣能簡化路徑。

另一方面，如果是要使用 `use` 引入結構體、枚舉或其他項目的話，直接指明完整路徑反而是符合習慣的方式。

```RS
use std::collections::HashMap;

fn main() {
    let mut map = HashMap::new();
    map.insert(1, 2);
}
```

這樣的習慣有個例外，那就是如果我們將兩個相同名稱的項目使用 `use` 陳述式引入作用域時，因為 Rust 不會允許。

```RS
use std::fmt;
use std::io;

fn function1() -> fmt::Result {
    //
}

fn function2() -> io::Result<()> {
    //
}
```

要將兩個同名的型別引入相同作用域的話，必須使用它們所屬的模組。如此可以分辨出是在使用哪個 `Result` 型別。

### 使用 as 關鍵字提供新名稱

要在相同作用域中使用 `use` 引入兩個同名型別的話，還有另一個辦法。在路徑之後，我們可以用 `as` 指定一個該型別在本地的新名稱，或者說別名。

```RS
use std::fmt::Result;
use std::io::Result as IoResult;

fn function1() -> Result {
    //
}

fn function2() -> IoResult<()> {
    //
}
```

### 使用 pub use 重新匯出名稱

當使用 `use` 關鍵字將名稱引入作用域時，該有效名稱在新的作用域中是私有的。要是我們希望呼叫我們這段程式碼時，也可以使用這個名稱的話（就像該名稱是在此作用域內定義的），我們可以組合 `pub` 和 `use`。這樣的技巧稱之為重新匯出（re-exporting），因為我們將項目引入作用域，並同時公開給其他作用域引用。

```RS
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

pub use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
}
```

使用 `pub use` 的話，我們可以用某種架構寫出程式碼，再以不同的架構對外公開。這樣讓我們的的函式庫可以完整的組織起來，且對開發函式庫的開發者與使用函式庫的開發者都提供友善的架構。

### 使用外部套件

要在專案內使用 `rand` 外部套件的話，我們會在 `Cargo.toml`` 加上此行：

```TOML
rand = "0.8.3"
```

在 `Cargo.toml` 新增 `rand` 作為依賴函式庫會告訴 Cargo 要從 crates.io 下載 `rand` 以及其他相關的依賴，讓我們可專案可以使用 `rand`。

接下來加上一行 `use` 後面接著 crate 的名稱 `rand`，然後列出我們想要引入作用域的項目。

```RS
use rand::Rng;

fn main() {
    let secret_number = rand::thread_rng().gen_range(1..101);
}
```

注意到標準函式庫（std）對於我們的套件來說也是一個外部 crate。由於標準函式庫會跟著 Rust 語言發佈，所以我們不需要更改 `Cargo.toml` 來包含 std。但是我們仍然需使用 `use` 來將它的項目引入我們套件的作用域中。舉例來說，要使用 `HashMap` 我們可以這樣寫：

```RS
use std::collections::HashMap;
```

這是個用標準函式庫的 crate 名稱 std 起頭的絕對路徑。

### 使用巢狀路徑來清理大量的 use 行數

如果我們要使用在相同 crate 或是相同模組內定義的數個項目，針對每個項目都單獨寫一行的話，會佔據我們檔案內很多空間。

```RS
use std::cmp::Ordering;
use std::io;
```

可以改使用巢狀路徑（nested paths）來只用一行就能將數個項目引入作用域中。

```RS
use std::{cmp::Ordering, io};
```

兩個 `use` 陳述式且其中一個是另一個的子路徑，例如以下情形。

```RS
use std::io;
use std::io::Write;
```

要將這兩個路徑合為一個 use 陳述式的話，我們可以在巢狀路徑使用 `self` 關鍵字。

```RS
use std::io::{self, Write};
```

### 全域運算子

如果我們想要將在一個路徑中所定義的所有公開項目引入作用域的話，我們可以在指明路徑之後加上全域（glob）運算子「`*`」。

```RS
use std::collections::*;
```

此 `use` 陳述式會將 `std::collections` 定義的所有公開項目都引入作用域中。不過請小心使用全域運算子！它容易讓我們無法分辨作用域內的名稱，以及程式中使用的名稱是從哪定義來的。

## 將模組拆成不同檔案

將 `front_of_house` 模組移到它自己的檔案 `src/front_of_house.rs`。

```RS
pub mod hosting {
    pub fn add_to_waitlist() {}
}
```

然後在 crate 源頭檔案加上這個模組。修改 `src/lib.rs` 檔。

```RS
mod front_of_house;

pub use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
    hosting::add_to_waitlist();
}
```

在 `mod front_of_house` 之後用分號而不是大括號會告訴 Rust 讀取其他與模組同名的檔案以取得模組內容。

繼續將範例中的 `hosting` 模組也取出並移到它自己的檔案中，修改 `src/front_of_house.rs` 檔。

```RS
pub mod hosting;
```

新增 `src/front_of_house/hosting.rs` 檔。

```RS
pub fn add_to_waitlist() {}
```

雖然定義都被移到不同的檔案了，但模組樹維持不變，而且在 `eat_at_restaurant` 的函式呼叫方式也不用做任何更改。此技巧可以將增長中的模組移到新的檔案。

## 參考資料

- [The Rust Programming Language](https://doc.rust-lang.org/stable/book/)
