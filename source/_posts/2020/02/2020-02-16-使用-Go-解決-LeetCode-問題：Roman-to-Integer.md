---
title: 使用 Go 解決 LeetCode 問題：Roman to Integer
date: 2020-02-16 23:35:54
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Roman numerals are represented by seven different symbols: I, V, X, L, C, D and M.

Symbol | Value
--- | ---
I | 1
V | 5
X | 10
L | 50
C | 100
D | 500
M | 1000

For example, two is written as II in Roman numeral, just two one's added together. Twelve is written as, XII, which is simply X + II. The number twenty seven is written as XXVII, which is XX + V + II.

Roman numerals are usually written largest to smallest from left to right. However, the numeral for four is not IIII. Instead, the number four is written as IV. Because the one is before the five we subtract it making four. The same principle applies to the number nine, which is written as IX. There are six instances where subtraction is used:

- I can be placed before V (5) and X (10) to make 4 and 9.
- X can be placed before L (50) and C (100) to make 40 and 90.
- C can be placed before D (500) and M (1000) to make 400 and 900.

Given a roman numeral, convert it to an integer. Input is guaranteed to be within the range from 1 to 3999.

## Solution

```GO
func romanToInt(s string) int {
	result := 0

	// 建立一個對照表
	m := map[byte]int{
		'I': 1, // 73:1
		'V': 5, // 86:5
		'X': 10, // 88:10
		'L': 50, // 76:50
		'C': 100, // 67:100
		'D': 500, // 68:500
		'M': 1000, // 77:1000
	}

	// 從最後一個字母開始對照
	last := 0
	for i := len(s) - 1; i >= 0; i-- {
		// 存放對照後要處理的數字
		temp := m[s[i]]

		// 宣告一個正負數的標記
		sign := 1
		if temp < last {
			sign = -1
		}

		// 左邊字母對照後的數字比右邊字母對照後的數字小，需要相減
		result += sign * temp

		// 將 temp 放到 last 繼續比較
		last = temp
	}

	return result
}
```

## Note

假設有以下參數：

```BASH
s: XIV
```

說明：

```BASH
last 為 0。

對照 V：

V 為 5，將 temp 設為 5。

temp 大於 last，所以 result 為 5。

將 last 設為 5。

對照 I：

I 為 1，將 temp 設為 1。

temp 小於 last，所以 result 為 4。

將 last 設為 1。

對照 X：

X 為 10，將 temp 設為 10。

temp 大於 last，所以 result 為 14。

將 last 設為 10。

最終返回：14
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
