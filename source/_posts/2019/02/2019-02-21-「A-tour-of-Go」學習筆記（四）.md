---
title: 「A tour of Go」學習筆記（四）
permalink: 「A-tour-of-Go」學習筆記（四）
date: 2019-02-21 10:25:58
tags: ["程式寫作", "Go"]
categories: ["程式寫作", "Go", "「A tour of Go」學習筆記"]
---

## 前言
本文為「[A tour of Go](https://go-tour-zh-tw.appspot.com/)」語言指南的學習筆記。

## 環境
- macOS

## 方法
Go 沒有「類」，但是可以在結構體類型上定義方法。「方法接收者」寫在 `func` 關鍵字和方法名稱之間的參數中。
```GO
package main

import (
    "fmt"
    "math"
)

type Vertex struct {
    X, Y float64
}

func (v *Vertex) Abs() float64 {
    return math.Sqrt(v.X * v.X + v.Y * v.Y)
}

func main() {
    v := &Vertex{3, 4}
    fmt.Println(v.Abs())
}

// 5
```

可以對包中的任意類型定義任意方法，但不能對來自其他包的類型或基礎類型定義方法。
```GO
package main

import (
    "fmt"
    "math"
)

type MyFloat float64

func (f MyFloat) Abs() float64 {
    if f < 0 {
        return float64(-f)
    }
    return float64(f)
}

func main() {
    f := MyFloat(-math.Sqrt2)
    fmt.Println(f.Abs())
}

// 1.4142135623730951
```

方法可以與命名類型或命名類型的指針關聯。有兩個原因需要使用「指針接收者」。

首先避免在每個方法調用中拷貝值（如果值類型是大的結構體的話會更有效率）。其次，方法可以修改接收者指向的值。

以下程式碼，當 `v` 是 `Vertex` 的時候 `Scale` 方法沒有任何作用。因為當 `v` 是一個值（非指針）的時候，方法看到的是 `Vertex` 的副本，無法修改原始值。
```Go
package main

import (
    "fmt"
    "math"
)

type Vertex struct {
    X, Y float64
}

func (v *Vertex) Scale(f float64) {
    v.X = v.X * f
    v.Y = v.Y * f
}

func (v *Vertex) Abs() float64 {
    return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func main() {
    v := &Vertex{3, 4}
    v.Scale(5)
    fmt.Println(v, v.Abs())
}

// &{15 20} 25
```

## 介面
介面類型是由一組方法定義的集合，介面類型的值可以存放實現這些方法的任何值。
```GO
package main

import (
    "fmt"
    "math"
)

type Abser interface {
    Abs() float64
}

func main() {
    // 存放實現該方法的值
    var a Abser
    f := MyFloat(-math.Sqrt2)
    v := Vertex{3, 4}

    // a MyFloat 實現 Abser
    a = f
    // a *Vertex 實現 Abser
    a = &v

    // 以下 v 是 Vertex（不是 *Vertex），無法實現 Abser
    // a = v

    fmt.Println(a.Abs())
}

type MyFloat float64

func (f MyFloat) Abs() float64 {
    if f < 0 {
        return float64(-f)
    }
    return float64(f)
}

type Vertex struct {
    X, Y float64
}

func (v *Vertex) Abs() float64 {
    return math.Sqrt(v.X * v.X + v.Y * v.Y)
}

// 5
```

「隱式介面」是類型通過實現那些方法來實現介面，沒有顯式聲明的必要。

隱式介面解藕了實現介面的包和定義介面的包：互不依賴。因此，也就無需在每一個實現上增加新的介面名稱，
```GO
package main

import (
    "fmt"
    "os"
)

type Reader interface {
    Read(b []byte) (n int, err error)
}

type Writer interface {
    Write(b []byte) (n int, err error)
}

type ReadWriter interface {
    Reader
    Writer
}

func main() {
    var w Writer

    // os.Stdout 實現 Writer
    w = os.Stdout

    fmt.Fprintf(w, "hello, writer\n")
}

// hello, writer
```

## 錯誤
錯誤是可以用字符串描述自己的任何東西。主要思路是由預定義的內建介面類型 `error`，和方法 `Error`，返回字符串。
```GO
type error interface {
    Error() string
}
```

當用 `fmt` 包的多種不同的列印函式輸出一個 `error` 時，會自動的調用該方法。
```GO
package main

import (
    "fmt"
    "time"
)

type MyError struct {
    When time.Time
    What string
}

func (e *MyError) Error() string {
    return fmt.Sprintf("at %v, %s", e.When, e.What)
}

func run() error {
    return &MyError{
        time.Now(),
        "it didn't work",
    }
}

func main() {
    if err := run(); err != nil {
        fmt.Println(err)
    }
}

// at 2009-11-10 23:00:00 +0000 UTC m=+0.000000001, it didn't work
```