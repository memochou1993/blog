---
title: 在前端專案使用 Google Fonts 字體和圖示
date: 2024-05-18 15:19:24
tags: ["Programming", "HTML"]
categories: ["Programming", "HTML"]
---

## 字體

前往 [Google Fonts](https://fonts.google.com/) 挑選喜歡的字體。

### 實作

建立 `index.html` 檔。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <!-- 預連接到 Google Fonts API 以加快字體加載速度 -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <!-- 引入 Google Fonts 中的 Noto Serif TC 字體系列，設置字重範圍 -->
    <link href="https://fonts.googleapis.com/css2?family=Noto+Serif+TC:wght@200..900&display=swap" rel="stylesheet">
</head>
<body>
    <h1>
        你好，世界！
    </h1>
    <!-- 定義全局樣式，設置字體和其他字體屬性 -->
    <style>
        html {
            /* 設置全局字體為 Noto Serif TC，備選字體為 serif */
            font-family: "Noto Serif TC", serif;
            /* 設置字體光學尺寸自動調整 */
            font-optical-sizing: auto;
            /* 設置全局字重為 400，即普通字重 */
            font-weight: 400;
            /* 設置字體樣式為正常 */
            font-style: normal;
        }
    </style>
</body>
</html>
```

## 豆腐字體

前往 [Google Fonts - Noto](https://fonts.google.com/noto) 挑選喜歡的豆腐字體。

### 實作

建立 `index.html` 檔。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <!-- 預連接到 Google Fonts API 以加快字體加載速度 -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
     <!-- 引入 Google Fonts 中的 Noto Color Emoji 和 Noto Serif TC 字體系列 -->
    <link href="https://fonts.googleapis.com/css2?family=Noto+Color+Emoji&display=swap" rel="stylesheet">
</head>
<body>
    <h1>
        🥰💀✌️🌴🐢🐐🍄⚽🍻👑📸😬👀🚨🏡🕊️🏆😻🌟🧿🍀🎨🍜
    </h1>
    <!-- 定義全局樣式，設置字體和其他字體屬性 -->
    <style>
        html {
            /* 設置全局字體為 Noto Color Emoji，備選字體為 sans-serif */
            font-family: "Noto Color Emoji", sans-serif;
            /* 設置全局字重為 400，即普通字重 */
            font-weight: 400;
            /* 設置字體樣式為正常 */
            font-style: normal;
        }
    </style>
</body>
</html>
```

## 圖示

前往 [Google Fonts - Icons](https://fonts.google.com/icons) 挑選喜歡的圖示。

### 實作

建立 `index.html` 檔。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <!-- 引入 Google Fonts 中的 Material Symbols Outlined 字體，允許使用變數字體屬性 -->
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
</head>
<body>
    <!-- 使用 Material Symbols Outlined 字體顯示 "home" 圖標 -->
    <span class="material-symbols-outlined">
        home
    </span>
    <!-- 定義 .material-symbols-outlined 類的樣式，設置變數字體屬性 -->
    <style>
        .material-symbols-outlined {
            font-variation-settings:
            'FILL' 0, /* 'FILL' 0 表示字體無填充，使用描邊樣式 */
            'wght' 400, /* 'wght' 400 設置字體的字重為 400，即普通字重 */
            'GRAD' 0, /* 'GRAD' 0 設置字體的梯度為 0，即無額外梯度效果 */
            'opsz' 24; /* 'opsz' 24 設置字體的光學尺寸為 24，適合在 24px 大小下顯示 */
        }
    </style>
</body>
</html>
```
