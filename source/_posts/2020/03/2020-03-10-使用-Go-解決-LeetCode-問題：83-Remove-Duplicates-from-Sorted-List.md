---
title: 使用 Go 解決 LeetCode 問題：83. Remove Duplicates from Sorted List
date: 2020-03-10 23:37:56
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given a sorted linked list, delete all duplicates such that each element appear only once.

- Example 1:

```bash
Input: 1->1->2
Output: 1->2
```

- Example 2:

```bash
Input: 1->1->2->3->3
Output: 1->2->3
```

## Solution

```go
// ListNode struct
type ListNode struct {
	Val  int
	Next *ListNode
}

func deleteDuplicates(head *ListNode) *ListNode {
	// 建立一個指向串列頭部節點的游標
	cursor := head

	// 疊代串列中的每一個節點
	for cursor != nil {
		// 判斷下一個節點存在，而且游標的值等於下一個節點的值
		if cursor.Next != nil && cursor.Val == cursor.Next.Val {
			cursor.Next = cursor.Next.Next

			continue
		}

		// 偏移游標
		cursor = cursor.Next
	}

	return head
}
```

## Note

假設有以下參數：

```bash
head: 1->1->2->3
```

說明：

```bash
cursor 的 Next 指向 1 的記憶體位置，假設為 a。

--------------------------------------------------
           c
head -> 1 (a) -> 1 (b) -> 2 (c) -> 3 (d) -> nil
--------------------------------------------------

第 1 次迴圈：

cursor 的值 1 等於下一個節點的值 1，因此將 cursor 的 Next 指向 c。

--------------------------------------------------
           c
head -> 1 (a) -> 2 (c) -> 3 (d) -> nil
--------------------------------------------------

第 2 次迴圈：

cursor 的值 1 不等於下一個節點的值 2，因此將 cursor 指向 c。

--------------------------------------------------
                    c
head -> 1 (a) -> 2 (c) -> 3 (d) -> nil
--------------------------------------------------

第 3 次迴圈：

cursor 的值 2 不等於下一個節點的值 3，因此將 cursor 指向 d。

--------------------------------------------------
                             c
head -> 1 (a) -> 2 (c) -> 3 (d) -> nil
--------------------------------------------------

第 4 次迴圈：

cursor 的值 nil 等於 nil，因此將 cursor 指向 nil。

--------------------------------------------------
                                   c
head -> 1 (a) -> 2 (c) -> 3 (d) -> nil
--------------------------------------------------

結束迴圈。

最後返回：1->2->3
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
