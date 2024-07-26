---
title: 使用 Python 解決 LeetCode 問題：3. Longest Substring Without Repeating Characters
date: 2024-07-27 17:57:18
tags: ["Programming", "Python", "Algorithm", "LeetCode"]
categories: ["Programming", "Python", "Algorithm"]
---

## Description

Given a string s, find the length of the longest substring without repeating characters.

```bash
Example 1:

Input: s = "abcabcbb"
Output: 3
Explanation: The answer is "abc", with the length of 3.
Example 2:

Input: s = "bbbbb"
Output: 1
Explanation: The answer is "b", with the length of 1.
Example 3:

Input: s = "pwwkew"
Output: 3
Explanation: The answer is "wke", with the length of 3.
Notice that the answer must be a substring, "pwke" is a subsequence and not a substring.
 
Constraints:

0 <= s.length <= 5 * 104
s consists of English letters, digits, symbols and spaces.
```

## Solution

以下使用滑動視窗（Sliding Window）技巧，來找出字符串中最長的無重複字符子串。

```py
from typing import List

class Solution:
    def lengthOfLongestSubstring(self, s: str) -> int:
        # 用於存儲當前視窗的字符集
        char_set = set()
        # 初始化最大長度
        max_len = 0
        # 初始化左指針
        left = 0

        # 用右指針遍歷整個字符串
        for right in range(len(s)):
            # 當當前字符在字符集中時，移動左指針並從集合中移除字符，直到當前字符不在字符集中
            while s[right] in char_set:
                # 移除最左邊的字符
                char_set.remove(s[left])
                # 左指針右移
                left += 1
            # 將當前字符加入集合
            char_set.add(s[right])
            # 更新最大長度
            max_len = max(max_len, right - left + 1)

        return max_len
```

滑動視窗很適合處理這類連續子資料的問題，使用兩個指針來表示當前窗口的左右邊界（left 和 right），並且動態調整窗口，來找到符合條件的子串。

## Code

- [leetcode-python](https://github.com/memochou1993/leetcode-python)
