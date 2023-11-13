---
title: 「The Rust Programming Language」學習筆記（十二）：建立命令列程式
date: 2022-09-24 14:06:20
tags: ["Programming", "Rust"]
categories: ["Programming", "Rust", "「The Rust Programming Language」Study Notes"]
---

## 前言

本文為「[The Rust Programming Language](https://doc.rust-lang.org/stable/book/)」語言指南的學習筆記。

## 簡介

Rust 的速度、安全、單一二進制輸出與跨平台支援使其成為建立命令列工具的絕佳語言。所以在我們的專案中，我們要寫出我們自己的經典命令列工具 `grep`（globally search a regular expression and print）。在最簡單的使用場合中，`grep` 會搜尋指定檔案中的指定字串。為此 `grep` 會接收一個檔案名稱與一個字串作為其引數。然後它會讀取檔案、在該檔案中找到包含字串引數的行，並印出這些行。

在過程中，我們會展示如何讓我們的命令列工具和其他許多命令列工具一樣使用終端機的功能。我們會讀取一個環境變數的數值來讓使用者可以配置此工具的行為。我們還會將錯誤訊息在控制台中的標準錯誤（stderr）顯示而非標準輸出（stdout）。所以舉例來說，使用者可以將成功的標準輸出重新導向至一個檔案，並仍能在螢幕上看到錯誤訊息。

## 接受命令列引數

建立專案。

```bash
cargo new minigrep
cd minigrep
```

第一項任務是要讓 `minigrep` 能接收兩個命令列引數：檔案名稱與欲搜尋的字串。如以下所示：

```bash
cargo run searchstring example-filename.txt
```

### 讀取引數數值

要讓 `minigrep` 能夠讀取傳入的命令列引數數值，需要使用 Rust 標準函式庫中提供的函式，也就是 `std::env::args`。此函式會回傳一個包含我們傳給 `minigrep` 的命令列引數的疊代器（iterator）。現在只需要知道疊代器的兩項重點：疊代器會產生一系列的數值，然後我們可以對疊代器呼叫 `collect` 方法來將其轉換成像是向量的集合，來包含疊代器產生的所有元素。

```rs
use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();
    println!("{:?}", args);
}
```

如果我們要用的函式模組路徑超過一層以上的話，通常就會將上層模組引入作用域中，而不是函式本身。這樣的話，我們可以輕鬆使用 `std::env` 中的其他函式。

我們在 `main` 中的第一行呼叫 `env::args`，然後馬上使用 `collect` 來將疊代器轉換成向量，這會包含疊代器產生的所有數值。我們可以使用 `collect` 函式來建立許多種集合，所以我們顯式詮釋 `args` 的型別來指定我們想要字串向量。雖然我們很少需要在 Rust 中詮釋型別，`collect` 是其中一個你常常需要詮釋的函式，因為 Rust 無法推斷出你想要何種集合。

最後，我們使用除錯格式 `:?` 來顯示向量。

```bash
cargo run needle haystack
    Finished dev [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/minigrep needle haystack`
["target/debug/minigrep", "needle", "haystack"]
```

值得注意的是向量中第一個數值為 `"target/debug/minigrep"`，這是我們的執行檔名稱。這與 C 的引數列表行為相符，讓程式在執行時能使用它們被呼叫的名稱路徑。

### 將引數數值儲存至變數

顯示向量中的引數數值能說明程式能夠取得命令列引數指定的數值。現在我們想要將這兩個引數存入變數中。

```rs
use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();

    let query = &args[1];
    let filename = &args[2];

    println!("搜尋 {}", query);
    println!("目標檔案為 {}", filename);
}
```

我們暫時印出這些變數的數值來證明程式碼運作無誤。

```bash
cargo run test sample.txt
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.0s
     Running `target/debug/minigrep test sample.txt`
搜尋 test
目標檔案為 sample.txt
```

## 讀取檔案

新增 `poem.txt` 檔。

```txt
I'm nobody! Who are you?
Are you nobody, too?
Then there's a pair of us - don't tell!
They'd banish us, you know.

How dreary to be somebody!
How public, like a frog
To tell your name the livelong day
To an admiring bog!
```

修改 `main.rs` 檔。

```rs
use std::env;
use std::fs;

