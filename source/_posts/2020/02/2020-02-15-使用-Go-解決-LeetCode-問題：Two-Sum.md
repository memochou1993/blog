---
title: 使用 Go 解決 LeetCode 問題：Two Sum
date: 2020-02-15 23:28:37
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given an array of integers, return indices of the two numbers such that they add up to a specific target.

You may assume that each input would have exactly one solution, and you may not use the same element twice.

- Example:

```bash
Given nums = [2, 7, 11, 15], target = 9,

Because nums[0] + nums[1] = 2 + 7 = 9,
return [0, 1].
```

## Solution

```go
func twoSum(nums []int, target int) []int {
	// 創建一個集合，用於放置疊代過的索引
	index := make(map[int]int, len(nums))

	for i, num := range nums {
		// 在集合中尋找加起來總和為目標值的索引
		if j, ok := index[target-num]; ok == true {
			return []int{j, i}
		}
		// 如果找不到，將索引放置到集合當中
		index[num] = i
	}

	return []int{}
}
```

## Note

假設有以下參數：

```bash
nums: [2, 7, 11, 15]
target: 18
```

說明：

```bash
在集合中找尋 2 的配對 16，找不到，所以放進集合中。

----------
{
  2: 0
}
----------

在集合中找尋 7 的配對 11，找不到，所以放進集合中。

----------
{
  2: 0,
  7: 1
}
----------

在集合中找尋 11 的配對 7，找到，所以返回。

----------
{
  2: 0,
  7: 1
}
----------

最終返回：[1, 2]
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
