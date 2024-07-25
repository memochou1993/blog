---
title: 使用 Python 解決 LeetCode 問題：200. Number of Islands
date: 2024-07-26 22:56:45
tags: ["Programming", "Python", "Algorithm", "LeetCode"]
categories: ["Programming", "Python", "Algorithm"]
---

## Description

Given an m x n 2D binary grid grid which represents a map of '1's (land) and '0's (water), return the number of islands.

An island is surrounded by water and is formed by connecting adjacent lands horizontally or vertically. You may assume all four edges of the grid are all surrounded by water.

```bash
Example 1:

Input: grid = [
  ["1","1","1","1","0"],
  ["1","1","0","1","0"],
  ["1","1","0","0","0"],
  ["0","0","0","0","0"]
]
Output: 1
Example 2:

Input: grid = [
  ["1","1","0","0","0"],
  ["1","1","0","0","0"],
  ["0","0","1","0","0"],
  ["0","0","0","1","1"]
]
Output: 3

Constraints:

m == grid.length
n == grid[i].length
1 <= m, n <= 300
grid[i][j] is '0' or '1'.
```

## Solution

以下使用深度優先搜尋演算法（DFS），解決網格搜尋問題。

### 遞迴實作的 DFS 版本

```python
from typing import List

class Solution:
    def numIslands(self, grid: List[List[str]]) -> int:
        # 初始化島嶼計數器
        count = 0

        # 定義遞迴的 DFS 函數
        def dfs(grid: List[List[str]], i: int, j: int):
            # 檢查邊界條件
            if i < 0 or j < 0 or i >= len(grid) or j >= len(grid[i]):
                return
            # 檢查當前節點是否為水域或已訪問過
            if grid[i][j] == '0' or grid[i][j] == 'V':
                return
            # 標記當前節點為已訪問
            if grid[i][j] == '1':
                grid[i][j] = 'V'
                # 遞迴訪問四個方向的節點
                dfs(grid, i+1, j)
                dfs(grid, i-1, j)
                dfs(grid, i, j+1)
                dfs(grid, i, j-1)

        # 遍歷整個網格
        for i in range(len(grid)):
            for j in range(len(grid[i])):
                # 如果找到一個新的島嶼，就啟動 DFS 並計數
                if grid[i][j] == '1':
                    dfs(grid, i, j)
                    count += 1

        return count
```

優點：

- 實作簡單：遞迴方法直觀且容易理解，直接將問題分解成多個子問題。
- 代碼量少：遞迴方法通常較為簡潔，不需要額外的資料結構。

缺點：

- 堆疊溢出風險：對於非常大的輸入資料，遞迴深度可能會很大，導致堆疊溢出。
- 效率問題：在某些情況下，遞迴調用開銷可能比顯式堆疊高，特別是當遞迴深度很大時。

### 顯式堆疊實作的 DFS 版本

```python
from typing import List

class Solution:
    def numIslands(self, grid: List[List[str]]) -> int:
        # 初始化島嶼計數器
        count = 0

        # 定義迭代的 DFS 函數
        def dfs(grid: List[List[str]], i: int, j: int):
            # 使用顯式堆疊來模擬遞迴
            stack = [(i, j)]
            while stack:
                i, j = stack.pop()
                # 檢查邊界條件
                if i < 0 or j < 0 or i >= len(grid) or j >= len(grid[i]):
                    continue
                # 檢查當前節點是否為水域或已訪問過
                if grid[i][j] == '0' or grid[i][j] == 'V':
                    continue
                # 標記當前節點為已訪問
                grid[i][j] = 'V'
                # 將四個方向的節點加入堆疊中
                stack.append((i+1, j))
                stack.append((i-1, j))
                stack.append((i, j+1))
                stack.append((i, j-1))

        # 遍歷整個網格
        for i in range(len(grid)):
            for j in range(len(grid[i])):
                # 如果找到一個新的島嶼，就啟動 DFS 並計數
                if grid[i][j] == '1':
                    dfs(grid, i, j)
                    count += 1

        return count
```

優點：

- 避免堆疊溢出：使用顯式堆疊模擬遞迴調用，可以有效避免堆疊溢出風險，適合處理大量資料。
- 更靈活：可以更靈活地控制迭代過程，比如在某些情況下可以優化堆疊操作。

缺點：

- 程式碼較複雜：需要手動維護堆疊，程式碼相對於遞迴版本來說略顯複雜。
- 空間開銷：顯式堆疊在某些情況下可能會消耗更多的空間。

## Code

- [leetcode-python](https://github.com/memochou1993/leetcode-python)
