---
title: 認識 JavaScript 函數原型的三個方法：call、apply、bind
date: 2021-10-21 20:46:32
tags: ["程式設計", "JavaScript"]
categories: ["程式設計", "JavaScript", "其他"]
---

## call

`call` 方法使用給定的 `this` 參數以及分別給定的參數來呼叫某個函數，接受一個可以被視為 `this` 的值，和一連串的參數。

```JS
fun.call(thisArg[, arg1[, arg2[, ...]]])
```

簡單的範例：

```JS
function add(a, b) {
  return a + b;
}

add.call(null, 1, 2); // 3
```

## apply

`call` 方法使用給定的 `this` 參數以及分別給定的參數來呼叫某個函數，接受一個可以被視為 `this` 的值，和一個陣列形式的參數。

```JS
fun.apply(thisArg, [argsArray])
```

簡單的範例：

```JS
add.apply(null, [1, 2]); // 3
```

## bind

`bind` 方法會建立一個新函式。該函式被呼叫時，會將 `this` 關鍵字設為給定的參數，並在呼叫時，帶入給定順序的參數。

```JS
fun.bind(thisArg[, arg1[, arg2[, ...]]])
```

簡單的範例：

```JS
function add(a, b) {
  return a + b;
}

const addTen = add.bind(null, 10);

addTen(20); // 30
```

## 差異

- `call` 和 `apply` 方法會回傳 function 執行的結果。
- `bind` 方法會回傳綁定 `this` 後原來的函數。

## 關於 this 值

傳入的 `this` 決定函式所指向的 `this`。若這個函數是在非嚴格模式（non-strict mode）下，`null`、`undefined` 將會被置換成全域變數。

```JS
const foo = {
    add: function(x) {
        return x + (this.num || 0);
    },
    num: 10,
};

const bar = function() {
    // 此處的 this 指向瀏覽器的 Window 物件
    console.log(foo.add.call(this, 1)); // 1
    console.log(foo.add.call(null, 1)); // 1
    console.log(foo.add.call(foo, 1)); // 11
    this.num = 5;
    console.log(foo.add.call(this, 1)); // 6
    console.log(foo.add.call(null, 1)); // 6
    console.log(foo.add.call(foo, 1)); // 11
};

bar();
```

## 參考資料

- [MDN - Function](https://developer.mozilla.org/zh-TW/docs/Web/JavaScript/Reference/Global_Objects/Function)
