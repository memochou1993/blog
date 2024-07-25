---
title: 使用 Go 解決 LeetCode 問題：121. Best Time to Buy and Sell Stock
date: 2020-03-31 23:39:30
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Say you have an array for which the ith element is the price of a given stock on day i.

If you were only permitted to complete at most one transaction (i.e., buy one and sell one share of the stock), design an algorithm to find the maximum profit.

Note that you cannot sell a stock before you buy one.

- Example 1:

```bash
Input: [7,1,5,3,6,4]
Output: 5
Explanation: Buy on day 2 (price = 1) and sell on day 5 (price = 6), profit = 6-1 = 5.
             Not 7-1 = 6, as selling price needs to be larger than buying price.
```

- Example 2:

```bash
Input: [7,6,4,3,1]
Output: 0
Explanation: In this case, no transaction is done, i.e. max profit = 0.
```

## Solution

```go
func maxProfit(prices []int) int {
	// 差額累計值
	temp := 0
	// 最大值
	max := 0

	// 從第 2 個元素開始疊代
	for i := 1; i < len(prices); i++ {
		// 累計
		temp += prices[i] - prices[i-1]

		// 如果差額累計值為負數，則將其歸零
		if temp < 0 {
			temp = 0
		}

		// 如果累計值大於最大值，則更新最大值
		if temp > max {
			max = temp
		}
	}

	return max
}
```

## Note

假設有以下參數：

```bash
prices: [7, 1, 5, 3, 6, 4]
```

說明：

```bash
第 1 次迴圈：

temp 累計為 -6，temp 歸零，max 為 0。

第 2 次迴圈：

temp 累計為 4，max 為 4。

第 3 次迴圈：

temp 累計為 2，max 為 4。

第 4 次迴圈：

temp 累計為 5，max 為 5。

第 5 次迴圈：

temp 累計為 3，max 為 5。

最終返回：5
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
