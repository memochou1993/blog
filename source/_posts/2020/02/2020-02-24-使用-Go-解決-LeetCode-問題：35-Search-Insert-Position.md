---
title: 使用 Go 解決 LeetCode 問題：35. Search Insert Position
date: 2020-02-24 23:36:51
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given a sorted array and a target value, return the index if the target is found. If not, return the index where it would be if it were inserted in order.

You may assume no duplicates in the array.

- Example 1:

```bash
Input: [1,3,5,6], 5
Output: 2
```

- Example 2:

```bash
Input: [1,3,5,6], 2
Output: 1
```

- Example 3:

```bash
Input: [1,3,5,6], 7
Output: 4
```

- Example 4:

```bash
Input: [1,3,5,6], 0
Output: 0
```

## Solution

```go
func searchInsert(nums []int, target int) int {
	// 低點索引
	low := 0
	// 高點索引
	high := len(nums) - 1

	for low <= high {
		// 中間索引
		mid := (low + high) / 2

		if nums[mid] > target {
			// 將高點索引設置為中間索引，並減 1 避免與低點索引重疊
			high = mid - 1
		} else if nums[mid] < target {
			// 將低點索引設置為中間索引，並加 1 避免與高點索引重疊
			low = mid + 1
		} else {
			return mid
		}
	}

	return low
}
```

## Note

假設有以下參數：

```bash
nums: [1, 3, 5, 6, 9, 13, 18, 24, 36, 45, 68, 78, 88, 95]
target: 7
```

說明：

```bash
第 1 次比較：

low 為 0，high 為 13，mid 為 6。

------------------------------------------------------------
 l                  m                           h
[1, 3, 5, 6, 9, 13, 18, 24, 36, 45, 68, 78, 88, 95]
------------------------------------------------------------

中間的數字為 18，大於指定值 7，所以設置 high 為 5。

第 2 次比較：

low 為 0，high 為 5，mid 為 2。

------------------------------------------------------------
 l     m        h
[1, 3, 5, 6, 9, 13, 18, 24, 36, 45, 68, 78, 88, 95]
------------------------------------------------------------

中間的數字為 5，小於指定值 7，所以設置 low 為 3。

第 3 次比較：

low 為 3，high 為 5，mid 為 4。

------------------------------------------------------------
          l  m  h
[1, 3, 5, 6, 9, 13, 18, 24, 36, 45, 68, 78, 88, 95]
------------------------------------------------------------

中間的數字為 9 大於指定值 7，所以設置 high 為 3。

第 4 次比較：

low 為 3，high 為 3，mid 為 3。

------------------------------------------------------------
          l
          m
          h
[1, 3, 5, 6, 9, 13, 18, 24, 36, 45, 68, 78, 88, 95]
------------------------------------------------------------

中間的數字為 6 小於指定值 7，所以設置 low 為 4。

最終返回：4
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
