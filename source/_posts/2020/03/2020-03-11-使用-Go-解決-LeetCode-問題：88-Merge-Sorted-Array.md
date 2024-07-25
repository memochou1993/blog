---
title: 使用 Go 解決 LeetCode 問題：88. Merge Sorted Array
date: 2020-03-11 23:38:04
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given two sorted integer arrays nums1 and nums2, merge nums2 into nums1 as one sorted array.

- Note:

The number of elements initialized in nums1 and nums2 are m and n respectively.

You may assume that nums1 has enough space (size that is greater or equal to m + n) to hold additional elements from nums2.

- Example:

```bash
Input:
nums1 = [1,2,3,0,0,0], m = 3
nums2 = [2,5,6],       n = 3

Output: [1,2,2,3,5,6]
```

## Solution

```go
func merge(nums1 []int, m int, nums2 []int, n int) {
	// 疊代直到陣列二的元素都被比較完成
	for n > 0 {
		// 判斷陣列一的元素是否被比較完成，而且陣列一的元素大於陣列二的元素
		if m > 0 && nums1[m-1] > nums2[n-1] {
			nums1[m+n-1] = nums1[m-1]
			m--
		} else {
			nums1[m+n-1] = nums2[n-1]
			n--
		}
	}
}
```

## Note

假設有以下參數：

```bash
nums1: [4, 5, 6, 0, 0, 0]
m: 3
nums2: [1, 2, 3]
n: 3
```

說明：

```bash
由於陣列二是被合併的陣列，因此陣列二的元素都被比較完成的話，則可結束迴圈。

第 1 次迴圈：

m 為 3，n 為 3。

由於陣列一的元素 6 大於陣列二的元素 3，因此將 6 設置到陣列一索引為 5 的位置。

--------------------
4, 5, 6, 0, 0, 6
--------------------

m 為 2，n 為 3。

由於陣列一的元素 5 大於陣列二的元素 3，因此將 5 設置到陣列一索引為 4 的位置。

--------------------
4, 5, 6, 0, 5, 6
--------------------

m 為 1，n 為 3。

由於陣列一的元素 4 大於陣列二的元素 3，因此將 4 設置到陣列一索引為 3 的位置。

--------------------
4, 5, 6, 4, 5, 6
--------------------

m 為 0，n 為 3。

由於陣列一已被比較完成，因此將陣列二的 3 設置到陣列一索引為 2 的位置。

--------------------
4, 5, 3, 4, 5, 6
--------------------

m 為 0，n 為 2。

由於陣列一已被比較完成，因此將陣列二的 2 設置到陣列一索引為 1 的位置。

--------------------
4, 2, 3, 4, 5, 6
--------------------

m 為 0，n 為 1。

由於陣列一已被比較完成，因此將陣列二的 1 設置到陣列一索引為 0 的位置。

--------------------
1, 2, 3, 4, 5, 6
--------------------

m 為 0，n 為 0。

結束迴圈。

最終 nums1 為：[1, 2, 2, 3, 5, 6]
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
