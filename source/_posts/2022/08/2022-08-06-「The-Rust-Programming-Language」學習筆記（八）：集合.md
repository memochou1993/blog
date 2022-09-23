---
title: 「The Rust Programming Language」學習筆記（八）：集合
permalink: 「The-Rust-Programming-Language」學習筆記（八）：集合
date: 2022-08-06 22:45:36
tags: ["程式設計", "Rust"]
categories: ["程式設計", "Rust", "「The Rust Programming Language」學習筆記"]
---

## 前言

本文為「[The Rust Programming Language](https://doc.rust-lang.org/stable/book/)」語言指南的學習筆記。

## 簡介

Rust 的標準函式庫提供一些非常實用的資料結構稱之為集合（collections）。多數其他資料型別只會呈現一個特定數值，但是集合可以包含數個數值。不像內建的陣列與元組型別，這些集合指向的資料位於堆積上，代表資料的數量不必在編譯期就知道，而且可以隨著程式執行增長或縮減。

以下三種是在 Rust 程式中十分常用的集合：

- 向量（Vector）：允許儲存數量不定的數值。
- 字串（String）：是字元的集合。
- 雜湊映射（Hash map）：允許將值（value）與特定的鍵（key）相關聯。這是從一種更通用的資料結構映射（map）衍生出來的特定實作。

## 向量

### 建立向量

集合 `Vec<T>` 常稱為向量（vector），允許在一個資料結構儲存不止一個數值，而且該結構的記憶體會接連排列所有數值。

要建立一個新的空向量的話，我們呼叫 `Vec::new` 函式。標準函式庫提供的 `Vec<T>` 型別可以持有任意型別，然後當特定向量要持有特定型別時，我們可以在尖括號內指定該型別。

```RS
let v: Vec<i32> = Vec::new();
```

Rust 還提供了 `vec!` 巨集讓我們能方便地建立一個新的向量並取得提供的數值。以下建立了一個新的 `Vec<i32>`，並擁有數值 1、2 和 3。整數型別為 `i32` 是因為這是預設整數型別。

```RS
let v = vec![1, 2, 3];
```

### 更新向量

要在建立向量之後新增元素的話，可以使用 `push` 方法。與其他變數一樣，如果想要變更其數值的話，需要使用 `mut` 關鍵字使它成為可變的。

```RS
let mut v: Vec<i32> = Vec::new();
v.push(5);
v.push(6);
v.push(7);
```

### 釋放向量

就像其它 `struct` 一樣，向量會在作用域結束時被釋放。當向量被釋放時，其所有內容也都會被釋放，代表它持有的那些整數都會被清除。

```RS
{
    let v = vec![1, 2, 3, 4];
    // 使用 v 做些事情
} // <- v 在此離開作用域並釋放
```

### 讀取向量

取得向量中數值的方法，可以使用索引語法與 `get` 方法。

```RS
let v = [1, 2, 3, 4, 5];
let third: &i32 = &v[2];
println!("第三個元素為 {}", third);

match v.get(2) {
    Some(v) => println!("第三個元素為 {}", v),
    None => println!("第三個元素並不存在。"),
}
```

Rust 提供兩種取得元素引用方式，第一個 `[]` 方法會讓程式恐慌，因為它引用了不存在的元素。此方法適用於當你希望一有無效索引時就讓程式崩潰的狀況。當使用 `get` 方法來索取向量不存在的索引時，它會回傳 `None` 而不會恐慌。如果正常情況下偶而會不小心存取超出向量範圍索引的話，就會想要只用此方法。

```RS
let v = vec![1, 2, 3, 4, 5];

let does_not_exist = &v[100];
let does_not_exist = v.get(100);
```

有個規則是我們不能在同個作用域同時擁有可變與不可變引用。在此我們有一個向量第一個元素的不可變引用，然後我們嘗試在向量後方新增元素。如果我們嘗試在此動作後繼續使用第一個引用的話，程式會無法執行。

```RS
let mut v = vec![1, 2, 3, 4, 5];

let first = &v[0];

v.push(6);

println!("第一個元素為 {}", first);
```

為何第一個元素的引用要在意向量的最後端發生了什麼事呢？此錯誤其實跟向量運作的方式有關：由於向量會將元素放在前一位的記憶體位置後方，在向量後方新增元素時，如果當前向量的空間不夠在塞入另一個值的話，可能會需要分配新的記憶體並複製舊的元素到新的空間中。這樣一來，第一個元素的索引可能就會指向已經被釋放的記憶體，借用規則會防止程式遇到這樣的情形。

### 遍歷向量

想要依序存取向量中每個元素的話，我們可以遍歷所有元素而不必用索引一個一個取得。

```RS
let v = vec![1, 2, 3, 4, 5];

for i in &v {
    println!("{}", i);
}
```

還可以遍歷可變向量中的每個元素取得可變引用來改變每個元素。

```RS
let mut v = vec![1, 2, 3, 4, 5];

for i in &mut v {
    *i += 50;
    println!("{}", i);
}
```

### 使用枚舉來儲存多種型別

向量只能儲存同型別的數值，這在某些情況會很不方便，一定會有場合是要儲存不同型別到一個列表中。幸運的是，枚舉的變體是定義在相同的枚舉型別，所以當我們需要在向量儲存不同型別的元素時，我們可以用枚舉來定義。

舉例來說，假設我們想從表格中的一行取得數值，但是有些行內的列會包含整數、浮點數以及一些字串。我們可以定義一個枚舉，其變體會持有不同的數值型別，然後所有的枚舉變體都會被視為相同型別：就是它們的枚舉。

```RS
enum SpreadsheetCell {
    Int(i32),
    Float(f64),
    Text(String),
}

let row = vec![
    SpreadsheetCell::Int(3),
    SpreadsheetCell::Text(String::from("藍色")),
    SpreadsheetCell::Float(10.12),
];
```

Rust 需要在編譯時期知道向量的型別以及要在堆積上用到多少記憶體才能儲存每個元素。我們必須明確知道哪些型別可以放入向量中。如果 Rust 允許向量一次持有任意型別的話，在對向量中每個元素進行處理時，可能就會有一或多種型別會產生錯誤。使用枚舉和 `match` 表達式讓 Rust 可以在編譯期間確保每個可能的情形都已經處理完善了。

## 字串

### 定義

Rust 在核心語言中只有一個字串型別，那就是字串切片 `str`，它通常是以借用的形式存在 `&str`。字串切片是一個針對存在某處的 UTF-8 編碼資料的引用。舉例來說，字串字面值（String literals）就儲存在程式的二進制檔案中，因此就是字串切片。

`String` 型別是 Rust 標準函式庫所提供的型別，並不是核心語言內建的型別，它是可增長的、可變的、可擁有所有權的 UTF-8 編碼字串型別。當 Rustaceans 提及 Rust 中的「字串」時，他們通常指的是 `String` 以及字串切片 `&str` 型別，而不只是其中一種型別。

Rust 的標準函式庫還包含了其他種類的字串型別，像是 `OsString`、`OsStr`、`CString` 以及 `CStr`。函式庫 crates 更可以提供儲存字串資料的更多選項。注意到這些型別的結尾都是 `String` 和 `Str`，它們分別代表擁有所有權與借用的變體。這些字串型別可以儲存不同編碼的文字或者以不同的記憶體形式呈現。

### 建立字串

許多 `Vec<T>` 可使用的方法在 `String` 也都能用，像是用 `new` 函式建立新的字串。

```RS
let mut s = String::new();
```

通常我們會希望建立字串的同時能夠初始化資料，為此我們可以使用 `to_string` 方法，任何有實作 `Display` 特徵的型別都可以使用此方法，就像字串字面值的使用方式一樣。

```RS
let data = "初始內容";

let s = data.to_string();

// 此方法也能直接用於字面值上
let s = "初始內容".to_string();
```

我們也可以用函式 `String::from` 從字串字面值建立 String。和使用 `to_string` 的效果一樣。

```RS
let s = String::from("初始內容");
```

在上面的範例中 `String::from` 和 `to_string` 都在做相同的事，所以選擇跟喜好風格與閱讀性比較有關。

字串是 UTF-8 編碼的，所以我們可以包含任何正確編碼的資料。

```RS
let hello = String::from("السلام عليكم");
let hello = String::from("Dobrý den");
let hello = String::from("Hello");
let hello = String::from("שָׁלוֹם");
let hello = String::from("नमस्ते");
let hello = String::from("こんにちは");
let hello = String::from("안녕하세요");
let hello = String::from("你好");
let hello = String::from("Olá");
let hello = String::from("Здравствуйте");
let hello = String::from("Hola");
```

### 更新字串

可以使用 `push_str` 方法來追加一個字串切片使字串增長。

```RS
let mut s = String::from("foo");
s.push_str("bar");
// foobar
```

而 `push` 方法會取得一個字元作為參數並加到 `String` 上。

```RS
let mut s = String::from("lo");
s.push('l');
// lol
```

通常會想要組合兩個字串在一起，其中一種方式是用 `+` 運算子。

```RS
let s1 = String::from("Hello, ");
let s2 = String::from("world!");
let s3 = s1 + &s2; // 注意到 s1 被移動因此無法再被使用
```

雖然 `let s3 = s1 + &s2;` 看起來像是它拷貝了兩個字串的值並產生了一個新的，但此陳述式實際上是取得 `s1` 的所有權、追加一份 `s2` 的複製內容，然後回傳最終結果的所有權。

如果要完成更複雜的字串組合的話，我們可以改使用 `format!` 巨集：

```RS
let s1 = String::from("tic");
let s2 = String::from("tac");
let s3 = String::from("toe");

let s = format!("{}-{}-{}", s1, s2, s3);
// tic-tac-toe
```

`format!` 巨集運作的方式和 `println!` 類似，但不會將輸出結果顯示在螢幕上，它做的是回傳內容的 `String`。使用 `format!` 的程式碼版本看起來比較好讀懂，而且 `format!` 產生的程式碼使用的是引用，所以此呼叫不會取走任何參數的所有權。

### 索引字串

Rust 字串並不支援索引。

將「Здравствуйте」用 UTF-8 編碼後的位元組長度，因為該字串的每個 Unicode 純量都佔據兩個位元組。因此字串位元組的索引不會永遠都能對應到有效的 Unicode 純量數值。

```RS
let hello = String::from("Здравствуйте");
```

Rust 還有一個不允許索引 `String` 來取得字元的原因是因為，索引運算必須永遠預期是花費常數時間（`O(1)`）。但在 `String` 上無法提供這樣的效能保證，因為 Rust 會需要從索引的開頭遍歷每個內容才能決定多少有效字元存在。

### 字串切片

與其在 `[]` 只使用一個數字來索引，你可以在 `[]` 指定一個範圍來建立包含特定位元組的字串切片。

```RS
let hello = "Здравствуйте";

let s = &hello[0..4];
```

使用範圍來建立字串切片時要格外小心，因為這樣做有可能會使你的程式崩潰。

### 遍歷字串

要對字串的部分進行操作最好的方式是明確表達想要的是字元還是位元組。對獨立的 Unicode 純量型別來說的話，就是使用 `chars` 方法。對「नमस्ते」呼叫 `chars` 會將六個擁有 `char` 型別的數值拆開並回傳，這樣一來就可以遍歷每個元素。

```RS
for c in "नमस्ते".chars() {
    println!("{}", c);
}
```

此程式碼會顯示以下輸出：

```RS
न
म
स
्
त
े
```

而 `bytes` 方法會回傳每個原始位元組。

```RS
for b in "नमस्ते".bytes() {
    println!("{}", b);
}
```

此程式碼會印出此 `String` 的 18 個位元組。

```RS
224
164
// --省略--
165
135
```

需要了解，有效的 Unicode 純量數值可能不止佔 1 個位元組。

## 雜湊映射

`HashMap<K, V>` 型別會儲存一個鍵（key）型別 `K` 對應到一個數值（value）型別 `V`。它透過雜湊函式（hashing function）來決定要將這些鍵與值放在記憶體何處。雜湊映射適合用於當不想像向量那樣用索引搜尋資料，而是透過一個可以為任意型別的鍵來搜尋的情況。

### 建立雜湊映射

一種建立空的雜湊映射的方式是使用 `new` 並透過 `insert` 加入新元素。

```RS
use std::collections::HashMap;

let mut scores = HashMap::new();

scores.insert(String::from("藍隊"), 10);
scores.insert(String::from("黃隊"), 50);
```

另一種建構雜湊映射的方式為使用疊代器並在一個元組組成的向量中使用 `collect` 方法，其中每個元組都包含一個鍵與值的配對。

```RS
use std::collections::HashMap;

let teams = vec![String::from("藍隊"), String::from("黃隊")];
let initial_scores = vec![10, 50];

let mut scores: HashMap<_, _> =
teams.into_iter().zip(initial_scores.into_iter()).collect();
```

### 雜湊映射與所有權

像是 `i32` 這種有實作 `Copy` 特徵的型別，其數值可以被拷貝進雜湊映射之中。但對於像是 `String` 這種擁有所有權的數值，則會被移動到雜湊映射，並且成為該數值新的擁有者。

```RS
use std::collections::HashMap;

let field_name = String::from("Favorite color");
let field_value = String::from("藍隊");

let mut map = HashMap::new();
map.insert(field_name, field_value);
// field_name 和 field_value 在這之後就不能使用了
```

### 讀取雜湊映射

可以透過 `get` 方法並提供鍵來取得其在雜湊映射對應的值。

```RS
use std::collections::HashMap;

let mut scores = HashMap::new();

scores.insert(String::from("藍隊"), 10);
scores.insert(String::from("黃隊"), 50);

let team_name = String::from("藍隊");
let score = scores.get(&team_name);
```

也可以使用 `for` 迴圈用類似的方式來遍歷雜湊映射中每個鍵值配對。

```RS
use std::collections::HashMap;

let mut scores = HashMap::new();

scores.insert(String::from("藍隊"), 10);
scores.insert(String::from("黃隊"), 50);

for (key, value) in &scores {
    println!("{}: {}", key, value);
}
```

### 更新雜湊映射

雖然鍵值配對的數量可以增加，但每個鍵同一時間就只能有一個對應的值而已。當想要改變雜湊映射的資料的話，必須決定如何處理當一個鍵已經有一個值的情況。

#### 覆蓋數值

如果我們在雜湊映射插入一個鍵值配對，然後又在相同鍵插入不同的數值的話，該鍵相對應的數值就會被取代。

```RS
use std::collections::HashMap;

let mut scores = HashMap::new();

scores.insert(String::from("藍隊"), 10);
scores.insert(String::from("藍隊"), 25);

println!("{:?}", scores);
```

#### 只在鍵沒有值的情況下插入數值

通常檢查某個特定的鍵有沒有數值，如果沒有的話才插入數值是很常見的。雜湊映射提供了一個特別的 API 叫做 `entry` 讓你可以用想要檢查的鍵作為參數。`entry` 方法的回傳值是一個枚舉叫做 `Entry`，它代表了一個可能存在或不存在的數值。

#### 依據舊值更新數值

雜湊映射還有另一種常見的用法是，依照鍵的舊數值來更新它。舉例來說，以下展示了一支如何計算一些文字內每個單字各出現多少次的程式碼。我們使用雜湊映射，鍵為單字然後值為我們每次追蹤計算對應單字出現多少次的次數。如果我們是第一次看到該單字的話，我們插入數值 0。

```RS
use std::collections::HashMap;

let text = "hello world wonderful world";

let mut map = HashMap::new();

for word in text.split_whitespace() {
    let count = map.entry(word).or_insert(0);
    *count += 1;
}

println!("{:?}", map);
```

### 雜湊函式

HashMap 預設是使用一種叫做 SipHash 的雜湊函式（hashing function），這可以透過雜湊表（hash table）抵禦阻斷服務（Denial of Service, DoS）的攻擊。這並不是最快的雜湊演算法，但為了提升安全性而犧牲一點效能是值得的。

## 參考資料

- [The Rust Programming Language](https://doc.rust-lang.org/stable/book/)
