---
title: 使用 Go 解決 LeetCode 問題：118. Pascal's Triangle
date: 2020-03-25 23:39:14
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given a non-negative integer numRows, generate the first numRows of Pascal's triangle.

In Pascal's triangle, each number is the sum of the two numbers directly above it.

- Example:

```bash
Input: 5
Output:
[
     [1],
    [1,1],
   [1,2,1],
  [1,3,3,1],
 [1,4,6,4,1]
]
```

## Solution

```go
func generate(numRows int) [][]int {
	// 建立一個空的二維陣列
	res := make([][]int, numRows)

	// 疊代陣列中的每一個元素
	for i := 0; i < numRows; i++ {
		// 將當前元素設置為一個空的子陣列
		res[i] = make([]int, i+1)
		// 將子陣列的第一個元素設置為 1
		res[i][0] = 1
		// 將子陣列的最後一個元素設置為 1
		res[i][i] = 1

		// 疊代子陣列的中間元素
		for j := 1; j < i; j++ {
			res[i][j] = res[i-1][j-1] + res[i-1][j]
		}
	}

	return res
}
```

## Note

假設有以下參數：

```bash
numRows: 5
```

說明：

```bash
建立一個空的二維陣列：

[[], [], [], [], []]

將子陣列的頭尾設置為 1，並將中間元素設置為相應總和值。

最終返回：[[1], [1, 1], [1, 2, 1], [1, 3, 3, 1], [1, 4, 6, 4, 1]]
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
