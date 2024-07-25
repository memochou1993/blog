---
title: 使用 Go 解決 LeetCode 問題：111. Minimum Depth of Binary Tree
date: 2020-03-23 23:39:00
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given a binary tree, find its minimum depth.

The minimum depth is the number of nodes along the shortest path from the root node down to the nearest leaf node.

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

return its minimum depth = 2.

## Solution

```go
func minDepth(root *TreeNode) int {
	switch {
	// 如果根為空，則返回 0 個階層
	case root == nil:
		return 0
	// 如果左節點為空，則返回右節點的階層並增值
	case root.Left == nil:
		return minDepth(root.Right) + 1
	// 如果右節點為空，則返回左節點的階層並增值
	case root.Right == nil:
		return minDepth(root.Left) + 1
	// 如果左右節點皆不為空，則返回兩節點較小的階層並增值
	default:
		return min(minDepth(root.Left), minDepth(root.Right)) + 1
	}
}

func min(a, b int) int {
	if a < b {
		return a
	}

	return b
}
```

## Note

假設有以下參數：

```bash
root: [2, 1, 5, 4]
```

說明：

```bash
樹的形狀如下：

--------------------
      2
    /   \
   1     5
        /
       4
--------------------

節點 4，左節點為空，返回 1（右節點的階層加 1）。

節點 5，右節點為空，返回 2（左節點的階層加 1）。

節點 1，左節點為空，返回 1（右節點的階層加 1）。

節點 2，比較左右節點，返回 2（兩節點較小的階層加 1）。

最終返回：2
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
