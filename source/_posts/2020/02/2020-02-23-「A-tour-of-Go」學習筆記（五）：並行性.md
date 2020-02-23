---
title: 「A tour of Go」學習筆記（五）：並行性
permalink: 「A-tour-of-Go」學習筆記（五）：並行性
date: 2020-02-23 17:47:10
tags: ["程式寫作", "Go"]
categories: ["程式寫作", "Go", "「A tour of Go」學習筆記"]
---

## 前言

本文為「[A tour of Go](https://go-tour-zh-tw.appspot.com/)」語言指南的學習筆記。

## goroutine

`goroutine` 是由 Go 運行時所管理的輕量級執行緒（thread）。以下會啟動一個新的 `goroutine` 並且執行：

```GO
go f(x, y, z)
```

- `f`、`x`、`y` 和 `z` 的賦值發生在當前的 `goroutine` 中，而 `f` 的執行發生在新的 `goroutine` 中。

`goroutine` 在相同的地址空間中運行。

```GO
package main

import (
	"fmt"
	"time"
)

func say(s string) {
	for i := 0; i < 5; i++ {
		time.Sleep(100 * time.Millisecond)
		fmt.Println(s)
	}
}

func main() {
	go say("world")
	say("hello")
}
```

## 通道

通道（channel）是帶有型別的管道，可以通過它使用通道操作符 `<-` 來發送或接收值。

```GO
ch <- v    // 將 v 發送至名為 ch 的 channel
v := <-ch  // 從名為 ch 的 channel 接收值並賦予 v
```

- 箭頭就是數據流的方向。

就像集合和切片一樣，`channel` 在使用前必須先創建：

```GO
ch := make(chan int)
```

預設情況下，發送和接收操作在另一端準備好之前都會阻塞，這使得 `goroutine` 可以在沒有顯式的鎖或靜態變數的情況下進行同步。

以下範例對切片中的數進行求和，將任務分配給兩個 `goroutine`。一旦兩個 `goroutine` 完成了它們的計算，它就能算出最終的結果。

```GO
package main

import "fmt"

func sum(s []int, c chan int) {
	sum := 0
	for _, v := range s {
		sum += v
	}
	c <- sum // 將 sum 發送至名為 c 的 channel
}

func main() {
	s := []int{7, 2, 8, -9, 4, 0}

	c := make(chan int)
	go sum(s[:len(s)/2], c)
	go sum(s[len(s)/2:], c)
	x, y := <-c, <-c // 從名為 c 的 channel 接收值

	fmt.Println(x, y, x+y)
}
```

## 具有緩衝的通道

`channel` 是可以具有緩衝的。將緩衝長度作為第二個參數提供給 `make()` 函式，來初始化一個具有緩衝的 `channel`。

```GO
ch := make(chan int, 100)
```

只有當 `channel` 的緩衝區被填滿後，向其發送資料時才會阻塞。當緩衝區為空時，接收的一端會阻塞。

```GO
package main

import "fmt"

func main() {
	ch := make(chan int, 2)
	ch <- 1
	ch <- 2
	fmt.Println(<-ch)
	fmt.Println(<-ch)
}
```

## range 和 close

發送者可以透過 `close` 關閉一個 `channel` 來表示沒有需要發送的值了。接收者可以透過為接收表達式分配第二個參數來測試 `channel` 是否被關閉。如果沒有值可以接收，而且 `channel` 已被關閉，那麼執行完之後，陳述式 `v, ok := <-ch` 的 `ok` 會被設置為 `false`。

陳述式 `for i := range c` 會不斷地從 `channel` 接收值，直到它被關閉為止。

只有發送者才能關閉 `channel` ，而接收者不能。向一個已經被關閉的 `channel` 發送資料，會引發 `panic`。

`channel` 與檔案不同，通常情況下無需關閉。只有在必須告訴接收者不再有需要發送的值時才有必要關閉，例如停止一個 `range` 迴圈。

```GO
package main

import (
	"fmt"
)

func fibonacci(n int, c chan int) {
	x, y := 0, 1
	for i := 0; i < n; i++ {
		c <- x
		x, y = y, x+y
	}
	close(c)
}

func main() {
	c := make(chan int, 10)
	go fibonacci(cap(c), c)
	for i := range c {
		fmt.Println(i)
	}
}
```

## select

`select` 語句使一個 `goroutine` 可以等待多個 `channel` 操作。

`select` 會阻塞到某個分支可以繼續執行為止，這時就會執行該分支。當多個分支都準備好時，會隨機選擇一個執行。

```GO
package main

import "fmt"

func fibonacci(c, quit chan int) {
	x, y := 0, 1
	for {
		select {
		case c <- x:
			x, y = y, x+y
		case <-quit:
			fmt.Println("quit")
			return
		}
	}
}

func main() {
	c := make(chan int)
	quit := make(chan int)
	go func() {
		for i := 0; i < 10; i++ {
			fmt.Println(<-c)
		}
		quit <- 0
	}()
	fibonacci(c, quit)
}
```

當 `select` 中的其他分支都沒有準備好時，`default` 分支就會執行。

為了在嘗試發送或接收時不發生阻塞，可以使用 `default` 分支：

```GO
package main

import (
	"fmt"
	"time"
)

func main() {
	tick := time.Tick(100 * time.Millisecond)
	boom := time.After(500 * time.Millisecond)
	for {
		select {
		case <-tick:
			fmt.Println("tick.")
		case <-boom:
			fmt.Println("BOOM!")
			return
		default:
			fmt.Println("    .")
			time.Sleep(50 * time.Millisecond)
		}
	}
}
```

## sync.Mutex

`channel` 非常適合在各個 `goroutine` 之間進行通訊，但是如果並不需要通訊，只是要保證每次只有一個 `goroutine` 能夠存取一個共用的變數，並且避免衝突，這裡就要涉及到「互斥」（mutual exclusion）的概念，使用「互斥鎖」（Mutex）這一資料結構來提供這種機制。

Go 標準庫提供了 `sync.Mutex` 型別以及兩個方法：`Lock()` 和 `Unlock()`。

可以透過在程式碼前調用 `Lock()` 方法，在程式碼後調用 `Unlock()` 方法，來保證一段程式碼的互斥執行。

也可以用 `defer` 語句來保證互斥鎖一定會被解鎖。

```GO
package main

import (
	"fmt"
	"sync"
	"time"
)

// SafeCounter 的並行使用是安全的
type SafeCounter struct {
	v   map[string]int
	mux sync.Mutex
}

// Inc 用來增加某個 key 計數器的值
func (c *SafeCounter) Inc(key string) {
	c.mux.Lock()
	// Lock 之後同一時刻，只有一個 goroutine 能存取 c.v
	c.v[key]++
	c.mux.Unlock()
}

// Value 用來返回某個 key 計數器的值
func (c *SafeCounter) Value(key string) int {
	c.mux.Lock()
	// Lock 之後同一時刻，只有一個 goroutine 能存取 c.v
	defer c.mux.Unlock()
	return c.v[key]
}

func main() {
	c := SafeCounter{v: make(map[string]int)}
	for i := 0; i < 1000; i++ {
		go c.Inc("somekey")
	}

	time.Sleep(time.Second)
	fmt.Println(c.Value("somekey"))
}
```
