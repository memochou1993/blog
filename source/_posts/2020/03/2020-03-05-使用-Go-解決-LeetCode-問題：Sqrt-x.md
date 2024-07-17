---
title: 使用 Go 解決 LeetCode 問題：Sqrt(x)
date: 2020-03-05 23:37:41
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Implement int sqrt(int x).

Compute and return the square root of x, where x is guaranteed to be a non-negative integer.

Since the return type is an integer, the decimal digits are truncated and only the integer part of the result is returned.

- Example 1:

```bash
Input: 4
Output: 2
```

- Example 2:

```bash
Input: 8
Output: 2
Explanation: The square root of 8 is 2.82842..., and since the decimal part is truncated, 2 is returned.
```

## Solution

```go
func mySqrt(x int) int {
	// 左端
	left := 0
	// 右端
	right := x

	for left <= right {
		// 中間值
		mid := (left + right) / 2

		if mid*mid > x {
			// 將右端設置為中間值，並減 1 避免與左端重疊
			right = mid - 1
		} else if mid*mid < x {
			// 將左端設置為中間值，並減 1 避免與右端重疊
			left = mid + 1
		} else {
			return mid
		}
	}

	return right
}
```

## Note

假設有以下參數：

```bash
x: 26
```

說明：

```bash
第 1 次比較：

left 為 0，right 為 26，mid 為 13。

------------------------------------------------------------
 l       m        r
[0, ..., 13, ..., 26]
------------------------------------------------------------

中間的數字為 13，其平方大於 x，所以設置 right 為 12。

第 2 次比較：

left 為 0，right 為 12，mid 為 6。

------------------------------------------------------------
 l       m       r
[0, ..., 6, ..., 12]
------------------------------------------------------------

中間的數字為 6，其平方大於 x，所以設置 right 為 5。

第 3 次比較：

left 為 0，right 為 5，mid 為 2。

------------------------------------------------------------
 l       m       r
[0, ..., 2, ..., 5]
------------------------------------------------------------

中間的數字為 2，其平方小於 x，所以設置 left 為 3。

第 4 次比較：

left 為 3，right 為 5，mid 為 4。

------------------------------------------------------------
 l  m  r
[3, 4, 5]
------------------------------------------------------------

中間的數字為 4，其平方小於 x，所以設置 left 為 5。

第 5 次比較：

left 為 5，right 為 5，mid 為 5，結束迴圈。

------------------------------------------------------------
 l
 m
 r
[5]
------------------------------------------------------------

最終返回：5
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
