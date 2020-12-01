---
title: 使用 Benchmark 為 Go 專案進行效能測試
permalink: 使用-Benchmark-為-Go-專案進行效能測試
date: 2020-12-01 14:46:04
tags: ["程式設計", "Go", "測試"]
categories: ["程式設計", "Go", "其他"]
---

## 前言

Go 的 `testing` 標準庫提供 Benchmark 效能測試，以下替三種將數字轉為字串的函式做效能測試。

## 做法

新增 `main.go` 檔：

```GO
import (
	"fmt"
	"log"
	"strconv"
)

func main() {
	log.Println(print01(1000))
	log.Println(print02(1000))
	log.Println(print03(1000))
}

func print01(num int) string {
	return fmt.Sprintf("%d", num)
}

func print02(num int64) string {
	return strconv.FormatInt(num, 10)
}

func print03(num int) string {
	return strconv.Itoa(num)
}
```

新增 `main_test.go`：

```GO
package main

import "testing"

func TestPrint01(t *testing.T) {
	if print01(1000) != "1000" {
		t.Fatal("error")
	}
}

func TestPrint02(t *testing.T) {
	if print02(int64(1000)) != "1000" {
		t.Fatal("error")
	}
}

func TestPrint03(t *testing.T) {
	if print03(1000) != "1000" {
		t.Fatal("error")
	}
}

func BenchmarkPrint01(b *testing.B) {
	for i := 0; i < b.N; i++ {
		print01(1000)
	}
}

func BenchmarkPrint02(b *testing.B) {
	for i := 0; i < b.N; i++ {
		print02(1000)
	}
}

func BenchmarkPrint03(b *testing.B) {
	for i := 0; i < b.N; i++ {
		print03(1000)
	}
}
```

- 檔案名稱以 `_test` 做為後綴。
- 方法名稱以 `Benchmark` 做為前綴。
- 在迴圈內放置要測試的程式碼。
- Go 內建 `b.N` 循環次數，以一秒鐘計算。

## 效能測試

執行效能測試：

```BASH
go test -v -bench=. -run=none -benchmem .
```
- 參數 `-v` 輸出測試的方法名稱等日誌。
- 參數 `-bench` 執行 Benchmark。
- 參數 `-run=none` 可以執行特定的測試，由於沒有叫做 `none` 的測試，所以只會跑 Benchmark。
- 參數 `-benchme` 顯示使用的記憶體空間。

## 參考資料

- [如何在 Go 語言內寫效能測試](https://blog.wu-boy.com/2018/06/how-to-write-benchmark-in-go/)
