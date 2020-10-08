---
title: 為 PhpStorm 編輯器設置 Vue 專案的路徑別名
permalink: 為-PhpStorm-編輯器設置-Vue-專案的路徑別名
date: 2020-10-08 23:18:34
tags: ["編輯器", "PhpStorm", "Vue"]
categories: ["其他", "編輯器"]
---

## 做法

使用 PhpStorm 編輯器時，如果出現 `Module is not installed` 的錯誤訊息，可以開啟 `Preferences` 視窗，將 Webpack 的 `webpack configuration file` 路徑設置為 `@vue` 套件中的 `webpack.config.js` 檔的路徑。

```BASH
/Users/<USER>/Projects/<PROJECT>/resources/js/node_modules/@vue/cli-service/webpack.config.js
```
