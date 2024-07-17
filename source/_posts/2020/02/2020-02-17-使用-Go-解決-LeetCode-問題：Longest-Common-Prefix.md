---
title: 使用 Go 解決 LeetCode 問題：Longest Common Prefix
date: 2020-02-17 23:36:04
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Write a function to find the longest common prefix string amongst an array of strings.

If there is no common prefix, return an empty string "".

- Example 1:

```bash
Input: ["flower","flow","flight"]
Output: "fl"
```

- Example 2:

```bash
Input: ["dog","racecar","car"]
Output: ""
Explanation: There is no common prefix among the input strings.
```

## Solution

```go
func longestCommonPrefix(strs []string) string {
	if len(strs) == 0 {
		return ""
	}

	for i := 0; i < len(strs[0]); i++ {
		// 用第一個字串當作基準，從第一個字母開始比對
		char := strs[0][:i+1]

		// 從第二個字串開始比對
		for j := 1; j < len(strs); j++ {
			// 判斷比對的字母是否不一樣
			if i == len(strs[j]) || strs[j][:i+1] != char {
				return strs[0][:i]
			}
		}
	}

	return strs[0]
}
```

## Note

假設有以下參數：

```bash
strs: ["flower","flow","flight"]
```

說明：

```bash
以第一個字串 flower 作為基準。

比對第二個字串 flow：

j 為 1：

比對 flower 的第 1 個字母 f 和 flow 的第 1 個字母 f，一樣。

j 為 2：

比對 flower 的第 2 個字母 l 和 flow 的第 2 個字母 l，一樣。

j 為 3：

比對 flower 的第 3 個字母 o 和 flow 的第 3 個字母 o，一樣。

j 為 4：

比對 flower 的第 4 個字母 w 和 flow 的第 4 個字母 w，一樣。

比對第三個字串 flight：

j 為 1：

比對 flower 的第 1 個字母 f 和 flight 的第 1 個字母 f，一樣。

j 為 2：

比對 flower 的第 2 個字母 l 和 flight 的第 2 個字母 l，一樣。

j 為 3：

比對 flower 的第 3 個字母 o 和 flight 的第 3 個字母 i，不一樣，停止比對。

最終返回："fl"
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
