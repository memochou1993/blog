---
title: 使用 Go 解決 LeetCode 問題：27. Remove Element
date: 2020-02-21 23:36:36
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given an array nums and a value val, remove all instances of that value in-place and return the new length.

Do not allocate extra space for another array, you must do this by modifying the input array in-place with O(1) extra memory.

The order of elements can be changed. It doesn't matter what you leave beyond the new length.

- Example 1:

```bash
Given nums = [3,2,2,3], val = 3,

Your function should return length = 2, with the first two elements of nums being 2.

It doesn't matter what you leave beyond the returned length.
```

- Example 2:

```bash
Given nums = [0,1,2,2,3,0,4,2], val = 2,

Your function should return length = 5, with the first five elements of nums containing 0, 1, 3, 0, and 4.

Note that the order of those five elements can be arbitrary.

It doesn't matter what values are set beyond the returned length.
```

- Clarification

Confused why the returned value is an integer but your answer is an array?

Note that the input array is passed in by reference, which means modification to the input array will be known to the caller as well.

Internally you can think of this:

```JAVA
// nums is passed in by reference. (i.e., without making a copy)
int len = removeElement(nums, val);

// any modification to nums in your function would be known by the caller.
// using the length returned by your function, it prints the first len elements.
for (int i = 0; i < len; i++) {
    print(nums[i]);
}
```

## Solution

```go
func removeElement(nums []int, val int) int {
	// 疊代過程中，不一樣的元素要設置在陣列中的位置
	index := 0

	// 疊代陣列中的每一個元素
	for i := 0; i < len(nums); i++ {
		// 判斷當前元素是否和指定元素不一樣
		if nums[i] != val {
			// 把當前元素設置在陣列中 index 的位置
			nums[index] = nums[i]
			// 偏移 index
			index++

		}
	}

	// 返回 index，也就是去除指定元素後的個數
	return index
}
```

## Note

假設有以下參數：

```bash
nums: [3, 2, 4, 3]
val: 3
```

說明：

```bash

index 為 0：

比較 3 和 3，一樣，所以不動作。

--------------------
[3, 2, 4, 3]
--------------------

index 為 0：

比較 3 和 2，不一樣，所以將陣列中 index 為 0 的元素設置為 2，並且偏移 index。

--------------------
[2, 2, 4, 3]
--------------------

index 為 1：

比較 3 和 4，不一樣，所以將陣列中 index 為 1 的元素設置為 4，並且偏移 index。

--------------------
[2, 4, 4, 3]
--------------------

index 為 2：

比較 3 和 3，一樣，所以不動作。

--------------------
[2, 4, 4, 3]
--------------------

最終返回：2
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
