---
title: 使用 Go 解決 LeetCode 問題：Length of Last Word
date: 2020-02-27 23:37:18
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given a string s consists of upper/lower-case alphabets and empty space characters ' ', return the length of last word (last word means the last appearing word if we loop from left to right) in the string.

If the last word does not exist, return 0.

- Note:

A word is defined as a maximal substring consisting of non-space characters only.

- Example:

```bash
Input: "Hello World"
Output: 5
```

## Solution

```go
func lengthOfLastWord(s string) int {
	// 建立一個游標
	cursor := len(s)

	// 從字串尾巴開始疊代
	for ; cursor > 0; cursor-- {
		// 如果發現不是空格就結束迴圈
		if s[cursor-1] != byte(' ') {
			break
		}
	}

	// 使用游標進行右切截
	s = s[:cursor]

	// 從字串尾巴開始疊代
	for ; cursor > 0; cursor-- {
		// 如果發現是空格就結束迴圈
		if s[cursor-1] == byte(' ') {
			break
		}
	}

	// 使用游標進行左切截
	s = s[cursor:]

	// 返回切截後的字串長度
	return len(s)
}
```

## Note

假設有以下參數：

```bash
s: "Hello World"
```

說明：

```bash
右切截：

當 cursor 為 11 時，發現 d 不是空格，結束當前迴圈。

--------------------
          c
Hello World
--------------------

對字串進行右切截。

--------------------
Hello World
--------------------

左切截：

cursor 為 11，d 不是空格。

--------------------
          c
Hello World
--------------------

cursor 為 10，l 不是空格。

--------------------
         c
Hello World
--------------------

cursor 為 9，r 不是空格。

--------------------
        c
Hello World
--------------------

cursor 為 8，o 不是空格。

--------------------
       c
Hello World
--------------------

cursor 為 7，W 不是空格。

--------------------
      c
Hello World
--------------------

cursor 為 6，發現空格，結束當前迴圈。

--------------------
     c
Hello World
--------------------

對字串進行左切截：

--------------------
World
--------------------

最終返回：5
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
