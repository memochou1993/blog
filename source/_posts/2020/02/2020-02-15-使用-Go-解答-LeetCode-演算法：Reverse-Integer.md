---
title: 使用 Go 解答 LeetCode 演算法：Reverse Integer
permalink: 使用-Go-解答-LeetCode-演算法：Reverse-Integer
date: 2020-02-15 21:29:24
tags: ["程式寫作", "Go", "演算法", "LeetCode"]
categories: ["程式寫作", "Go", "演算法"]
---

## 題目

(7) Reverse Integer

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

## 解答

### 解法一

```GO
func reverse(x int) int {
	// 宣告一個正負數的標記
	sign := 1

	// 如果 x 是負數，將標記設為 -1，並將 x 修改為正數
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

## 程式碼

[GitHub](https://github.com/memochou1993/leetcode-in-go)

## 參考資料

- [LeetCode-in-Go](https://github.com/aQuaYi/LeetCode-in-Go)
