---
title: 使用 Go 解決 LeetCode 問題：12. Integer to Roman
date: 2020-02-16 23:35:47
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

Given an integer, convert it to a roman numeral. Input is guaranteed to be within the range from 1 to 3999.

- Example 1:

```bash
Input: 3
Output: "III"
```

- Example 2:

```bash
Input: 4
Output: "IV"
```

- Example 3:

```bash
Input: 9
Output: "IX"
```

- Example 4:

```bash
Input: 58
Output: "LVIII"
Explanation: L = 50, V = 5, III = 3.
```

- Example 5:

```bash
Input: 1994
Output: "MCMXCIV"
Explanation: M = 1000, CM = 900, XC = 90 and IV = 4.
```

## Solution

```go
func intToRoman(num int) string {
	// 建立一個二維陣列的對照表
	r := [4][]string{
		[]string{"", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"},
		[]string{"", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC"},
		[]string{"", "C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM"},
		[]string{"", "M", "MM", "MMM"},
	}

	return r[3][num/1000] + // 取出千位數轉換
		r[2][num/100%10] + // 取出百位數轉換
		r[1][num/10%10] + // 取出十位數轉換
		r[0][num%10] // 取出個位數轉換
}
```

## Note

假設有以下參數：

```bash
num: 58
```

說明：

```bash
拼接第 1 個字母：

58 除以 1000 為 0，在對照表找到索引為 3 的陣列中，索引為 0 的元素。

拼接第 2 個字母：

58 除以 100 取尾數為 0，在對照表找到索引為 2 的陣列中，索引為 0 的元素。

拼接第 3 個字母：

58 除以 10 取尾數為 5，在對照表找到索引為 1 的陣列中，索引為 5 的元素。

拼接第 4 個字母：

58 取尾數為 8，在對照表找到索引為 0 的陣列中，索引為 8 的元素。

最終返回："LVIII"
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
