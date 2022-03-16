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

```JSX
// 將標題渲染到指定節點
ReactDOM.render(<h1>Hello, World!</h1>, document.getElementById('root'));
```

修改 `index.js` 檔，試著渲染一個列表到指定節點。

```JSX
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

```JSX
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

```JSX
const element = <h1>你好，世界！</h1>;
```

使用 JSX 渲染一個字串，JSX 會為其產生一個 React 的 `element` 元素。

```JSX
const element = <h1>Hello, World!</h1>;

ReactDOM.render(element, document.getElementById('root'));
```

使用 JSX 渲染一個列表。

```JSX
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

```JSX
function MyPage() {
  return (
    <div>
      <header>
        <nav>
          <img src="./react-logo.svg" width="40px" />
        </nav>
      </header>
      <main>
        <h1>Reasons I'm excited to learn React</h1>
        <ol>
          <li>It's a popular library, so I'll be able to fit in with the cool kids!</li>
          <li>I'm more likely to get a job as a developer if I know React</li>
        </ol>
      </main>
      <footer>
        <small>© 2022 Memo Chou</small>
      </footer>
    </div>
  );
}

ReactDOM.render(<MyPage />, document.getElementById('root'));
```

將不同的區塊拆分成元件，並且組合在一起。

```JSX
function Header() {
  return (
    <header>
      <nav>
        <img src="./react-logo.svg" width="40px" />
      </nav>
    </header>
  );
}

function MainContent() {
  return (
    <main>
      <h1>Reasons I'm excited to learn React</h1>
      <ol>
        <li>It's a popular library, so I'll be able to fit in with the cool kids!</li>
        <li>I'm more likely to get a job as a developer if I know React</li>
      </ol>
    </main>
  );
}

function Footer() {
  return (
    <footer>
      <small>© 2022 Memo Chou</small>
    </footer>
  );
}

function MyPage() {
  return (
    <div>
      <Header />
      <MainContent />
      <Footer />
    </div>
  );
}

ReactDOM.render(<MyPage />, document.getElementById('root'));
```

## 套用樣式

新增 `style.css` 檔。

```CSS
.nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.nav-logo {
    width: 60px;
}

.nav-items {
    list-style: none;
    display: flex;
}

.nav-items > li {
    padding: 10px;
}
```

將 `style.css` 檔引入 `index.html` 中。

```HTML
<link rel="stylesheet" href="style.css">
```

套用樣式到 `Header` 元件。

```JSX
function Header() {
  return (
    <header>
      <nav className="nav">
        <img src="./react-logo.svg" className="nav-logo" />
        <ul className="nav-items">
          <li>Pricing</li>
          <li>About</li>
          <li>Contact</li>
        </ul>
      </nav>
    </header>
  );
}
```

## 匯出與匯入

為了將元件放置在各自的檔案，並且可以將元件匯出與匯入，需要使用到 `webpack` 工具，並且進行編譯。

首先，修改 `package.json` 檔。

```JSON
{
  "name": "project",
  "scripts": {
    "watch": "webpack -w",
    "build": "webpack"
  },
  "dependencies": {
    "react": "17.0.2",
    "react-dom": "17.0.2"
  },
  "devDependencies": {
    "webpack": "^2.0",
    "babel-core": "^6.0",
    "babel-loader": "^7.0",
    "babel-preset-env": "*",
    "babel-preset-react": "*"
  }
}
```

新增 `webpack.config.js` 檔。

```JS
module.exports = {
  "output": {
    "filename": "[name].pack.js"
  },
  "module": {
    "rules": [
      {
        "use": {
          "loader": "babel-loader",
          "options": {
            "presets": [
              "babel-preset-env",
              "babel-preset-react"
            ],
          },
        },
        "exclude": /node_modules/,
        "test": /\.js$/
      }
    ]
  },
  "entry": {
    "index": "./index"
  }
}
```

修改 `index.html` 檔。

```HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div id="root"></div>
    <script src="index.pack.js"></script>
</body>
</html>
```

新增 `Header.js` 檔。

```JS
import React from "react"

export default function Header() {
  return (
    <header>
      <nav className="nav">
        <img src="./react-logo.svg" className="nav-logo" />
        <ul className="nav-items">
          <li>Pricing</li>
          <li>About</li>
          <li>Contact</li>
        </ul>
      </nav>
    </header>
  )
}
```

新增 `MainContent.js` 檔。

```JS
import React from "react"

export default function MainContent() {
  return (
    <main>
      <h1>Reasons I'm excited to learn React</h1>
      <ol>
        <li>It's a popular library, so I'll be able to fit in with the cool kids!</li>
        <li>I'm more likely to get a job as a developer if I know React</li>
      </ol>
    </main>
  )
}
```

新增 `Footer.js` 檔。

```JS
import React from "react"

export default function Footer() {
  return (
    <footer>
      <small>© 2022 Memo Chou</small>
    </footer>
  )
}
```

修改 `index.js` 檔。

```JS
import React from "react"
import ReactDOM from "react-dom"
import Header from "./Header"
import MainContent from "./MainContent"
import Footer from "./Footer"

function App() {
  return (
    <div>
      <Header />
      <MainContent />
      <Footer />
    </div>
  )
}

ReactDOM.render(<App />, document.getElementById('root'))
```

執行編譯。

```BASH
npm run watch
```

啟動伺服器。

```BASH
live-server
```

## 程式碼

- [react-info-site](https://github.com/memochou1993/react-info-site)

## 參考資料

- [Learn React for free](https://scrimba.com/learn/learnreact)
