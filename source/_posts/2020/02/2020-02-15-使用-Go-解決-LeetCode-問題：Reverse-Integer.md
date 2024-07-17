---
title: 使用 Go 解決 LeetCode 問題：Reverse Integer
date: 2020-02-15 23:35:27
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given a 32-bit signed integer, reverse digits of an integer.

- Example 1:

```BASH
Input: 123
Output: 321
Example 2:
```

- Example 2:

```BASH
Input: -123
Output: -321
Example 3:
```

- Example 3:

```BASH
Input: 120
Output: 21
```

## Solution

```GO
func reverse(x int) int {
	// 宣告一個正負數的標記
	sign := 1

	// 如果 x 是負數，將標記設置為 -1，並將 x 修改為正數
	if x < 0 {
		sign = -1
		x *= -1
	}

	result := 0
	for x > 0 {
		// 取得 x 的尾數
		temp := x % 10
		// 將 x 的尾數加至 result
		result = result*10 + temp
		// 去除 x 的尾數
		x = x / 10
	}

	// 用正負數的標記修正 result
	result *= sign

	// 避免 result 溢出
	if result > math.MaxInt32 || result < math.MinInt32 {
		result = 0
	}

	return result
}
```

## Note

假設有以下參數：

```BASH
x: 321
```

說明：

```BASH
x 為 321：
result 為 0：

取得 x 的尾數為 1，把 result 乘以 10 加上 1，把 x 除以 10。

x 為 32：
result 為 1：

取得 x 的尾數為 2，把 result 乘以 10 加上 2，把 x 除以 10。

x 為 3：
result 為 21：

取得 x 的尾數為 3，把 result 乘以 10 加上 3，把 x 除以 10。

x 為 0：
result 為 321：
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
