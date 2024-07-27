---
title: 使用 Python 解決 LeetCode 問題：2. Add Two Numbers
date: 2024-07-28 22:22:25
tags: ["Programming", "Python", "Algorithm", "LeetCode"]
categories: ["Programming", "Python", "Algorithm"]
---

## Description

You are given two non-empty linked lists representing two non-negative integers. The digits are stored in reverse order, and each of their nodes contains a single digit. Add the two numbers and return the sum as a linked list.

You may assume the two numbers do not contain any leading zero, except the number 0 itself.

```bash
Example 1:

Input: l1 = [2,4,3], l2 = [5,6,4]
Output: [7,0,8]
Explanation: 342 + 465 = 807.

Example 2:

Input: l1 = [0], l2 = [0]
Output: [0]

Example 3:

Input: l1 = [9,9,9,9,9,9,9], l2 = [9,9,9,9]
Output: [8,9,9,9,0,0,0,1]
 
Constraints:

The number of nodes in each linked list is in the range [1, 100].
0 <= Node.val <= 9
It is guaranteed that the list represents a number that does not have leading zeros.
```

## Solution

以下解決兩個表示數字的鏈結串列相加的問題。數字按逆序存儲，它們的每個節點包含一個數字。將兩數相加並返回一個新的鏈結串列。

```py
from typing import Optional
from utils import ListNode

class Solution:
    def addTwoNumbers(self, l1: Optional[ListNode], l2: Optional[ListNode]) -> Optional[ListNode]:
        # 建立一個虛擬節點作為結果鏈結串列的起始點
        head = ListNode(0)
        current = head  # current 指向結果鏈結串列的當前節點
        carry = 0  # 初始化進位值為 0

        # 當 l1, l2 或進位不為 0 時，持續迴圈
        while l1 or l2 or carry:
            # 若當前 l1 節點不為空，則取其值，否則取 0
            val1 = l1.val if l1 else 0
            # 若當前 l2 節點不為空，則取其值，否則取 0
            val2 = l2.val if l2 else 0
            # 將 val1, val2 與進位值相加，並計算新的進位值與當前位的數字
            carry, out = divmod(val1 + val2 + carry, 10)

            # 將計算出的當前位的數字作為新的節點加入結果鏈結串列
            current.next = ListNode(out)
            # 將 current 移到新加入的節點
            current = current.next

            # 若 l1 節點不為空，則移到下一個節點
            if l1:
                l1 = l1.next
            # 若 l2 節點不為空，則移到下一個節點
            if l2:
                l2 = l2.next

        # 返回結果鏈結串列的起始點（略過虛擬節點）
        return head.next
```

## Code

- [leetcode-python](https://github.com/memochou1993/leetcode-python)
