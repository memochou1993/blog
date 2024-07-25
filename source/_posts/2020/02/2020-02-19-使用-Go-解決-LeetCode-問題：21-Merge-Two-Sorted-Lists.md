---
title: 使用 Go 解決 LeetCode 問題：21. Merge Two Sorted Lists
date: 2020-02-19 23:36:20
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Merge two sorted linked lists and return it as a new list. The new list should be made by splicing together the nodes of the first two lists.

- Example:

```bash
Input: 1->2->4, 1->3->4
Output: 1->1->2->3->4->4
```

## Solution

```go
// ListNode struct
type ListNode struct {
	Val  int
	Next *ListNode
}

func mergeTwoLists(l1 *ListNode, l2 *ListNode) *ListNode {
	// 如果串列 1 為空，返回串列 2
	if l1 == nil {
		return l2
	}

	// 如果串列 2 為空，返回串列 1
	if l2 == nil {
		return l1
	}

	// 判斷串列 1 的值是否小於串列 2 的值
	if l1.Val < l2.Val {
		// 合併串列 1 的下一個節點開始的串列和串列 2
		l1.Next = mergeTwoLists(l1.Next, l2)

		// 返回串列 1
		return l1
	}

	// 合併串列 2 的下一個節點開始的串列和串列 1
	l2.Next = mergeTwoLists(l2.Next, l1)

	// 返回串列 2
	return l2
}
```

## Note

假設有以下參數：

```bash
l1: 1->4
l2: 2->3
```

說明：

```bash
比較串列 1 和串列 2。

----------
l1: 1, 4
----------
l2: 2, 3
----------

1 < 2，合併串列 1 的下一個節點開始的串列和串列 2，1.Next 等待返回。

----------
l1: 4
----------
l2: 2, 3
----------

2 < 4，合併串列 2 的下一個節點開始的串列和串列 1，2.Next 等待返回。

----------
l1: 4
----------
l2: 3
----------

3 < 4，合併串列 2 的下一個節點開始的串列和串列 1，3.Next 等待返回。

----------
l1: 4
----------
l2: nil
----------

串列 2 為空，返回 4。

----------
l1: 4
----------
l2: nil
----------

3.Next 接收到 4。

----------
3.Next = 4
----------

2.Next 接收到 3。

----------
2.Next = 3
----------

1.Next 接收到 2。

----------
1.Next = 2
----------

最終返回: 1->2->3->4
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
