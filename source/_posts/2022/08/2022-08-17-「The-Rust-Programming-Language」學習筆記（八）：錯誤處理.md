---
title: 「The Rust Programming Language」學習筆記（八）：錯誤處理
permalink: 「The-Rust-Programming-Language」學習筆記（八）：錯誤處理
date: 2022-08-17 22:36:03
tags: ["程式設計", "Rust"]
categories: ["程式設計", "Rust", "「The Rust Programming Language」學習筆記"]
---

## 前言

本文為「[The Rust Programming Language](https://doc.rust-lang.org/stable/book/)」語言指南的學習筆記。

## 介紹

Rust 將錯誤分成兩大類：可復原的（recoverable）和不可復原的（unrecoverable）錯誤。像是找不到檔案這種可復原的錯誤，回報問題給使用者並重試是很合理的。而不可復原的錯誤就會是程式錯誤的跡象，像是嘗試取得陣列結尾之後的位置。

許多語言不會區分這兩種錯誤，並以相同的方式處理，使用像是例外（exceptions）這樣統一的機制處理。Rust 沒有例外處理機制，取而代之的是它對可復原的錯誤提供 `Result<T, E>` 型別，對不可復原的錯誤使用 `panic!` 將程式停止執行。

## 無法復原的錯誤

Rust 有提供 `panic!` 巨集，當 `panic!` 巨集執行時，程式就會印出程式出錯的訊息，展開並清理堆疊，然後離開程式。這常用來處理當程式遇到某種錯誤時，開發者不清楚如何處理該錯誤的狀況。

先在小程式內嘗試呼叫 `panic!` 巨集。

```RS
fn main() {
    panic!("◢▆▅▄▃ 崩╰(〒皿〒)╯潰 ▃▄▅▆◣");
}
```

顯示結果如下。

```BASH
$ cargo run
   Compiling panic v0.1.0 (file:///projects/panic)
    Finished dev [unoptimized + debuginfo] target(s) in 0.25s
     Running `target/debug/panic`
thread 'main' panicked at '◢▆▅▄▃ 崩╰(〒皿〒)╯潰 ▃▄▅▆◣', src/main.rs:2:5
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

另一個例子，這是函式庫發生錯誤而呼叫 `panic!`，而不是來自於我們在程式碼自己呼叫的巨集。

```RS
fn main() {
    let v = vec![1, 2, 3];

    v[99];
}
```

這邊嘗試取得向量中第 100 個元素，但它只有 3 個元素。在此情況下，Rust 就會恐慌。

在 C 中，嘗試讀取資料結構結束之後的元素屬於未定義行為。可能會得到該記憶體位置對應其資料結構的元素，即使該記憶體完全不屬於該資料結構。這就稱做緩衝區過讀（buffer overread）而且會導致安全漏洞。攻擊者可能故意操縱該索引來取得在資料結構後面他們原本不應該讀寫的值。

為了保護程式免於這樣的漏洞，如果嘗試用一個不存在的索引讀取元素的話，Rust 會停止執行並拒絕繼續運作下去。

顯示結果如下。

```BASH
$ cargo run
   Compiling panic v0.1.0 (file:///projects/panic)
    Finished dev [unoptimized + debuginfo] target(s) in 0.27s
     Running `target/debug/panic`
thread 'main' panicked at 'index out of bounds: the len is 3 but the index is 99', src/main.rs:4:5
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

此錯誤指向 `main.rs` 的第四行，也就是嘗試存取索引 99 的地方。下一行提示告訴我們可以設置 `RUST_BACKTRACE` 環境變數來取得 `backtrace` 以知道錯誤發生時到底發生什麼事。`backtrace` 是一個函式列表，指出得到此錯誤時到底依序呼叫了哪些函式。Rust 的 `backtraces` 運作方式和其他語言一樣：讀取 `backtrace` 關鍵是從最一開始讀取直到你看到你寫的檔案。那就會是問題發生的源頭。程式碼以上的行數就是呼叫的程式，而以下則是其他呼叫程式碼的程式。這些行數可能還會包含 Rust 核心程式碼、標準函式庫程式碼，或是所使用的 crate。我們設置 `RUST_BACKTRACE` 環境變數的值不為 `0`，來嘗試取得 `backtrace`。

```BASH
$ RUST_BACKTRACE=1 cargo run
thread 'main' panicked at 'index out of bounds: the len is 3 but the index is 99', src/main.rs:4:5
stack backtrace:
   0: rust_begin_unwind
             at /rustc/7eac88abb2e57e752f3302f02be5f3ce3d7adfb4/library/std/src/panicking.rs:483
   1: core::panicking::panic_fmt
             at /rustc/7eac88abb2e57e752f3302f02be5f3ce3d7adfb4/library/core/src/panicking.rs:85
   2: core::panicking::panic_bounds_check
             at /rustc/7eac88abb2e57e752f3302f02be5f3ce3d7adfb4/library/core/src/panicking.rs:62
   3: <usize as core::slice::index::SliceIndex<[T]>>::index
             at /rustc/7eac88abb2e57e752f3302f02be5f3ce3d7adfb4/library/core/src/slice/index.rs:255
   4: core::slice::index::<impl core::ops::index::Index<I> for [T]>::index
             at /rustc/7eac88abb2e57e752f3302f02be5f3ce3d7adfb4/library/core/src/slice/index.rs:15
   5: <alloc::vec::Vec<T> as core::ops::index::Index<I>>::index
             at /rustc/7eac88abb2e57e752f3302f02be5f3ce3d7adfb4/library/alloc/src/vec.rs:1982
   6: panic::main
             at ./src/main.rs:4
   7: core::ops::function::FnOnce::call_once
             at /rustc/7eac88abb2e57e752f3302f02be5f3ce3d7adfb4/library/core/src/ops/function.rs:227
note: Some details are omitted, run with `RUST_BACKTRACE=full` for a verbose backtrace.
```

要取得這些資訊的 `backtrace`，除錯符號（debug symbols）必須啟用。當在使用 `cargo build` 或 `cargo run` 指令且沒有加上 `--release` 時，除錯符號預設是啟用的。

## 可復原的錯誤

大多數的錯誤沒有嚴重到需要讓整個程式停止執行。有時候當函式失敗時，是可以輕易理解並作出反應的。舉例來說，如果嘗試開啟一個檔案，但該動作卻因為沒有該檔案而失敗的話，可能會想要建立檔案，而不是終止程序。

使用 `Result` 型別處理可能的錯誤，`Result` 枚舉的定義有兩個變體 `Ok` 和 `Err`，如以下所示：

```RS
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

`T` 和 `E` 是泛型型別參數。現在只需要知道的是 `T` 代表我們在成功時會在 `Ok` 變體回傳的型別，而 `E` 則代表失敗時在 `Err` 變體會回傳的錯誤型別。因為 `Result` 有這些泛型型別參數，可以將 `Result` 型別和標準函式庫運用到它的函式用在許多不同場合，讓成功與失敗時回傳的型別不相同。

以下呼叫一個可能會失敗的函式，並回傳 `Result` 型別。

```RS
use std::fs::File;

fn main() {
    let f = File::open("hello.txt");
}
```

這樣的回傳型別代表 `File::open` 的呼叫在成功時會回傳我們可以讀寫的檔案控制代碼，但該函式呼叫也可能失敗。舉例來說，該檔案可能會不存在，或者我們沒有檔案的存取權限。`File::open` 需要有某種方式能告訴我們它的結果是成功或失敗，並回傳檔案控制代碼或是錯誤資訊。這樣的資訊正是 `Result` 枚舉想表達的。

如果 `File::open` 成功的話，變數 `f` 的數值就會獲得包含檔案控制代碼的 `Ok` 實例。如果失敗的話，`f` 的值就會是包含為何產生該錯誤的資訊的 `Err` 實例。

```RS
use std::fs::File;

fn main() {
    let f = File::open("hello.txt");

    let f = match f {
        Ok(file) => file,
        Err(error) => panic!("開啟檔案時發生問題：{:?}", error),
    };
}
```

和 `Option` 枚舉一樣，`Result` 枚舉與其變體都會透過 prelude 引入作用域，所以我們不需要指明 `Result::`，可以直接在 `match` 的分支中使用 `Ok` 和 `Err` 變體。

我們在此告訴 Rust 結果是 `Ok` 的話，就回傳 `Ok` 變體中內部的 `file`，然後就可以將檔案控制代碼賦值給變數 `f`。在 `match` 之後，就可以適用檔案控制代碼來讀寫。

`match` 的另一個分支則負責處理從 `File::open` 中取得的 `Err` 數值。在此範例中，選擇呼叫 `panic!` 巨集。如果檔案 `hello.txt` 不存在當前的目錄的話，就會執行此程式碼，接著就會看到來自 `panic!` 巨集的輸出結果：

```BASH
$ cargo run
   Compiling error-handling v0.1.0 (file:///projects/error-handling)
    Finished dev [unoptimized + debuginfo] target(s) in 0.73s
     Running `target/debug/error-handling`
thread 'main' panicked at '開啟檔案時發生問題：Os { code: 2, kind: NotFound, message: "No such file or directory" }', src/main.rs:8:23
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

### 配對不同種的錯誤

以上範例不管 `File::open` 為何失敗都會呼叫 `panic!`。我們希望做的是依據不同的錯誤原因採取不同的動作，如果 `File::open` 是因為檔案不存在的話，我們想要建立檔案並回傳新檔案的控制代碼。如果 `File::open` 是因為其他原因失敗的話，像是我們沒有開啟檔案的權限，我們仍然要呼叫 `panic!`。

```RS
use std::fs::File;
use std::io::ErrorKind;

fn main() {
    let f = File::open("hello.txt");

    let f = match f {
        Ok(file) => file,
        Err(error) => match error.kind() {
            ErrorKind::NotFound => match File::create("hello.txt") {
                Ok(fc) => fc,
                Err(e) => panic!("建立檔案時發生問題：{:?}", e),
            },
            other_error => {
                panic!("開啟檔案時發生問題：{:?}", other_error)
            }
        },
    };
}
```

`File::open` 在 `Err` 變體的回傳型別為 `io::Error`，這是標準函式庫提供的結構體。此結構體有個 `kind` 方法讓我們可以取得 `io::ErrorKind` 數值。標準函式庫提供的枚舉 `io::ErrorKind` 有從 io 運算可能發生的各種錯誤。我們想處理的變體是 `ErrorKind::NotFound`，這指的是我們嘗試開啟的檔案還不存在。所以我們對 `f` 配對並在用 `error.kind()` 繼續配對下去。

我們從內部配對檢查 `error.kind()` 的回傳值是否是 `ErrorKind` 枚舉中的 `NotFound` 變體。如果是的話，我們就嘗試使用 `File::create` 建立檔案。不過 `File::create` 也可能會失敗，所以我們需要第二個內部 `match` 表達式來處理。如果檔案無法建立的話，我們就會印出不同的錯誤訊息。第二個分支的外部 `match` 分支保持不變，如果程式遇到其他錯誤的話就會恐慌。

更熟練的 Rustacean 可能會像這樣寫：

```RS
use std::fs::File;
use std::io::ErrorKind;

fn main() {
    let f = File::open("hello.txt").unwrap_or_else(|error| {
        if error.kind() == ErrorKind::NotFound {
            File::create("hello.txt").unwrap_or_else(|error| {
                panic!("建立檔案時發生問題：{:?}", error);
            })
        } else {
            panic!("開啟檔案時發生問題：{:?}", error);
        }
    });
}
```

### 錯誤發生時產生恐慌的捷徑：unwrap 與 expect

雖然 `match` 已經足以勝任指派的任務了，但它還是有點冗長，而且可能無法正確傳遞錯誤的嚴重性。`Result<T, E>` 型別有非常多的輔助方法來執行不同的任務。其中一個方法就是 `unwrap`，這是和我們在範例所寫的 `match` 表達式一樣，擁有類似效果的捷徑方法。如果 `Result` 的值是 `Ok` 變體，`unwrap` 會回傳 `Ok` 裡面的值；如果 `Result` 是 `Err` 變體的話，`unwrap` 會呼叫 `panic!` 巨集。

```RS
use std::fs::File;

fn main() {
    let f = File::open("hello.txt").unwrap();
}
```

如果沒有 `hello.txt` 這個檔案並執行此程式碼的話，我們會看到從 `unwrap` 方法所呼叫的 `panic!` 回傳訊息：

```BASH
thread 'main' panicked at 'called `Result::unwrap()` on an `Err` value: Error {
repr: Os { code: 2, message: "No such file or directory" } }',
src/libcore/result.rs:906:4
```

還有另一個方法 `expect` 和 `unwrap` 類似，不過能讓我們選擇 `panic!` 回傳的錯誤訊息。使用 `expect` 而非 `unwrap` 並提供完善的錯誤訊息可以表明開發者的意圖，讓追蹤恐慌的源頭更容易。

```RS
use std::fs::File;

fn main() {
    let f = File::open("hello.txt").expect("開啟 hello.txt 失敗");
}
```

我們使用 `expect` 的方式和 `unwrap` 一樣，不是回傳檔案控制代碼就是呼叫 `panic!` 巨集。使用 `expect` 呼叫 `panic!` 時的錯誤訊息會是我們傳遞給 `expect` 的參數，而不是像 `unwrap` 使用 `panic!` 預設的訊息。訊息看起來就會像這樣：

```BASH
thread 'main' panicked at '開啟 hello.txt 失敗: Error { repr: Os { code:
2, message: "No such file or directory" } }', src/libcore/result.rs:906:4
```

由於此錯誤訊息指明了我們想表達的訊息「開啟 hello.txt 失敗」，我們比較能知道此錯誤訊息是從哪裡發生的。如果我們在多處使用 `unwrap`，我們會需要一些時間才能理解 `unwrap` 是從哪裡引發恐慌的，因為 `unwrap` 很可能會顯示相同的訊息。

### 傳播錯誤

當在實作某函式時，要是它的呼叫的程式碼可能會失敗，與其直接在此函式處理錯誤，可以回傳錯誤給呼叫此程式的程式碼，由它們決定如何處理。這稱之為傳播（propagating）錯誤，並讓呼叫者可以有更多的控制權，因為比起程式碼當下的內容，回傳的錯誤可能提供更多資訊與邏輯以利處理。

舉例來說，一個從檔案讀取使用者名稱的函式。如果檔案不存在或無法讀取的話，此函式會回傳該錯誤給呼叫此函式的程式碼。

```RS
use std::fs::File;
use std::io::{self, Read};

fn read_username_from_file() -> Result<String, io::Error> {
    let f = File::open("hello.txt");

    let mut f = match f {
        Ok(file) => file,
        Err(e) => return Err(e),
    };

    let mut s = String::new();

    match f.read_to_string(&mut s) {
        Ok(_) => Ok(s),
        Err(e) => Err(e),
    }
}
```

我們不會知道呼叫此程式碼的人會如何處理這些數值。舉例來說，如果呼叫此程式碼而獲得錯誤的話，它可能選擇呼叫 `panic!` 讓程式崩潰，或者使用預設的使用者名稱從檔案以外的地方尋找該使用者。所以我們傳播所有成功或錯誤的資訊給呼叫者，讓它們能妥善處理。

以下範例是另一個 `read_username_from_file` 的實作，不過這次使用 `?` 運算子。

```RS
use std::fs::File;
use std::io;
use std::io::Read;

fn read_username_from_file() -> Result<String, io::Error> {
    let mut f = File::open("hello.txt")?;
    let mut s = String::new();
    f.read_to_string(&mut s)?;
    Ok(s)
}
```

定義在 `Result` 數值後的 `?` 運作方式幾乎與 `match` 表達式處理 `Result` 的方式一樣。如果 `Result` 的數值是 `Ok` 的話，`Ok` 內的數值就會從此表達式回傳，然後程式就會繼續執行。如果數值是 `Err` 的話，`Err` 就會使用 `return` 關鍵字作為整個函式的回傳值回傳，讓錯誤數值可以傳遞給呼叫者的程式碼。

使用 `?` 運算子可以消除大量樣板程式碼並讓函式實作更簡單。我們還可以再進一步將方法直接串接到 `?` 後來簡化程式碼。

```RS
use std::fs::File;
use std::io;
use std::io::Read;

fn read_username_from_file() -> Result<String, io::Error> {
    let mut s = String::new();

    File::open("hello.txt")?.read_to_string(&mut s)?;

    Ok(s)
}
```

以下是另一個更簡短的寫法。

```RS
use std::fs;
use std::io;

fn read_username_from_file() -> Result<String, io::Error> {
    fs::read_to_string("hello.txt")
}
```

讀取檔案至字串中算是個常見動作，所以 Rust 提供了一個方便的函式 `fs::read_to_string` 來開啟檔案、建立新的 `String`、讀取檔案內容、將內容放入該 `String` 並回傳它。

### ? 運算子

`?` 運算子只能用在有函式的回傳值相容於 `?` 使用的值才行。這是因為 `?` 運算子會在函式中提早回傳數值，就像範例那樣用 `match` 表達式提早回傳一樣。在範例中，`match` 使用的是 `Result` 數值，函式的回傳值必須是 `Result` 才能相容於此 `return`。

若在 `main` 函式中回傳值為 `()`，如果使用 `?` 運算子會發生什麼事：

```RS
use std::fs::File;

fn main() {
    let f = File::open("hello.txt")?;
}
```

`?` 運算子會拿到 `File::open` 回傳的 `Result` 數值，但是此 `main` 函式的回傳值為 `()`，而非 `Result`。當我們編譯此程式碼時，我們會得到以下錯誤訊息：

```BASH
$ cargo run
   Compiling error-handling v0.1.0 (file:///projects/error-handling)
error[E0277]: the `?` operator can only be used in a function that returns `Result` or `Option` (or another type that implements `FromResidual`)
 --> src/main.rs:4:36
  |
3 | / fn main() {
4 | |     let f = File::open("hello.txt")?;
  | |                                    ^ cannot use the `?` operator in a function that returns `()`
5 | | }
  | |_- this function should return `Result` or `Option` to accept `?`
  |
  = help: the trait `FromResidual<Result<Infallible, std::io::Error>>` is not implemented for `()`

For more information about this error, try `rustc --explain E0277`.
error: could not compile `error-handling` due to previous error
```

目前為止，所有我們使用過的 `main` 函式都是回傳 `()`。`main` 是個特別的函式，因為它是可執行程式的入口點與出口點，而要讓程式可預期執行的話，它的回傳型別就得要有些限制。

`main` 可以擁有的另一種回傳型別為 `Result<(), E>`。不過我們更改 `main` 的回傳型別為 `Result<(), Box<dyn Error>>`，並在結尾的回傳數值加上 `Ok(())`。這樣的程式碼是能編譯的：

```RS
use std::error::Error;
use std::fs::File;

fn main() -> Result<(), Box<dyn Error>> {
    let f = File::open("hello.txt")?;

    Ok(())
}
```

`Box<dyn Error>` 型別使用了特徵物件（trait object）。可以先將 `Box<dyn Error>` 視為它是「任何種類的錯誤」。這樣 `main` 函式中的 `Result` 使用 `?` 就允許了，因為現在 `Err` 數值可以被提早回傳。當 `main` 函式回傳 `Result<(), E>` 時，如果 `main` 回傳 `Ok(())` 的話，執行檔就會用 `0` 退出；如果 `main` 回傳 `Err` 數值的話，就會用非零數值退出。

`main` 之所以能夠退出是因為實作了 `std::process::Termination` 特徵。

### 選擇

該如何決定何時要呼叫 `panic!` 還是要回傳 `Result` 呢？當程式碼恐慌時，就沒有任何回復的方式。可以在任何錯誤場合呼叫 `panic!`，無論是可能或不可能復原的情況。不過這樣就等於替呼叫者做出決定，讓情況變成無法復原的錯誤了。當你選擇回傳 `Result` 數值，你將決定權交給呼叫者的程式碼。呼叫者可能會選擇符合當下場合的方式嘗試復原錯誤，或者它可以選擇 `Err` 內的數值是不可回復的，所以它就呼叫 `panic!` 讓原本可回復的錯誤轉成不可回復。因此，當定義可能失敗的函式時預設回傳 `Result` 是不錯的選擇。

在少數情況下，程式碼恐慌會比回傳 `Result` 來得恰當。然後討論到一種編譯器無法辨別出不可能失敗，但人類卻可以的情況。

### 範例、程式碼原型與測試

當在寫解釋一些概念的範例時，寫出完善錯誤處理的範例，反而會讓範例變得較不清楚。在範例中，使用像是 `unwrap` 這樣會恐慌的方法可以被視為是一種要求使用者自行決定如何處理錯誤的表現，因為他們可以依據程式碼執行的方式來修改此方法。

同樣地 `unwrap` 與 `expect` 方法也很適用在試做原型，可以在決定準備開始處理錯誤前使用它們。它們會留下清楚的痕跡，當你準備好要讓程式碼更穩固時，你就能回來修改。

如果有方法在測試內失敗時，會希望整個測試都失敗，就算該方法不是要測試的功能。因為 `panic!` 會將測試標記為失敗，所以在此呼叫 `unwrap` 或 `expect` 是很正確的。

### 當知道的比編譯器還多的時候

如果開發者知道一些編譯器不知道的邏輯的話，直接在 `Result` 呼叫 `unwrap` 來直接取得 `Ok` 的數值是很有用的。還是會有個 `Result` 數值需要做處理，呼叫的程式碼還是有機會失敗的，就算在特定場合中邏輯上是不可能的。如果能保證在親自審閱程式碼後，絕對不可能會有 `Err` 變體的話，那麼呼叫 `unwrap` 是完全可以接受的。以下範例就是如此：

```RS
use std::net::IpAddr;

let home: IpAddr = "127.0.0.1".parse().unwrap();
```

傳遞寫死的字串來建立 `IpAddr` 的實例。可以看出 `127.0.0.1` 是完全合理的 IP 位址，所以這邊可以直接 `unwrap`。不過使用寫死的合理字串並不會改變 `parse` 方法的回傳型別，還是會取得 `Result` 數值，編譯器仍然會要我們處理 `Result` 並認為 `Err` 變體是有可能發生的。因為編譯器並沒有聰明到可以看出此字串是個有效的 IP 位址。如果 IP 位址的字串是來自使用者輸入而非我們寫死進程式的話，它的確有可能會失敗，這時我們就得要認真處理 `Result` 了。

### 錯誤處理的指導原則

當程式碼可能會導致嚴重狀態的話，就建議讓你的程式恐慌。這裡的嚴重狀態是指一些假設、保證、協議或不可變性被打破時的狀態，像是當程式碼有無效的數值、互相矛盾的數值或缺少數值。另外還加上以下情形：

- 該嚴重狀態並非預期會發生的，而不是像使用者輸入了錯誤格式這種偶而可能會發生的。
- 程式在此時需要避免這種嚴重狀態，而不是在每一步都處理此問題。
- 所使用的型別沒有適合的方式能夠處理此嚴重狀態。

如果有人呼叫了程式碼卻傳遞了不合理的數值，最好的辦法是呼叫 `panic!` 並警告使用函式庫的人他們程式碼錯誤發生的位置，好讓他們在開發時就能修正。同樣地，`panic!` 也適合用於如果你呼叫了你無法掌控的外部程式碼，然後它回傳了你無法修正的無效狀態。

不過如果失敗是可預期的，回傳 `Result` 就會比呼叫 `panic!` 來得好。類似的例子有，語法分析器 （parser）收到格式錯誤的資訊，或是 HTTP 請求回傳了一個狀態，告訴開發者已經達到請求上限了。在這樣的案例，回傳 `Result` 代表失敗是預期有時會發生的，而且呼叫者必須決定如何處理。

當程式碼針對數值進行運算時，程式需要先驗證該數值，如果數值無效的話就要恐慌。這是基於安全原則，嘗試對無效資料做運算的話可能會導致你的程式碼產生漏洞。這也是標準函式庫在開發者嘗試取得超出界限的記憶體存取會呼叫 `panic!` 的主要原因。嘗試取得不屬於當前資料結構的記憶體是常見的安全問題。函式通常都會訂下一些合約（contracts），它們的行為只有在輸入資料符合特定要求時才帶有保障。當違反合約時恐慌是十分合理的，因為違反合約就代表這是呼叫者的錯誤，這不是程式碼該主動處理的錯誤。事實上，呼叫者也沒有任何合理的理由來復原這樣的錯誤。函式的合約應該要寫在函式的技術文件中解釋，尤其是違反時會恐慌的情況。

然而要在函式寫一大堆錯誤檢查有時是很冗長且麻煩的。幸運的是，開發者可以利用 Rust 的型別系統（以及編譯器的型別檢查）來幫忙完成檢驗。如果函式用特定型別作為參數的話，就可以認定程式邏輯是編輯器已經幫忙確保拿到的數值是有效的。舉例來說，如果有一個型別而非 `Option` 的話，程式就會預期取得某個值而不是沒拿到值。程式就不必處理 `Some` 和 `None` 這兩個變體情形，它只會有一種情況並絕對會拿到數值。要是有人沒有傳遞任何值給函式會根本無法編譯，所以函式就不需要在執行時做檢查。另一個例子是使用非帶號整數像是 `u32` 來確保參數不會是負數。

### 建立自訂型別來驗證

試著使用 Rust 的型別系統來進一步確保擁有有效數值，並建立自訂型別來驗證。

可以建立一個新的型別，並且建立一個驗證產生實例的函式，這樣就不必在每個地方都做驗證。函式可以安全地以這個新型別作為簽名，並放心地使用收到的數值。

```RS
pub struct Guess {
    value: i32,
}

impl Guess {
    pub fn new(value: i32) -> Guess {
        if value < 1 || value > 100 {
            panic!("猜測數字必須介於 1 到 100 之間，你輸入的是 {}。", value);
        }

        Guess { value }
    }

    pub fn value(&self) -> i32 {
        self.value
    }
}
```

## 參考資料

- [The Rust Programming Language](https://doc.rust-lang.org/stable/book/)
