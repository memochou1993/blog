---
title: 在 Laravel 5.6 使用 Laravel Mix 編譯資源
date: 2018-04-29 10:18:49
tags: ["Programming", "PHP", "Laravel", "Mix"]
categories: ["Programming", "PHP", "Laravel"]
---

## 環境

- Windows 10
- Homestead 7.4.2
- node 8.11.1
- npm 5.6.0

## 安裝模組

在 Laravel 專案根目錄執行以下命令：

```bash
npm install
```

## 編譯資源

在 `webpack.mix.js` 檔整合所有的前端資源。

編譯 Sass 檔。

```php
mix.sass('resources/assets/sass/app.sass', 'public/css');
```

編譯 JavaScript 檔。

```php
mix.js('resources/assets/js/app.js', 'public/js');
```

整合 CSS 檔。

```php
mix.styles([
    'public/css/style.css',
    'public/css/navbar.css'
], 'public/css/all.css');
```

產生原始碼映射表（Source Maps）。

```php
mix.sourceMaps();
```

串接。

```php
mix.js('resources/assets/js/app.js', 'public/js')
   .sass('resources/assets/sass/app.scss', 'public/css');
```

## 開始編譯

編譯並展開所有資源。

```bash
npm run dev
```

編譯並壓縮所有資源。

```bash
npm run prod
```

編譯並監聽所有資源。

```bash
npm run watch // 在 Windows 環境
npm run watch-poll // 在虛擬機環境
```

## 虛擬機環境

- 如果遇到 `symlink` 問題，在執行命令後面添加 `--no-bin-links`：

```bash
npm install --no-bin-links
```

- 如果遇到 `cross-env` 問題，輸入以下命令全域安裝 `cross-env`：

```bash
npm i -g cross-env --no-bin-links
```

- 如果遇到 `node-sass` 問題，輸入以下命令重建 `node-sass`：

```bash
npm rebuild node-sass --no-bin-links
```