fn main() {
    // ...
    println!("目標檔案為 {}", filename);

    let contents = fs::read_to_string(filename)
        .expect("讀取檔案時發生了錯誤");

    println!("文字內容：\n{}", contents);
}
```

我們加上另一個 `use` 陳述式來將標準函式庫中的另一個相關部分引入：我們需要 `std::fs` 來處理檔案。

在 `main` 中，我們加上新的陳述式：`fs::read_to_string` 會接收 `filename`、開啟該檔案並回傳檔案內容的 `Result<String>`。

在陳述式之後，我們再次加上暫時的 `println!` 陳述式來在讀取檔案之後，顯示 `contents` 的數值，讓我們能檢查程式目前運作無誤。

```bash
cargo run the poem.txt
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.0s
     Running `target/debug/minigrep the poem.txt`
搜尋 the
目標檔案為 poem.txt
文字內容：
I'm nobody! Who are you?
Are you nobody, too?
Then there's a pair of us - don't tell!
They'd banish us, you know.

How dreary to be somebody!
How public, like a frog
To tell your name the livelong day
To an admiring bog!
```

## 重構

### 分開二進制專案的任務

`main` 函式負責多數任務的組織分配問題在許多二進制專案中都很常見。所以 Rust 社群開發出了一種流程，這在當 `main` 開始變大時，能作為分開二進制程式中任務的指導原則。此流程有以下步驟：

- 將你的程式分成 `main.rs` 與 `lib.rs` 並將程式邏輯放到 `lib.rs`。
- 只要你的命令列解析邏輯很小，它可以留在 `main.rs`。
- 當命令行解析邏輯變得複雜時，就將其從 `main.rs` 移至 `lib.rs`。

在此流程之後的 `main` 函式應該要只負責以下任務：

- 透過引數數值呼叫命令列解析邏輯。
- 設置任何其他的配置。
- 呼叫 `lib.rs` 中的 `run` 函式。
- 如果 `run` 回傳錯誤的話，處理該錯誤。

此模式用於分開不同任務：`main.rs` 處理程式的執行，然後 `lib.rs` 處理眼前的所有任務邏輯。因為你無法直接測試 `main`，此架構讓你能測試所有移至 `lib.rs` 的程式函式邏輯。留在 `main.rs` 的程式碼會非常小，所以容易直接用閱讀來驗證。

#### 提取引數解析器

新的 `main` 會呼叫新的函式 `parse_config`，而此函式我們先暫時留在 `src/main.rs`。

```rs
use std::env;
use std::fs;

fn main() {
    let args: Vec<String> = env::args().collect();

    let (query, filename) = parse_config(&args);

    // ...
}

fn parse_config(args: &Vec<String>) -> (&str, &str) {
    let query = &args[1];
    let filename = &args[2];
    (query, filename)
}
```

#### 集結配置數值

我們定義一個結構體 `Config` 其欄位有 `query` 與 `filename`。但是 `main` 中的 `args` 變數是引數數值的擁有者，而且只是借用它們給 `parse_config` 函式，這意味著如果 `Config` 嘗試取得 `args` 中數值的所有權的話，會違反 Rust 的借用規則。

我們可以用許多不同的方式來管理 `String` 的資料，但最簡單（卻較不有效率）的方式是對數值呼叫 `clone` 方法。這會複製整個資料讓 `Config` 能夠擁有，這會比引用字串資料還要花時間與記憶體。然而克隆資料讓我們的程式碼比較直白，因為在此情況下我們就不需要管理引用的生命週期，犧牲一點效能以換取簡潔性是值得的。

```rs
use std::env;
use std::fs;

fn main() {
    let args: Vec<String> = env::args().collect();

    let config = parse_config(&args);

    println!("搜尋 {}", config.query);
    println!("目標檔案為 {}", config.filename);

    let contents = fs::read_to_string(config.filename).expect("讀取檔案時發生了錯誤");

    println!("文字內容：\n{}", contents);
}

struct Config {
    query: String,
    filename: String,
}

