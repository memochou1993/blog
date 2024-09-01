---
title: 在 JavaScript 專案安全渲染 Markdown 文本
date: 2024-09-01 22:03:05
tags:
categories:
---

## 建立專案

建立專案。

```bash
npm create vite@latest markdown-js-example -- --template vue
```

## 安裝依賴套件

安裝套件。

```bash
npm i marked dompurify
npm i @types/dompurify -D
```

建立 `utils` 資料夾。

```bash
mkdir utils
```

建立 `utils/html-utils.js` 檔。

```js
import DOMPurify from 'dompurify';

class HtmlUtils {
  /**
   * Sanitizes a string to prevent XSS attacks.
   */
  static sanitize(rawHtml, options) {
    return DOMPurify.sanitize(rawHtml, options);
  };
}

export default HtmlUtils;
```

建立 `utils/markdown-utils.js` 檔。

```js
import { marked } from 'marked';
import HtmlUtils from './html-utils';

class MarkdownUtils {
  /**
   * Converts a markdown string to a safe HTML string.
   */
  static toSafeHtml(markdown) {
    return HtmlUtils.sanitize(MarkdownUtils.toHtml(markdown), {
      ADD_ATTR: ['target'],
    });
  }

  /**
   * Converts a markdown string to an HTML string.
   */
  static toHtml(markdown) {
    const renderer = new marked.Renderer();
    renderer.link = ({ href, title, text }) => {
      return `<a href="${href}" title="${title || ''}" target="_blank" rel="noopener noreferrer">${text}</a>`;
    };
    return marked(markdown, { renderer });
  };
}

export default MarkdownUtils;
```

修改 `main.js` 檔。

```js
import './style.css';
import MarkdownUtils from './utils/markdown-utils.js';

const text = `## Memo Chou\n
Hi there 🙋\n
I'm Memo Chou, a creative developer passionate about Go, PHP, Rust and JavaScript.\n
Any questions, or want to get involved, please get in touch.\n
[Click me](https://epoch.epoch.tw) for more details.`;

document.querySelector('#app').innerHTML = `
  <div>
    ${MarkdownUtils.toSafeHtml(text)}
  </div>
`;
```

啟動網頁伺服器。

```bash
npm run dev
```

## 參考資料

- [markedjs/marked](https://github.com/markedjs/marked)
- [cure53/DOMPurify](https://github.com/cure53/DOMPurify)
