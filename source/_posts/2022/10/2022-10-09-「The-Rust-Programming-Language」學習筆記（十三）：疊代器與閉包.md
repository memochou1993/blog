---
title: 「The Rust Programming Language」學習筆記（十三）：疊代器與閉包
date: 2022-10-09 21:57:17
tags: ["程式設計", "Rust"]
categories: ["程式設計", "Rust", "「The Rust Programming Language」學習筆記"]
---

## 前言

本文為「[The Rust Programming Language](https://doc.rust-lang.org/stable/book/)」語言指南的學習筆記。

## 閉包

Rust 的閉包（closures）是個能賦值給變數或作為其他函式引數的匿名函式。可以在某處建立閉包，然後在不同的地方呼叫閉包並執行它。而且不像函式，閉包可以從它們所定義的作用域中獲取數值。這些閉包功能如何允許程式碼重用以及自訂行為。

### 透過閉包建立抽象行為

考慮以下假設情境：我們在一家新創公司上班並正在推出一支會產生自訂重訓方案的應用程式。此例中實際使用的演算法並不重要，重要的是此運算會花費數秒鐘。我們只想要在我們需要時呼叫此演算法並只會呼叫一次，讓使用者不會等待太久。

我們會模擬這個假設的演算法為函式 `simulated_expensive_calculation`，他會印出「緩慢計算中...」，並等待兩秒鐘，然後回傳我們傳入的數值。

```rs
use std::thread;
use std::time::Duration;

fn simulated_expensive_calculation(intensity: u32) -> u32 {
    println!("緩慢計算中...");
    thread::sleep(Duration::from_secs(2));
    intensity
}
```

接下來 `main` 函式會包含此健身應用程式中最重要的部分。此函式代表當使用者請求健身方案時應用程式會呼叫的程式碼。由於應用程式的前端與我們的閉包使用並沒有任何關聯，我們將會用寫死的數值來代表我們程式的輸入並印出輸出結果。

必要的輸入如以下所示：

- 使用者想要的重訓強度，用來指明他們想要的訓練是低強度訓練或是高強度訓練。
- 一個用來產生重訓方案變化的隨機數值。

```rs
fn main() {
    let simulated_user_specified_value = 10;
    let simulated_random_number = 7;

    generate_workout(simulated_user_specified_value, simulated_random_number);
}
```

函式 `generate_workout` 包含了應用程式的業務邏輯，也就是在此例最在意的地方。

```rs
fn generate_workout(intensity: u32, random_number: u32) {
    if intensity < 25 {
        println!(
            "今天請做 {} 下伏地挺身！",
            simulated_expensive_calculation(intensity)
        );
        println!(
            "然後請做 {} 下仰臥起坐！",
            simulated_expensive_calculation(intensity)
        );
    } else {
        if random_number == 3 {
            println!("今天休息！別忘了多喝水！");
        } else {
            println!(
                "今天請慢跑 {} 分鐘！",
                simulated_expensive_calculation(intensity)
            );
        }
    }
}
```

此程式碼能夠應付業務邏輯了，但是假設未來資料科學團隊決定要求我們需要更改我們呼叫 `simulated_expensive_calculation` 函式的方式。為了簡化這些更新步驟，我們想要重構此程式碼好讓 `simulated_expensive_calculation` 只會呼叫一次。同時我們也想要去掉我們目前呼叫兩次的多餘程式碼，我們不希望再對此程序加上更多的函式呼叫。也就是說，我們不希望在沒有需要取得結果時呼叫程式碼，且我們希望它只會被呼叫一次。

#### 透過函式重構

首先我們先將重複呼叫 `simulated_expensive_calculation` 的地方改成變數。

```rs
fn generate_workout(intensity: u32, random_number: u32) {
    let expensive_result = simulated_expensive_calculation(intensity);

    if intensity < 25 {
        println!("今天請做 {} 下伏地挺身！", expensive_result);
        println!("然後請做 {} 下仰臥起坐！", expensive_result);
    } else {
        if random_number == 3 {
            println!("今天休息！別忘了多喝水！");
        } else {
            println!("今天請慢跑 {} 分鐘！", expensive_result);
        }
    }
}
```

此變更統一了所有 `simulated_expensive_calculation` 的呼叫並解決第一個 `if` 區塊重複呼叫函式兩次的問題。不幸的是，現在我們一定得呼叫此函式並在所有情形下都得等待，這包含沒有使用到此結果的 `if` 區塊。

我們想在 `generate_workout` 內只用一次此函式的呼叫，且只在我們真的需要結果的地方進行昂貴的運算就好。

#### 透過閉包重構來儲存程式碼

與其在 `if` 區塊之前就呼叫 `simulated_expensive_calculation` 函式，我們可以定義一個閉包並將閉包存入變數中，而不是儲存函式呼叫的結果。

```rs
let expensive_closure = |num| {
    println!("緩慢計算中...");
    thread::sleep(Duration::from_secs(2));
    num
};
```

閉包定義位於 `expensive_closure` 賦值時 `=` 後面的部分。要定義閉包，我們先從一對直線（`|`）開始，其內我們會指定閉包的參數，選擇此語法的原因是因為這與 Smalltalk 和 Ruby 的閉包定義類似。此閉包有一個參數 `num`，如果我們想要不止一個的話，我們可以用逗號來分隔，像是這樣 `|param1, param2|`。

在參數之後，我們加上大括號來作為閉包的本體，不過如果閉包本體只是一個表達式的話就不必這樣寫。在閉包結束後，也就是大括號之後，我們要加上分號才能完成 `let` 陳述式的動作。在閉包本體最後一行的回傳數值就會是當閉包被呼叫時的回傳數值，因為該行沒有以分號做結尾，就像函式本體一樣。

注意到此 `let` 陳述式代表 `expensive_closure` 包含了匿名函式的定義，而不是呼叫匿名函式的回傳數值。回想一下我們使用閉包是為了讓我們能在某處定義程式碼、儲存這段程式碼然後在之後別的地方呼叫它。我們想呼叫的程式碼現在儲存在 `expensive_closure` 中。

有了閉包定義，我們就可以變更 `if` 區塊內的程式碼呼叫閉包來執行其程式碼並取得結果數值。我們呼叫閉包的方式與呼叫函式一樣：我們指定握有閉包定義的變數名稱，然後在括號內加上我們想使用的引數數值。

```rs
fn generate_workout(intensity: u32, random_number: u32) {
    let expensive_closure = |num| {
        println!("緩慢計算中...");
        thread::sleep(Duration::from_secs(2));
        num
    };

    if intensity < 25 {
        println!("今天請做 {} 下伏地挺身！", expensive_closure(intensity));
        println!("然後請做 {} 下仰臥起坐！", expensive_closure(intensity));
    } else {
        if random_number == 3 {
            println!("今天休息！別忘了多喝水！");
        } else {
            println!(
                "今天請慢跑 {} 分鐘！",
                expensive_closure(intensity)
            );
        }
    }
}
```

現在進行耗時的計算都定義在同一處了，而且只會在需要結果時才會執行該程式碼。

### 閉包型別推導與詮釋

閉包不必像 `fn` 函式那樣要求要詮釋參數或回傳值的型別。函式需要型別詮釋是因為它們是顯式公開給使用者的介面。嚴格定義此介面是很重要的，這能確保每個人同意函式使用或回傳的數值型別為何。但是閉包並不是為了對外公開使用，它們儲存在變數且沒有名稱能公開給我們函式庫的使用者。

閉包通常很短，而且只與小範圍內的程式碼有關，而非適用於任何場合。有了這樣限制的環境，編譯器能可靠地推導出參數與回傳值的型別，如同其如何推導出大部分的變數型別一樣。

要求開發者得為這些小小的匿名函式詮釋型別的話會變得很惱人且非常多餘，因為編譯器早就有足夠的資訊能推導出來了。至於變數的話，雖然不是必要的，但如果我們希望能夠增加閱讀性與清楚程度，還是可以加上型別詮釋。

```rs
let expensive_closure = |num: u32| -> u32 {
    println!("緩慢計算中...");
    thread::sleep(Duration::from_secs(2));
    num
};
```

加上型別詮釋後，閉包的語法看起來就更像函式的語法了。以下對一個參數加 `1` 的函式定義語法與有相同行為的閉包的比較表。這顯示了閉包語法和函式語法有多類似，只是改用直線以及有些語法是選擇性的。

```rs
fn  add_one_v1   (x: u32) -> u32 { x + 1 }
let add_one_v2 = |x: u32| -> u32 { x + 1 };
let add_one_v3 = |x|             { x + 1 };
let add_one_v4 = |x|               x + 1  ;
```

### 透過泛型參數與 `Fn` 特徵儲存閉包

將耗時閉包的結果存入變數中，並在我們需要結果的地方使用該變數，而不是再呼叫閉包一次。不過此方法可能會增加很多重複的程式碼。

幸運的是還有另一個解決辦法，可以建立一個結構體來儲存閉包以及呼叫閉包的結果數值。此結構體只會在我們需要結果數值時執行閉包，然後它會獲取結果數值，所以我們的程式碼就不必負責儲存要重複使用的結果。這種模式叫做記憶化（memoization）或惰性求值（lazy evaluation）。

我們在 `Fn` 特徵界限加上了型別來表示閉包參數與回傳值必須擁有的型別。在此例中，我們的閉包參數型別為 `u32` 且回傳 `u32`，所以我們指定的特徵界限為 `Fn(u32) -> u32`。

以下顯示了擁有一個閉包與一個 `Option` 結果數值的 `Cacher` 結構體定義。

```rs
struct Cacher<T>
where
    T: Fn(u32) -> u32,
{
    calculation: T,
    value: Option<u32>,
}
```

`Cacher` 結構體有個欄位 `calculation` 其泛型型別為 `T`。`T` 的特徵界限指定這是一個使用 `Fn` 特徵的閉包。任何我們想存入的 `calculation` 欄位的閉包都必須只有一個 `u32` 參數（在 `Fn` 後方的括號內指定）以及回傳一個 `u32`（在 `->` 之後指定）。

`value` 欄位型別為 `Option<u32>`。在我們執行閉包前，`value` 會是 `None`。當有程式碼使用 `Cacher` 要求取得閉包結果時，`Cacher` 就會在那時候執行閉包並以 `Some` 變體儲存結果到 `value` 欄位。然後如果有程式碼再次要求閉包結果時，我們就不必再執行閉包一次，可以靠 `Cacher` 回傳 `Some` 變體內的結果。

```rs
impl<T> Cacher<T>
where
    T: Fn(u32) -> u32,
{
    fn new(calculation: T) -> Cacher<T> {
        Cacher {
            calculation,
            value: None,
        }
    }

    fn value(&mut self, arg: u32) -> u32 {
        match self.value {
            Some(v) => v,
            None => {
                let v = (self.calculation)(arg);
                self.value = Some(v);
                v
            }
        }
    }
}
```

我們想要 `Cacher` 來管理結構體的欄位數值，而不是讓呼叫者有機會直接改變這些欄位的數值，所以這些欄位是私有的。

`Cacher::new` 函式接收一個泛型參數 `T`，其特徵界限與我們在 `Cacher` 結構體定義的是相同的。接著 `Cacher::new` 回傳一個 `Cacher` 實例，其 `calculation` 欄位擁有指定的閉包而 `value` 欄位則是 `None`，因為我們還沒有執行閉包。

當呼叫者需要閉包計算的結果時，不是直接呼叫閉包，而是呼叫 `value` 方法。此方法會檢查我們的 `self.value` 是否已經有個結果數值在 `Some` 內。如果有的話，它會回傳 `Some` 內的數值而不用再次執行閉包。

如果 `self.value` 是 `None`，程式碼會呼叫存在 `self.calculation` 的閉包、儲存結果到 `self.value` 以便未來使用，並回傳數值。

```rs
fn generate_workout(intensity: u32, random_number: u32) {
    let mut expensive_result = Cacher::new(|num| {
        println!("緩慢計算中...");
        thread::sleep(Duration::from_secs(2));
        num
    });

    if intensity < 25 {
        println!("今天請做 {} 下伏地挺身！", expensive_result.value(intensity));
        println!("然後請做 {} 下仰臥起坐！", expensive_result.value(intensity));
    } else {
        if random_number == 3 {
            println!("今天休息！別忘了多喝水！");
        } else {
            println!(
                "今天請慢跑 {} 分鐘！",
                expensive_result.value(intensity)
            );
        }
    }
}
```

不同於將閉包儲存給變數，我們建立一個新的 `Cacher` 實例來儲存閉包。然後在每個我們需要結果的地方，我們呼叫 `Cacher` 實例的 `value` 方法。我們要呼叫 `value` 方法幾次都行，或者不叫也行，無論如何耗時計算最多就只會被執行一次。

### Cacher 實作的限制

快取數值是個廣泛實用的行為，我們可能會希望在程式碼中的其他不同閉包也使用到。然而目前 `Cacher` 的實作有兩個問題可能會在不同場合重複使用變得有點困難。

第一個問題是 `Cacher` 實例假設它永遠會從方法 `value` 的參數 `arg` 中取得相同數值，所以說以下 `Cacher` 的測試就會失敗：

```rs
#[test]
fn call_with_different_values() {
    let mut c = Cacher::new(|a| a);

    let v1 = c.value(1);
    let v2 = c.value(2);

    assert_eq!(v2, 2);
}
```

我們可以嘗試將 `Cacher` 改成儲存雜湊映射（hash map）而非單一數值。雜湊映射的鍵會是傳入的 `arg` 數值，而雜湊映射的值則是用該鍵呼叫閉包的結果。所以不同於查看 `self.value` 是 `Some` 還是 `None` 值，`value` 函式將會查看 `arg` 有沒有在雜湊映射內，而如果有的話就會傳對應數值。如果沒有的話，`Cacher` 會呼叫閉包並儲存 `arg` 數值與對應的結果數值到雜湊映射中。

第二個問題是目前的 `Cacher` 實作只會接受參數型別為 `u32` 並回傳 `u32` 的閉包。舉例來說，我們可能會想要快取給予字串並回傳 `usize` 的閉包結果數值。要修正此問題，可以嘗試加上更多泛型參數來增加 `Cacher` 功能的彈性。

### 透過閉包獲取環境

在重訓生成範例中，我們只將閉包作為行內匿名函式。但是閉包還有個函式所沒有的能力：它們可以獲取它們的環境並取得在它們所定義的作用域內的變數。

以下有一個儲存在變數 `equal_to_x` 的閉包，其使用變數 `x` 來取得閉包周圍的環境。

```rs
fn main() {
    let x = 4;

    let equal_to_x = |z| z == x;

    let y = 4;

    assert!(equal_to_x(y));
}
```

用函式就做不到，以下範例會無法編譯。

```rs
fn main() {
    let x = 4;

    fn equal_to_x(z: i32) -> bool {
        z == x
    }

    let y = 4;

    assert!(equal_to_x(y));
}
```

當閉包從它的環境獲取數值時，它會在閉包本體中使用記憶體來儲存這個數值。這種儲存記憶體的方式會產生額外開銷。在更常見的場合中，也就是不需要獲取程式碼的環境時，我們並不希望產生這種開銷。因為函式並不允許獲取它們的環境，定義與使用函式就不會產生這種開銷。

閉包可以用三種方式獲取它們的環境，這剛好能對應到函式取得參數的三種方式：取得所有權、可變借用與不可變借用。這就被定義成以下三種 `Fn` 特徵：

- `FnOnce` 會消耗周圍作用域中，也就是閉包的環境，所獲取變數。要消耗掉所獲取的變數，閉包必須取得這些變數的所有權並在定義時將它們移入閉包中。特徵名稱中的 `Once` 指的是因為閉包無法取得相同變數的所有權一次以上，所以它只能被呼叫一次。
- `FnMut` 可以改變環境，因為它取得的是可變的借用數值。
- `Fn` 則取得環境中不可變的借用數值。

當建立閉包時，Rust 會依據閉包如何使用環境的數值來推導該使用何種特徵。所有的閉包都會實作 `FnOnce` 因為它們都可以至少被呼叫一次。不會移動獲取變數的閉包還會實作 `FnMut`，最後不需要向獲取變數取得可變引用的閉包會再實作 `Fn`。

如果希望強制閉包會取得周圍環境數值的所有權，你可以在參數列表前使用 `move` 關鍵字。此技巧在要將閉包傳給新的執行緒以便將資料移動到新執行緒時會很實用。

注意：就算 `move` 閉包透過移動獲取變數，它們仍可能會實作成 `Fn` 或 `FnMut`。這是因爲閉包型別會實作哪種特徵，是由該閉包如何處理其獲取的變數來決定，而不是它如何獲取的。`move` 關鍵字只會處理後者的行爲。

以下範例使用 `move` 關鍵字到閉包定義中，並使用向量而非整數，因為整數可以被拷貝而不是移動。注意此程式還不能編譯過。

```rs
fn main() {
    let x = vec![1, 2, 3];

    let equal_to_x = move |z| z == x;

    println!("無法在此使用 x：{:?}", x);

    let y = vec![1, 2, 3];

    assert!(equal_to_x(y));
}
```

當閉包定義時，數值 `x` 會移入閉包中，因為我們加上了 `move` 關鍵字。閉包因此取得 `x` 的所有權，然後 `main` 就會不允許 `x` 在 `println!` 陳述式中使用。移除此例的 `println!` 就能修正問題。

大多數要指定 `Fn` 特徵界限時，可以先從 `Fn` 開始，然後編譯器會依據閉包本體的使用情況來告訴你該使用 `FnMut` 或 `FnOnce`。

## 疊代器

疊代器（Iterator）模式可以對一個項目序列依序進行某些任務。一個疊代器負責遍歷每個項目，以及序列何時結束的邏輯。當使用疊代器，不需要自己實作這些邏輯。

在 Rust 中疊代器是惰性（lazy）的，代表除非你呼叫方法來使用疊代器，不然它們不會有任何效果。舉例來說，以下程式碼會透過 `Vec<T>` 定義的方法 `iter` 從向量 `v1` 建立一個疊代器來遍歷它的項目。此程式碼本身沒有啥實用之處。

```rs
let v1 = vec![1, 2, 3];

let v1_iter = v1.iter();
```

一旦我們建立了疊代器，我們可以有很多使用它的方式。

以下範例區隔了疊代器的建立與使用疊代器 `for` 迴圈。疊代器儲存在變數 `v1_iter`，且在此時沒有任何遍歷的動作發生。當使用 `v1_iter` 疊代器的 `for` 迴圈被呼叫時，疊代器中的每個元素才會在迴圈中每次疊代中使用，以此印出每個數值。

```rs
let v1 = vec![1, 2, 3];

let v1_iter = v1.iter();

for val in v1_iter {
    println!("取得：{}", val);
}
```

在標準函式庫沒有提供疊代器的語言中，你可能會用別種方式寫這個相同的函式，像是先從一個變數 `0` 作為索引開始、使用該變數索引向量來獲取數值，然後在迴圈中增加變數的值直到它抵達向量的總長。

疊代器會為你處理這些所有邏輯，減少重複且你可能會搞砸的程式碼。疊代器還能讓你靈活地將相同的邏輯用於不同的序列，而不只是像向量這種進行索引的資料結構。

### Iterator 特徵與 next 方法

所有的疊代器都會實作定義在標準函式庫的 `Iterator` 特徵。特徵的定義如以下所示：

```rs
pub trait Iterator {
    type Item;

    fn next(&mut self) -> Option<Self::Item>;

    // ...
}
```

注意到此定義使用了一些新的語法：`type Item` 與 `Self::Item`，這是此特徵定義的關聯型別（associated type）。現在只需要知道此程式碼表示要實作 `Iterator` 特徵的話，你還需要定義 `Item` 型別，而此 `Item` 型別會用在方法 `next` 的回傳型別中。換句話說，`Item` 型別會是從疊代器回傳的型別。

`Iterator` 型別只要求實作者定義一個方法：`next` 方法會用 `Some` 依序回傳疊代器中的每個項目，並在疊代器結束時回傳 `None`。

我們可以直接在疊代器呼叫 `next` 方法。以下範例展示從向量建立的疊代器重複呼叫 `next` 每次會得到什麼數值。

```rs
#[test]
fn iterator_demonstration() {
    let v1 = vec![1, 2, 3];

    let mut v1_iter = v1.iter();

    assert_eq!(v1_iter.next(), Some(&1));
    assert_eq!(v1_iter.next(), Some(&2));
    assert_eq!(v1_iter.next(), Some(&3));
    assert_eq!(v1_iter.next(), None);
}
```

注意到 `v1_iter` 需要是可變的：在疊代器上呼叫 `next` 方法會改變疊代器內部用來紀錄序列位置的狀態。換句話說，此程式碼消耗或者說使用了疊代器。每次 `next` 的呼叫會從疊代器消耗一個項目。而我們不必在 for 迴圈指定 `v1_iter` 為可變是因為迴圈會取得 `v1_iter` 的所有權並在內部將其改為可變。

另外還要注意的是我們從 `next` 呼叫取得的是向量中數值的不可變引用。`iter` 方法會從疊代器中產生不可變引用。如果我們想要一個取得 `v1` 所有權的疊代器，我們可以呼叫 `into_iter` 而非 `iter`。同樣地，如果我們想要遍歷可變引用，我們可以呼叫 `iter_mut` 而非 `iter`。

### 消耗疊代器的方法

標準函式庫提供的 `Iterator` 特徵有一些不同的預設實作方法，可以查閱標準函式庫的 `Iterator` 特徵 API 技術文件來找到這些方法。其中有些方法就是在它們的定義呼叫 `next` 方法，這就是為何當實作 `Iterator` 特徵時需要提供 `next` 方法的實作。

會呼叫 `next` 的方法被稱之為消耗配接器（consuming adaptors），因為呼叫它們會使用掉疊代器。其中一個例子就是方法 `sum`，這會取得疊代器的所有權並重複呼叫 `next` 來遍歷所有項目，因而消耗掉疊代器。隨著遍歷的過程中，他會將每個項目加到總計中，並在疊代完成時回傳總計數值。

```rs
#[test]
fn iterator_sum() {
    let v1 = vec![1, 2, 3];

    let v1_iter = v1.iter();

    let total: i32 = v1_iter.sum();

    assert_eq!(total, 6);
}
```

呼叫 `sum` 之後就不再被允許使用 `v1_iter` 了，因為 `sum` 取得了疊代器的所有權。

### 產生其他疊代器的方法

其他定義在 `Iterator` 特徵的方法則叫做疊代配接器（iterator adaptors），它們能變更疊代器成其他種類的疊代器。可以串接數個疊代配接器的呼叫來組織一系列複雜的動作並仍能保持閱讀性。不過因為所有的疊代器都是惰性的，所以需要呼叫一個消耗配接器方法來取得疊代配接器呼叫的結果。

呼叫了疊代器的疊代配接器方法 `map`，這可以取得一個閉包來對每個項目進行處理以產生一個新的疊代器。閉包會將向量中的每個項目加 `1` 來產生新的疊代器。

```rs
let v1: Vec<i32> = vec![1, 2, 3];

v1.iter().map(|x| x + 1);
```

以上程式碼不會做任何事情，我們指定的閉包沒有被呼叫到半次。警告提醒了我們原因：疊代配接器是惰性的，我們必須在此消耗疊代器才行。

要修正並消耗此疊代器，我們將使用 `collect` 方法，這是在先前範例搭配 `env::args` 使用的方法。此方法會消耗疊代器並收集結果數值至一個資料型別集合。

在以下範例中，將遍歷 `map` 呼叫所產生的疊代器結果數值收集到一個向量中。此向量最後會包含原本向量每個項目都加 `1` 的數值。

```rs
let v1: Vec<i32> = vec![1, 2, 3];

let v2: Vec<_> = v1.iter().map(|x| x + 1).collect();

assert_eq!(v2, vec![2, 3, 4]);
```

因為 `map` 接受一個閉包，我們可以對每個項目指定任何我們想做的動作。這是一個展示如何使用閉包來自訂行為，又能重複使用 `Iterator` 特徵提供的遍歷行為的絕佳例子。

### 使用閉包獲取它們的環境

以下展示一個透過使用 `filter` 疊代配接器與閉包獲取它們環境的常見範例。疊代器中的 `filter` 方法會接受一個使用疊代器的每個項目並回傳布林值的閉包。如果閉包回傳 `true`，該數值就會被包含在 `filter` 產生的疊代器中；如果閉包回傳 `false`，該數值就不會被包含在結果疊代器中。

以下範例使用 `filter` 與一個從它的環境獲取變數 `shoe_size` 的閉包來遍歷一個有 `Shoe` 結構體實例的集合。它會回傳只有符合指定大小的鞋子。

```rs
#[derive(PartialEq, Debug)]
struct Shoe {
    size: u32,
    style: String,
}

fn shoes_in_size(shoes: Vec<Shoe>, shoe_size: u32) -> Vec<Shoe> {
    shoes.into_iter().filter(|s| s.size == shoe_size).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn filters_by_size() {
        let shoes = vec![
            Shoe {
                size: 10,
                style: String::from("運動鞋"),
            },
            Shoe {
                size: 13,
                style: String::from("涼鞋"),
            },
            Shoe {
                size: 10,
                style: String::from("靴子"),
            },
        ];

        let in_my_size = shoes_in_size(shoes, 10);

        assert_eq!(
            in_my_size,
            vec![
                Shoe {
                    size: 10,
                    style: String::from("運動鞋")
                },
                Shoe {
                    size: 10,
                    style: String::from("靴子")
                },
            ]
        );
    }
}
```

函式 `shoes_in_size` 會取得鞋子向量的所有權以及一個鞋子大小作為參數。它會回傳只有符合指定大小的鞋子向量。

在 `shoes_in_size` 的本體中，我們呼叫 `into_iter` 來建立一個會取得向量所有權的疊代器。然後我們呼叫 `filter` 來將該疊代器轉換成只包含閉包回傳為 `true` 的元素的新疊代器。

閉包會從環境獲取 `shoe_size` 參數並比較每個鞋子數值的大小，讓只有符合大小的鞋子保留下來。最後呼叫 `collect` 來收集疊代器回傳的數值進一個函式會回傳的向量。

此測試顯示了當我們呼叫 `shoes_in_size` 時，我們會得到我們指定相同大小的鞋子。

### 透過 Iterator 特徵建立疊代器

可以從標準函式庫的其他集合型別產生疊代器，像是雜湊映射等，也可以透過自己的型別實作 `Iterator` 特徵來建立任何希望的疊代器。唯一需要提供的方法定義就是 `next` 方法。一旦完成，就可以使用 `Iterator` 特徵提供的所有預設實作方法！

作為展示，以下建立一個只會從 `1` 數到 `5` 的疊代器。首先，要建立一個擁有一些數值的結構體。然後我們對此結構體實作 `Iterator` 特徵將它變成一個疊代器，並在實作中使用其值。

以下有個結構體 `Counter` 的定義以及能夠產生 `Counter` 實例的關聯函式 `new`。

```rs
struct Counter {
    count: u32,
}

impl Counter {
    fn new() -> Counter {
        Counter { count: 0 }
    }
}
```

`Counter` 結構體只有一個欄位 `count`，此欄位擁有一個 `u32` 數值來追蹤我們遍歷 `1` 到 `5` 的當前位置。`count` 欄位是私有的，因為我們希望 `Counter` 的實作會管理此數值。函式 `new` 強制建立新實例的行為永遠會從 `count` 欄位為 `0` 時開始。

接下來我們對 `Counter` 型別實作 `Iterator` 特徵，定義 `next` 方法本體來指定疊代器的使用行為。

```rs
impl Iterator for Counter {
    type Item = u32;

    fn next(&mut self) -> Option<Self::Item> {
        if self.count < 5 {
            self.count += 1;
            Some(self.count)
        } else {
            None
        }
    }
}
```

我們將疊代器的關聯型別 `Item` 設為 `u32`，代表疊代器將會回傳 `u32` 數值。我們希望疊代器對目前的狀態加 `1`，所以我們將 `count` 初始化為 `0`，這樣它就會先回傳 `1`。如果 `count` 的值小於 `5`，`next` 就會增加 `count` 的值並用 `Some` 回傳目前數值。一旦 `count` 等於 `5`，我們的疊代器就會停止增加 `count` 並永遠回傳傳 `None`。

#### 使用 Counter 疊代器的 next 方法

一旦實作了 `Iterator` 特徵，我們就有一個疊代器了！以下範例的測試展示我們可以對 `Counter` 結構體直接呼叫 `next` 方法來使用疊代器的功能。

```rs
#[test]
fn calling_next_directly() {
    let mut counter = Counter::new();

    assert_eq!(counter.next(), Some(1));
    assert_eq!(counter.next(), Some(2));
    assert_eq!(counter.next(), Some(3));
    assert_eq!(counter.next(), Some(4));
    assert_eq!(counter.next(), Some(5));
    assert_eq!(counter.next(), None);
}
```

此測試建立了一個新的 `Counter` 實例給變數 `counter` 並重複呼叫 `next`，驗證實作的疊代器是否行為如預期的一樣：回傳數值 `1` 到 `5`。

#### 使用其他 Iterator 特徵方法

我們透過定義 `next` 方法來實作 `Iterator` 特徵，所以現在可使用在標準函式庫提供的 `Iterator` 特徵中所任何有預設實作的方法了，因為它們都使用到了 `next` 的方法功能。

舉例來說，如果我們因為某些原因想要取得一個 `Counter` 實例的數值與另一個 `Counter` 實例去掉第一個值的數值來做配對、對每個配對相乘、保留結果可以被 `3` 整除的值，最後將所有結果數值相加，我們可以這樣寫。

```rs
 #[test]
fn using_other_iterator_trait_methods() {
    let sum: u32 = Counter::new()
        .zip(Counter::new().skip(1))
        .map(|(a, b)| a * b)
        .filter(|x| x % 3 == 0)
        .sum();
    assert_eq!(18, sum);
}
```

注意到 `zip` 只會產生四個配對，理論上的 `(5, None)` 配對是不會產生出來的，因為 `zip` 會在它的其中一個輸入疊代器回傳 `None` 時就回傳 `None`。

這些所有呼叫都是可行的，因為我們已經定義了 `next` 運作的行為，而標準函式庫會提供其他呼叫 `next` 方法的預設實作。

## 改善命令列程式

### 使用疊代器移除 `clone`

有了新學到的疊代器，我們可以改變 `new` 函式來取得疊代器的所有權來作為引數，而非借用切片。我們會來使用疊代器的功能，而不是檢查切片長度並索引特定位置。這能讓 `Config::new` 函式的意圖更清楚，因為疊代器會存取數值。

一旦 `Config::new` 取得疊代器的所有權並不再使用借用的索引動作，我們就可以從疊代器中移動 `String` 的數值至 `Config` 而非呼叫 `clone` 來產生新的分配。

#### 直接使用回傳的疊代器

```rs
fn main() {
    let config = Config::new(env::args()).unwrap_or_else(|err| {
        eprintln!("解析引數時出現問題：{}", err);
        process::exit(1);
    });

    // ...
}
```

`env::args` 函式回傳的是疊代器！與其收集疊代器的數值成一個向量再傳遞切片給 `Config::new`，現在我們可以直接傳遞 `env::args` 回傳的疊代器所有權給 `Config::new`。

接下來，我們需要更新 `Config::new` 的定義。在 I/O 專案的 `src/lib.rs` 檔案中，變更 `Config::new` 的簽名成以下樣子。這還無法編譯，因為我們需要更新函式本體。

```rs
impl Config {
    pub fn new(mut args: env::Args) -> Result<Config, &'static str> {
        // ...
    }
}
```

標準函式庫技術文件顯示 `env::args` 函式回傳的疊代器型別為 `std::env::Args`。我們更新了 `Config::new` 函式的簽名，讓參數 `args` 的型別為 `std::env::Args` 而非 `&[String]`。因為我們取得了 `args` 的所有權，而且我們需要將 `args` 成為可變的讓我們可以疊代它，所以將關鍵字 `mut` 加到 `args` 的參數指定使其成為可變的。

#### 使用 Iterator 特徵方法而非索引

接下來，我們要修正 `Config::new` 的本體。標準函式庫還提到了 `std::env::Args` 有實作 `Iterator` 特徵，所以我們知道我們可以對它呼叫 `next` 方法！

```rs
impl Config {
    pub fn new(mut args: env::Args) -> Result<Config, &'static str> {
        args.next();

        let query = match args.next() {
            Some(arg) => arg,
            None => return Err("沒有取得欲搜尋的字串"),
        };

        let filename = match args.next() {
            Some(arg) => arg,
            None => return Err("沒有取得檔案名稱"),
        };

        let case_sensitive = env::var("CASE_INSENSITIVE").is_err();

        Ok(Config {
            query,
            filename,
            case_sensitive,
        })
    }
}
```

記得 `env::args` 回傳的第一個數值會是程式名稱。我們想要忽略該值並取得下個數值，所以我們第一次呼叫 `next` 時不會對回傳值做任何事。再來我們才會呼叫 `next` 來取得我們想要的數值置入 `Config` 中的 `query` 欄位。如果 `next` 回傳 `Some` 的話，我們使用 `match` 來提取數值。如果它回傳 `None` 的話，這代表引數不足，所以我們提早用 `Err` 數值回傳。我們對 `filename` 數值也做一樣的事。

#### 透過疊代配接器讓程式碼更清楚

我們可以使用疊代配接器（iterator adaptor）方法讓程式碼更精簡。這樣做也能避免我們產生過程中的 `results` 可變向量。函式程式設計風格傾向於最小化可變狀態的數量使程式碼更加簡潔。移除可變狀態還在未來有機會讓搜尋可以平行化，因為我們不需要去管理 `results` 向量的並行存取。

```rs
pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    contents
        .lines()
        .filter(|line| line.contains(query))
        .collect()
}
```

## 迴圈與疊代器

為了決定該使用迴圈還是疊代器，需要知道哪個實作比較快：是顯式 `for` 迴圈的版本，還是疊代器的版本。

我們可以透過讀取整本 Sir Arthur Conan Doyle 寫的 The Adventures of Sherlock Holmes 到 `String` 中並搜尋內容中的 `the` 來進行評測。以下為針對 `search` 函式使用 `for` 迴圈與使用疊代器的版本評測（benchmark）：

```rs
test bench_search_for  ... bench:  19,620,300 ns/iter (+/- 915,700)
test bench_search_iter ... bench:  19,234,900 ns/iter (+/- 657,200)
```

疊代器版本竟然比較快一些！在此不解釋評測的程式碼，因為這裡的重點不再於證明這兩種版本是一樣快的，而是要理解這兩種實作對效能的影響。

要做更全面的評測的話，應該要檢查使用不同大小的不同文字來作為 contents、不同單字與不同長度來作為 query，以及所有各式各樣的可能性。這邊的重點在於：疊代器雖然是高階抽象，但其編譯出來的程式碼與你親自寫出低階的程式碼幾乎相同。疊代器是 Rust 其中一種零成本抽象（zero-cost abstractions），這指的是使用的抽象不會在執行時有額外的開銷。這是 C++ 的初始設計暨實作者 Bjarne Stroustrup 在 "Foundations of C++"（2012）書中所定義的零開銷（zero-overhead）的概念：「大致上來說，C++ 的實作遵守著零開銷的原則：你沒有使用到的話，你就不必買單。而且你有使用到的話，你不可能再寫出更好的程式碼。」

作為另一個例子，以下程式碼是音訊解碼器的其中一個段落。解碼演算碼使用線性預測數學運算，並依據之前樣本的線性函式來預估未來的數值。此程式碼使用一連串的疊代器來對作用域中的三個變數進行數學運算：資料切片 `buffer`、長度為 12 的 `coefficients` 陣列以及要偏移的數量 `qlp_shift`。在範例中宣告變數但沒有給予任何數值，雖然只看此程式碼的確沒有什麼意義，但是這仍然是個現實世界中的其中一個簡例，可以來看出 Rust 如何將高階的想法轉換成低階的程式碼。

```rs
let buffer: &mut [i32];
let coefficients: [i64; 12];
let qlp_shift: i16;

for i in 12..buffer.len() {
    let prediction = coefficients.iter()
                                 .zip(&buffer[i - 12..i])
                                 .map(|(&c, &s)| c * s as i64)
                                 .sum::<i64>() >> qlp_shift;
    let delta = buffer[i];
    buffer[i] = prediction as i32 + delta;
}
```

要計算 `prediction` 的數值的話，此程式碼會遍歷 `coefficients` 的 12 個數值並使用 `zip` 方法將係數數值與 `buffer` 中之前 12 個數值做配對。然後在每個配對中，我們將數值相乘，然後相加所有結果，最後對總和往右偏移 `qlp_shift` 位。

像音訊解碼器這種的應用程式運算通常最注重效率。我們在此建立了一個疊代器，使用兩個配接器，然後消化數值。這段 Rust 程式碼會產生什麼樣的組合語言程式碼呢？在本書撰寫時，它會編譯出與你自己手寫一樣的組合語言。遍歷 `coefficients` 的數值完全不需用到迴圈：Rust 知道一共有 12 次疊代，所以它會「展開（unroll）」迴圈。展開是一種優化方式，這會移除迴圈控制程式碼並改產生針對迴圈中每次疊代的重複程式碼。

所有的係數都會存在暫存器中，這意味著存取數值會非常地快。在執行時不會有對陣列的界限檢查。這些所有 Rust 能做的優化讓產生的程式碼可以十分迅速。現在既然你已經知道了，你就可以自在地使用疊代器與閉包！它們可以寫出高階的程式碼，但不會犧牲執行時的效能。

## 參考資料

- [The Rust Programming Language](https://doc.rust-lang.org/stable/book/)