fn parse_config(args: &Vec<String>) -> Config {
    let query = args[1].clone();
    let filename = args[2].clone();
    Config { query, filename }
}
```

#### 建立 `Config` 的建構子

現在 `parse_config` 函式的目的是要建立 `Config` 實例，我們可以將 `parse_config` 從普通的函式變成與 `Config` 結構體相關連的 `new` 函式。這樣做能讓程式碼更符合慣例。我們可以對像是 `String` 等標準函式庫中的型別呼叫 `String::new` 來建立實例。同樣地，透過將 `parse_config` 改為 `Config` 的關聯函式 `new`，我們可以透過呼叫 `Config::new` 來建立 `Config` 的實例。

```rs
fn main() {
    let args: Vec<String> = env::args().collect();

    let config = Config::new(&args);

    // ...
}

impl Config {
    fn new(args: &Vec<String>) -> Config {
        let query = args[1].clone();
        let filename = args[2].clone();
        Config { query, filename }
    }
}
```

### 修正錯誤處理

要是 `args` 向量中的項目太少的話，嘗試取得向量中索引 `1` 或索引 `2` 的數值的話可能就會導致程式恐慌。

#### 改善錯誤訊息

在 `new` 函式加上了一項檢查來驗證 `slice` 是否夠長，接著才會取得索引 `1` 和 `2`。如果 `slice` 不夠長的話，程式就會恐慌。

```rs
fn new(args: &[String]) -> Config {
    if args.len() < 3 {
        panic!("引數不足");
    }
    // ...
}
```

#### 回傳 Result 而非恐慌

我們可以回傳 `Result` 數值，在成功時包含 `Config` 的實例並在錯誤時描述問題原因。當 `Config::new` 與 `main` 溝通時，我們可以使用 `Result` 型別來表達這裡有問題發生。然後我們改變 `main` 來將 `Err` 變體轉換成適當的錯誤訊息給使用者，而不是像呼叫 `panic!` 時出現圍繞著 `thread 'main'` 與 `RUST_BACKTRACE` 的文字。

```rs
impl Config {
    fn new(args: &Vec<String>) -> Result<Config, &'static str> {
        if args.len() < 3 {
            return Err("引數不足");
        }
        let query = args[1].clone();
        let filename = args[2].clone();
        Ok(Config { query, filename })
    }
}
```

我們的 `new` 函式現在會回傳 `Result`，在成功時會有 `Config` 實例，而在錯誤時會有個 `&'static str`。我們的錯誤值永遠會是有 `'static` 生命週期的字串字面值。

我們在 `new` 函式本體作出了兩項改變：不同於呼叫 `panic!`，當使用者沒有傳遞足夠引數時，我們現在會回傳 `Err` 數值。此外我們也將 `Config` 封裝進 `Ok` 作為回傳值。這些改變讓函式能符合其新的型別簽名。

從 `Config::new` 回傳 `Err` 數值讓 `main` 函式能處理 `new` 函式回傳的 `Result` 數值，並明確地在錯誤情況下離開程序。

#### 呼叫 `Config::new` 並處理錯誤

為了能處理錯誤情形並印出對使用者友善的訊息，我們需要更新 `main` 來處理 `Config::new` 回傳的 `Result`。我們還要負責用一個非零的錯誤碼來離開命令列工具，這原先是 `panic!` 會處理的，現在我們得自己實作。非零退出狀態是個常見信號，用來告訴呼叫程式的程序，該程式離開時有個錯誤狀態。

```rs
use std::process;

fn main() {
    let args: Vec<String> = env::args().collect();

    let config = Config::new(&args).unwrap_or_else(|err| {
        println!("解析引數時出現問題：{}", err);
        process::exit(1);
    });
    
    // ...
}
```

方法 `unwrap_or_else`，這定義在標準函式庫的 `Result<T, E>` 中。使用 `unwrap_or_else` 讓我們能定義一些自訂的非 `panic!` 錯誤處理。如果 `Result` 數值為 `Ok`，此方法行為就類似於 `unwrap`，它會回傳 `Ok` 所封裝的內部數值。然而，如果數值為 `Err` 的話，此方法會呼叫閉包（closure）內的程式碼，這會是由我們所定義的匿名函式並作為引數傳給 `unwrap_or_else`。

還新增了一行 `use` 來將標準函式庫中的 `process` 引入作用域。在錯誤情形下要執行的閉包程式碼只有兩行：我們印出 `err` 數值並呼叫 `process::exit`。`process::exit` 函式會立即停止程式並回傳給予的數字來作為退出狀態碼。

```bash
cargo run
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.48s
     Running `target/debug/minigrep`
