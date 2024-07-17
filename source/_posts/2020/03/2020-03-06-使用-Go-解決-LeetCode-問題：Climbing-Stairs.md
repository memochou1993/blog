---
title: 使用 Go 解決 LeetCode 問題：Climbing Stairs
date: 2020-03-06 23:37:49
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

You are climbing a stair case. It takes n steps to reach to the top.

Each time you can either climb 1 or 2 steps. In how many distinct ways can you climb to the top?

- Note:

Given n will be a positive integer.

- Example 1:

```BASH
Input: 2
Output: 2
Explanation: There are two ways to climb to the top.
1. 1 step + 1 step
2. 2 steps
```

- Example 2:

```BASH
Input: 3
Output: 3
Explanation: There are three ways to climb to the top.
1. 1 step + 1 step + 1 step
2. 1 step + 2 steps
3. 2 steps + 1 step
```

## Solution

```GO
func climbStairs(n int) int {
	// 第一個數
	a := 1
	// 第二個數
	b := 1 + n%2

	for i := 0; i < n/2; i++ {
		// 將第一個數設置為自己再加上第二個數
		a += b
		// 將第二個數設置為自己再加上被自己加過的第二個數
		b += a
	}

	return a
}
```

## Note

假設有以下參數：

```BASH
n: 8
```

說明：

```BASH
n 為 8，所以第一個數為 1，第二個數為 1。

在迴圈中，讓第一個數加上自己和第二個數，再讓第二個數加上自己和被加過自己的第一個數。

所以第一個數的演變如下：

--------------------
2, 5, 13, 34
--------------------

最終返回：34
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
