---
title: 使用 Go 解決 LeetCode 問題：Palindrome Number
date: 2020-02-16 23:35:38
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Determine whether an integer is a palindrome. An integer is a palindrome when it reads the same backward as forward.

- Example 1:

```BASH
Input: 121
Output: true
```

- Example 2:

```BASH
Input: -121
Output: false
Explanation: From left to right, it reads -121. From right to left, it becomes 121-. Therefore it is not a palindrome.
```

- Example 3:

```BASH
Input: 10
Output: false
Explanation: Reads 01 from right to left. Therefore it is not a palindrome.
```

## Solution

```GO
func isPalindrome(x int) bool {
	// 判斷 x 是否為負數
	if x < 0 {
		return false
	}

	// 將 x 複製到 copy
	copy := x
	reverse := 0

	// 將 x 反轉
	for copy > 0 {
		reverse = reverse*10 + copy%10
		copy /= 10
	}

	// 判斷 x 是否和反轉的 x 相等
	return x == reverse
}
```

## Note

假設有以下參數：

```BASH
x: 121
```

說明：

```BASH
copy 為 121：
reverse 為 0：

把 reverse 乘以 10 加上 copy 的尾數為 1，把 copy 除以 10。

copy 為 12：
reverse 為 1：

把 reverse 乘以 10 加上 copy 的尾數為 2，把 copy 除以 10。

copy 為 1：
reverse 為 12：

把 reverse 乘以 10 加上 copy 的尾數為 1，把 copy 除以 10。

copy 為 0：
reverse 為 121：

判斷 reverse 是否等於 x。

最終返回：true
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
