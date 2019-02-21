---
title: 「A tour of Go」學習筆記（一）
permalink: 「A-tour-of-Go」學習筆記（一）
date: 2019-02-14 17:13:09
tags: ["程式寫作", "Go"]
categories: ["程式寫作", "Go", "「A tour of Go」學習筆記"]
---

## 前言
本文為「[A tour of Go](https://go-tour-zh-tw.appspot.com/)」語言指南的學習筆記。

## 環境
- macOS

## 安裝
使用 Homebrew 安裝 Go。
```
$ brew install go
```

查看 Go 版本。
```
$ go version
go version go1.11.5
```

執行 Go 程式。
```
$ go run hello.go
```

## 包
每個 Go 程式由包組成，程式運行的入口是 `main` 包。
```GO
package main

import (
    "fmt"
    "math/rand"
)

func main() {
    fmt.Println("My favorite number is", rand.Intn(10))
}

// My favorite number is 1
```

## 導入
使用 `import` 關鍵字導入包，可以使用圓括號或編寫多個導入語句。
```GO
package main

import "fmt"
import "math"

func main() {
    fmt.Printf("Now you have %g problems.",
    math.Nextafter(2, 3))
}

// Now you have 2.0000000000000004 problems.
```

## 導出名
導入一個包之後，可以用其導出的名稱來調用它，並以大寫字母調用包的函式。
```GO
package main

import (
    "fmt"
    "math"
)

func main() {
    fmt.Println(math.Pi)
}

// 3.141592653589793
```

## 函式
函式可以接收參數，型別放在參數名稱之後。
```GO
package main

import "fmt"

func add(x int, y int) int {
    return x + y
}

func main() {
    fmt.Println(add(42, 13))
}

// 55
```

若函式的每一個參數皆為相同型別，可簡寫為：
```GO
package main

import "fmt"

func add(x, y int) int {
    return x + y
}

func main() {
    fmt.Println(add(42, 13))
}

// 55
```

## 多值返回
函式可以返回一個以上的值。
```GO
package main

import "fmt"

func swap(x, y string) (string, string) {
    return y, x
}

func main() {
    a, b := swap("hello", "world")
    fmt.Println(a, b)
}

// world hello
```

## 命名返回值
函式所返回的值可以像變數一樣命名，並直接使用 `return` 語句，將當前的值返回。
```GO
package main

import "fmt"

func split(sum int) (x, y int) {
    x = sum * 4 / 9
    y = sum - x
    return
}

func main() {
    fmt.Println(split(17))
}

// 7 10
```

## 變數
使用 `var` 關鍵字宣告變數，型別放在參數名稱之後。
```GO
package main

import "fmt"

var i int
var c, python, java bool

func main() {
    fmt.Println(i, c, python, java)
}

// 0 false false false
```

宣告變數時，可以包含初始值，型別可以被省略。
```GO
package main

import "fmt"

var i, j int = 1, 2
var c, python, java = true, false, "no!"

func main() {
    fmt.Println(i, j, c, python, java)
}

// 1 2 true false no!
```

使用 `:=` 賦值語句宣告變數，作為 `var` 關鍵字的簡寫。
```GO
package main

import "fmt"

func main() {
    var i, j int = 1, 2
    k := 3
    c, python, java := true, false, "no!"

    fmt.Println(i, j, k, c, python, java)
}

// 1 2 3 true false no!
```

## 型別
Go 的基本型別有 bool、string、int、int8、int16、int32、int64、uint、uint8、uint16、uint32、uint64、uintptr、byte（uint8 的別名）、rune(int32 的別名)、float32、float64、complex64、complex128。
```GO
package main

import (
    "fmt"
    "math/cmplx"
)

var (
    ToBe   bool       = false
    MaxInt uint64     = 1<<64 - 1
    z      complex128 = cmplx.Sqrt(-5 + 12i)
)

func main() {
    const f = "%T(%v)\n"
    fmt.Printf(f, ToBe, ToBe)
    fmt.Printf(f, MaxInt, MaxInt)
    fmt.Printf(f, z, z)
}

// bool(false)
// uint64(18446744073709551615)
// complex128((2+3i))
```
- 格式化樣式 `%T` 代表輸出變數的型別

使用表達式 `T(v)` 將 `v` 的型別轉換為 `T`。
```GO
package main

import (
    "fmt"
    "math"
)

func main() {
    var x, y int = 3, 4
    var f float64 = math.Sqrt(float64(x*x + y*y))
    var z int = int(f)
    fmt.Println(x, y, z)
}

// 3 4 5
```

使用 `:=` 賦值語句也可以轉換型別。
```GO
package main

import (
    "fmt"
    "math"
)

func main() {
    x, y := 3, 4
    f := math.Sqrt(float64(x*x + y*y))
    z := int(f)
    fmt.Println(x, y, z)
}

// 3 4 5
```

## 常數
使用 `const` 關鍵字宣告變數，不能使用 `:=` 賦值語句。
```GO
package main

import "fmt"

const Pi = 3.14

func main() {
    const World = "世界"
    fmt.Println("Hello", World)
    fmt.Println("Happy", Pi, "Day")

    const Truth = true
    fmt.Println("Go rules?", Truth)
}

// Hello 世界
// Happy 3.14 Day
// Go rules? true
```

數值常數是高精度的值。
```GO
package main

import "fmt"

const (
    Big   = 1 << 100
    Small = Big >> 99
)

func needInt(x int) int {
  return x * 10 + 1
}

func needFloat(x float64) float64 {
    return x * 0.1
}

func main() {
    fmt.Println(needInt(Small))
    fmt.Println(needFloat(Small))
    fmt.Println(needFloat(Big))
}

// 21
// 0.2
// 1.2676506002282295e+29
```