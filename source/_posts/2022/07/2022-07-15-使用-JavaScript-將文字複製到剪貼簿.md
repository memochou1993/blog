---
title: 使用 JavaScript 將文字複製到剪貼簿
date: 2022-07-15 01:07:15
tags: ["Programming", "JavaScript"]
categories: ["Programming", "JavaScript", "Others"]
---

## 做法

### 方法一

使用已被淘汰的 `document.execCommand` 方法。

```js
const copy = (value) => {
  const ele = document.createElement('textarea');
  ele.value = value;
  document.body.appendChild(ele);
  ele.select();
  ele.setSelectionRange(0, ele.value.length);
  document.execCommand('copy');
  ele.remove();
};
```

實際使用。

```js
document.getElementById('copy').addEventListener('click', () => {
  copy('Hello, World!');
});
```

### 方法二

使用新的 Clipboard API 方法。

```js
const copy = (value) => {
  navigator.clipboard.writeText(value);
};
```

實際使用。

```js
document.getElementById('copy').addEventListener('click', () => {
  copy('Hello, World!');
});
```

## 參考資料

- [Clipboard API](https://developer.mozilla.org/en-US/docs/Web/API/Clipboard_API)
