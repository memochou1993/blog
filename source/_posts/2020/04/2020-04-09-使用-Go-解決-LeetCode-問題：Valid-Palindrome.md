---
title: 使用 Go 解決 LeetCode 問題：Valid Palindrome
date: 2020-04-09 23:39:45
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given a string, determine if it is a palindrome, considering only alphanumeric characters and ignoring cases.

- Note:

For the purpose of this problem, we define empty string as valid palindrome.

- Example 1:

```BASH
Input: "A man, a plan, a canal: Panama"
Output: true
```

- Example 2:

```BASH
Input: "race a car"
Output: false
```

## Solution

```GO
func isPalindrome(s string) bool {
	arr := []rune{}

	for _, b := range s {
		// 排除標點符號
		if (b >= '0' && b <= '9') || (b >= 'a' && b <= 'z') || (b >= 'A' && b <= 'Z') {
			arr = append(arr, b)
		}
	}

	for i := 0; i < len(arr)/2; i++ {
		diff := arr[i] - arr[len(arr)-i-1]

		// 判斷元素是否相同
		if diff == 0 {
			continue
		}

		// 判斷字母是否相同（忽略大小寫）
		if arr[i] > '9' && diff != 32 && diff != -32 {
			return false
		}

		// 判斷數字是否相同
		if arr[i] <= '9' && diff != 0 {
			return false
		}
	}

	return true
}
```

## Note

假設有以下參數：

```BASH
s: "A man, a plan, a canal: Panama"
```

說明：

```BASH
排除標點符號，只將數字和字母的位元組放進陣列中。

此時 arr 為 [65 109 97 110 97 112 108 97 110 97 99 97 110 97 108 80 97 110 97 109 97]。

再判斷陣列中的元素是否對稱。

最終返回：true
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
