---
title: 使用 JavaScript 透過 postMessage 方法在 window 物件之間傳值
date: 2021-10-20 12:58:59
tags: ["Programming", "JavaScript"]
categories: ["Programming", "JavaScript", "Others"]
---

## 做法

使用 `postMessage` 方法，將值從父頁傳遞至 `8080` 埠的子頁（iframe）：

```js
const iframe = document.querySelector('iframe').contentWindow;
iframe.postMessage('hello', 'http://localhost:8080/');
```

使用 `postMessage` 方法，將值從子頁（iframe）傳遞至 `8000` 埠的父頁：

```js
parent.postMessage('hello', 'http://localhost:8000/');
```

監聽 `message` 事件，以取得傳遞值：

```js
window.addEventListener('message', (event) => {
  console.log(event.data);
}, false);
```
