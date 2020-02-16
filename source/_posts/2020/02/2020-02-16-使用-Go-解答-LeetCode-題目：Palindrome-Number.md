---
title: 使用 Go 解答 LeetCode 題目：Palindrome Number
permalink: 使用-Go-解答-LeetCode-題目：Palindrome-Number
date: 2020-02-16 13:08:04
tags: ["程式寫作", "Go", "演算法", "LeetCode"]
categories: ["程式寫作", "Go", "演算法"]
---

## 題目

(9) Palindrome Number

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

## 解答

```GO
func isPalindrome(x int) bool {
	// 判斷是否為負數
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

## 程式碼

[GitHub](https://github.com/memochou1993/leetcode-in-go)
