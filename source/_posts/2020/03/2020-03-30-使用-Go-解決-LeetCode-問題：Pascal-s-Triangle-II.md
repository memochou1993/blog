---
title: 使用 Go 解決 LeetCode 問題：Pascal's Triangle II
date: 2020-03-30 23:39:22
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given a non-negative index k where k ≤ 33, return the kth index row of the Pascal's triangle.

Note that the row index starts from 0.

In Pascal's triangle, each number is the sum of the two numbers directly above it.

- Example:

```BASH
Input: 3
Output: [1,3,3,1]
```

- Follow up:

Could you optimize your algorithm to use only O(k) extra space?

## Solution

```GO
func getRow(rowIndex int) []int {
	// 建立一個空的陣列
	res := make([]int, rowIndex+1)

	// 將第一個元素設置為 1
	res[0] = 1
	// 將最後一個元素設置為 1
	res[rowIndex] = 1

	// 找出中間的索引
	mid := (rowIndex+1)/2 + 1

	// 從陣列索引為 1 的位置開始疊代
	for i := 1; i < mid; i++ {
		// 用上一個元素計算出當前元素
		res[i] = res[i-1] * (rowIndex + 1 - i) / i
		// 將對稱的位置設置為當前元素
		res[rowIndex-i] = res[i]
	}

	return res
}
```

## Note

假設有以下參數：

```BASH
rowIndex: 4
```

說明：

```BASH
設置頭尾元素：

陣列變為 [1, 0, 0, 0, 1]。

第 1 次迴圈：

將索引位置為 1 的元素設置為 1 * 4 / 1，即 4；並將對稱的位置設置為 4。

陣列變為 [1, 4, 0, 4, 1]。

第 2 次迴圈：

將索引位置為 2 的元素設置為 4 * 3 / 2，即 6；並將對稱的位置設置為 6。

陣列變為 [1, 4, 6, 4, 1]。

最終返回： [1, 4, 6, 4, 1]
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
