---
title: 「The Rust Programming Language」學習筆記（三）：基礎語法
permalink: 「The-Rust-Programming-Language」學習筆記（三）：基礎語法
date: 2022-04-19 21:09:25
tags: ["程式設計", "Rust"]
categories: ["程式設計", "Rust", "「The Rust Programming Language」學習筆記"]
---

## 前言

本文為「[The Rust Programming Language](https://doc.rust-lang.org/stable/book/)」語言指南的學習筆記。

## 變數與可變性

### 變數

執行以下程式，會收到一則錯誤訊息。

```RS
fn main() {
    let x = 5;
    println!("x 的數值為：{}", x);
    x = 6;
    println!("x 的數值為：{}", x);
}
```

可以在變數名稱前面加上 `mut` 讓它們可以成為可變的，加上 `mut` 也向未來的讀取者表明了其他部分的程式碼將會改變此變數的數值。

```RS
fn main() {
    let mut x = 5;
    println!("x 的數值為：{}", x);
    x = 6;
    println!("x 的數值為：{}", x);
}
```

執行後，會得到以下訊息。

```RS
cargo run
   Compiling hello_cargo v0.1.0 (/Users/memochou/Projects/hello_cargo)
    Finished dev [unoptimized + debuginfo] target(s) in 0.93s
     Running `target/debug/hello_cargo`
x 的數值為：5
x 的數值為：6
```

### 常數

常數（constants）和不可變變數一樣，常數會讓數值與名稱綁定且不允許被改變，但是不可變變數與常數還是有些差異。

常數可以被定義在任一有效範圍，包含全域有效範圍。這讓它們非常有用，讓許多部分的程式碼都能夠知道它們。

最後一個差別是常數只能被常數表達式設置，不能用任一在運行時產生的其他數值設置。

```RS
const THREE_HOURS_IN_SECONDS: u32 = 60 * 60 * 3;
```

Rust 的常數命名規則為使用全部英文大寫並用底寫區隔每個單字。

### 遮蔽（Shadowing）

我們可以用 `let` 關鍵字來重複宣告相同的變數名稱來遮蔽一個變數。

```RS
fn main() {
    let x = 5;

    let x = x + 1;

    {
        let x = x * 2;
        println!("x 在內部範圍的數值為：{}", x);
    }

    println!("x 的數值為：{}", x);
}
```

執行後，會得到以下訊息。

```BASH
cargo run
   Compiling variables v0.1.0 (file:///projects/variables)
    Finished dev [unoptimized + debuginfo] target(s) in 0.31s
     Running `target/debug/variables`
x 在內部範圍的數值為：12
x 的數值為：6
```

遮蔽與標記變數為 `mut` 是不一樣的，因為如果我們不小心重新賦值而沒有加上 `let` 關鍵字的話，是會產生編譯期錯誤的。使用 `let` 的話，我們可以作出一些改變，然後在這之後該變數仍然是不可變的。

另一個 `mut` 與遮蔽不同的地方是，我們能有效地再次運用 `let` 產生新的變數，可以在重新運用相同名稱時改變它的型別。

```RS
let spaces = "   ";
let spaces = spaces.len();
```

不過，可變變數仍然是無法變更變數型別的，如果這樣做的話我們就會拿到編譯期錯誤。

```RS
let mut spaces = "   ";
spaces = spaces.len();
```

執行後，會得到以下訊息。

```BASH
cargo run
   Compiling hello_cargo v0.1.0 (/Users/memochou/Projects/hello_cargo)
error[E0308]: mismatched types
 --> src/main.rs:3:14
  |
2 |     let mut spaces = "   ";
  |                      ----- expected due to this value
3 |     spaces = spaces.len();
  |              ^^^^^^^^^^^^ expected `&str`, found `usize`
```

## 資料型別

### 整數型別

整數是沒有小數點的數字。在第二章用到了一個整數型別 `u32`，此型別表示其擁有的數值應該是一個佔 32 位元大小的非帶號整數（帶號整數的話則是用 `i` 起頭而非 `u`）。

每一帶號變體可以儲存的數字範圍包含從 `-(2^n - 1)` 到 `2^n - 1 - 1` 以內的數字，`n` 就是該變體佔用的位元大小。所以一個 `i8` 可以儲存的數字範圍就是從 `-(2^7)` 到 `2^7 - 1`，也就是 -128 到 127。而非帶號可以儲存的數字範圍則是從 `0` 到 `2^n - 1`，所以 `u8` 可以儲存的範圍是從 `0` 到 `2^8 - 1`，也就是 0 到 255。

### 浮點數型別

Rust 還有針對有小數點的浮點數提供兩種基本型別：`f32` 和 `f64`，分別佔有 32 位元與 64 位元的大小。而預設的型別為 `f64`，因為現代的電腦處理的速度幾乎和 `f32` 一樣卻還能擁有更高的精準度。所有的浮點數型別都是帶號的（signed）。

```RS
fn main() {
    let x = 2.0; // f64

    let y: f32 = 3.0; // f32
}
```

### 數值運算

Rust 支援所有想得到的數值型別基本運算：加法、減法、乘法、除法和取餘。整數除法會取最接進的下界數值。

```RS
fn main() {
    // 加法
    let sum = 5 + 10;

    // 減法
    let difference = 95.5 - 4.3;

    // 乘法
    let product = 4 * 30;

    // 除法
    let quotient = 56.7 / 32.2;
    let floored = 2 / 3; // 結果爲 0

    // 取餘
    let remainder = 43 % 5;
}
```

### 布林型別

Rust 中的布林型別有兩個可能的值：`true` 和 `false`。布林值的大小為一個位元組。

```RS
fn main() {
    let t = true;

    let f: bool = false; // 型別詮釋的方式
}
```

### 字元型別

Rust 的 char 型別是最基本的字母型別。

```RS
fn main() {
    let c = 'z';
    let z = 'ℤ';
    let heart_eyed_cat = '😻';
}
```

注意到 `char` 字面值是用單引號賦值，宣告字串字面值時才是用雙引號。Rust 的 `char` 型別大小為四個位元組並表示為一個 Unicode 純量數值，這代表它能擁有的字元比 ASCII 還來的多。舉凡標音字母（Accented letters）、中文、日文、韓文、表情符號以及零長度空格都是 `char` 的有效字元。

### 元組型別

元組是個將許多不同型別的數值合成一個複合型別的常見方法。元組擁有固定長度：一旦宣告好後，它們就無法增長或縮減。

建立一個元組的方法是寫一個用括號囊括起來的數值列表，每個值再用逗號分隔開來。元組的每一格都是一個獨立型別，不同數值不必是相同型別。

```RS
fn main() {
    let tup: (i32, f64, u8) = (500, 6.4, 1);
}
```

此變數 `tup` 就是整個元組，因為一個元組就被視為單一複合元素。要拿到元組中的每個獨立數值的話，我們可以用模式配對（pattern matching）來解構一個元組的數值。

```RS
fn main() {
    let tup = (500, 6.4, 1);

    let (x, y, z) = tup;

    println!("y 的數值為：{}", y);
}
```

也可以直接用句號（`.`）再加上數值的索引來取得元組內的元素。

```RS
fn main() {
    let x: (i32, f64, u8) = (500, 6.4, 1);

    let five_hundred = x.0;

    let six_point_four = x.1;

    let one = x.2;
}
```

和多數程式語言一樣，元組的第一個索引是 0。

沒有任何數值的元組 `()` 會是個只有一種數值的特殊型別，其值也寫作 `()`。此型別稱爲「單元型別」而其數值稱爲「單元數值」。

### 陣列型別

和元組不一樣的是，陣列中的每個型別必須是一樣的。和其他語言的陣列不同，Rust 的陣列是固定長度的。

```RS
fn main() {
    let a = [1, 2, 3, 4, 5];
}
```

如果希望資料被分配在堆疊（stack）而不是堆積（heap）的話，使用陣列是很好的選擇（在第四章會討論堆疊與堆積的內容）。

如果知道元素的多寡不會變的話，陣列就是個不錯的選擇。

```RS
let months = ["一月", "二月", "三月", "四月", "五月", "六月", "七月",
              "八月", "九月", "十月", "十一月", "十二月"];
```

要詮釋陣列型別的話，可以在中括號寫出型別和元素個數，並用分號區隔開來。

```RS
let a: [i32; 5] = [1, 2, 3, 4, 5];
```

如果想建立的陣列中每個元素數值都一樣的話，可以指定一個數值後加上分號，最後寫出元素個數。

```RS
let a = [3; 5]; // 和 let a = [3, 3, 3, 3, 3]; 一樣
```

一個陣列是被分配在堆疊上且已知固定大小的一整塊記憶體，可以使用索引來取得陣列的元素。

```RS
fn main() {
    let a = [1, 2, 3, 4, 5];

    let first = a[0];
    let second = a[1];
}
```

## 函式

Rust 程式碼使用 snake case 式作為函式與變數名稱的慣例風格。所有的字母都是小寫，並用底線區隔單字。

```RS
fn main() {
    println!("Hello, world!");

    another_function();
}

fn another_function() {
    println!("另一支函式。");
}
```

### 參數

可以定義函式成擁有參數（parameters）的，這是函式簽名（signatures）中特殊的變數。當函式有參數時，可以提供那些參數的確切數值。嚴格上來說，傳遞的數值會叫做引數（arguments）。

```RS
fn main() {
    another_function(5);
}

fn another_function(x: i32) {
    println!("x 的數值為：{}", x);
}
```

### 陳述式與表達式

函式本體是由一系列的陳述式（statements）並在最後可以選擇加上表達式（expression）來組成。Rust 是門基於表達式（expression-based）的語言。陳述式（statements）是進行一些動作的指令，且不回傳任何數值。表達式（expressions）則是計算並產生數值。

```RS
fn main() {
    let x = 5;

    let y = {
        let x = 3;
        x + 1
    };

    println!("y 的數值為：{}", y);
}
```

注意到 `x + 1` 這行沒有加上分號，因為表達式結尾不會加上分號。如果在此表達式加上分號的話，它就不會回傳數值。

### 函式回傳值

函式可以回傳數值給呼叫它們的程式碼，我們不會為回傳值命名，但我們必須用箭頭（`->`）來宣告它們的型別。在 Rust 中，回傳值其實就是函式本體最後一行的表達式。可以用 return 關鍵字加上一個數值來提早回傳函式，但多數函式都能用最後一行的表達式作為數值回傳。

```RS
fn five() -> i32 {
    5
}

fn main() {
    let x = five();

    println!("x 的數值為：{}", x);
}
```

## 註解

這是一個簡單的註解。

```RS
// 安安，你好
```

經常看到以下格式，註解會位於要說明的程式碼上一行。

```RS
fn main() {
    // 幸運 777！
    let lucky_number = 7;
}
```

## 控制流程

### if 表達式

`if` 能依照條件判斷對程式碼產生分支。

```RS
fn main() {
    let number = 3;

    if number < 5 {
        println!("條件為真");
    } else {
        println!("條件為否");
    }
}
```

值得注意的是程式碼的條件判斷必須是 `bool`。如果條件不是 `bool` 的話，我們就會遇到錯誤。

### else if 表達式

想要實現多重條件的話，可以將 `if` 和 `else` 組合成 `else if` 表達式。

```RS
fn main() {
    let number = 6;

    if number % 4 == 0 {
        println!("數字可以被 4 整除");
    } else if number % 3 == 0 {
        println!("數字可以被 3 整除");
    } else if number % 2 == 0 {
        println!("數字可以被 2 整除");
    } else {
        println!("數字無法被 4、3、2 整除");
    }
}
```

### 在 let 陳述式中使用 if 表達式

因為 `if` 是表達式，所以可以像這樣放在 `let` 陳述式的右邊，將結果賦值給變數。

```RS
fn main() {
    let condition = true;
    let number = if condition { 5 } else { 6 };

    println!("數字結果為：{}", number);
}
```

### 使用迴圈重複執行

#### 使用 loop 重複執行程式碼

`loop` 關鍵字告訴 Rust 去反覆不停地執行一段程式碼直到你親自告訴它要停下來。

```RS
fn main() {
    loop {
        println!("再一次！");
    }
}
```

如果有迴圈在迴圈之內的話，`break` 和 `continue` 會用在該位置最內層的迴圈中。可以選擇在迴圈使用「迴圈標籤」（loop label），然後使用 `break` 和 `continue` 加上那些迴圈標籤定義的關鍵字，而不是作用在最內層迴圈而已。

```RS
fn main() {
    let mut count = 0;
    'counting_up: loop {
        println!("count = {}", count);
        let mut remaining = 10;

        loop {
            println!("remaining = {}", remaining);
            if remaining == 9 {
                break;
            }
            if count == 2 {
                break 'counting_up;
            }
            remaining -= 1;
        }

        count += 1;
    }
    println!("End count = {}", count);
}
```

其中一種使用 `loop` 的用途是重試某些可能覺得會失敗的動作，像是檢查一個執行緒是否已經完成其任務。這樣可能就會想傳遞任務結果給之後的程式碼。

```RS
fn main() {
    let mut counter = 0;

    let result = loop {
        counter += 1;

        if counter == 10 {
            break counter * 2;
        }
    };

    println!("結果為：{}", result);
}
```

#### 使用 while 做條件迴圈

在程式中用條件判斷迴圈的執行通常是很有用的。當條件為真時，迴圈就繼續執行。當條件不再符合時，程式就用 break 停止迴圈。這樣的循環行為可以用 `loop`、`if`、`else` 和 `break` 組合出來。但是這種模式非常常見，所以 Rust 有提供內建的結構稱為 `while` 迴圈。

```RS
fn main() {
    let mut number = 3;

    while number != 0 {
        println!("{}!", number);

        number -= 1;
    }

    println!("升空！！！");
}
```

#### 使用 for 遍歷集合

可以使用 `for` 迴圈來對集合的每個元素執行一些程式碼。

```RS
fn main() {
    let a = [10, 20, 30, 40, 50];

    for element in a {
        println!("數值為：{}", element);
    }
}
```

`for` 迴圈的安全性與簡潔程度讓它成為 Rust 最常被使用的迴圈結構。就算你想執行的是依照次數循環的程式碼，多數 Rustaceans 還是會選擇 `for` 迴圈。要這麼做的方法是使用 `Range`，這是標準函式庫提供的型別，用來產生一連串的數字序列，從指定一個數字開始一直到另一個數字之前結束。

```RS
fn main() {
    for number in (1..4).rev() {
        println!("{}!", number);
    }
    println!("升空！！！");
}
```

## 參考資料

- [The Rust Programming Language](https://doc.rust-lang.org/stable/book/)
