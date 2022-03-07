---
title: 「Learn React for free」學習筆記（一）
permalink: 「Learn-React-for-free」學習筆記（一）
date: 2022-04-01 01:30:56
tags: ["程式設計", "JavaScript", "React"]
categories: ["程式設計", "JavaScript", "React"]
---

## 前言

本文為「[Learn React for free](https://scrimba.com/learn/learnreact)」教學影片的學習筆記。

## 基礎

建立專案。

```BASH
mkdir react-info-site
cd react-info-site
```

新增 `index.html` 檔。

```HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <div id="root"></div>
    <script src="index.js" type="text/babel"></script>
</body>
</html>
```

使用 CDN 引入 `react` 和 `react-dom` 套件。

```HTML
<script crossorigin src="https://unpkg.com/react@17/umd/react.development.js"></script>
<script crossorigin src="https://unpkg.com/react-dom@17/umd/react-dom.development.js"></script>
```

使用 CDN 引入 `babel` 套件。

```HTML
<script src="https://unpkg.com/babel-standalone@6/babel.min.js"></script>
```

新增 `index.js` 檔，試著渲染一個標題到指定節點。

```JS
// 將標題渲染到指定節點
ReactDOM.render(<h1>Hello, World!</h1>, document.getElementById('root'));
```

修改 `index.js` 檔，試著渲染一個列表到指定節點。

```JS
// 將列表渲染到指定節點
ReactDOM.render(
  <ul>
    <li>Thing 1</li>
    <li>Thing 2</li>
  </ul>,
  document.getElementById('root')
);
```

## 參考資料

- [Learn React for free](https://scrimba.com/learn/learnreact)
