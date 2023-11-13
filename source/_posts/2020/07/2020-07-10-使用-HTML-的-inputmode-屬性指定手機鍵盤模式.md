---
title: 使用 HTML 的 inputmode 屬性指定手機鍵盤模式
date: 2020-07-10 23:50:48
tags: ["Programming", "HTML", "RWD", "PWA"]
categories: ["Programming", "HTML"]
---

## 做法

設置為 `numeric`，可以顯示數字鍵盤。

```html
<input type="number" inputmode="numeric">
```

設置為 `decimal`，可以顯示帶有小數點的數字鍵盤。

```html
<input type="number" inputmode="decimal">
```

設置為 `none`，則完全不顯示鍵盤（可能使用客製化鍵盤）。

```html
<input type="text" inputmode="none">
```

## 參考資料

- [MDN - inputmode](https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/inputmode)
