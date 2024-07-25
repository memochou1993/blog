---
title: 使用 Go 解決 LeetCode 問題：67. Add Binary
date: 2020-03-04 23:37:33
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given two binary strings, return their sum (also a binary string).

The input strings are both non-empty and contains only characters 1 or 0.

- Example 1:

```bash
Input: a = "11", b = "1"
Output: "100"
```

- Example 2:

```bash
Input: a = "1010", b = "1011"
Output: "10101"
```

## Solution

```go
func addBinary(a string, b string) string {
	// 取得 a 的長度
	la := len(a) - 1
	// 取得 b 的長度
	lb := len(b) - 1

	// 累計值
	temp := 0
	// 進位值
	carry := 0
	// 結果
	result := ""

	// 疊代至所有條件皆小於 0 為止
	for la >= 0 || lb >= 0 || carry != 0 {
		// 將進位值累計至 temp
		temp = carry

		if la >= 0 {
			// 判斷當前數字為 1 或 0，並累計至 temp
			temp += int(a[la] - byte('0'))
			la--
		}

		if lb >= 0 {
			// 判斷當前數字為 1 或 0，並累計至 temp
			temp += int(b[lb] - byte('0'))
			lb--
		}

		// 判斷當前數字為 1 或 0，將累計值轉為字串，並且進行拼接
		result = string(temp%2+'0') + result

		// 進位
		carry = temp / 2
	}

    return result
}
```

## Note

假設有以下參數：

```bash
a = "1010"
b = "1011"
```

說明：

```bash
第 1 次迴圈：

temp 為 0，加上 a 的 0，再加上 b 的 1，累計值為 1。

result 為 "" 加 "1"。carry 為 0，不需進位。

第 2 次迴圈：

temp 為 0，加上 a 的 1，再加上 b 的 1，累計值為 2。

result 為 "0" 加 "1"。carry 為 1，需要進位。

第 3 次迴圈：

temp 為 1，加上 a 的 0，再加上 b 的 0，累計值為 1。

result 為 "1" 加 "01"。carry 為 0，不需進位。

第 4 次迴圈：

temp 為 0，加上 a 的 1，再加上 b 的 1，累計值為 2。

result 為 "0" 加 "101"。carry 為 1，需要進位。

第 5 次迴圈：

temp 為 1，a 不跑迴圈，b 不跑迴圈，累計值為 1。

result 為 "1" 加 "0101"。carry 為 0，不需進位。

最終返回："10101"
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
