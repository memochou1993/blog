---
title: 使用 Go 解決 LeetCode 問題：Binary Tree Level Order Traversal II
date: 2020-03-18 23:38:34
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given a binary tree, return the bottom-up level order traversal of its nodes' values. (ie, from left to right, level by level from leaf to root).

For example:
Given binary tree [3,9,20,null,null,15,7],

```bash
    3
   / \
  9  20
    /  \
   15   7
```

return its bottom-up level order traversal as:

```bash
[
  [15,7],
  [9,20],
  [3]
]
```

## Solution

```go
func levelOrderBottom(root *TreeNode) [][]int {
	// 宣告一個二維陣列
	res := [][]int{}

	// 宣告一個深度優先搜尋的方法
	var dfs func(*TreeNode, int)

	dfs = func(root *TreeNode, level int) {
		// 如果根為空則返回
		if root == nil {
			return
		}

		// 如果階層尚未在 res 中，則在 res 的頭部添加一個空的一維陣列
		if level == len(res) {
			res = append([][]int{[]int{}}, res...)
		}

		index := len(res) - level - 1

		// 將值合併到同一個階層的一維陣列中
		res[index] = append(res[index], root.Val)

		dfs(root.Left, level+1)
		dfs(root.Right, level+1)
	}

	dfs(root, 0)

	return res
}
```

## Note

假設有以下參數：

```bash
root: [3, 9, 20, 15, 7]
```

說明：

```bash
值為 3，level 為 0，等於 res 的長度 0，所以在 res 的頭部添加一個空的一維陣列。

將 res[0] 設置為 [3]，res 為 [[3]]。

值為 9，level 為 1，等於 res 的長度 1，所以在 res 的頭部添加一個空的一維陣列。

將 res[0] 設置為 [9]，res 為 [[9], [3]]。

值為 20，level 為 1，不等於 res 的長度 2。

將 res[0] 設置為 [9, 20]，res 為 [[9, 20], [3]]。

值為 15，level 為 2，等於 res 的長度 2，所以在 res 的頭部添加一個空的一維陣列。

將 res[0] 設置為 [15]，res 為 [[15], [9, 20], [3]]。

值為 7，level 為 2，不等於 res 的長度 3。

將 res[0] 設置為 [15, 7]，res 為 [[15, 7], [9, 20], [3]]。

最終返回：[[15 7], [9 20], [3]]
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
