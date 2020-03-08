---
title: 「A tour of Go」學習筆記（二）：控制流程
permalink: 「A-tour-of-Go」學習筆記（二）：控制流程
date: 2019-02-15 10:42:53
tags: ["程式設計", "Go"]
categories: ["程式設計", "Go", "「A tour of Go」學習筆記"]
---

## 前言

本文為「[A tour of Go](https://go-tour-zh-tw.appspot.com/)」語言指南的學習筆記。

## 控制流程

### for

Go 只有一種循環結構 `for` 循環。`for` 語句沒有圓括號。

```GO
package main

import "fmt"

func main() {
    sum := 0
    for i := 0; i < 10; i++ {
        sum += i
    }
    fmt.Println(sum)
}

// 45
```

前置與後置語句可以省略。

```GO
package main

import "fmt"

func main() {
    sum := 1
    for ; sum < 1000; {
        sum += sum
    }
    fmt.Println(sum)
}

// 1024
```

`for` 語句可以是其他語言的 `while` 語句。

```GO
package main

import "fmt"

func main() {
    sum := 1
    for sum < 1000 {
        sum += sum
    }
    fmt.Println(sum)
}

// 1024
```

無窮迴圈是將循環條件省略。

```GO
package main

func main() {
    for {
    }
}

// process took too long
```

### if

`if` 語句沒有圓括號。

```GO
package main

import (
    "fmt"
    "math"
)

func sqrt(x float64) string {
    if x < 0 {
        return sqrt(-x) + "i"
    }
    return fmt.Sprint(math.Sqrt(x))
}

func main() {
    fmt.Println(sqrt(2), sqrt(-4))
}

// 1.4142135623730951 2i
```

- `math.Sqrt()` 函式用來取得平方根。

`if` 語句可以在條件之前執行一個簡單的語句，由這個語句定義的變數，其作用域只限於在該 `if` 語句之內。

```GO
package main

import (
    "fmt"
    "math"
)

func pow(x, n, lim float64) float64 {
    if v := math.Pow(x, n); v < lim {
        return v
    }
    return lim
}

func main() {
    fmt.Println(
        pow(3, 2, 10),
        pow(3, 3, 20),
    )
}

// 9 20
```

在 `if` 的便捷語句定義的變數可以在對應的 `else` 區塊中使用。

```GO
package main

import (
    "fmt"
    "math"
)

func pow(x, n, lim float64) float64 {
    if v := math.Pow(x, n); v < lim {
        return v
    } else {
        fmt.Printf("%g >= %g\n", v, lim)
    }
    // can't use v here, though
    return lim
}

func main() {
    fmt.Println(
        pow(3, 2, 10),
        pow(3, 3, 20),
    )
}

// 27 >= 20
// 9 20
```

### switch

`switch` 語句的條件從上到下執行。

```GO
package main

import (
    "fmt"
    "runtime"
)

func main() {
    fmt.Print("Go runs on ")
    switch os := runtime.GOOS; os {
    case "darwin":
        fmt.Println("OS X.")
    case "linux":
        fmt.Println("Linux.")
    default:
        // freebsd, openbsd,
        // plan9, windows...
        fmt.Printf("%s.", os)
    }
}

// Go runs on nacl.
```

除非使用 `fallthrough` 語句，否則匹配成功會自動終止

```GO
package main

import (
    "fmt"
    "time"
)

func main() {
    fmt.Println("When's Saturday?")
    today := time.Now().Weekday()
    switch time.Saturday {
    case today + 0:
        fmt.Println("Today.")
    case today + 1:
        fmt.Println("Tomorrow.")
    case today + 2:
        fmt.Println("In two days.")
    default:
        fmt.Println("Too far away.")
    }
}

// When's Saturday?
// Too far away.
```

沒有條件的 `switch` 語句同 `switch true` 一樣，用以替代長的 `if-then-else` 條件式。

```GO
package main

import (
    "fmt"
    "time"
)

func main() {
    t := time.Now()
    switch {
    case t.Hour() < 12:
        fmt.Println("Good morning!")
    case t.Hour() < 17:
        fmt.Println("Good afternoon.")
    default:
        fmt.Println("Good evening.")
    }
}

// Good evening.
```
