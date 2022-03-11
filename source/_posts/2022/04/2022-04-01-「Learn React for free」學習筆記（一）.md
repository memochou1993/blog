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

修改 `index.js` 檔，試著渲染一個自定義的元件到指定節點。

```JS
function MainContent() {
  return (
      <main>Hello World!</main>
  );
};

ReactDOM.render(
  <div>
      <MainContent />
  </div>,
  document.getElementById('root')
);
```

## JSX

所謂 JSX 是一個 JavaScript 的語法擴充。

```JS
const element = <h1>你好，世界！</h1>;
```

使用 JSX 渲染一個字串，JSX 會為其產生一個 React 的 `element` 元素。

```JS
const element = <h1>Hello, World!</h1>;

ReactDOM.render(element, document.getElementById('root'));
```

使用 JSX 渲染一個列表。

```JS
const nav = (
  <nav>
    <ul>
      <li>Pricing</li>
      <li>About</li>
      <li>Contact</li>
    </ul>
  </nav>
);

ReactDOM.render(nav, document.getElementById('root'));
```

## 元件

使用方法建立一個以 `CamelCase` 為命名方式的元件。

```JS
function MyPage() {
  return (
    <div>
      <header>
        <nav>
          <img src="./react-logo.svg" width="40px" />
        </nav>
      </header>
      <h1>Reasons I'm excited to learn React</h1>
      <ol>
        <li>It's a popular library, so I'll be able to fit in with the cool kids!</li>
        <li>I'm more likely to get a job as a developer if I know React</li>
      </ol>
      <footer>
        <small>© 2022 Memo Chou</small>
      </footer>
    </div>
  );
};

ReactDOM.render(<MyPage />, document.getElementById('root'));
```

## 參考資料

- [Learn React for free](https://scrimba.com/learn/learnreact)
