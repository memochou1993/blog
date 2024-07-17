---
title: 使用 Go 解決 LeetCode 問題：Count and Say
date: 2020-02-25 23:37:00
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

The count-and-say sequence is the sequence of integers with the first five terms as following:

```BASH
1.     1
2.     11
3.     21
4.     1211
5.     111221
```

1 is read off as "one 1" or 11.
11 is read off as "two 1s" or 21.
21 is read off as "one 2, then one 1" or 1211.

Given an integer n where 1 ≤ n ≤ 30, generate the nth term of the count-and-say sequence. You can do so recursively, in other words from the previous member read off the digits, counting the number of digits in groups of the same digit.

- Note:

Each term of the sequence of integers will be represented as a string.

- Example 1:

```BASH
Input: 1
Output: "1"
Explanation: This is the base case.
```

- Example 2:

```BASH
Input: 4
Output: "1211"
Explanation: For n = 3 the term was "21" in which we have two groups "2" and "1", "2" can be read as "12" which means frequency = 1 and value = 2, the same way "1" is read as "11", so the answer is the concatenation of "12" and "11" which is "1211".
```

## Solution

```GO
func countAndSay(n int) string {
	if n == 1 {
		return "1"
	}

	// 從 1 開始數數
	s := countAndSay(n - 1)

	result := []byte{}
	count := 0
	last := byte('0')

	// 疊代每一個數字
	for i := 0; i < len(s); i++ {
		// 第一次將 last 設為第 1 個數字，將 count 增值
		if last == byte('0') {
			last = s[i]
			count++
			continue
		}

		// 第二次以後，如果上一個數字與當前數字相同，將 count 增值
		if last == s[i] {
			count++
			continue
		}

		// 如果上一個數字與當前數字不同，將計數與上一數字推進至 result 中
		result = append(result, byte(count+'0'), last)

		last = s[i]
		count = 1
	}

	// 將計數與上一數字推進至 result 中
	result = append(result, byte(count+'0'), last)

	// 轉成字串
	return string(result)
}
```

## Note

假設有以下參數：

```BASH
n: 5
```

說明：

```BASH
n 為 5：執行遞迴函式，s 等待返回。

n 為 4：執行遞迴函式，s 等待返回。

n 為 3：執行遞迴函式，s 等待返回。

n 為 2：執行遞迴函式，s 等待返回。

n 為 1：返回 "1"。

s 接收 "1"，所以跑 1 次迴圈：

last 為 byte('0') 時，將 last 設置為 byte('1')，並且 count 加 1，結束當前迴圈。

最後推進 byte('1') 和 byte('1')。

成為「1 個 1」，故返回 "11"。

s 接收 "11"，所以跑 2 次迴圈：

last 為 byte('0') 時，將 last 設置為 byte('1')，並且 count 加 1，結束當前迴圈。

last 為 byte('1') 時，與第 2 個數字 byte('1') 一樣，所以 count 加 1，結束當前迴圈。

最後推進 byte('2') 和 byte('1')。

成為「2 個 1」，故返回 "21"。

s 接收 "21"，所以跑 2 次迴圈：

last 為 byte('0') 時，將 last 設置為 byte('1')，並且 count 加 1，結束當前迴圈。

last 為 byte('2') 時，與第 2 個數字 byte('1') 不一樣，所以推進 byte('1') 和 byte('2') 到 result 中，結束當前迴圈。

最後推進 byte('1') 和 byte('1')。

成為「1 個 2，1 個 1」，故返回 "1211"。

s 接收 "1211"，所以跑 4 次迴圈：

last 為 byte('0') 時，將 last 設置為 byte('1')，並且 count 加 1，結束當前迴圈。

last 為 byte('1') 時，與第 2 個數字 byte('2') 不一樣，所以推進 byte('1') 和 byte('1') 到 result 中，結束當前迴圈。

last 為 byte('2') 時，與第 3 個數字 byte('1') 不一樣，所以推進 byte('1') 和 byte('2') 到 result 中，結束當前迴圈。

last 為 byte('1') 時，與第 4 個數字 byte('1') 一樣，所以 count 加 1，結束當前迴圈。

最後推進 byte('2') 和 byte('1')。

成為「1 個 1，1 個 2，2 個 1」，故返回 "111221"。

最終返回："111221"
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
