---
title: 使用 Go 解決 LeetCode 問題：Remove Duplicates from Sorted Array
date: 2020-02-20 23:36:28
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given a sorted array nums, remove the duplicates in-place such that each element appear only once and return the new length.

Do not allocate extra space for another array, you must do this by modifying the input array in-place with O(1) extra memory.

- Example 1:

```BASH
Given nums = [1,1,2],

Your function should return length = 2, with the first two elements of nums being 1 and 2 respectively.

It doesn't matter what you leave beyond the returned length.
```

- Example 2:

```BASH
Given nums = [0,0,1,1,1,2,2,3,3,4],

Your function should return length = 5, with the first five elements of nums being modified to 0, 1, 2, 3, and 4 respectively.

It doesn't matter what values are set beyond the returned length.
```

- Clarification

Confused why the returned value is an integer but your answer is an array?

Note that the input array is passed in by reference, which means modification to the input array will be known to the caller as well.

Internally you can think of this:

```JAVA
// nums is passed in by reference. (i.e., without making a copy)
int len = removeDuplicates(nums);

// any modification to nums in your function would be known by the caller.
// using the length returned by your function, it prints the first len elements.
for (int i = 0; i < len; i++) {
    print(nums[i]);
}
```

## Solution

```GO
func removeDuplicates(nums []int) int {
	// 疊代過程中，不一樣的元素要設置在陣列中的位置
	index := 1

	// 疊代陣列中的每一個元素
	for i := 1; i < len(nums); i++ {
		// 判斷當前元素是否和前一個元素不一樣
		if nums[i] != nums[i-1] {
			// 把當前元素設置在陣列中 index 的位置
			nums[index] = nums[i]
			// 偏移 index
			index++
		}
	}

	// 返回 index，也就是不一樣的元素的個數
	return index
}
```

## Note

假設有以下參數：

```BASH
nums: [0, 1, 1, 2]
```

說明：

```BASH

index 為 1：

比較 0 和 1，不一樣，所以將陣列中 index 為 1 的元素設置為 1，並且偏移 index。

--------------------
[0, 1, 1, 2]
--------------------

index 為 2：

比較 1 和 1，一樣，所以不動作。

--------------------
[0, 1, 1, 2]
--------------------

index 為 2：

比較 1 和 2，不一樣，所以將陣列中 index 為 2 的元素設置為 2，並且偏移 index。

--------------------
[0, 1, 2, 2]
--------------------

最終返回：3
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
