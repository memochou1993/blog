---
title: 「The Rust Programming Language」學習筆記（六）：枚舉與模式配對
date: 2022-06-05 20:35:58
tags: ["程式設計", "Rust"]
categories: ["程式設計", "Rust", "「The Rust Programming Language」學習筆記"]
---

## 前言

本文為「[The Rust Programming Language](https://doc.rust-lang.org/stable/book/)」語言指南的學習筆記。

## 枚舉

枚舉是有別於結構體，另一種定義自訂資料型別的方式。

假設我們要使用 IP 位址，而且現在有兩個主要的標準能使用：IPv4 與 IPv6。我們可以枚舉（enumerate）出所有可能的變體，這正是枚舉的由來。

```rs
enum IpAddrKind {
    V4,
    V6,
}
```

### 枚舉數值

注意變體會位於枚舉命名空間底下，所以可以用兩個冒號來標示。這樣的好處在於 `IpAddrKind::V4` 和 `IpAddrKind::V6` 都是同型別 `IpAddrKind`。

```rs
let four = IpAddrKind::V4;
let six = IpAddrKind::V6;
```

比方說，我們就可以定義一個接收任 `IpAddrKind` 的函式。

```rs
fn route(ip_kind: IpAddrKind) {}
```

然後可以用任意變體呼叫此函式。

```rs
route(IpAddrKind::V4);
route(IpAddrKind::V6);
```

使用枚舉還有更多好處。這裡定義了一個有兩個欄位的 `IpAddr` 結構體，欄位 `kind` 擁有 `IpAddrKind`。我們用結構體來組織 `kind` 和 `address` 的值在一起，讓變體可以與數值相關。

```rs
enum IpAddrKind {
    V4,
    V6,
}

struct IpAddr {
    kind: IpAddrKind,
    address: String,
}

let home = IpAddr {
    kind: IpAddrKind::V4,
    address: String::from("127.0.0.1"),
};

let loopback = IpAddr {
    kind: IpAddrKind::V6,
    address: String::from("::1"),
};
```

可以用另一種更簡潔的方式來定義枚舉，而不必使用結構體加上枚舉。枚舉內的每個變體其實都能擁有數值。以下方式讓 `IpAddr` 的 `V4` 與 `V6` 都能擁有與其相關的 `String` 數值。另一項枚舉的細節：每一個枚舉變體會變成建構該枚舉的函式。也就是說 `IpAddr::V4()` 是個函式，且接收 `String` 引數並回傳 `IpAddr` 的實例。在定義枚舉時就會自動拿到這樣的建構函式。

```rs
enum IpAddr {
    V4(String),
    V6(String),
}

let home = IpAddr::V4(String::from("127.0.0.1"));

let loopback = IpAddr::V6(String::from("::1"));
```

使用枚舉而非結構體的話還有另一項好處：每個變體可以擁有不同型別與資料的數量。第四版的 IP 位址永遠只會有四個 `0` 到 `255` 的數字部分，如果我們想要讓 `V4` 儲存四個 `u8`，但 `V6` 位址仍保持 `String` 不變的話，我們在結構體是無法做到的。

```rs
enum IpAddr {
    V4(u8, u8, u8, u8),
    V6(String),
}

let home = IpAddr::V4(127, 0, 0, 1);

let loopback = IpAddr::V6(String::from("::1"));
```

以上展示了許多種定義儲存第四版與第六版 IP 位址資料結構的方式，不過需要儲存 IP 位址並編碼成不同類型的案例實在太常見了，所以標準函式庫已經幫我們定義好了。

```rs
struct Ipv4Addr {
    // ...
}

struct Ipv6Addr {
    // ...
}

enum IpAddr {
    V4(Ipv4Addr),
    V6(Ipv6Addr),
}
```

再看另一個枚舉範例，這次的變體有各式各樣的型別。

```rs
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}
```

此枚舉有四個不同型別的變體：

- `Quit`：沒有包含任何資料。
- `Move`：包含了和結構體一樣的名稱欄位。
- `Write`：包含了一個 `String`。
- `ChangeColor`：包含了三個 `i32`。

這樣定義枚舉變體和定義不同類型的結構體很像，只不過枚舉不使用 `struct` 關鍵字，而且所有的變體都會在 `Message` 型別底下。但是如果我們使用不同結構體且各自都有自己的型別的話，我們就無法將 `Message` 視為單一型別，輕鬆在定義函式時接收訊息所有可能的類型。

```rs
struct QuitMessage; // 類單元結構體
struct MoveMessage {
    x: i32,
    y: i32,
}
struct WriteMessage(String); // 元組結構體
struct ChangeColorMessage(i32, i32, i32); // 元組結構體
```

枚舉和結構體還有一個地方很像：如同我們可以對結構體使用 `impl` 定義方法，我們也可以對枚舉定義方法。

```rs
impl Message {
    fn call(&self) {
        // 在此定義方法本體
    }
}

let m = Message::Write(String::from("hello"));
m.call();
```

### Option 枚舉相對於空值的優勢

`Option` 是在標準函式庫中定義的另一種枚舉。`Option` 能表示一個數值可能有某個東西，或者什麼都沒有。

Rust 沒有像其他許多語言都有空值，但是它有一個枚舉可以表達出這樣的概念，也就是一個值可能是存在或不存在的。此枚舉就是 `Option<T>`，它是在標準函式庫中這樣定義的：

```rs
enum Option<T> {
    None,
    Some(T),
}
```

`Option<T>` 實在太實用了，所以它早已加進 prelude 中，不需要特地匯入作用域中。它的變體一樣也被加進 prelude 中，可以直接使用 `Some` 和 `None` 而不必加上 `Option::` 的前綴。

語法 `<T>` 是個泛型型別參數，指的是 `Option` 枚舉中的 `Some` 變體可以是任意型別。而透過 `Option` 數值來持有數字型別和字串型別的話，它們最終會換掉 `Option<T>` 中的 `T`，成為不同的型別。

```rs
let some_number = Some(5);
let some_string = Some("一個字串");

let absent_number: Option<i32> = None;
```

因為 `Option<T>` 與 `T`（`T` 可以是任意型別）是不同的型別，編譯器不會允許我們像一般有效的值那樣來使用 `Option<T>`。舉例來說，以下範例是無法編譯的，因為這是將 `i8` 與 `Option<i8>` 相加。

```rs
let x: i8 = 5;
let y: Option<i8> = Some(5);

let sum = x + y;
```

會得到以下錯誤訊息：

```bash
$ cargo run
   Compiling enums v0.1.0 (file:///projects/enums)
error[E0277]: cannot add `Option<i8>` to `i8`
```

此錯誤訊息指的是 Rust 不知道如何將 `i8` 與 `Option<i8>` 相加，因為它們是不同的型別。當我們在 Rust 中有個型別像是 `i8`，編譯器將會確保我們永遠會擁有有效數值，而不必檢查是不是空的。我們只有在使用 `Option<i8>`（或者任何其他要使用的型別）時才需要去擔心會不會沒有值。

要讓一個值變成可能為空的話，必須顯式建立成對應型別的 `Option<T>`。然後當要使用該值時，就得顯式處理數值是否為空的條件。只要一個數值的型別不是 `Option<T>`，就可以安全地認定該值不為空。這是 Rust 刻意考慮的設計決定，限制無所不在的空值，並增強 Rust 程式碼的安全性。

## match 語法

Rust 有個功能非常強大的控制流建構子叫做 `match`，我們可以使用一系列模式來配對數值並依據配對到的模式來執行對應的程式。模式（Patterns）可以是字面數值、變數名稱、通配符（wildcards）和其他更多元件來組成。

可以想像 `match` 表達式成一個硬幣分類機器：硬幣會滑到不同大小的軌道，然後每個硬幣會滑入第一個符合大小的軌道。數值會依序遍歷 `match` 的每個模式，然後進入第一個「配對」到該數值的模式所在的程式碼區塊，並在執行過程中使用。

```rs
enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter,
}

fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter => 25,
    }
}
```

如果想要在配對分支執行多行程式碼的話，就必須用大括號。

```rs
fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => {
            println!("幸運幣！");
            1
        }
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter => 25,
    }
}
```

### 綁定數值的模式

另一項配對分支的實用功能是它們可以綁定配對模式中部分的數值，這讓我們可以取出枚舉變體中的數值。

舉例來說，讓我們改變其中一個枚舉變體成擁有資料。從 1999 年到 2008 年，美國在鑄造 25 美分硬幣時，其中一側會有 50 個州不同的設計。不過其他的硬幣就沒有這樣的設計，只有 25 美分會有特殊值而已。我們可以改變我們的 `enum` 中的 `Quarter` 變體成儲存 `UsState` 數值。

```rs
#[derive(Debug)] // 這讓我們可以顯示每個州
enum UsState {
    Alabama,
    Alaska,
    // ...
}

enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(UsState),
}
```

讓我們想像有一個朋友想要收集所有 50 州的 25 美分硬幣。當我們在排序零錢的同時，我們會在拿到 25 美分時喊出該硬幣對應的州，好讓我們的朋友知道，如果他沒有的話就可以納入收藏。

在此程式中的配對表達式中，我們在 `Coin::Quarter` 變體的配對模式中新增了一個變數 `state`。當 `Coin::Quarter` 配對符合時，變數 `state` 會綁定該 25 美分的數值，然後我們就可以在分支程式碼中使用 `state`。

```rs
fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter(state) => {
            println!("此 25 美分所屬的州為 {:?}!", state);
            25
        }
    }
}
```

如果我們呼叫 `value_in_cents(Coin::Quarter(UsState::Alaska))` 的話，`coin` 就會是 `Coin::Quarter(UsState::Alaska)`。當我們比較每個配對分支時，我們會到 `Coin::Quarter(state)` 的分支才配對成功。

### 配對 Option<T>

我們想要在使用 `Option<T>` 時取得 `Some` 內部的 `T` 值。如同枚舉 `Coin`，我們一樣可以使用 `match` 來處理 `Option<T>`。相對於比較硬幣，我們要比較的是 `Option<T>` 的變體，不過 `match` 表達式運作的方式一模一樣。

假設我們要寫個接受 `Option<i32>` 的函式，而且如果內部有值的話就將其加上 `1`。如果內部沒有數值的話，該函式就回傳 `None` 且不再嘗試做任何動作。

```rs
fn plus_one(x: Option<i32>) -> Option<i32> {
    match x {
        None => None,
        Some(i) => Some(i + 1),
    }
}

let five = Some(5);
let six = plus_one(five);
let none = plus_one(None);
```

### 配對必須是徹底的

要是像這樣寫了一個有錯誤的 `plus_one` 函式版本，它會無法編譯：

```rs
fn plus_one(x: Option<i32>) -> Option<i32> {
    match x {
        Some(i) => Some(i + 1),
    }
}
```

因為我們沒有處理到 `None` 的情形，所以此程式碼會產生錯誤。幸運的是這是 Rust 能夠抓到的錯誤。當 Rust 防止我們忘記處理 `None` 的情形時，它使我們免於以為擁有一個有效實際上卻是空的值。

```bash
$ cargo run
   Compiling enums v0.1.0 (file:///projects/enums)
error[E0004]: non-exhaustive patterns: `None` not covered
```

### Catch-all 模式與 `_` 佔位符

使用枚舉的話，我們可以針對特定數值做特別的動作，而對其他所有數值採取預設動作。

此程式碼就算我們沒有列完所有 `u8` 可能的數字也能編譯完成，因為最後的模式會配對所有尚未被列出來的數值。最後一個涵蓋其他可能數值的分支，我們用變數 `other` 作為模式。在 `other` 分支執行的程式碼會將該變數傳入函式 `move_player` 中。

```rs
fn main() {
    let dice_roll = 9;
    match dice_roll {
        3 => add_fancy_hat(),
        7 => remove_fancy_hat(),
        other => move_player(other),
    }

    fn add_fancy_hat() {}
    fn remove_fancy_hat() {}
    fn move_player(num_spaces: u8) {}
}
```

當我們不想使用 catch-all 模式中的數值時，Rust 還有一種模式能讓我們使用：`_` 這是個特殊模式，用來配對任意數值且不綁定該數值。

```rs
let dice_roll = 9;
match dice_roll {
    3 => add_fancy_hat(),
    7 => remove_fancy_hat(),
    _ => reroll(),
}

fn add_fancy_hat() {}
fn remove_fancy_hat() {}
fn reroll() {}
```

如果我們再改一次遊戲規則，改成如果我們骰到除了 3 與 7 以外，不會有任何事發生的話，我們可以用單元數值作為 `_` 的程式碼：

```rs
let dice_roll = 9;
match dice_roll {
    3 => add_fancy_hat(),
    7 => remove_fancy_hat(),
    _ => (),
}

fn add_fancy_hat() {}
fn remove_fancy_hat() {}
```

## if let 語法

使用 `if let` 語法讓我們可以用 `if` 與 `let` 的組合來以比較不冗長的方式，處理只在乎其中一種模式而忽略其餘的數值。

現在考慮一支程式如下所示，我們在配對 `config_max` 中 `Option<u8>` 的值，但只想在數值為 `Some` 變體時執行程式。我們必須在只處理一種變體的分支後面，再加上 `_ => ()`，這樣就加了不少樣板程式碼。

```rs
let config_max = Some(3u8);
match config_max {
    Some(max) => println!("最大值被設為 {}", max),
    _ => (),
}
```

我們可以使用 `if let` 以更精簡的方式寫出來。

```rs
let config_max = Some(3u8);
if let Some(max) = config_max {
    println!("最大值被設為 {}", max);
}
```

使用 `if let` 可以少打些字、減少縮排以及不用寫多餘的樣板程式碼。不過就少了 `match` 強制的徹底窮舉檢查。要何時選擇 `match` 還是 `if let` 得依據場合，以及在精簡度與徹底檢查之間做取捨。

換句話說，可以想像 `if let` 是 `match` 的語法糖（syntax sugar），它只會配對一種模式來執行程式碼並忽略其他數值。

## 參考資料

- [The Rust Programming Language](https://doc.rust-lang.org/stable/book/)
