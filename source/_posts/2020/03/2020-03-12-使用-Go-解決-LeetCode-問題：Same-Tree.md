---
title: 使用 Go 解決 LeetCode 問題：Same Tree
date: 2020-03-12 23:38:12
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given two binary trees, write a function to check if they are the same or not.

Two binary trees are considered the same if they are structurally identical and the nodes have the same value.

- Example 1:

```BASH
Input:     1         1
          / \       / \
         2   3     2   3

        [1,2,3],   [1,2,3]

Output: true
```

- Example 2:

```BASH
Input:     1         1
          /           \
         2             2

        [1,2],     [1,null,2]

Output: false
```

- Example 3:

```BASH
Input:     1         1
          / \       / \
         2   1     1   2

        [1,2,1],   [1,1,2]

Output: false
```

## Solution

```GO
// TreeNode struct
type TreeNode struct {
	Val   int
	Left  *TreeNode
	Right *TreeNode
}

func isSameTree(p *TreeNode, q *TreeNode) bool {
	// 判斷兩樹是否同時為空
	if p == nil && q == nil {
		return true
	}

	// 判斷兩樹是否其一為空
	if p == nil || q == nil {
		return false
	}

	// 判斷兩樹其值是否相同
	if p.Val != q.Val {
		return false
	}

	// 判斷左右節點是否相同
	return isSameTree(p.Left, q.Left) && isSameTree(p.Right, q.Right)
}
```

## Note

假設有以下參數：

```BASH
p: [1, 2, 3]
q: [1, 2, 3]
```

說明：

```BASH
一開始，判斷 p 的左節點和 q 的左節點是否相同，以及 p 的右節點和 q 的右節點是否相同，等待返回。

------------------------------
      1(p)          1(q)
    /   \         /   \
   2(a)  3(b)    2(c)  3(d)
------------------------------

左節點開始遞迴：

判斷 a 的左節點和 c 的左節點是否相同，由於同時為空，返回 true。
判斷 a 的右節點和 c 的右節點是否相同，由於同時為空，返回 true。

左節點的遞迴返回 true。

右節點開始遞迴：

判斷 b 的左節點和 d 的左節點是否相同，由於同時為空，返回 true。
判斷 b 的右節點和 d 的右節點是否相同，由於同時為空，返回 true。

右節點的遞迴返回 true。

最終返回：true
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