解析引數時出現問題：引數不足
```

### 提取 main 邏輯

修改 `src/main.rs` 檔。

```rs
fn main() {
    // ...

    println!("搜尋 {}", config.query);
    println!("目標檔案為 {}", config.filename);

    run(config);
}

fn run(config: Config) {
    let contents = fs::read_to_string(config.filename)
        .expect("讀取檔案時發生了錯誤");

    println!("文字內容：\n{}", contents);
}
```

### 從 run 函式回傳錯誤

可以像 `Config::new` 一樣來改善錯誤處理。不同於讓程式呼叫 `expect` 來恐慌，當有問題發生時，`run` 函式會回傳 `Result<T, E>`。

```rs
use std::error::Error;

fn run(config: Config) -> Result<(), Box<dyn Error>> {
    let contents = fs::read_to_string(config.filename)?;

    println!("文字內容：\n{}", contents);

    Ok(())
}
```

對於錯誤型別，我們使用特徵物件（trait object）`Box<dyn Error>`（然後我們在最上方透過 `use` 陳述式來將 `std::error::Error` 引入作用域）。現在只需要知道 `Box<dyn Error>` 代表函式會回傳有實作 `Error` 特徵的型別，但我們不必指定回傳值的明確型別。這增加了回傳錯誤數值的彈性，其在不同錯誤情形中可能有不同的型別。`dyn` 關鍵字是「動態（dynamic）」的縮寫。

再來，我們移除了 `expect` 的呼叫並改為 `?` 運算子。所以與其對錯誤 `panic!`，`?` 運算子會回傳當前函式的錯誤數值，並交由呼叫者處理。

第三，`run` 函式現在成功時會回傳 `Ok` 數值。我們在 `run` 函式簽名中的成功型別為 `()`，這意味著我們需要將單元型別封裝進 `Ok` 數值。`Ok(())` 這樣的語法一開始看可能會覺得有點奇怪，但這樣子使用 `()` 的確符合慣例，說明我們呼叫 `run` 只是為了它的副作用，它不會回傳我們需要的數值。

#### 處理 `run` 回傳的錯誤

修改 `src/main.rs` 檔。

```rs
fn main() {
    // ...

    println!("搜尋 {}", config.query);
    println!("目標檔案為 {}", config.filename);

    if let Err(e) = run(config) {
        println!("應用程式錯誤：{}", e);

        process::exit(1);
    }
}
```

在此使用 `if let` 而非 `unwrap_or_else` 來檢查 `run` 是否有回傳 `Err` 數值，並以此呼叫 `process::exit(1)`。`run` 函式沒有回傳數值，所以我們不必像處理 `Config::new` 得用 `unwrap` 取得 `Config` 實例。因為 `run` 在成功時會回傳 `()`，而我們只在乎偵測錯誤，所以我們不需要 `unwrap_or_else` 來回傳解封裝後的數值，因為它只會是 `()`。

`if let` 的本體與 `unwrap_or_else` 函式則都做一樣的事情：印出錯誤並離開。

### 將程式碼拆到函式庫 Crate

新增 `src/lib.rs` 檔。

```rs
use std::error::Error;
use std::fs;

pub struct Config {
    pub query: String,
    pub filename: String,
}

impl Config {
    pub fn new(args: &Vec<String>) -> Result<Config, &'static str> {
        if args.len() < 3 {
            return Err("引數不足");
        }
        let query = args[1].clone();
        let filename = args[2].clone();
        Ok(Config { query, filename })
    }
}

pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
    let contents = fs::read_to_string(config.filename)?;

    println!("文字內容：\n{}", contents);

    Ok(())
}
```

我們對許多項目都使用了 `pub` 關鍵字，這包含 `Config` 與其欄位，以及其 `new` 方法，還有 `run` 函式。

現在將移至 `src/lib.rs` 的程式碼引入二進制 `crate` 的 `src/main.rs` 作用域中。

```rs
use minigrep::Config;
use std::env;
use std::process;

