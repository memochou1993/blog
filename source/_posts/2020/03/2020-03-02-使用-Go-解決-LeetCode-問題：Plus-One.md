---
title: 使用 Go 解決 LeetCode 問題：Plus One
date: 2020-03-02 23:37:26
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given a non-empty array of digits representing a non-negative integer, plus one to the integer.

The digits are stored such that the most significant digit is at the head of the list, and each element in the array contain a single digit.

You may assume the integer does not contain any leading zero, except the number 0 itself.

- Example 1:

```BASH
Input: [1,2,3]
Output: [1,2,4]
Explanation: The array represents the integer 123.
```

- Example 2:

```BASH
Input: [4,3,2,1]
Output: [4,3,2,2]
Explanation: The array represents the integer 4321.
```

## Solution

```GO
func plusOne(digits []int) []int {
	// 將最後一個元素加上 1
	digits[len(digits)-1]++

	// 疊代每一個數字
	for i := len(digits) - 1; i > 0; i-- {
		// 如果最後一個元素小於 10，就直接返回
		if digits[i] < 10 {
			return digits
		}

		// 處理進位
		digits[i] = 0
		digits[i-1]++
	}

	// 處理第一個元素的進位
	if digits[0] == 10 {
		digits = make([]int, len(digits)+1)
		digits[0] = 1
	}

	return digits
}
```

## Note

假設有以下參數：

```BASH
digits: [9, 9, 9]
```

說明：

```BASH
將最後一個元素 + 1，digits 變成 [9, 9, 10]。

第 1 次迴圈：

將 digits 的第 3 個元素設置為 0，digits 變成 [9, 9, 0]。

處理進位後，digits 變成 [9, 10, 0]。

第 2 次迴圈：

將 digits 的第 2 個元素設置為 0，digits 變成 [9, 0, 0]。

處理進位後，digits 變成 [10, 0, 0]。

由於 digits 的第 1 個元素為 10，因此處理第 1 個元素的進位，將 digits 設置為 [1, 0, 0, 0]。

最終返回：[1, 0, 0, 0]
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
