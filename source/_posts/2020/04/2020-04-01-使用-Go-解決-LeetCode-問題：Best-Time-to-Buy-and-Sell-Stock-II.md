---
title: 使用 Go 解決 LeetCode 問題：Best Time to Buy and Sell Stock II
date: 2020-04-01 23:39:38
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Say you have an array for which the ith element is the price of a given stock on day i.

Design an algorithm to find the maximum profit. You may complete as many transactions as you like (i.e., buy one and sell one share of the stock multiple times).

- Note:

You may not engage in multiple transactions at the same time (i.e., you must sell the stock before you buy again).

- Example 1:

```BASH
Input: [7,1,5,3,6,4]
Output: 7
Explanation: Buy on day 2 (price = 1) and sell on day 3 (price = 5), profit = 5-1 = 4.
             Then buy on day 4 (price = 3) and sell on day 5 (price = 6), profit = 6-3 = 3.
```

- Example 2:

```BASH
Input: [1,2,3,4,5]
Output: 4
Explanation: Buy on day 1 (price = 1) and sell on day 5 (price = 5), profit = 5-1 = 4.
             Note that you cannot buy on day 1, buy on day 2 and sell them later, as you are
             engaging multiple transactions at the same time. You must sell before buying again.
```

- Example 3:

```BASH
Input: [7,6,4,3,1]
Output: 0
Explanation: In this case, no transaction is done, i.e. max profit = 0.
```

## Solution

```GO
func maxProfit(prices []int) int {
	max := 0

	// 從第 2 個元素開始疊代
	for i := 1; i < len(prices); i++ {
		// 如果差額大於 0，則累計差額
		if prices[i]-prices[i-1] > 0 {
			max += prices[i] - prices[i-1]
		}
	}

	return max
}
```

## Note

假設有以下參數：

```BASH
prices: [7, 1, 5, 3, 6, 4]
```

說明：

```BASH
第 1 次迴圈：

差額為 -6，max 累計為 0。

第 2 次迴圈：

差額為 4，max 累計為 4。

第 3 次迴圈：

差額為 -2，max 累計為 4。

第 4 次迴圈：

差額為 3，max 累計為 7。

第 5 次迴圈：

差額為 -2，max 累計為 7。

最終返回：7
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