fn main() {
    let args: Vec<String> = env::args().collect();

    let config = Config::new(&args).unwrap_or_else(|err| {
        println!("解析引數時出現問題：{}", err);
        process::exit(1);
    });

    println!("搜尋 {}", config.query);
    println!("目標檔案為 {}", config.filename);

    if let Err(e) = minigrep::run(config) {
        println!("應用程式錯誤：{}", e);

        process::exit(1);
    }
}
```

現在所有的功能都應該正常。透過 `cargo run` 來執行程式並確保一切正常。

## 完善功能

以下會在 `minigrep` 程式中利用試驅動開發（Test-driven development, TDD）來新增搜尋邏輯。此程式開發技巧遵循以下步驟：

1. 寫出一個會失敗的測試並執行它來確保它失敗的原因如你所預期。
2. 寫出或修改足夠的程式碼來讓新測試可以通過。
3. 重構你新增或變更的程式碼並確保測試仍能持續通過。
4. 重複第一步！

### 編寫失敗的測試

修改 `src/lib.rs` 檔。

```rs
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn one_result() {
        let query = "duct";
        let contents = "\
Rust:
safe, fast, productive.
Pick three.";

        assert_eq!(vec!["safe, fast, productive."], search(query, contents));
    }
}
```

此測試搜尋字串 `"duct"`。而要被搜尋的文字有三行，只有一行包含 `"duct"`（在雙引號開頭後方的斜線會告訴 Rust 別在此字串內容開始處換行）。我們判定 `search` 函式回傳的數值只會包含我們預期的那一行。

我們還無法執行此程式並觀察其失敗，因為測試還無法編譯，`search` 函式根本還不存在！所以現在我們要加上足夠的程式碼讓測試可以編譯並執行，而我們要加上的是 `search` 函式的定義並永遠回傳一個空的向量，如下所示。

```rs
pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    vec![]
}
```

值得注意的是在 `search` 的簽名中需要定義一個顯式的生命週期 `'a`，並用於 `contents` 引數與回傳值。生命週期參數會連結引數生命週期與回傳值生命週期。在此例中，我們指明回傳值應包含字串切片且其會引用 `contents` 引數的切片（而非引數 `query`）。

換句話說，我們告訴 Rust，`search` 函式回傳的資料會跟傳遞給 `search` 函式的引數 `contents` 資料存活得一樣久。這點很重要！被切片引用的資料必須有效，這樣其引用才會有效。如果編譯器假設是在建立 `query` 而非 `contents` 的字串切片，它的安全檢查就會不正確。

由於引數 `contents` 包含所有文字且我們想要回傳符合條件的部分文字，所以我們知道 `contents` 引數要用生命週期語法與回傳值做連結。其他程式設計語言不會要求你要在簽名中連結引數與回傳值。

### 寫出讓測試成功的程式碼

目前我們的測試會失敗，因為我們永遠只回傳一個空向量。要修正並實作 `search`，我們的程式需要完成以下步驟：

- 遍歷內容的每一行。
- 檢查該行是否包含我們要搜尋的字串。
- 如果有的話，將它加入我們要回傳的數值列表。
- 如果沒有的話，不做任何事。
- 回傳符合的結果列表。

#### 透過 `lines` 方法來遍歷每一行

Rust 有個實用的方法能逐步處理字串的每一行，這方法就叫 `lines`，`lines` 方法會回傳疊代器（iterator）。

```rs
pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    for line in contents.lines() {
        // ...
    }
}
```

#### 檢查每行是否有要搜尋的字串

我們要檢查目前的行是否有包含我們要搜尋的字串。幸運的是，字串有個好用的方法叫做 `contains` 能幫我處理這件事。

```rs
pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    for line in contents.lines() {
        if line.contains(query) {
            // ...
        }
    }
}
```

#### 儲存符合條件的行

需要有個方式能儲存包含搜尋字串的行。為此我們可以在 `for` 迴圈前建立一個可變向量然後對向量呼叫 `push` 方法來儲存 `line`。在 `for` 迴圈之後，我們回傳向量。

```rs
pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    let mut results = Vec::new();

    for line in contents.lines() {
        if line.contains(query) {
            results.push(line);
        }
    }

    results
}
```

現在 `search` 函式應該只會回傳包含 `query` 的行，而測試也該通過。

```bash
cargo test
```

#### 在 `run` 函式中使用 `search` 函式

