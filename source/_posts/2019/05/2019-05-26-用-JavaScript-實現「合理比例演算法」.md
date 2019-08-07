---
title: 用 JavaScript 實現「合理比例演算法」
permalink: 用-JavaScript-實現「合理比例演算法」
date: 2019-05-26 23:06:59
tags: ["程式寫作", "JavaScript", "演算法"]
categories: ["程式寫作", "JavaScript", "演算法"]
---

## 前言

目的是將若干組個別總和為（趨近於）1 的小數陣列，轉換為若干組整數陣列。

```JS
// 小數陣列
[
  [0.88, 0.11],
  [0.22, 0.66, 0.05, 0.05],
  [0.50, 0.22, 0.16, 0.11],
  [0.27, 0.27, 0.11, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05],
  [0.05, 0.22, 0.16, 0.33, 0.11, 0.11],
];

// 整數陣列
[
  [16, 2],
  [4, 12, 1, 1],
  [9, 4, 3, 2],
  [5, 5, 2, 1, 1, 1, 1, 1, 1],
  [1, 4, 3, 6, 2, 2],
]
```

## 做法

```JS
// 將小數陣列注入，並開始分析合理小數。
function analyze(arr) {
  return unique(max([].concat(...arr.map(ele => calculate(ele)))));
}

// 將小數陣列注入，取得預測整數的總和以及預測整數趨近於整數的次數。
function calculate(arr, {
  min = 11,
  max = 30,
} = {}) {
  return this.range(min, max).map((i) => {
    // 小數陣列乘以預測整數的總和
    const total = arr.reduce((acc, ele) => {
      const value = Math.round(ele * i);
      return acc + value;
    }, 0);
    // 小數乘以預測整數趨近於整數的次數
    const divisible = arr.reduce((acc, ele) => {
      const value = Math.round(ele * i % 1 * 10) / 10 % 1 === 0 ? 1 : 0;
      return acc + value;
    }, 0);
    const exceed = total > max;
    return {
      total: exceed ? 0 : total,
      divisible: exceed ? 0 : divisible,
    };
  });
}

// 將小數陣列注入，轉換為整數陣列。
function convert(arr, {
  total = 0,
} = {}) {
  return arr.map(row => {
    return row.map(col => Math.round(col * total));
  });
}

// 將分析結果注入，找出合理次數最多的結果。
function max(arr) {
  return arr.filter(ele => {
    return ele.divisible === Math.max(...arr.map(ele => ele.divisible));
  });
}

// 將分析結果注入，找出不重複的結果。
function unique(arr) {
  return arr.filter((ele, i) => {
    return i === arr.findIndex(obj => {
      return JSON.stringify(obj) === JSON.stringify(ele);
    });
  });
}

// 創造一個從 min 到 max 的陣列，如 [1, 2, 3, 4, 5]。
function range(min, max) {
  return Array.from(
    {
      length: max - min + 1,
    },
    (_, i) => min + i,
  );
}

// 小數陣列
const arr = [
  [0.88, 0.11],
  [0.22, 0.66, 0.05, 0.05],
  [0.50, 0.22, 0.16, 0.11],
  [0.27, 0.27, 0.11, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05],
  [0.05, 0.22, 0.16, 0.33, 0.11, 0.11],
];

// 預測整數的總和
const { total } = analyze(arr)[0];

// 整數陣列
console.log(convert(arr, {
  total,
}));
```

## 程式碼

[GitHub](https://github.com/memochou1993/104calculator-example)
