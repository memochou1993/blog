---
title: 「The Rust Programming Language」學習筆記（五）：結構體
date: 2022-05-24 02:23:48
tags: ["程式設計", "Rust"]
categories: ["程式設計", "Rust", "「The Rust Programming Language」學習筆記"]
---

## 前言

本文為「[The Rust Programming Language](https://doc.rust-lang.org/stable/book/)」語言指南的學習筆記。

## 結構體

結構體（Structs）和元組類似。和元組一樣的地方是，結構體的每個部分可以是不同的型別。但與元組不同的地方是，在結構體中我們必須為每個資料部分命名以便表達每個數值的意義。有了這些名稱，結構體通常更有彈性：不需要依賴資料的順序來指定或存取實例中的值。

欲定義結構體，我們使用關鍵字 `struct` 並為整個結構體命名。結構體的名稱需要能夠描述其所組合出的資料意義。然後在大括號內，我們對每個資料部分定義名稱與型別，稱為欄位（fields）。

```RS
struct User {
    active: bool,
    username: String,
    email: String,
    sign_in_count: u64,
}
```

要使用該結構體，可以指定每個欄位的實際數值來建立結構體的實例（instance）。先寫出結構體的名稱再加上大括號，裡面會包含數個 `key: value` 的配對。欄位的順序可以不用和定義結構體時的順序一樣。

```RS
let user1 = User {
    email: String::from("someone@example.com"),
    username: String::from("someusername123"),
    active: true,
    sign_in_count: 1,
};
```

要取得結構體中特定數值的話，可以使用句點。如果該實例可變的話，可以使用句點並賦值給該欄位來改變其值。

```RS
fn main() {
    let mut user1 = User {
        email: String::from("someone@example.com"),
        username: String::from("someusername123"),
        active: true,
        sign_in_count: 1,
    };

    user1.email = String::from("anotheremail@example.com");
}
```

注意，整個實例必須是可變的，Rust 不允許只標記特定欄位是可變的。以下範例展示了 `build_user` 函式會依據給予的電子郵件和使用者名稱來回傳 `User` 實例。

```RS
fn build_user(email: String, username: String) -> User {
    User {
        email: email,
        username: username,
        active: true,
        sign_in_count: 1,
    }
}
```

### 用欄位初始化簡寫語法

若參數名稱與結構體欄位名稱相同，我們可以使用欄位初始化簡寫（field init shorthand）語法來重寫 `build_user` 函式。

```RS
fn build_user(email: String, username: String) -> User {
    User {
        email,
        username,
        active: true,
        sign_in_count: 1,
    }
}
```

### 使用結構體更新語法從其他結構體建立實例

使用結構體更新語法，從其他的實例來產生新的實例，並保留大部分欄位。「`..`」語法表示剩下沒指明的欄位都會取得與所提供的實例相同的值。

```RS
fn main() {
    let user1 = User {
        email: String::from("someone@example.com"),
        username: String::from("someusername123"),
        active: true,
        sign_in_count: 1,
    };

    let user2 = User {
        email: String::from("another@example.com"),
        ..user1
    };
}
```

在此範例中，我們在建立 `user2` 之後就無法再使用 `user1`，因為 `user1` 的 `username` 欄位的 `String` 被移到 `user2` 了。如果我們同時給 `user2` 的 `email` 與 `username` 新的 `String`，這樣 `user1` 會用到的數值只會有 `active` 和 `sign_in_count`，這樣 `user1` 在 `user2` 就仍會有效。因為 `active` 和 `sign_in_count` 的型別都有實作 `Copy` 特徵。

### 使用無名稱欄位的元組結構體來建立不同型別

Rust 還支援定義結構體讓它長得像是元組那樣，我們稱作元組結構體（tuple structs）。元組結構體仍然有定義整個結構的名稱，但是它們的欄位不會有名稱，它們只會有欄位型別而已。元組結構體的用途在於，當想要為元組命名，好讓它跟其他不同型別的元組作出區別，以及對常規結構體每個欄位命名是冗長且不必要的時候。

```RS
struct Color(i32, i32, i32);
struct Point(i32, i32, i32);

fn main() {
    let black = Color(0, 0, 0);
    let origin = Point(0, 0, 0);
}
```

### 無任何欄位的類單元結構體

也可以定義沒有任何欄位的結構體，這些叫做類單元結構體（unit-like structs），因為它們的行為就很像單元型別（unit type）。類單元結構體很適合用在當要實作一個特徵（trait）或某種型別，但卻沒有任何需要儲存在型別中的資料。

```RS
struct AlwaysEqual;

fn main() {
    let subject = AlwaysEqual;
}
```

我們可以針對 `AlwaysEqual` 的實例實作與其他型別實例相同的行爲，像是爲了測試回傳已知的結果。我們不需要任何資料就能實作該行爲。

## 結構體的所有權

以上範例，我們使用了擁有所有權的 `String` 型別，而不是 `&str` 字串切片型別。這是故意的，因為我們希望每個結構體的實例可以擁有它所有的資料，並在整個結構體都有效時資料也是有效的。

要在結構體中儲存別人擁有的資料引用是可行的，但這會用到生命週期（lifetimes）。生命週期能確保資料引用在結構體存在期間都是有效的。要是沒有使用生命週期來用結構體儲存引用的話，會出現錯誤。

```RS
struct User {
    active: bool,
    username: &str,
    email: &str,
    sign_in_count: u64,
}

fn main() {
    let user1 = User {
        email: "someone@example.com",
        username: "someusername123",
        active: true,
        sign_in_count: 1,
    };
}
```

編譯器會抱怨它需要生命週期標記：

```BASH
help: consider introducing a named lifetime parameter
```

後面的章節，將會討論如何修正這樣的錯誤，好讓我們可以在結構體中儲存引用。但現在的話，先用有所有權的 `String` 而非 `&str` 引用來避免錯誤。

## 結構體的程式範例

為了瞭解我們何時會想要使用結構體，讓我們來寫一支計算長方形面積的程式。我們會先從單一變數開始，再慢慢重構成使用結構體。

```RS
fn main() {
    let width1 = 30;
    let height1 = 50;

    println!(
        "長方形的面積為 {} 平方像素。",
        area(width1, height1)
    );
}

fn area(width: u32, height: u32) -> u32 {
    width * height
}
```

`area` 函式應該要計算長方形的面積，但是我們寫的函式有兩個參數，但在我們得程式中參數的相關性卻沒有表達出來。

### 使用元組重構

一方面來說，元組讓我們增加了一些結構，而我們現在只需要傳遞一個引數。但另一方面來說，此版本的閱讀性反而更差。元組無法命名它的元素，所以我們需要索引部分元組，讓我們的計算變得比較不清晰。

```RS
fn main() {
    let rect1 = (30, 50);

    println!(
        "長方形的面積為 {} 平方像素。",
        area(rect1)
    );
}

fn area(dimensions: (u32, u32)) -> u32 {
    dimensions.0 * dimensions.1
}
```

### 使用結構體重構：賦予更多意義

我們在此定義了一個結構體叫做 `Rectangle`。在大括號內，我們定義了 `width` 與 `height` 的欄位，兩者型別皆為 `u32`。然後在 `main` 中，我們建立了一個 `Rectangle` 實例。

現在我們的 `area` 函式使需要一個參數 `rectangle`，其型別為 `Rectangle` 結構體實例的不可變借用。如同前面提到的，我們希望借用結構體而非取走其所有權。這樣一來，`main` 能保留它的所有權並讓 `rect1` 繼續使用，這也是為何我們要在要呼叫函式的簽名中使用 `&` 符號。

```RS
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!(
        "長方形的面積為 {} 平方像素。",
        area(&rect1)
    );
}

fn area(rectangle: &Rectangle) -> u32 {
    rectangle.width * rectangle.height
}
```

### 使用推導特徵實現更多功能

要是能夠在我們除錯程式時能夠印出 `Rectangle` 的實例並看到它所有的欄位數值就更好了。但是使用我們之前章節提到的 `println!` 巨集，但是卻無法執行。

```RS
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!("rect1 is {}", rect1);
}
```

Rust 的確有印出除錯資訊的功能，但是我們要針對我們的結構體顯式實作出來才會有對應的功能。為此我們可以在結構體前加上 `#[derive(Debug)]` 屬性（attribute）。

```RS
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!("rect1 is {:?}", rect1);
}
```

另一種使用 `Debug` 格式印出數值的方式是使用 `dbg!` 巨集 。這會拿走一個表達式的所有權，印出該 `dbg!` 巨集在程式碼中呼叫的檔案與行數，以及該表達式的數值結果，最後回傳該數值的所有權。

我們在表達式 `30 * scale` 加上 `dbg!`，因爲 `dbg!` 會回傳表達式的數值所有權， `width` 將能取得和如果我們不加上 `dbg!` 時相同的數值。而我們不希望 `dbg!` 取走 `rect1` 的所有權，所以我們在下一個 `rect1` 的呼叫使用引用。

```RS
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let scale = 2;
    let rect1 = Rectangle {
        width: dbg!(30 * scale),
        height: 50,
    };

    dbg!(&rect1);
}
```

我們的函式 `area` 最後就非常清楚明白了，它只會計算長方形的面積。這樣的行為要是能夠緊貼著我們的 Rectangle 結構體，因為這樣一來它就不會相容於其他型別。

除了 `Debug` 特徵之外，Rust 還提供了一些特徵能讓我們透過 `derive` 屬性來使用並爲我們的自訂型別擴增實用的行爲。

## 方法語法

方法（Methods）和函式類似，我們用 `fn` 關鍵字並加上它們名稱來宣告，它們都有參數與回傳值，然後它們包含一些程式碼能夠在其他地方呼叫方法。和函式不同的是，方法是針對結構體定義的（或是枚舉和特徵物件），且它們第一個參數永遠是 `self`，這代表的是呼叫該方法的結構體實例。

### 定義方法

我們把 `Rectangle` 作為參數的 `area` 函式轉換成定義在 `Rectangle` 內的 `area` 方法。要定義 `Rectangle` 中的方法，我們先為 `Rectangle` 加個 `impl`（implementation） 區塊來開始。所有在此區塊的內容都跟 `Rectangle` 型別有關。

```RS
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!(
        "長方形的面積為 {} 平方像素。",
        rect1.area()
    );
}
```

在 `area` 的簽名中，我們使用 `&self` 而非 `rectangle: &Rectangle`。`&self` 是 `self: &Self` 的簡寫。在一個 `impl` 區塊內，`Self` 型別是該 `impl` 區塊要實作型別的別名。方法必須有個叫做 `self` 的 `Self` 型別作為它們的第一個參數，所以 Rust 讓我們在寫第一個參數時能直接簡寫成 `self`。注意到我們在 `self` 縮寫的前面仍使用 `&` 符號，已表示此方法是借用 `Self` 的實例，就像我們在 `rectangle: &Rectangle` 做的一樣。就和其他參數一樣，方法可以選擇拿走 `self` 的所有權，像我們這裡借用不可變的 `self` 或是借用可變的 `self`。

我們之所以選擇 `&self` 的原因和我們在之前函式版本的 `&Rectangle` 一樣，我們不想取得所有權，只想讀取結構體的資料，而非寫入它。如果我們想要透過方法改變實例的數值的話，我們會使用 `&mut self` 作為第一個參數。而只使用 `self` 取得所有權的方法更是非常少見，這種使用技巧通常是為了想改變 `self` 成我們想要的樣子，並且希望能避免原本被改變的實例繼續被呼叫。

### 擁有更多參數的方法

練習實作另一個 `Rectangle` 的方法。這次我們要 `Rectangle` 的實例可以接收另一個 `Rectangle` 實例，要是 `self` 本身（第一個 `Rectangle`）可以包含另一個 `Rectangle` 的話我們就回傳 `true`，不然的話就回傳 `false`。也就是我們希望定一個方法 `can_hold`，如下所示。

方法可以在參數 `self` 之後接收更多參數，而那些參數就和函式中的參數用法一樣。

```RS
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }

    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };
    let rect2 = Rectangle {
        width: 10,
        height: 40,
    };
    let rect3 = Rectangle {
        width: 60,
        height: 45,
    };

    println!("rect1 能容納 rect2 嗎？{}", rect1.can_hold(&rect2));
    println!("rect1 能容納 rect3 嗎？{}", rect1.can_hold(&rect3));
}
```

### 關聯函式

所有在 `impl` 區塊內的方法都屬於關聯函式（associated functions），因為它們都與 `impl` 實作的型別相關。要是有方法不需要自己的型別實例的話，我們可以定義個沒有 `self` 作為它們第一個參數的關聯函式（因此不會被稱作方法）。我們已經在 `String` 型別使用過 `String::from` 這種關聯函式了。

不屬於方法的關聯函式很常用作建構子，來產生新的結構體實例。舉例來說，我們可以提供一個只接收一個維度作為參數的關聯函式，讓它賦值給寬度與長度，讓我們可以用 `Rectangle` 來產生正方形，而不必提供兩次相同的值。

```RS
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

impl Rectangle {
    fn square(size: u32) -> Rectangle {
        Rectangle {
            width: size,
            height: size,
        }
    }
}

fn main() {
    let sq = Rectangle::square(3);

    println!("{:?}", sq);
}
```

### 多重 impl 區塊

每個結構體都允許有數個 `impl` 區塊。不過這邊我們的確沒有將方法拆為 `impl` 區塊的理由，不過這樣的語法是合理的。我們會在後面介紹泛型型別與特徵，看到多重 `impl` 區塊是非常實用的案例。

```RS
impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }
}

impl Rectangle {
    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
}
```

使用結構體的話，可以讓每個資料部分與其他部分具有相關性，並為每個部分讓程式更好讀懂。在 `impl` 區塊中，可以定義與我們的型別有關的函式，而方法就是其中一種關聯函式，能讓我們指定結構體能有何種行為。

## 參考資料

- [The Rust Programming Language](https://doc.rust-lang.org/stable/book/)