修改 `src/lib.rs` 檔。

```rs
pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
    let contents = fs::read_to_string(config.filename)?;

    for line in search(&config.query, &contents) {
        println!("{}", line);
    }

    Ok(())
}
```

執行程式。

```bash
cargo run frog poem.txt
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.38s
     Running `target/debug/minigrep frog poem.txt`
How public, like a frog
```

最後，讓我們確保使用詩中沒出現的單字來搜尋時，我們不會得到任何一行，像是「monomorphization」：

```bash
cargo run monomorphization poem.txt
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.0s
     Running `target/debug/minigrep monomorphization poem.txt`
```

## 處理環境變數

使用者可以透過環境變數來啟用不區分大小寫的搜尋功能。

### 寫個不區分大小寫的 `search` 函式的失敗測試

新增一個 `search_case_insensitive` 函式在環境變數啟用時呼叫它。並將舊測試從 `one_result` 改名為 `case_sensitive` 以便清楚兩個測試的差別。

```rs
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn case_sensitive() {
        let query = "duct";
        let contents = "\
Rust:
safe, fast, productive.
Pick three.
Duct tape.";

        assert_eq!(vec!["safe, fast, productive."], search(query, contents))
    }

    #[test]
    fn case_insensitive() {
        let query = "rUsT";
        let contents = "\
Rust:
safe, fast, productive.
Pick three.
Trust me.";

        assert_eq!(
            vec!["Rust:", "Trust me."],
            search_case_insensitive(query, contents)
        );
    }
}
```

執行測試。

```bash
cargo test
```

### 實作 `search_case_insensitive` 函式

與 `search` 函式幾乎一樣。唯一的不同在於我們將 `query` 與每個 `line` 都變成小寫，所以無論輸入引數是大寫還是小寫，當我們在檢查行是否包含搜尋的字串時，它們都會是小寫。

```rs
pub fn search_case_insensitive<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    let query = query.to_lowercase();
    let mut results = Vec::new();

    for line in contents.lines() {
        if line.to_lowercase().contains(&query) {
            results.push(line);
        }
    }

    results
}
```

現在當我們將 `query` 作為引數傳給 `contains` 方法時，我們需要加上「`&`」，因為 `contains` 所定義的簽名接收的是一個字串切片。

接著，在我們檢查是否包含小寫的 `query` 前，我們對每個 `line` 加上 `to_lowercase` 的呼叫。現在我們將 `line` 和 `query` 都轉換成小寫了。我們可以不區分大小寫來找到符合的行。

執行測試。

```bash
cargo test
```

現在讓我們從 `run` 函式呼叫新的 `search_case_insensitive` 函式。首先，我們要在 `Config` 中新增一個配置選項來切換區分大小寫與不區分大小寫之間的搜尋。

```rs
pub struct Config {
    pub query: String,
    pub filename: String,
    pub case_sensitive: bool,
}
```

接著，我們需要 `run` 函式檢查 `case_sensitive` 欄位的數值，並以此決定要呼叫 `search` 函式或是 `search_case_insensitive` 函式。

```rs
pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
    let contents = fs::read_to_string(config.filename)?;

    let results = if config.case_sensitive {
        search(&config.query, &contents)
    } else {
        search_case_insensitive(&config.query, &contents)
    };

    for line in results {
        println!("{}", line);
    }

    Ok(())
}
```

最後，我們需要檢查環境變數。處理環境變數的函式位於標準函式庫中的 `env` 模組中，所以我們可以在 `src/lib.rs` 檔最上方加上 `use std::env;` 來將該模組引入作用域。然後我們使用 `env` 模組中的 `var` 函式來檢查一個叫做 `CASE_INSENSITIVE` 的環境變數。

```rs
use std::env;
// ...

impl Config {
    pub fn new(args: &Vec<String>) -> Result<Config, &'static str> {
        if args.len() < 3 {
            return Err("引數不足");
        }

        let query = args[1].clone();
        let filename = args[2].clone();

        let case_sensitive = env::var("CASE_INSENSITIVE").is_err();

        Ok(Config {
            query,
            filename,
            case_sensitive,
        })
    }
}
```

