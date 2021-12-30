---
title: 在 Bash Shell 腳本中指定輸出文字的顏色
permalink: 在-Bash-Shell-腳本中指定輸出文字的顏色
date: 2020-12-10 13:38:02
tags: ["Bash Shell"]
categories: ["程式設計", "Bash Shell"]
---

## 前言

在 Bash 中，可以藉由解析跳脫序列（escape sequences）來顯示不同的顏色或格式。跳脫序列由許多跳脫字元（escape character）組成。使用 `Escape` 字元來解析跳脫序列，`Escape` 字元通常使用 `\e` 來表達。

## 範例

使用 echo 指令如下：

```BASH
echo -e "\e[31mHello World\e[0m"
```

- `-e` 參數代表解析跳脫序列。

### 腳本

使用 Bash Shell 腳本如下：

```BASH
#!/bin/bash
printf "\e[31mHello World\e[0m"
```

## 格式

### 設置

代碼 | 格式
--- | ---
1 | 粗體／明亮
2 | 黯淡
4 | 底線
5 | 閃爍
7 | 反向顏色
8 | 隱藏

### 重置

代碼 | 格式
--- | ---
0 | 重置所有格式
21 | 重置粗體／明亮
22 | 重置黯淡
24 | 重置底線
25 | 重置閃爍
27 | 重置反向顏色
28 | 重置隱藏

## 顏色

代碼 | 顏色
--- | ---
39 | Default
30 | Black
31 | Red
32 | Green
33 | Yellow
34 | Blue
35 | Magenta
36 | Cyan
37 | Light gray
90 | Dark gray
91 | Light red
92 | Light green
93 | Light yellow
94 | Light blue
95 | Light magenta
96 | Light cyan
97 | White

## 參考資料

- [Bash tips: Colors and formatting](https://misc.flogisoft.com/bash/tip_colors_and_formatting)
