---
title: 「The Rust Programming Language」學習筆記（九）：測試
permalink: 「The-Rust-Programming-Language」學習筆記（九）：測試
tags: ["程式設計", "Rust"]
categories: ["程式設計", "Rust", "「The Rust Programming Language」學習筆記"]
---

## 前言

本文為「[The Rust Programming Language](https://doc.rust-lang.org/stable/book/)」語言指南的學習筆記。

## 簡介

程式碼的正確性意謂著程式碼可以如預期執行。Rust 就被設計為特別注重程式的正確性，但正確性是很複雜且難以證明的。Rust 的型別系統就承擔了很大一部分的負擔，但是型別系統還是沒辦法抓到所有不正確的地方。所以 Rust 在語言內提供了編寫自動化程式測試的支援。

## 撰寫測試

測試是一種 Rust 函式來驗證非測試程式碼是否以預期的方式執行。測試函式的本體通常會做三件動作：

- 設置任何所需要的資料或狀態。
- 執行你希望測試的程式碼
- 判定結果是否與你預期的相符。

### 測試函式剖析

最簡單的形式來看，測試在 Rust 中就是附有 `test` 屬性的函式。屬性（Attributes）是一種關於某段 Rust 程式碼的詮釋資料（metadata），其中一個例子是 `derive` 屬性。要將一個函式轉換成測試函式，在 `fn` 前一行加上 `#[test]` 即可。當用 `cargo test` 命令來執行測試時，Rust 會建構一個測試執行檔並執行標有 `test` 屬性的程式，並回報每個測試函式是否通過或失敗。

以下建立一個函式庫專案叫做 `adder`。

```BASH
cargo new adder --lib
```

專案中的 `src/lib.rs` 檔如下。

```RS
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

```BASH
cargo test
```

讓我們再加上另一個測試，不過這次要讓測試失敗！測試會在測試函式恐慌時失敗，每個測試會跑在新的執行緒（thread）上，然後當主執行緒看到測試執行緒死亡時，就會將該測試標記為失敗的。引發恐慌最簡單的辦法，那就是呼叫 `panic!` 巨集。

```BASH
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

在獨立結果與總結之間出現了兩個新的段落，第一個段落會顯示每個測試失敗的原因細節。

### 透過 `assert!` 巨集檢查結果

標準函式庫提供的 `assert!` 巨集可以在要確保測試中的一些條件評估為 `true` 時使用。

```RS
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

們建立了一個寬度為 `8`、長度為 `7` 的 `Rectangle` 實例，並判定它可以包含另一個寬度為 `5`、長度為 `1` 的 `Rectangle` 實例。

```RS
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

```RS
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

```RS
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

```RS
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

```RS
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

```RS
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

TODO

## 參考資料

- [The Rust Programming Language](https://doc.rust-lang.org/stable/book/)
