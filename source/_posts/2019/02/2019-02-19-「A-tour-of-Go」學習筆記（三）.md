---
title: 「A tour of Go」學習筆記（三）
permalink: 「A-tour-of-Go」學習筆記（三）
date: 2019-02-19 13:25:59
tags: ["程式寫作", "Go"]
categories: ["程式寫作", "Go", "「A tour of Go」學習筆記"]
---

## 前言

本文為「[A tour of Go](https://go-tour-zh-tw.appspot.com/)」語言指南的學習筆記。

## 環境

- macOS

## 結構體

一個結構體（ struct ）的一個字段的集合。

```GO
package main

import "fmt"

type Vertex struct {
    X int
    Y int
}

func main() {
    fmt.Println(Vertex{1, 2})
}

// 1 2
```

結構體字段使用 `.` 符號來存取。

```GO
package main

import "fmt"

type Vertex struct {
    X int
    Y int
}

func main() {
    v := Vertex{1, 2}
    v.X = 4
    fmt.Println(v.X)
}

// 4
```

結構體字段可以通過結構體指針來訪問。

```GO
package main

import "fmt"

type Vertex struct {
    X int
    Y int
}

func main() {
    p := Vertex{1, 2}
    q := &p
    q.X = 1e9
    fmt.Println(p)
}

{1000000000 2}
```

通過結構體字段的值作為列表來分配一個結構體，或使用 `{Key:Value}` 語法賦值。

```GO
package main

import "fmt"

type Vertex struct {
    X, Y int
}

var (
    p = Vertex{1, 2}  // has type Vertex
    q = &Vertex{1, 2} // has type *Vertex
    r = Vertex{X: 1}  // Y:0 is implicit
    s = Vertex{}      // X:0 and Y:0
)

func main() {
    fmt.Println(p, q, r, s)
}

// {1 2} &{1 2} {1 0} {0 0}
```

表達式 `new(T)` 分配了一個零初始化的 `T` 值，並返回指向它的指針。

```GO
package main

import "fmt"

type Vertex struct {
    X, Y int
}

func main() {
    v := new(Vertex)
    fmt.Println(v)
    v.X, v.Y = 11, 9
    fmt.Println(v)
}

// &{0 0}
// &{11 9}
```

## 陣列

類型 `[n]T` 是一個有 `n` 個類型為 `T` 的值的陣列。

```GO
var a [10]int
// [0 0 0 0 0 0 0 0 0 0]
```

陣列的長度是其類型的一部分，因此陣列不能改變大小。

```GO
package main

import "fmt"

func main() {
    var a [2]string
    a[0] = "Hello"
    a[1] = "World"
    fmt.Println(a[0], a[1])
    fmt.Println(a)

  var ab [10]int
    fmt.Println(ab)
}

// Hello World
// [Hello World]
```

## 切片

一個切片（slice）指向一個陣列，並且包含長度信息。`[]T` 是一個元素類型為 `T` 的 `slice`。

```GO
package main

import "fmt"

func main() {
    p := []int{2, 3, 5, 7, 11, 13}
    fmt.Println("p ==", p)

    for i := 0; i < len(p); i++ {
        fmt.Printf("p[%d] == %d\n", i, p[i])
    }
}

// p == [2 3 5 7 11 13]
// p[0] == 2
// p[1] == 3
// p[2] == 5
// p[3] == 7
// p[4] == 11
// p[5] == 13
```

`slice` 可以重新切片，創建一個新的 `slice` 值指向相同的陣列。

```Go
package main

import "fmt"

func main() {
    p := []int{2, 3, 5, 7, 11, 13}
    fmt.Println("p ==", p)
    fmt.Println("p[1:4] ==", p[1:4])

    // missing low index implies 0
    fmt.Println("p[:3] ==", p[:3])

    // missing high index implies len(s)
    fmt.Println("p[4:] ==", p[4:])
}

// p == [2 3 5 7 11 13]
// p[1:4] == [3 5 7]
// p[:3] == [2 3 5]
// p[4:] == [11 13]
```

`slice` 由函式 `make` 創建。這會分配一個零長度的陣列並且返回一個 `slice` 指向這個陣列。為了指定容量，可以傳遞第三個參數到 `make`。

```GO
package main

import "fmt"

func main() {
    a := make([]int, 5)
    printSlice("a", a)
    b := make([]int, 0, 5)
    printSlice("b", b)
    c := b[:2]
    printSlice("c", c)
    d := c[2:5]
    printSlice("d", d)
}

func printSlice(s string, x []int) {
    fmt.Printf("%s len=%d cap=%d %v\n",
        s, len(x), cap(x), x)
}

// a len=5 cap=5 [0 0 0 0 0]
// b len=0 cap=5 []
// c len=2 cap=5 [0 0]
// d len=3 cap=3 [0 0 0]
```

空 `slice` 的值為 `nil`，一個 `nil` 的 `slice` 的長度和容量是 0。

```GO
package main

import "fmt"

func main() {
    var z []int
    fmt.Println(z, len(z), cap(z))
    if z == nil {
        fmt.Println("nil!")
    }
}

// [] 0 0
// nil!
```

`for` 循環的 `range` 格式可以對 `slice` 或者 `map` 進行迭代循環。

```GO
package main

import "fmt"

var pow = []int{1, 2, 4, 8, 16, 32, 64, 128}

func main() {
    for i, v := range pow {
        fmt.Printf("2**%d = %d\n", i, v)
    }
}

// 2**0 = 1
// 2**1 = 2
// 2**2 = 4
// 2**3 = 8
// 2**4 = 16
// 2**5 = 32
// 2**6 = 64
// 2**7 = 128
```

使用 `_` 符號忽略 `key`。

```GO
package main

import "fmt"

func main() {
    pow := make([]int, 10)
    for i := range pow {
        pow[i] = 1 << uint(i)
    }
    for _, value := range pow {
        fmt.Printf("%d\n", value)
    }
    for key := range pow {
        fmt.Printf("%d\n", key)
    }
}

// 1
// 2
// 4
// 8
// 16
// 0
// 1
// 2
// 3
// 4
```

## 集合

集合（map）是一種無序的鍵值對的集合，使用 `make` 而不是 `new` 來創建；值為 `nil` 的 `map` 是空的，並且不能賦值。

```GO
package main

import "fmt"

type Vertex struct {
    Lat, Long float64
}

var m map[string]Vertex

func main() {
    m = make(map[string]Vertex)
    m["Bell Labs"] = Vertex{
        40.68433, -74.39967,
    }
    fmt.Println(m["Bell Labs"])
}

// {40.68433 -74.39967}
```

`map` 的文法跟結構體文法相似，不過必須有鍵名。

```GO
package main

import "fmt"

type Vertex struct {
    Lat, Long float64
}

var m = map[string]Vertex{
    "Bell Labs": Vertex{
        40.68433, -74.39967,
    },
    "Google": Vertex{
        37.42202, -122.08408,
    },
}

func main() {
    fmt.Println(m)
}

// map[Bell Labs:{40.68433 -74.39967} Google:{37.42202 -122.08408}]
```

使用 `m[key] = elem` 語法存取 `map`。使用 `elem, ok = m[key]` 語法檢測元素是否存在。

```GO
package main

import "fmt"

func main() {
    m := make(map[string]int)

    m["Answer"] = 42
    fmt.Println("The value:", m["Answer"])

    m["Answer"] = 48
    fmt.Println("The value:", m["Answer"])

    delete(m, "Answer")
    fmt.Println("The value:", m["Answer"])

    v, ok := m["Answer"]
    fmt.Println("The value:", v, "Present?", ok)
}

// The value: 42
// The value: 48
// The value: 0
// The value: 0 Present? false
```

## 函式

函式為值。

```GO
package main

import (
    "fmt"
    "math"
)

func main() {
    hypot := func(x, y float64) float64 {
        return math.Sqrt(x*x + y*y)
    }

    fmt.Println(hypot(3, 4))
}

// 5
```

## 閉包

閉包是一個函式值，它來自函式體的外部的變數引用。函式可以對這個引用值進行存取；意即，這個函式被「綁定」在這個變數上。

```GO
package main

import "fmt"

func adder() func(int) int {
    sum := 0
    return func(x int) int {
        sum += x
        return sum
    }
}

func main() {
    pos, neg := adder(), adder()
    for i := 0; i < 10; i++ {
        fmt.Println(
            pos(i),
            neg(-2*i),
        )
    }
}

// 0 0
// 1 -2
// 3 -6
// 6 -12
// 10 -20
// 15 -30
// 21 -42
// 28 -56
// 36 -72
// 45 -90
```
