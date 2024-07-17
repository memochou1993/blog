---
title: 使用 Go 解決 LeetCode 問題：Convert Sorted Array to Binary Search Tree
date: 2020-03-19 23:38:42
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given an array where elements are sorted in ascending order, convert it to a height balanced BST.

For this problem, a height-balanced binary tree is defined as a binary tree in which the depth of the two subtrees of every node never differ by more than 1.

- Example:

```bash
Given the sorted array: [-10,-3,0,5,9],

One possible answer is: [0,-3,9,-10,null,5], which represents the following height balanced BST:

      0
     / \
   -3   9
   /   /
 -10  5
```

## Solution

```go
func sortedArrayToBST(nums []int) *TreeNode {
	// 當陣列沒有元素時，返回空
	if len(nums) == 0 {
		return nil
	}

	// 以陣列的中間元素作為根
	mid := len(nums) / 2

	// 返回一個樹，其值為中間元素、左節點為陣列左半元素組成的樹、右節點為陣列右半元素組成的樹
	return &TreeNode{
		Val:   nums[mid],
		Left:  sortedArrayToBST(nums[:mid]),
		Right: sortedArrayToBST(nums[mid+1:]),
	}
}
```

## Note

假設有以下參數：

```bash
nums: [1, 2, 3, 4, 5, 6, 7]
```

說明：

```bash
返回一個樹，其值為 4、左節點為 [1, 2, 3] 組成的樹、右節點為 [5, 6, 7] 組成的樹。

左節點的遞迴，返回一個樹，其值為 2、左節點為 [1] 組成的樹、右節點為 [3] 組成的樹。

右節點的遞迴，返回一個樹，其值為 6、左節點為 [5] 組成的樹、右節點為 [7] 組成的樹。

最終返回：

        4
      /   \
     2     6
    / \   / \
   1   3 5   7
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
