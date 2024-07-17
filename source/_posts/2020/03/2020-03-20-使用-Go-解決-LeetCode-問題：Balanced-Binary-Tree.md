---
title: 使用 Go 解決 LeetCode 問題：Balanced Binary Tree
date: 2020-03-20 23:38:52
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given a binary tree, determine if it is height-balanced.

For this problem, a height-balanced binary tree is defined as:

> a binary tree in which the left and right subtrees of every node differ in height by no more than 1.

- Example 1:

Given the following tree [3,9,20,null,null,15,7]:

```BASH
    3
   / \
  9  20
    /  \
   15   7
```

Return true.

- Example 2:

Given the following tree [1,2,2,3,3,null,null,4,4]:

```BASH
       1
      / \
     2   2
    / \
   3   3
  / \
 4   4
```

Return false.

## Solution

```GO
func isBalanced(root *TreeNode) bool {
	// 判斷兩樹的階層相差是否超過 1，標記 -1 表示超過
	return maxDepth(root) != -1
}

func maxDepth(root *TreeNode) int {
	// 節點為空，返回 0 個階層
	if root == nil {
		return 0
	}

	// 左節點的最大階層
	left := maxDepth(root.Left)
	// 右節點的最大階層
	right := maxDepth(root.Right)

	// 判斷左節點或右節點的最大階層是否為超過的標記 -1，或者兩樹的階層相差超過 1
	if left == -1 || right == -1 || left-right > 1 || right-left > 1 {
		return -1
	}

	// 返回兩樹較大的階層並增值
	return max(left, right) + 1
}

func max(a, b int) int {
	if a > b {
		return a
	}

	return b
}
```

## Note

假設有以下參數：

```BASH
root: [2, 1, 5, 4, 3, 6, 7]
```

說明：

```BASH
樹的形狀如下：

--------------------
      2
    /   \
   1     5
        / \
       4   6
      /     \
     3       7
--------------------

先執行左節點的遞迴，再執行右節點的遞迴。

節點 1 返回階層 1。

節點 3 返回階層 1。

節點 4 比較子節點 3 和 nil，返回階層 2。

節點 7 返回階層 1。

節點 6 比較子節點 nil 和 7，返回階層 2。

節點 5 比較子節點 4 和 6，返回階層 3。

節點 2 比較子節點 1 和 5，由於階層相差大於 1，因此返回標記 -1。

最終返回：false
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
