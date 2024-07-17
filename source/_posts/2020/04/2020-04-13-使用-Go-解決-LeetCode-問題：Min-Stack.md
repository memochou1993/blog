---
title: 使用 Go 解決 LeetCode 問題：Min Stack
date: 2020-04-13 23:40:09
tags: ["Programming", "Go", "Algorithm", "LeetCode"]
categories: ["Programming", "Go", "Algorithm"]
---

## Description

Design a stack that supports push, pop, top, and retrieving the minimum element in constant time.

push(x) -- Push element x onto stack.
pop() -- Removes the element on top of the stack.
top() -- Get the top element.
getMin() -- Retrieve the minimum element in the stack.

- Example:

```bash
MinStack minStack = new MinStack();
minStack.push(-2);
minStack.push(0);
minStack.push(-3);
minStack.getMin();   --> Returns -3.
minStack.pop();
minStack.top();      --> Returns 0.
minStack.getMin();   --> Returns -2.
```

## Solution

```go
func Constructor() MinStack {
	return MinStack{}
}

func (stack *MinStack) Push(x int) {
	stack.nums = append(stack.nums, x)
	if len(stack.mins) == 0 || x <= stack.GetMin() {
		stack.mins = append(stack.mins, x)
	}
}

func (stack *MinStack) Pop() {
	if stack.Top() == stack.GetMin() {
		stack.mins = stack.mins[:len(stack.mins)-1]
	}
	stack.nums = stack.nums[:len(stack.nums)-1]
}

func (stack *MinStack) Top() int {
	return stack.nums[len(stack.nums)-1]
}

func (stack *MinStack) GetMin() int {
	return stack.mins[len(stack.mins)-1]
}
```

## Note

假設有以下參數：

```bash
stack: [-2, 0, -1]
```

說明：

```bash
使用 2 個堆疊，第 1 個堆疊紀錄所有的數；第 2 個堆疊紀錄推進時更小的數。

當推進 -2 時：

nums 為 [-2]，mins 為 [-2]。

當推進 0 時：

nums 為 [-2, 0]，mins 仍為 [-2]。

當推進 -1 時：

nums 為 [-2, 0, -1]，mins 仍為 [-2]。

top() 方法返回：-1
GetMin() 方法返回：-2
```

## Code

- [leetcode-go](https://github.com/memochou1993/leetcode-go)
