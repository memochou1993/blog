---
title: 使用 Highlight.js 套件為程式碼區塊上色
date: 2024-10-04 01:31:20
tags: ["Programming", "JavaScript"]
categories: ["Programming", "JavaScript", "Others"]
---

## 建立專案

建立專案。

```bash
npm create vite@latest highlight-js-example -- --template vanilla
cd highlight-js-example
```

安裝套件。

```bash
npm install highlight.js
```

修改 `index.html` 檔，引入主題樣式。

```html
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/atom-one-dark.css">
```

修改 `main.js` 檔。

```js
import './style.css'
// 載入模組
import hljs from 'highlight.js/lib/core';
// 按需載入語言包
import javascript from 'highlight.js/lib/languages/javascript';

// 註冊語言
hljs.registerLanguage('javascript', javascript);

const code = `function greet() {
  console.log("Hello, World!");
}`;

document.querySelector('#app').innerHTML = `<pre style="text-align: left;">
<code>${code}</code>
</pre>`;

// 渲染
hljs.highlightAll();
```

啟動本地伺服器。

```bash
npm run dev
```

前往 <http://localhost:5173/> 瀏覽。

## 程式碼

- [highlight-js-example](https://github.com/memochou1993/highlight-js-example)

## 參考資料

- [Highlight.js](https://highlightjs.org/)
