---
title: 在 Laravel 5.6 安裝 Zurb Foundatin 前端框架
permalink: 在-Laravel-5-6-安裝-Zurb-Foundatin-前端框架
date: 2018-05-05 10:19:53
tags: ["程式設計", "Laravel", "Zurb Foundatin"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 環境

- Windows 10
- Homestead 7.4.1
- npm 5.6.0
- node 8.11.1

## 建立專案

```BASH
laravel new foundation
```

## 安裝模組

```BASH
cd foundation
npm install
```

## 安裝

編輯 `package.json` 檔，把 `"bootstrap": "^4.0.0"` 改為以下：

```JSON
"foundation-sites": "^6.4.4-rc1",
```

更新 `package.json` 檔。

```BASH
npm update
```

如果在 Windows 環境沒有反應就執行以下：

```BASH
npm install
```

如果在 Homestead 環境需要重建 `node-sass` 模組：

```BASH
npm rebuild node-sass --force --no-bin-links
```

## 引入 CSS

1. 把 `node_modules\foundation-sites\scss\settings\_settings.scss` 檔，複製到 `resources\assets\sass` 資料夾，並刪除 `_variables.scss` 檔。
2. 編輯 `resources/assets/sass/app.scss` 檔，把 `Variables` 和 `Bootstrap` 的部分改為以下：

```SCSS
// Settings
@import "settings";

// Foundation
@import "node_modules/foundation-sites/assets/foundation";
```

3. 編輯 `_settings.scss` 檔，把 `@import 'util/util';` 改為以下：

```SCSS
@import "node_modules/foundation-sites/scss/util/util";
```

## 引入 JavaScript

1. 把 `resources/assets/js/bootstrap.js` 檔更名為 `foundation.js`。
2. 編輯 `foundation.js` 檔，改為以下：

```JS
try {
    window.$ = window.jQuery = require('jquery');

    require('foundation-sites/dist/js/foundation');

    $(function() {
        $(document).foundation();
    });
} catch (e) { }
```

3. 編輯 `app.js` 檔，把 `require('./bootstrap');` 改為以下：

```jS
require('./foundation');
```

## 編譯資源

```BASH
npm run dev
```

## 程式碼

[GitHub](https://github.com/memochou1993/laravel-foundation)
