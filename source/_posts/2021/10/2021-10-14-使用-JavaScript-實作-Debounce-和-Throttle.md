---
title: 使用 JavaScript 實作 Debounce 和 Throttle
permalink: 使用-JavaScript-實作-Debounce-和-Throttle
date: 2021-10-14 13:54:41
tags: ["程式設計", "JavaScript"]
categories: ["程式設計", "JavaScript"]
---

## 前言

在瀏覽器中，滑鼠移動、滾動、改變視窗大小等事件，時常在短時間內觸發很多次的事件處理器（event handler），如果這些事件處理器綁定了 DOM 節點操作，就會引發大量消耗效能的 DOM 計算。

如此一來可能造成頁面緩慢，或頻繁地向後端發送 API 請求。為了避免頻繁觸發事件處理器，可以使用 Debounce 或 Throttle 函式，來減少觸發頻率。

## Debounce

Debounce（去抖動）是讓一個函式在連續被觸發時只執行最後一次。比較常見的情境是使用者連續輸入資訊後，最終才觸發事件處理器向後端發送 API 請求進行資料查詢。

簡單的實作方式如下：

```JS
const debounce = (func, delay = 250) => {
    let timer = null;
    return (e) => {
        clearTimeout(timer);
        timer = setTimeout(() => func(e), delay);
    };
}
```

使用方式如下：

```JS
const handle = (e) => {
    console.log(e);
}

window.addEventListener('mousemove', debounce(handle));
```

## Throttle

Throttle（節流閥）可以讓一個函式不要執行得太頻繁，能夠控制函式的最高呼叫頻率。比較常見的情境是減少 `scroll` 或 `resize` 事件的觸發頻率。

簡單的實作方式如下：

```JS
const throttle = (func, frame = 250) => {
    let last = 0;
    return (e) => {
        const now = new Date();
        if (now - last >= frame) {
            func(e);
            last = now;
        }
    };
}
```

使用方式如下：

```JS
const handle = (e) => {
    console.log(e);
}

window.addEventListener('mousemove', throttle(handle));
```

## 參考資料

- [How to Implement Debounce and Throttle with JavaScript](https://webdesign.tutsplus.com/tutorials/javascript-debounce-and-throttle--cms-36783)
- [debounce & throttle](http://demo.nimius.net/debounce_throttle/)
