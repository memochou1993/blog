---
title: 使用 Go 解決 LeetCode 問題：Linked List Cycle
date: 2020-04-12 23:40:01
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Given a linked list, determine if it has a cycle in it.

To represent a cycle in the given linked list, we use an integer pos which represents the position (0-indexed) in the linked list where tail connects to. If pos is -1, then there is no cycle in the linked list.

- Example 1:

```bash
Input: head = [3,2,0,-4], pos = 1
Output: true
Explanation: There is a cycle in the linked list, where tail connects to the second node.
```

- Example 2:

```bash
Input: head = [1,2], pos = 0
Output: true
Explanation: There is a cycle in the linked list, where tail connects to the first node.
```

- Example 3:

```bash
Input: head = [1], pos = -1
Output: false
Explanation: There is no cycle in the linked list.
```

- Follow up:

Can you solve it using O(1) (i.e. constant) memory?

## Solution

```go
func hasCycle(head *ListNode) bool {
	if head == nil || head.Next == nil {
		return false
	}

	// 龜指針
	slow := head
	// 兔指針
	fast := head.Next

	// 當兔指針倒追龜指針，代表循環存在
	for slow != fast {
		if fast == nil || fast.Next == nil {
			return false
		}

		slow = slow.Next
		fast = fast.Next.Next
	}

	return true
}
```

## Note

假設有以下參數：

```bash
head: [3, 2, 0, -4]
pos: 1
```

說明：

```bash
運用 tortoise and hare algorithm 的概念，使用 2 個指針比較。

第 1 次迴圈：
--------------------
s  f
|  |
3->2->0->-4
--------------------

第 2 次迴圈：
--------------------
   s      f
   |      |
3->2->0->-4
--------------------

第 3 次迴圈：
--------------------
   f
   s
   |
3->2->0->-4
--------------------

最終返回：true
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
