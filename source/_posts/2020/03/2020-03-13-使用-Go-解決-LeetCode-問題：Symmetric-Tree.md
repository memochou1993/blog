---
title: 使用 Go 解決 LeetCode 問題：Symmetric Tree
date: 2020-03-13 23:38:18
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given a binary tree, check whether it is a mirror of itself (ie, symmetric around its center).

For example, this binary tree [1,2,2,3,4,4,3] is symmetric:

```bash
    1
   / \
  2   2
 / \ / \
3  4 4  3
```

But the following [1,2,2,null,3,null,3] is not:

```bash
    1
   / \
  2   2
   \   \
   3    3
```

- Note:

Bonus points if you could solve it both recursively and iteratively.

## Solution

```go
// TreeNode struct
type TreeNode struct {
	Val   int
	Left  *TreeNode
	Right *TreeNode
}

func isSymmetric(root *TreeNode) bool {
	// 判斷樹根是否為空
	if root == nil {
		return true
	}

	// 判斷左右節點是否對稱
	return rec(root.Left, root.Right)
}

func rec(left *TreeNode, right *TreeNode) bool {
	// 判斷兩樹是否同時為空
	if left == nil && right == nil {
		return true
	}

	// 判斷兩樹是否其一為空
	if left == nil || right == nil {
		return false
	}

	// 判斷兩樹其值是否相同
	if left.Val != right.Val {
		return false
	}

	// 判斷左右節點是否對稱
	return rec(left.Left, right.Right) && rec(left.Right, right.Left)
}
```

## Note

假設有以下參數：

```bash
p: [1, 2, 2]
q: [1, 2, 2]
```

說明：

```bash
一開始，判斷 root 是否為空，再判斷左右節點是否對稱。

判斷 left 的左節點和 right 的右節點是否對稱，以及 left 的右節點和 right 的左節點是否對稱，等待返回。

------------------------------
      1(p)
    /   \
   2(a)  2(b)
------------------------------

左節點開始遞迴：

判斷 left 的左節點和 right 的右節點是否對稱，由於同時為空，返回 true。

左節點的遞迴返回 true。

右節點開始遞迴：

判斷 left 的右節點和 right 的左節點是否對稱，由於同時為空，返回 true。

右節點的遞迴返回 true。

最終返回：true
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
