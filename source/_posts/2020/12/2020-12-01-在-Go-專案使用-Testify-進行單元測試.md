---
title: 在 Go 專案使用 Testify 進行單元測試
date: 2020-12-01 15:50:08
tags: ["Programming", "Go", "Testing"]
categories: ["Programming", "Go", "Others"]
---

## 前言

Go 的 `testing` 標準庫內建單元測試方法，不過 `testify` 套件進一步封裝，並提供許多方便的斷言方法。

以下以 LeetCode 第 1 題 Two Sum 為例，建立一些測試案例，並進行單元測試。

## 做法

下載 Testify 套件。

```bash
go get github.com/stretchr/testify
```

新增 `main.go` 檔：

```go
package main

func twoSum(nums []int, target int) []int {
	index := make(map[int]int, len(nums))

	for i, num := range nums {
		if j, ok := index[target-num]; ok == true {
			return []int{j, i}
		}
		index[num] = i
	}

	return []int{}
}
```

新增 `main_test.go` 檔，並建立測試案例：

```go
package main

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

// 測試案例
type question struct {
	p parameter
	a answer
}

// 參數
type parameter struct {
	first  []int
	second int
}

// 答案
type answer struct {
	first []int
}

func TestProblem(t *testing.T) {
	questions := []question{
		question{
			p: parameter{
				first:  []int{2, 7, 11, 15},
				second: 9,
			},
			a: answer{
				first: []int{0, 1},
			},
		},
		question{
			p: parameter{
				first:  []int{2, 7, 11, 15},
				second: 8,
			},
			a: answer{
				first: []int{},
			},
		},
	}

	for _, q := range questions {
		a, p := q.a, q.p
		assert.Equal(t, a.first, twoSum(p.first, p.second))
	}
}
```

執行測試：

```bash
go test ./...
```

- 路徑 `./...` 代表所有子資料夾下的測試都會被執行。
