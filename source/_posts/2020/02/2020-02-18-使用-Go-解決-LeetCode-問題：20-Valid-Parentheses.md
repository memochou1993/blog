---
title: 使用 Go 解決 LeetCode 問題：20. Valid Parentheses
date: 2020-02-18 23:36:13
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given a string containing just the characters '(', ')', '{', '}', '[' and ']', determine if the input string is valid.

An input string is valid if:

1. Open brackets must be closed by the same type of brackets.
2. Open brackets must be closed in the correct order.

Note that an empty string is also considered valid.

- Example 1:

```bash
Input: "()"
Output: true
```

- Example 2:

```bash
Input: "()[]{}"
Output: true
```

- Example 3:

```bash
Input: "(]"
Output: false
```

- Example 4:

```bash
Input: "([)]"
Output: false
```

- Example 5:

```bash
Input: "{[]}"
Output: true
```

## Solution

```go
func isValid(s string) bool {
	// 建立一個堆疊
	stack := []string{}

	// 建立一個對照表
	pairs := map[string]string{
		")": "(",
		"]": "[",
		"}": "{",
	}

	for i := 0; i < len(s); i++ {
		// 從字串的第一個符號開始處理
		char := s[i : i+1]

		// 判斷是否為右括號
		if opposite, ok := pairs[char]; ok {
			// 判斷堆疊中不存在元素，或者最上層的元素不是對應的左括號
			if len(stack) == 0 || stack[len(stack)-1] != opposite {
				return false
			}

			// 配對成功，移出最上層的元素
			stack = stack[:len(stack)-1]

			continue
		}

		// 推進左括號至堆疊中
		stack = append(stack, char)
	}

	// 判斷堆疊是否還有元素未被移出
	return len(stack) == 0
}
```

## Note

假設有以下參數：

```bash
s: "{[]}"
```

說明：

```bash

第 1 個符號為左括號，所以推進至堆疊中：

----------
{
----------

第 2 個符號為左括號，所以推進至堆疊中：

----------
{[
----------

第 3 個符號為右括號，與最上層的元素配對成功，因此移出最上層的元素：

----------
{
----------

第 4 個符號為右括號，與最上層的元素配對成功，因此移出最上層的元素：

----------

----------

最終返回：true
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
