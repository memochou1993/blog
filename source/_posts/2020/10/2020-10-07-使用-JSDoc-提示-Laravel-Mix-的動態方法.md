---
title: 使用 JSDoc 提示 Laravel Mix 的動態方法
date: 2020-10-07 23:14:29
tags: ["Programming", "PHP", "Laravel", "Mix", "Vue"]
categories: ["Programming", "PHP", "Laravel"]
---

## 前言

Laravel Mix 使用了許多的動態方法，為了避免出現錯誤提示，可以使用 JSDoc 註解。

## 做法

修改 `webpack.mix.js` 檔：

```js
const mix = require('laravel-mix');

mix
  /**
   * @method js
   * @param {string}
   * @param {string}
   * @memberof Api
   * @instance
   */
  .js('resources/js/app.js', 'public/js') // 動態方法
  /**
   * @method extract
   * @param {array}
   * @memberof Api
   * @instance
   */
  .extract([]) // 動態方法
  .sourceMaps(); // 一般方法
```