我們在 `Result` 使用 `is_err` 方法來檢查是否為錯誤，如果是的話就代表沒有設置，也意味著它該使用區分大小寫的搜尋。如果 `CASE_INSENSITIVE` 環境變數有設置成任何數值的話，`is_err` 會回傳否，所以程式就會進行不區分大小寫的搜尋。我們不在乎環境變數的數值，只在意它有沒有被設置而已，所以我們使用 `is_err` 來檢查而非使用 `unwrap`、`expect` 或其他任何我們看過的 `Result` 方法。

首先，我們先不設置環境變數並執行程式來搜尋「to」，任何包含小寫單字「to」的行都應要符合。

```bash
cargo run to poem.txt
   Compiling minigrep v0.1.0 (file:///projects/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.0s
     Running `target/debug/minigrep to poem.txt`
Are you nobody, too?
How dreary to be somebody!
```

現在，設置 `CASE_INSENSITIVE` 為 `1`，並執行程式來搜尋相同的字串「to」。

```bash
CASE_INSENSITIVE=1 cargo run to poem.txt
    Finished dev [unoptimized + debuginfo] target(s) in 0.0s
     Running `target/debug/minigrep to poem.txt`
Are you nobody, too?
How dreary to be somebody!
To tell your name the livelong day
To an admiring bog!
```

現在 `minigrep` 程式現在可以進行不區分大小寫的搜尋並以環境變數配置。

## 處理標準錯誤

目前我們使用 `println!` 巨集來將所有的輸出顯示到終端機。大多數的終端機都提供兩種輸出方式：用於通用資訊的標準輸出（standard output, stdout）以及用於錯誤訊息的標準錯誤（standard error, stderr）。這樣的區別讓使用者可以選擇將程式的成功輸出導向到一個檔案中，並仍能在螢幕上顯示錯誤訊息。

`println!` 巨集只能夠印出標準輸出，所以我們得用其他方式來印出標準錯誤。

### 檢查該在哪裡寫錯誤

命令列程式應該要傳送錯誤訊息至標準錯誤，讓我們可以在重新導向標準輸出至檔案時，仍能在螢幕上看到錯誤訊息。

要觀察此行為的方式是透過 `>` 來執行程式並加上檔案名稱 `output.txt`，這是我們要重新導向標準輸出到的地方。我們不會傳遞任何引數，這樣就應該會造成錯誤：

```bash
cargo run > output.txt
```

透過 `>` 語法告訴 shell 要將標準輸出的內容寫入 `output.txt` 而不是顯示在螢幕上。但沒有看到應顯示在螢幕上的錯誤訊息，這代表它一定跑到檔案中了。

```txt
解析引數時出現問題：引數不足
```

我們的錯誤訊息印到了標準輸出。像這樣的錯誤訊息印到標準錯誤會比較好，這樣才能只讓成功執行的資料存至檔案中。

### 將錯誤印出至標準錯誤

標準函式庫有提供 `eprintln!` 巨集來印到標準錯誤，所以讓我們變更兩個原本呼叫 println! 來印出錯誤的段落來改使用 `eprintln!`。

```rs
fn main() {
    let args: Vec<String> = env::args().collect();

    let config = Config::new(&args).unwrap_or_else(|err| {
        eprintln!("解析引數時出現問題：{}", err);
        process::exit(1);
    });

    if let Err(e) = minigrep::run(config) {
        eprintln!("應用程式錯誤：{}", e);

        process::exit(1);
    }
}
```

以相同方式再執行程式一次。

```bash
cargo run > output.txt
解析引數時出現問題：引數不足
```

現在我們看到錯誤顯示在螢幕上而且 `output.txt` 裡什麼也沒只有，這正是命令列程式所預期的行為。

讓我們加上不會產生錯誤的引數來執行程式，並仍重新導向標準輸出至檔案中。

```bash
cargo run to poem.txt > output.txt
```

在終端機不會看到任何輸出，而 `output.txt` 會包含我們的結果。

```txt
Are you nobody, too?
How dreary to be somebody!
```

這說明我們現在有對成功的輸出使用標準輸出，而且有妥善地將錯誤輸出傳至標準錯誤。

## 程式碼

- [minigrep](https://github.com/memochou1993/minigrep)

## 參考資料

- [The Rust Programming Language](https://doc.rust-lang.org/stable/book/)
