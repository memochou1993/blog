---
title: 使用 Go 解決 LeetCode 問題：Implement strStr()
date: 2020-02-24 23:36:45
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Implement strStr().

Return the index of the first occurrence of needle in haystack, or -1 if needle is not part of haystack.

- Example 1:

```BASH
Input: haystack = "hello", needle = "ll"
Output: 2
```

- Example 2:

```BASH
Input: haystack = "aaaaa", needle = "bba"
Output: -1
```

- Clarification:

What should we return when needle is an empty string? This is a great question to ask during an interview.

For the purpose of this problem, we will return 0 when needle is an empty string. This is consistent to C's strstr() and Java's indexOf().

## Solution

```GO
func strStr(haystack string, needle string) int {
	for i := 0; i < len(haystack)-len(needle)+1; i++ {
		if haystack[i:i+len(needle)] == needle {
			return i
		}
	}

	return -1
}
```

## Note

假設有以下參數：

```BASH
haystack: hello
needle: ll
```

說明：

```BASH

i 為 0：

比較指定字串 ll 和目標字串中 index 為 0 到 2 的字串切片 he，不一樣，所以不動作。

i 為 1：

比較指定字串 ll 和目標字串中 index 為 1 到 3 的字串切片 el，不一樣，所以不動作。

i 為 2：

比較指定字串 ll 和目標字串中 index 為 2 到 4 的字串切片 ll，一樣，所以停止。

最終返回：2
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
