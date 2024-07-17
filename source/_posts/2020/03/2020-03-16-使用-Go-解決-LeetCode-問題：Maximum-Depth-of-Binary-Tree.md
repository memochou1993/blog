---
title: 使用 Go 解決 LeetCode 問題：Maximum Depth of Binary Tree
date: 2020-03-16 23:38:26
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given a binary tree, find its maximum depth.

The maximum depth is the number of nodes along the longest path from the root node down to the farthest leaf node.Given a binary tree, find its maximum depth.

The maximum depth is the number of nodes along the longest path from the root node down to the farthest leaf node.

- Note:

A leaf is a node with no children.

- Example:

Given binary tree [3,9,20,null,null,15,7],

```bash
    3
   / \
  9  20
    /  \
   15   7
```

return its depth = 3.

## Solution

```go
func maxDepth(root *TreeNode) int {
	// 節點為空，返回 0 個階層
	if root == nil {
		return 0
	}

	// 節點不為空，則加上 1 個階層並返回
	return 1 + max(maxDepth(root.Left), maxDepth(root.Right))
}

func max(a int, b int) int {
	if a < b {
		return b
	}

	return a
}
```

## Note

假設有以下參數：

```bash
root: [3, 9, 20, 15, 7]
```

說明：

```bash

首先，判斷 root 是否為空。

------------------------------
         3(a)
       /   \
      9(b)  20(c)
           /   \
          15(d) 7(e)
------------------------------

a 的左節點 b 進入遞迴，判斷 b 是否為空。

b 節點返回 1。

a 的右節點 c 進入遞迴，判斷 c 是否為空。

c 的左節點 d 進入遞迴，判斷 d 是否為空。

d 節點返回 1。

c 的右節點 e 進入遞迴，判斷 e 是否為空。

e 節點返回 1。

c 節點返回 2。

a 節點返回 3。

最終返回：3
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
