---
title: 使用 Go 解答 LeetCode 演算法：Two Sum
permalink: 使用-Go-解答-LeetCode-演算法：Two-Sum
date: 2020-02-15 15:36:54
tags: ["程式寫作", "Go", "演算法", "LeetCode"]
categories: ["程式寫作", "Go", "演算法"]
---

## 題目

(1) Two Sum

Given an array of integers, return indices of the two numbers such that they add up to a specific target.

You may assume that each input would have exactly one solution, and you may not use the same element twice.

- Example:

```BASH
Given nums = [2, 7, 11, 15], target = 9,

Because nums[0] + nums[1] = 2 + 7 = 9,
return [0, 1].
```

## 解答

```GO
func twoSum(nums []int, target int) []int {
	// 創建一個空集合，用於放置迭代過的索引
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

## 程式碼

[GitHub](https://github.com/memochou1993/leetcode-in-go)
