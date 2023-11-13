---
title: 「The Rust Programming Language」學習筆記（十四）：Cargo
date: 2022-10-11 21:08:39
tags: ["Programming", "Rust"]
categories: ["Programming", "Rust", "「The Rust Programming Language」Study Notes"]
---

## 前言

本文為「[The Rust Programming Language](https://doc.rust-lang.org/stable/book/)」語言指南的學習筆記。

## 自訂建構

Cargo 有兩個主要的設定檔：`dev` 設定檔會在執行 `cargo build` 時所使用，`dev` 設定檔預設定義為開發時使用。

```bash
cargo build
    Finished dev [unoptimized + debuginfo] target(s) in 0.0s
```

而 `release` 設定檔會在執行 `cargo build --release` 時所使用，`release` 設定檔預設定義為發布時使用。

```bash
cargo build --release
    Finished release [optimized] target(s) in 0.0s
```

當專案的 `Cargo.toml` 中沒有任何 `[profile.*]` 段落的話，Cargo 就會使用每個設定檔的預設設置。透過對你想要自訂的任何設定檔加上 `[profile.*]` 段落，你可以覆寫任何預設設定的子集。舉例來說，以下是 `dev` 與 `release` 設定檔中 `opt-level` 設定的預設數值。

```toml
[profile.dev]
opt-level = 0

[profile.release]
opt-level = 3
```

`opt-level` 設定控制了 Rust 對程式碼進行優化的程度，範圍從 0 到 3。提高優化程度會增加編譯時間，所以如果在開發過程中得時常編譯程式碼的話，你會比較想要編譯快一點，就算結果程式碼會執行的比較慢。這就是 `dev` 的 `opt-level` 預設為 0 的原因。當準備好要發佈程式碼時，則最好花多點時間來編譯。只需要在發佈模式編譯一次，但編譯程式則會被執行很多次，所以發佈模式選擇花費多點編譯時間來讓程式跑得比較快。這就是 `release` 的 `opt-level` 預設為 3 的原因。

可以在 `Cargo.toml` 加上不同的數值來覆蓋任何預設設定。

```toml
[profile.dev]
opt-level = 1
```

這樣就會覆蓋預設設定 0。

## 發布 Crate

發佈自己的套件來將程式碼提供給其他人使用。crates.io 會發行套件的原始碼，所以它主要用來託管開源程式碼。

### 寫上有幫助的技術文件註解

準確地加上套件的技術文件有助於其他使用者知道如何及何時使用它們，所以投資時間在寫技術文件上是值得的。我們提過如何使用兩條斜線 `//` 來加上 Rust 程式碼註解。Rust 還有個特別的註解用來作為技術文件，俗稱為技術文件註解（documentation comment），這能用來產生 HTML 技術文件。這些 HTML 顯示公開 API 項目中技術文件註解的內容，讓對此函式庫有興趣的開發者知道如何使用你的 crate，而不需知道 crate 是如何實作的。

技術文件註解使用三條斜線 `///` 而不是兩條，並支援 Markdown 符號來格式化文字。技術文件註解位於它們對應項目的上方。以下顯示了 `my_crate` 的 crate 中 `add_one` 的技術文件註解。

```rs
/// Adds one to the number given.
///
/// # Examples
///
/// ```
/// let arg = 5;
/// let answer = my_crate::add_one(arg);
///
/// assert_eq!(6, answer);
/// ```
pub fn add_one(x: i32) -> i32 {
    x + 1
}
```

這裡加上了解釋函式 `add_one` 行為的描述、加上一個標題為 `Examples` 的段落並附上展示如何使用 `add_one` 函式的程式碼。我們可以透過執行 `cargo doc` 來從技術文件註解產生 HTML 技術文件。此命令會執行隨著 Rust 一起發佈的工具 `rustdoc`，並在 `target/doc` 目錄下產生 HTML 技術文件。

為了方便起見，可以執行 `cargo doc --open` 來建構當前 crate 的 HTML 技術文件（以及 crate 所有依賴的技術文件）並在網頁瀏覽器中開啟結果。導向到函式 `add_one` 而你就能看到技術文件註解是如何呈現的。

#### 常見技術文件段落

以下是 crate 技術文件中常見的段落標題：

- Panics：該函式可能會導致恐慌的可能場合。函式的呼叫者不希望他們的程式恐慌的話，就要確保他們沒有在這些情況下呼叫該函式。
- Errors：如果函式回傳 `Result`，解釋發生錯誤的可能種類以及在何種條件下可能會回傳這些錯誤有助於呼叫者，讓他們可以用不同方式來寫出處理不同種錯誤的程式碼。
- Safety: 如果呼叫的函式是 `unsafe` 的話，就必須要有個段落解釋為何該函式是不安全的，並提及函式預期呼叫者要確保哪些不變條件（invariants）。

大多數的技術文件註解不全都需要這些段落，但這些是呼叫程式碼的人可能有興趣瞭解的內容，你可以作為提醒你的檢查列表。

#### 將技術文件註解作為測試

在技術文件註解加上範例程式碼區塊有助於解釋如何使用你的函式庫，而且這麼做還有個額外好處：執行 `cargo test` 也會將你的技術文件視為測試來執行！在技術文件加上範例的確是最佳示範，但是如果程式碼在技術文件寫完之後變更的話，該範例可能就會無法執行了。

對以下範例執行 `cargo test` 的話，會看見測試結果有以下這樣的段落：

```bash
Doc-tests my_crate

running 1 test
test src/lib.rs - add_one (line 5) ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.27s
```

#### 包含項目結構的註解

還有另一種技術文件註解的風格為 `//!`，這是對其包含該註解的項目所加上的技術文件，而不是對註解後的項目所加上的技術文件。通常將此技術文件註解用於 crate 源頭檔（通常為 `src/lib.rs`）或模組來對整個 crate 或模組加上技術文件。

舉例來說，如果我們希望能加上技術文件來描述包含 `add_one` 函式的 `my_crate` 目的，我們可以用 `//!` 在 `src/lib.rs` 檔案開頭加上技術文件註解。

```rs
//! # My Crate
//!
//! `my_crate` is a collection of utilities to make performing certain
//! calculations more convenient.

/// Adds one to the number given.
// ...
```

注意到 `//!` 最後一行之後並沒有緊貼任何程式碼，因為我們是用 `//!` 而非 `///` 來下註解。在此例中，包含此註解的項目為 `src/lib.rs` 檔案，也就是 crate 的源頭。這些註解會描述整個 crate。

當我們執行 `cargo doc --open`，這些註解會顯示在 `my_crate` 技術文件的首頁，位於 crate 公開項目列表的上方。

項目中的技術文件註解可以用來分別描述 crate 和模組。用它們來將解釋容器整體的目的有助於使用者瞭解該 crate 的程式碼組織架構。

### 透過 `pub use` 匯出理想的公開 API

可能會希望用有數個層級的分層架構來組織程式碼，但是要是有人想使用你定義在分層架構裡的型別時，它們可能就很難發現這些型別的存在。而且輸入 `use my_crate::some_module::another_module::UsefulType;` 是非常惱人的，我們會希望輸入 `use my_crate::UsefulType;` 就好。

公開 API 的架構是發佈 crate 時要考量到的一大重點。使用 crate 的人可能並沒有你那麼熟悉其中的架構，而且如果你的 crate 模組分層越深的話，他們可能就難以找到他們想使用的部分。

好消息是如果你的架構不便於其他函式庫所使用的話，你不必重新組織你的內部架構：你可以透過使用 `pub use` 選擇重新匯出（re-export）項目來建立一個不同於內部私有架構的公開架構。重新匯出會先取得某處的公開項目，再從其他地方使其公開，讓它像是被定義在其他地方一樣。

舉例來說，我們建立了一個函式庫叫做 `art` 來模擬藝術概念。在函式庫中有兩個模組：`kinds` 模組包含兩個枚舉 `PrimaryColor` 和 `SecondaryColor`；而 `utils` 模組包含一個函式 `mix`，如以下範例所示：

```rs
//! # Art
//!
//! A library for modeling artistic concepts.

pub mod kinds {
    /// The primary colors according to the RYB color model.
    pub enum PrimaryColor {
        Red,
        Yellow,
        Blue,
    }

    /// The secondary colors according to the RYB color model.
    pub enum SecondaryColor {
        Orange,
        Green,
        Purple,
    }
}

pub mod utils {
    use crate::kinds::*;

    /// Combines two primary colors in equal amounts to create
    /// a secondary color.
    pub fn mix(c1: PrimaryColor, c2: PrimaryColor) -> SecondaryColor {
        // ...
    }
}
```

注意到 `PrimaryColor` 與 `SecondaryColor` 型別沒有列在首頁，而函式 `mix` 也沒有。我們必須點擊 `kinds` 與 `utils` 才能看到它們。

其他依賴此函式庫的 crate 需要使用 `use` 陳述式來將 `art` 的項目引入作用域中，並指定當前模組定義的架構。

```rs
use art::kinds::PrimaryColor;
use art::utils::mix;

fn main() {
    let red = PrimaryColor::Red;
    let yellow = PrimaryColor::Yellow;
    mix(red, yellow);
}
```

要從公開 API 移除內部架構，可以修改程式碼，並加上 `pub use` 陳述式來在頂層重新匯出項目。

```rs
//! # Art
//!
//! A library for modeling artistic concepts.

pub use self::kinds::PrimaryColor;
pub use self::kinds::SecondaryColor;
pub use self::utils::mix;

pub mod kinds {
    // ...
}

pub mod utils {
    // ...
}
```

使用 `cargo doc` 指令對此 crate 產生的 API 技術文件，現在就會顯示與連結重新匯出的項目到首頁中。

使用者仍可以看到並使用內部架構，或者它們可以使用像以下範例這樣更方便的架構。

```rs
use art::mix;
use art::PrimaryColor;

fn main() {
    // ...
}
```

如果有許多巢狀模組（nested modules）的話，在頂層透過 pub use 重新匯出型別可以大大提升使用 crate 的體驗。

提供實用的公開 API 架構更像是一門藝術而不只是科學，而你可以一步步來尋找最適合使用者的 API 架構。使用 `pub use` 可以給你更多組織 crate 內部架構的彈性，並將內部架構與要呈現給使用者的介面互相解偶（decouple）。

### 設定 Crates.io 帳號

在可以發佈任何 crate 之前，需要建立一個 crates.io 的帳號並取得一個 API token。前往 crates.io 的首頁，並透過 GitHub 帳號來登入，到[帳號](https://crates.io/me/)設定，並索取 API key，然後用這個 API key 來執行 `cargo login` 命令。

```bash
cargo login abcdefghijklmnopqrstuvwxyz012345
```

此命令會傳遞 API token 給 Cargo 並儲存在本地的 `~/.cargo/credentials`。注意此 token 是個祕密（secret），不要分享給其他人。如果因為任何原因分享給任何人的話，最好撤銷掉並回到 crates.io 產生新的 token。

### 新增詮釋資料到新的 Crate

現在已經有個帳號，然後讓我們假設有個 crate 想要發佈。在發佈之前，需要對 crate 加上一些詮釋資料（metadata），也就是在 crate 的 `Cargo.toml` 檔案中 `[package]` 的段落內加上更多資料。

此 crate 必須要有個獨特的名稱。雖然在本地端開發 crate 時，可以是任何想要的名稱。但是 crates.io 上的 crate 名稱採先搶先贏制。一旦有 crate 名稱被取走了，其他人就不能再使用該名稱來發佈 crate。在嘗試發佈 crate 前，最好先在 crates.io 上搜尋想使用的名稱。如果該名稱已被其他 crate 使用，就需要想另一個名稱，並在 `Cargo.toml` 檔案中 `[package]` 段落的 `name` 欄位使用新的名稱來發佈，如以下所示：

```toml
[package]
name = "guessing_game"
```

當選好獨特名稱後，此時執行 `cargo publish` 來發佈 crate 的話，會得到以下警告與錯誤：

```bash
cargo publish
    Updating crates.io index
warning: manifest has no description, license, license-file, documentation, homepage or repository.
See https://doc.rust-lang.org/cargo/reference/manifest.html#package-metadata for more info.
...
error: failed to publish to registry at https://crates.io

Caused by:
  the remote server responded with an error: missing or empty metadata fields: description, license. Please see https://doc.rust-lang.org/cargo/reference/manifest.html for how to upload metadata
```

原因是因為缺少一些關鍵資訊：描述與授權條款是必須的，所以人們才能知道此 crate 在做什麼以及在何種情況下允許使用。要修正此錯誤，就需要將這些資訊加到 `Cargo.toml` 檔案中。

加上一兩句描述，它就會顯示在 crate 的搜尋結果中。至於 `license` 欄位，需要給予 license identifier value。舉例來說，要指定 crate 使用 MIT 授權條款的話，就加上 MIT 標識符：

```rs
[package]
name = "guessing_game"
license = "MIT"
```

如果想使用沒有出現在 SPDX 的授權條款，需要將該授權條款的文字儲存在一個檔案中、將該檔案加入專案中，並使用 license-file 來指定該檔案名稱，而不使用 license。

Rust 社群中許多人都會用 `MIT OR Apache-2.0` 雙授權條款作為它們專案的授權方式，這和 Rust 的授權條款一樣。這也剛好展示用 OR 指定數個授權條款，讓專案擁有數個不同的授權方式。

有了獨特名稱、版本、描述與授權條款，準備好發佈的 Cargo.toml 檔案會如以下所示：

```toml
[package]
name = "guessing_game"
version = "0.1.0"
edition = "2021"
description = "A fun game where you guess what number the computer has chosen."
license = "MIT OR Apache-2.0"

[dependencies]
```

### 發佈至 Crates.io

現在已經準備好發佈了！發佈 crate 會上傳一個指定版本到 crates.io 供其他人使用。

發佈 crate 時請格外小心，因為發佈是會永遠存在的。該版本無法被覆寫，而且程式碼無法被刪除。crates.io 其中一個主要目標就是要作為儲存程式碼的永久伺服器，讓所有依賴 crates.io 的 crate 的專案可以持續正常運作。允許刪除版本會讓此目標幾乎無法達成。不過能發佈的 crate 版本不會有數量限制。

再次執行 `cargo publish` 命令，這次就應該會成功了：

```rs
cargo publish
    Updating crates.io index
    Packaging guessing_game v0.1.0 (file:///projects/guessing_game)
    Verifying guessing_game v0.1.0 (file:///projects/guessing_game)
    Compiling guessing_game v0.1.0
(file:///projects/guessing_game/target/package/guessing_game-0.1.0)
    Finished dev [unoptimized + debuginfo] target(s) in 0.19s
    Uploading guessing_game v0.1.0 (file:///projects/guessing_game)
```

### 對現有 Crate 發佈新版本

當對 crate 做了一些改變並準備好發佈新版本時，可以變更 `Cargo.toml` 中的 `version` 數值，並再發佈一次。使用語意化版本規則，依據作出的改變來決定下一個妥當的版本數字。接著執行 `cargo publish` 來上傳新版本。

### 移除 Crates.io 的版本

雖然無法刪除 crate 之前的版本，還是可以防止任何未來的專案加入它們作為依賴。這在 crate 版本因某些原因而被破壞時會很有用。在這樣的情況下，Cargo 支援撤回（yanking） crate 版本。

撤回一個版本能防止新專案用該版本作為依賴，同時允許現存依賴它的專案能夠繼續下載並依賴該版本。實際上，撤回代表所有專案的 `Cargo.lock` 都不會被破壞，且任何未來產生的 `Cargo.lock` 檔案不會使用被撤回的版本。

要撤回一個 crate 的版本，執行 `cargo yank` 並指定想撤回的版本：

```rs
cargo yank --vers 1.0.1
```

而對命令加上 `--undo` 的話，還可以在復原撤回的動作，允許其他專案可以再次依賴該版本：

```rs
cargo yank --vers 1.0.1 --undo
```

撤回並不會刪除任何程式碼。舉例來說，撤回此功能並不會刪除任何不小心上傳的祕密訊息。如果真的出現這種情形，必須立即重設那些資訊。

## 工作空間

函式庫 crate 變得越來越大，會想要將套件拆成數個函式庫 crate。針對這種情形，Cargo 提供了一個功能叫做工作空間（workspaces）能來幫助管理並開發數個相關的套件。

### 建立工作空間

工作空間是一系列的共享相同 `Cargo.lock` 與輸出目錄的套件。組織工作空間的架構有很多種方式，我們會顯示其中一種常見的方式。我們的工作空間將會包含一個二進制執行檔與兩個函式庫。執行檔會提供主要功能，並依賴其他兩個函式庫。其中一個函式庫會提供函式 `add_one`，而另一個函式庫會提供函式 `add_two`。這三個 crate 會包含在相同的工作空間中，先從建立工作空間的目錄開始。

```bash
mkdir add
cd add
```

接著在 `add` 目錄中，我們建立會設置整個工作空間的 `Cargo.toml` 檔案。此檔案不會有 `[package]` 段落或是我們在其他 `Cargo.toml` 檔案看過的詮釋資料。反之，他會使用一個 `[workspace]` 段落作為起始，讓我們可以透過指定二進制 crate 的套件路徑來將它加到工作空間的成員中。在此例中，我們的路徑是 `adder`。

```toml
[workspace]

members = [
    "adder",
]
```

接下來在 `add` 目錄下執行 `cargo new` 來建立 `adder` 二進制 crate。

```bash
cargo new adder
```

目錄 `add` 底下的檔案應該會看起來像這樣。

```bash
├── Cargo.lock
├── Cargo.toml
├── adder
│   ├── Cargo.toml
│   └── src
│       └── main.rs
└── target
```

工作空間在頂層有一個 `target` 目錄用來儲存編譯結果。`adder` 套件不會有自己的 `target` 目錄。就算我們在 `adder` 目錄底下執行 `cargo build`，編譯結果仍然會在 `add/target` 底下而非 `add/adder/target`。Cargo 之所以這樣組織工作空間的 `target` 目錄是因為工作空間的 crate 是會彼此互相依賴的。 如果每個 crate 都有自己的 `target` 目錄，每個 crate 就得重新編譯工作空間中的其他每個 crate 才能將編譯結果放入它們自己的 `target` 目錄。共享 `target` 目錄的話，crate 可以避免不必要的重新建構。

### 在工作空間中建立第二個套件

接下來在工作空間中建立另一個套件成員 `add_one`。修改頂層 `Cargo.toml` 來指定 `add_one` 的路徑到 `members` 列表中：

```toml
[workspace]

members = [
    "adder",
    "add_one",
]
```

然後產生新的函式庫 crate 叫 `add_one`：

```bash
cargo new add_one --lib
```

現在 `add` 目錄應該要擁有這些目錄與檔案：

```bash
├── Cargo.lock
├── Cargo.toml
├── add_one
│   ├── Cargo.toml
│   └── src
│       └── lib.rs
├── adder
│   ├── Cargo.toml
│   └── src
│       └── main.rs
└── target
```

在 `add_one/src/lib.rs` 檔案中，加上一個函式 `add_one`：

```rs
pub fn add_one(x: i32) -> i32 {
    x + 1
}
```

現在在工作空間中有另一個套件了，我們可以讓 `adder` 套件的執行檔依賴擁有函式庫的 `add_one` 套件。首先，需要將 `add_one` 的路徑依賴加到 `adder/Cargo.toml`。

```toml
[dependencies]
add_one = { path = "../add_one" }
```

Cargo 不會假設工作空間下的 crate 會彼此依賴，需要指定 crate 彼此之間依賴的關係。

接著在 `adder` 內使用 `add_one` 的 crate 的 `add_one` 函式。開啟 `adder/src/main.rs` 檔案並在最上方加上 `use` 來將 `add_one` 函式庫引入作用域。然後變更 `main` 函式來呼叫 `add_one` 函式。

```rs
use add_one;

fn main() {
    let num = 10;
    println!("你好，世界！{} 加一會是 {}！", num, add_one::add_one(num));
}
```

在頂層的 `add` 目錄執行 `cargo build` 來建構工作空間。

```bash
cargo build
```

要執行 `add` 目錄的二進制 crate，我們可以透過 `-p` 加上套件名稱使用 `cargo run` 來執行我們想要在工作空間中指定的套件。

```bash
cargo run -p adder
```

這就會執行 `adder/src/main.rs` 的程式碼，其依賴於 `add_one` 的 crate。

#### 在工作空間中依賴外部套件

注意到工作空間只有在頂層有一個 `Cargo.lock` 檔案，而不是在每個 crate 目錄都有一個 `Cargo.lock`。這確保所有的 crate 都對所有的依賴使用相同的版本。如果我們加了 `rand` 套件到 `adder/Cargo.toml` 與 `add_one/Cargo.toml` 檔案中，Cargo 會將兩者的版本解析為同一個 rand 版本並記錄到同個 `Cargo.lock` 中。確保工作空間所有 crate 都會使用相同依賴代表工作空間中的 crate 永遠都彼此相容。讓我們將 `rand` 這個 crate 加到 `add_one/Cargo.toml` 檔案的 `[dependencies]` 段落中，使 `add_one` 這個 crate 可以使用 `rand` 這個 crate。

```toml
rand = "0.8.3"
```

現在就可以將 `use rand;` 加到 `add_one/src/lib.rs` 檔案中，接著在 `add` 目錄下執行 `cargo build` 來建構整個工作空間就會引入並編譯 `rand` 這個 crate。我們會得到一個警告，因爲我們還沒有開始使用引入作用域的 `rand`。

```bash
cargo build
```

頂層的 `Cargo.lock` 現在就包含 `add_one` 有 `rand` 作為依賴的資訊。不過就算我們能在工作空間的某處使用 `rand`，並不代表我們可以在工作空間的其他 crate 中使用它，除非它們的 `Cargo.toml` 也加上了 `rand`。舉例來說，如果將 `use rand;` 加到 `adder/src/main.rs` 檔案中想讓 `adder` 套件也使用的話，我們就會得到錯誤。

要修正此問題，只要修改 `adder` 套件的 `Cargo.toml` 檔案，指示它也加入 `rand` 作為依賴就好了。這樣建構 `adder` 套件就會將在 `Cargo.lock` 中將 `rand` 加入 `adder` 的依賴，但是沒有額外的 `rand` 會被下載。Cargo 會確保工作空間中每個套件的每個 crate 都會使用相同的 `rand` 套件版本。在工作空間中使用相同版本的 `rand` 可以節省空間，因為我們就不會重複下載並能確保工作空間中的 crate 彼此可以互相兼容。

#### 在工作空間中新增測試

再進一步加入一個測試函式 `add_one::add_one` 到 `add_one` 這個 crate 之中：

```rs
pub fn add_one(x: i32) -> i32 {
    x + 1
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        assert_eq!(3, add_one(2));
    }
}
```

現在在頂層的 `add` 目錄執行 `cargo test` 指令。

```bash
cargo test
```

也可以在頂層目錄使用 `-p` 並指定想測試的 crate 名稱來測試工作空間中特定的 crate。

```bash
cargo test -p add_one
```

此輸出顯示 `cargo test` 只執行了 `add_one` 這個 crate 的測試並沒有執行 `adder` 這個 crate 的測試。

如果想要發佈工作空間的 crate 到 crates.io，工作空間中的每個 crate 必須分別獨自發佈。`cargo publish` 命令並沒有 `--all` 或是 `-p` 之類的選項，必須移動到每個 crate 的目錄並執行 `cargo publish`，這樣工作空間中的每個 crate 才會發佈出去。

可以在工作空間中在加上 `add_two` 這個 crate，方式和 `add_one` 這個 crate 類似。

## 安裝執行檔

使用 `cargo install` 命令能在本地安裝並使用二進制執行檔 crates。這並不是打算要取代系統套件，這是為了方便讓 Rust 開發者可以安裝 crates.io 上分享的工具。注意你只能安裝有二進制目標的套件。二進制目標（binary target）是在 crate 有 `src/main.rs` 檔案或其他指定的二進制檔案時，所建立的可執行程式。而相反地，函式庫目標就無法單獨執行，因為它是提供給其他程式使用的函式庫。通常 crate 都會提供 `README` 檔案說明此 crate 是函式庫還是二進制目標，或者兩者都是。

所有透過 `cargo install` 安裝的二進制檔案都儲存在安裝根目錄的 `bin` 資料夾中。如果是用 `rustup.rs` 安裝 Rust 且沒有任何自訂設置的話，此目錄會是 `$HOME/.cargo/bin`。請確定該目錄有在 `$PATH` 中，這樣才能夠執行 `cargo install` 安裝的程式。

舉例來說，有個工具叫做 `ripgrep` 能用來搜尋檔案。如果我們想要安裝的話，我們可以執行以下命令。

```bash
cargo install ripgrep
```

## 擴展

Cargo 的設計能讓你在不用修改 Cargo 的情況下擴展新的子命令。如果 `$PATH` 中有任何叫做 `cargo-something` 的二進制檔案，就可以用像是執行 Cargo 子命令的方式 `cargo something` 來執行它。像這樣的自訂命令在執行 `cargo --list` 時也會顯示出來。能夠透過 `cargo install` 來安裝擴展插件並有如內建 Cargo 工具般來執行使用是 Cargo 設計上的一大方便優勢。

## 程式碼

- [rust-cargo-workspace](https://github.com/memochou1993/rust-cargo-workspace)

## 參考資料

- [The Rust Programming Language](https://doc.rust-lang.org/stable/book/)
