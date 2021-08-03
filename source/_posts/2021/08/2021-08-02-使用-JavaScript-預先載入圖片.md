---
title: 使用 JavaScript 預先載入圖片
permalink: 使用-JavaScript-預先載入圖片
date: 2021-08-02 14:04:36
tags: ["程式設計", "JavaScript"]
categories: ["程式設計", "JavaScript"]
---

## 做法

使用預先建立 `Image` 物件的方式，將圖片預先載入。

```JS
const images = [
    {
        src: '' // some image
    }
];

images.forEach((s) => {
    (new Image()).src = s.src;
});
```
