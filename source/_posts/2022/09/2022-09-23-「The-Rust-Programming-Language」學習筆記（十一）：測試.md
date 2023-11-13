---
title: 「The Rust Programming Language」學習筆記（十一）：測試
tags: ["Programming", "Rust"]
categories: ["Programming", "Rust", "「The Rust Programming Language」Study Notes"]
---

## 前言

本文為「[The Rust Programming Language](https://doc.rust-lang.org/stable/book/)」語言指南的學習筆記。

## 簡介

程式碼的正確性意謂著程式碼可以如預期執行。Rust 就被設計為特別注重程式的正確性，但正確性是很複雜且難以證明的。Rust 的型別系統就承擔了很大一部分的負擔，但是型別系統還是沒辦法抓到所有不正確的地方。所以 Rust 在語言內提供了編寫自動化程式測試的支援。

## 撰寫測試

測試是一種 Rust 函式來驗證非測試程式碼是否以預期的方式執行。測試函式的本體通常會做三件動作：

- 設置任何所需要的資料或狀態。
- 執行你希望測試的程式碼。
- 判定結果是否與你預期的相符。

### 測試函式剖析

最簡單的形式來看，測試在 Rust 中就是附有 `test` 屬性的函式。屬性（Attributes）是一種關於某段 Rust 程式碼的詮釋資料（metadata），其中一個例子是 `derive` 屬性。要將一個函式轉換成測試函式，在 `fn` 前一行加上 `#[test]` 即可。當用 `cargo test` 命令來執行測試時，Rust 會建構一個測試執行檔並執行標有 `test` 屬性的程式，並回報每個測試函式是否通過或失敗。

以下建立一個函式庫專案叫做 `adder`。

```bash
cargo new adder --lib
```

專案中的 `src/lib.rs` 檔如下。

```rs
pub fn add(left: usize, right: usize) -> usize {
    left + right
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }
}
```

注意到 `fn` 上一行的 `#[test]` 詮釋：此屬性指出這是測試函式，所以測試者會知道此函式是用來測試的。我們也可以在 `tests` 模組中加入非測試函式來協助設置常見場景或是執行常見運算，所以我們需要在想要測試的函式前加上 `#[test]` 屬性。

函式本體使用 `assert_eq!` 巨集來判定 `2 + 2` 等於 `4`。此判定是作為典型測試的範例格式。

以下執行 `cargo test` 命令會執行專案中的所有測試。

```bash
cargo test
```

讓我們再加上另一個測試，不過這次要讓測試失敗！測試會在測試函式恐慌時失敗，每個測試會跑在新的執行緒（thread）上，然後當主執行緒看到測試執行緒死亡時，就會將該測試標記為失敗的。引發恐慌最簡單的辦法，那就是呼叫 `panic!` 巨集。

```bash
#[cfg(test)]
mod tests {
    #[test]
    fn exploration() {
        assert_eq!(2 + 2, 4);
    }

    #[test]
    fn another() {
        panic!("此測試會失敗");
    }
}
```

在獨立結果與總結之間出現了兩個新的段落，第一個段落會顯示每個測試失敗的原因。

### 透過 `assert!` 巨集檢查結果

標準函式庫提供的 `assert!` 巨集可以在要確保測試中的一些條件為 `true` 時使用。

```rs
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

impl Rectangle {
    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
}
```

建立一個寬度為 `8`、長度為 `7` 的 `Rectangle` 實例，並判定它可以包含另一個寬度為 `5`、長度為 `1` 的 `Rectangle` 實例。

```rs
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn larger_can_hold_smaller() {
        let larger = Rectangle {
            width: 8,
            height: 7,
        };
        let smaller = Rectangle {
            width: 5,
            height: 1,
        };

        assert!(larger.can_hold(&smaller));
    }
}
```

注意到我們有在 `tests` 模組中加了一行 `use super::*;`。`tests` 和一般的模組一樣都遵循先前提及的常見能見度規則。因為 `tests` 模組是內部模組，我們需要將外部模組的程式碼引入內部模組的作用域中。我們使用全域運算子（glob）讓外部模組定義的所有程式碼在此 `tests` 模組都可以使用。

再加另一個測試，這是是判定小長方形無法包含大長方形：

```rs
#[cfg(test)]
mod tests {
    use super::*;

    // ...

    #[test]
    fn smaller_cannot_hold_larger() {
        let larger = Rectangle {
            width: 8,
            height: 7,
        };
        let smaller = Rectangle {
            width: 5,
            height: 1,
        };

        assert!(!smaller.can_hold(&larger));
    }
}
```

### 透過 `assert_eq!` 與 `assert_ne!` 巨集檢查結果

標準函式庫提供了一對巨集 `assert_eq!` 與 `assert_ne!` 來更方便地測試。這兩個巨集分別比較兩個引數是否相等或不相等。

以下函式叫做 `add_two` 並對參數加上 `2` 然後回傳為結果。然後我們使用 `assert_eq!` 巨集來測試此函式。

```rs
pub fn add_two(a: i32) -> i32 {
    a + 2
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_adds_two() {
        assert_eq!(4, add_two(2));
    }
}
```

注意到在有些語言或測試框架中，判定兩個數值是否相等的函式的參數會稱作 `expected` 和 `actual`，然後它們會因為指定的引數順序而有差。但在 Rust 中它們被稱為 `left` 和 `right`，且我們預期的值與測試中程式碼產生的值之間的順序沒有任何影響。我們可以在此程式這樣寫判定 `assert_eq!(add_two(2), 4)`，而錯誤訊息就會顯示成 `assertion failed: (left == right)`，然後 `left` 會是 `5` 而 `right` 會是 `4`。

### 加入自訂失敗訊息

可以寫一個一個與失敗訊息一同顯示的自訂訊息，作為 `assert!`、`assert_eq!` 與 `assert_ne!` 巨集的選擇性引數。可以傳入一個包含 `{}` 佔位符（placeholder）的格式化字串以及其對應的數值。自訂訊息可以用來紀錄判定的意義，當測試失敗時，你可以更清楚知道程式碼的問題。

```rs
pub fn greeting(name: &str) -> String {
    String::from("哈囉！")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn greeting_contains_name() {
        let result = greeting("卡爾");
        assert!(
            result.contains("卡爾"),
            "打招呼時並沒有喊出名稱，其數值為 `{}`",
            result
        );
    }
}
```

我們可以看到我們實際從測試輸出拿到的數值，這能幫助我們除錯找到實際發生什麼，而不只是預期會是什麼。

### 透過 `should_panic` 檢查恐慌

除了檢查我們的程式碼有沒有回傳我們預期的正確數值，檢查我們的程式碼有沒有如我們預期處理錯誤條件也是很重要的。為此我們可以加上另一個屬性 `should_panic` 到我們的測試函式。此屬性讓函式的程式碼恐慌時才會通過測試，反之如果函式的程式碼沒有恐慌的話測試就會失敗。

```rs
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
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    #[should_panic]
    fn greater_than_100() {
        Guess::new(200);
    }
}
```

使用 `should_panic` 的測試可能會有點模棱兩可，因為它們只代表該程式碼會造成某種恐慌而已。`should_panic` 測試只要是有恐慌都會通過，就算是不同於我們預期發生的恐慌而造成的也一樣。要讓測試 `should_panic` 更精準的話，我們可以加上選擇性的 `expected` 參數到 `should_panic` 中。這樣測試就會確保錯誤訊息會包含我們所寫的文字。

```rs
pub struct Guess {
    value: i32,
}

impl Guess {
    pub fn new(value: i32) -> Guess {
        if value < 1 {
            panic!("猜測數字必須大於等於 1，取得的數值是 {}。", value);
        } else if value > 100 {
            panic!("猜測數字必須小於等於 100，取得的數值是 {}。", value);
        }

        Guess { value }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    #[should_panic(expected = "猜測數字必須小於等於 100")]
    fn greater_than_100() {
        Guess::new(200);
    }
}
```

此測試會通過是因為我們在 `should_panic` 屬性加上的 `expected` 就是 `Guess::new` 函式恐慌時的子字串。在 `should_panic` 所指定的預期參數取決於該恐慌訊息是獨特或動態的，以及希望測試要多精準。

### 在測試中使用 `Result<T, E>` 結構體

目前為止，我們的測試在失敗時就會恐慌。我們也可以寫出使用 `Result<T, E>` 的測試！以下重寫成 `Result<T, E>` 的版本並回傳 `Err` 而非恐慌：

```rs
#[cfg(test)]
mod tests {
    #[test]
    fn it_works() -> Result<(), String> {
        if 2 + 2 == 4 {
            Ok(())
        } else {
            Err(String::from("二加二不等於四"))
        }
    }
}
```

`it_works` 函式現在有個回傳型別 `Result<(), String>`。在函式本體中，我們不再呼叫 `assert_eq!` 巨集，而是當測試成功時回傳 `Ok(())`，當程式失敗時回傳存有 `String` 的 `Err`。

測試中回傳 `Result<T, E>` 讓你可以在測試本體中使用問號運算子，這樣能方便地寫出任何運算回傳 `Err` 時該失敗的測試。

不過就不能將 `#[should_panic]` 詮釋用在使用 `Result<T, E>` 的測試。要判斷一個操作是否回傳 `Err` 的話，不要在 `Result<T, E>` 數值後加上 `?`，而是改用 `assert!(value.is_err())`。

## 控制程式

舉例來說 `cargo test` 預設行為產生的二進制執行檔，會平行執行所有測試並獲取測試執行時產生的輸出，讓測試各自的輸出結果不會顯示出來，以更容易讀取相關測試的結果。有些命令列選項用於 `cargo test` 而有些則用於產生的測試二進制檔案。要分開這兩種引數，你可以先列出要用於 `cargo test` 的引數然後加上 `--` 分隔線來區隔要用於測試二進制檔案的引數。

### 平行或接續執行測試

當執行數個測試時，它們預設會使用執行緒（thread）來平行執行。這樣測試可以更快完成。因為測試是同時一起執行的，請確保你的測試並不依賴其他測試或是共享的狀態。這包含共享環境，像是目前的工作目錄或是環境變數。

如果不想平行執行測試，或者想要能更加掌控使用的執行緒數量，可以傳遞 `--test-threads` 的選項以及希望在測試執行檔使用的執行緒數量。

```bash
cargo test -- --test-threads=1
```

在此將測試執行緒設為 `1`，告訴程式不要做任何平行化。使用一條執行緒執行測試會比平行執行它們還來的久，但是如果測試有共享狀態的話，它們就會不互相影響到對方了。

### 顯示函式輸出結果

如果測試通過的話，Rust 的測試函式庫預設會獲取所有印出的標準輸出。舉例來說，如果在測試中呼叫 `println!` 然後測試通過的話，不會在終端機看到 `println!` 的輸出，只會看到一行表達測試通過的訊息。如果測試失敗，才會看到所有印出的標準輸出與失敗訊息。

```rs
fn prints_and_returns_10(a: i32) -> i32 {
    println!("我得到的數值為 {}", a);
    10
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn this_test_will_pass() {
        let value = prints_and_returns_10(4);
        assert_eq!(10, value);
    }

    #[test]
    fn this_test_will_fail() {
        let value = prints_and_returns_10(8);
        assert_eq!(5, value);
    }
}
```

如果我們希望在測試通過時也能看到印出的數值，我們可以用 `--show-output` 告訴 Rust 也在成功的測試顯示輸出結果。

```bash
cargo test -- --show-output
```

### 透過名稱來執行部分測試

有時執行完整所有的測試會很花時間。如果正專注於程式碼的特定部分，可能會想要只執行與該程式碼有關的測試。

```rs
pub fn add_two(a: i32) -> i32 {
    a + 2
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn add_two_and_two() {
        assert_eq!(4, add_two(2));
    }

    #[test]
    fn add_three_and_two() {
        assert_eq!(5, add_two(3));
    }

    #[test]
    fn one_hundred() {
        assert_eq!(102, add_two(100));
    }
}
```

可以向 `cargo test` 傳遞想要執行的測試名稱作為引數。只有名稱為 `one_hundred` 的測試會執行，其他兩個的名稱並不符合。

```bash
cargo test one_hundred
```

也可以指定部分測試名稱，然後任何測試名稱中有相符的就會被執行。舉例來說，因為有兩個測試的名稱都包含 `add`，我們可以透過執行 `cargo test add` 來執行這兩個測試。

```bash
cargo test add
```

### 忽略某些測試除非特別指定

有時候有些特定的測試執行會花非常多時間，所以可能希望在執行 `cargo test` 時能排除它們。與其列出所有想要的測試作為引數，可以在花時間的測試前加上 `ignore` 屬性詮釋來排除它們。

```rs
#[test]
fn it_works() {
    assert_eq!(2 + 2, 4);
}

#[test]
#[ignore]
fn expensive_test() {
    // 會執行一小時的程式碼
}
```

對於想排除的測試，我們在 `#[test]` 之後我們加上 `#[ignore]`。現在當執行測試時，`it_works` 會執行但 `expensive_test` 就不會。

當有時間能夠執行 `ignored` 的測試時，可以執行以下指令。

```bash
cargo test -- --ignored
```

如果想執行所有程式，無論他們是不是被忽略的話，可以執行以下指令。

```bash
cargo test -- --include-ignored
```

## 組織架構

Rust 社群將測試分為兩大分類術語：單元測試（unit tests）和整合測試（integration tests）。單元測試比較小且較專注，傾向在隔離環境中一次只測試一個模組，且能夠測試私有介面。整合測試對於你的函式庫來說是個完全外部的程式碼，所以會如其他外部程式碼一樣使用你的程式碼，只能使用公開介面且每個測試可能會有數個模組。

這兩種測試都很重要，且能確保函式庫每個部分能在分別或一起執行的情況下，如你預期的方式運作。

### 單元測試

#### 測試模組與 `#[cfg(test)]` 詮釋

測試模組上的 `#[cfg(test)]` 詮釋會告訴 Rust 當你執行 `cargo test` 才會編譯並執行測試程式碼。而不是當你執行 `cargo build`。當你想要建構函式庫時，這能節省編譯時間並降低編譯出的檔案所佔的空間，因為這些測試沒有被包含到。整合測試位於不同目錄，所以它們不需要 `#[cfg(test)]`。但是因為單元測試與程式碼位於相同的檔案下，因此需要使用 `#[cfg(test)]` 來指明它們不應該被包含在編譯結果。

```rs
#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
```

此程式碼是自動產生的測試模組。`cfg` 屬性代表的是 `configuration` 並告訴 Rust 以下項目只有在給予特定配置選項時才會被考慮。在此例中配置選項是 `test`，這是 Rust 提供用來編譯與執行測試的選項。使用 `cfg` 屬性的話，Cargo 只有在我們透過 `cargo test` 執行測試時才會編譯我們的測試程式碼。這包含此模組能可能需要的輔助函式，以及用 `#[test]` 詮釋的測試函式。

#### 測試私有函式

在測試領域的社群中對於是否應該直接測試私有函式一直存在著爭議，而且有些其他語言會讓測試私有函式變得很困難，甚至不可能。不管你認為哪個論點比較理想，Rust 的隱私權規則還是能讓你測試私有函式。考慮以下範例。

```rs
pub fn add_two(a: i32) -> i32 {
    internal_adder(a, 2)
}

fn internal_adder(a: i32, b: i32) -> i32 {
    a + b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn internal() {
        assert_eq!(4, internal_adder(2, 2));
    }
}
```

注意到函式 `internal_adder` 沒有標記為 `pub`。測試也只是 Rust 的程式碼，且 `tests` 也只是另一個模組。如同我們在引用模組項目的路徑段落討論到的，下層模組的項目可以使用該項目以上的模組。在此測試中，我們透過 `use super::*` 引入 `test` 模組上層的所有項目，所以測試能呼叫 `internal_adder`。如果你不認為私有函式應該測試，Rust 也沒有什麼好阻止你的地方。

### 整合測試

在 Rust 中，整合測試對你的函式庫來說是完全外部的程式。它們使用你的函式庫的方式與其他程式碼一樣，所以它們只能呼叫屬於函式庫中公開 API 的函式。它們的目的是要測試你的函式庫屬個部分一起運作時有沒有正確無誤。單獨運作無誤的程式碼單元可能會在整合時出現問題，所以整合測試的程式碼的涵蓋率也很重要。要建立整合測試，你需要先有個 `tests` 目錄。

#### `tests` 目錄

在專案目錄最上層在 `src` 旁建立一個 `tests` 目錄。Cargo 知道要從此目錄來尋找整合測試。我們接著就可以在此目錄建立多少個測試都沒問題，Cargo 會編譯每個檔案成獨立的 crate。

建立 `tests/integration_test.rs` 檔。

```rs
use adder;

#[test]
fn it_adds_two() {
    assert_eq!(4, adder::add_two(2));
}
```

不用對 `tests/integration_test.rs` 的任何程式碼詮釋 `#[cfg(test)]`。Cargo 會特別對待 `tests` 目錄並只在我們執行 `cargo test` 時，編譯此目錄的檔案。

```bash
cargo test
```

我們一樣能用測試函式的名稱來作為 `cargo test` 的引數，來執行特定整合測試。要執行特定整合測試檔案內的所有測試，可以用 `--test` 作為 `cargo test` 的引數並加上檔案名稱

```bash
cargo test --test integration_test
```

此命令會只執行 `tests/integration_test.rs` 檔案內的測試。

#### 整合測試的子模組

隨著加入的整合測試越多，可能會想要在 `tests` 目錄下產生更多檔案來協助組織它們。舉例來說，以用測試函式測試的功能來組織它們。`tests` 目錄下的每個檔案都會編譯成自己獨立的 `crate`。

將每個整合測試檔案視為獨立的 `crate` 有助於建立不同的作用域，這就像是使用者使用你的 `crate` 的可能環境。然而這也代表 `tests` 目錄的檔案不會和 `src` 的檔案行為一樣。

當你希望擁有一些能協助數個整合測試檔案的輔助函式，並提取它們到一個通用模組時，就會發現 `tests` 目錄下的檔案行為是不同的。舉例來說，我們建立了 `tests/common.rs` 並寫了一個函式 `setup`，然後我們希望 `setup` 能被不同測試檔案的數個測試函式呼叫。

```rs
pub fn setup() {
    // 在此設置測試函式庫會用到的程式碼
}
```

要防止 `common` 出現在測試輸出，我們不該建立 `tests/common.rs`，而是要建立 `tests/common/mod.rs`。這是另一個 Rust 知道的常用命名手段。這樣命名檔案的話會告訴 Rust 不要將 `common` 模組視為整合測試檔案。當我們將 `setup` 函式程式碼移到 `tests/common/mod.rs` 並刪除 `tests/common.rs` 檔案時，原本的段落就不會再出現在測試輸出。`tests` 目錄下子目錄的檔案不會被編譯成獨立 `crate` 或在測試輸出顯示段落。

在我們建立 `tests/common/mod.rs` 之後，我們可以將它以模組的形式用在任何整合測試檔案中。

```rs
use adder;

mod common;

#[test]
fn it_adds_two() {
    common::setup();
    assert_eq!(4, adder::add_two(2));
}
```

#### 二進制執行檔 Crate 的整合測試

如果我們的專案是只包含 `src/main.rs` 檔案的二進制執行檔 crate 而沒有 `src/lib.rs` 檔案的話，我們無法在 `tests` 目錄下建立整合測試，也無法將 `src/main.rs` 檔案中定義的函式透過 `use` 陳述式引入作用域。只有函式庫 `crate` 能公開函式給其他 `crate` 使用，二進制 `crate` 只用於獨自執行。

這也是為何 Rust 專案為二進制執行檔提供直白的 `src/main.rs` 檔案並允許呼叫 `src/lib.rs` 檔案中的邏輯程式碼。使用這樣子的架構的話，整合測試可以透過 `use` 來測試函式庫 `crate`，並讓重點功能可以公開使用。如果重點功能可以運作的話，那 `src/main.rs` 檔案中剩下的程式碼部分也能夠如期執行，而這一小部分就不必特定做測試。

## 參考資料

- [The Rust Programming Language](https://doc.rust-lang.org/stable/book/)
