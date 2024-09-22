---
title: 在 JavaScript 專案安全渲染 Markdown 文本
date: 2024-09-01 22:03:05
tags: ["Programming", "JavaScript", "Markdown"]
categories: ["Programming", "JavaScript", "Others"]
---

## 建立專案

建立專案。

```bash
npm create vite@latest markdown-js-example -- --template vanilla
```

## 安裝依賴套件

安裝套件。

```bash
npm i marked dompurify
npm i @types/dompurify -D
```

## 實作

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

輸出如下：

```html
  <div>
    <h2>Memo Chou</h2>
<p>Hi there 🙋</p>
<p>I'm Memo Chou, a creative developer passionate about Go, PHP, Rust and JavaScript.</p>
<p>Any questions, or want to get involved, please get in touch.</p>
<p><a rel="noopener noreferrer" target="_blank" title="" href="https://epoch.epoch.tw">Click me</a> for more details.</p>

  </div>
```

### 程式碼區塊

安裝依賴套件。

```bash
npm install marked-highlight highlight.js
```

修改 `utils/markdown-utils.js` 檔。

```js
import hljs from 'highlight.js';
import { Marked } from 'marked';
import { markedHighlight } from 'marked-highlight';
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
    const marked = new Marked(
      markedHighlight({
        langPrefix: 'lang-',
        highlight(code, lang) {
          const options = {
            language: hljs.getLanguage(lang) ? lang : 'javascript',
          };
          return hljs.highlight(code, options).value;
        },
      }),
    );
    const renderer = {
      link({ href, title, text }) {
        return `<a href="${href}" title="${title || ''}" target="_blank" rel="noopener noreferrer">${text}</a>`;
      },
    };
    return marked
      .use({ renderer })
      .parse(markdown);
  }
}

export default MarkdownUtils;
```

修改 `style.css` 檔。

```css
@import 'highlight.js/styles/atom-one-dark.css';
```

修改 `main.js` 檔。

```js
import './style.css';
import MarkdownUtils from './utils/markdown-utils.js';

const text = `## Memo Chou\n
Hi there 🙋\n
I'm Memo Chou, a creative developer passionate about Go, PHP, Rust and JavaScript.\n
Any questions, or want to get involved, please get in touch.\n
[Click me](https://epoch.epoch.tw) for more details.\n
\`\`\`javascript
console.log('Hello, World!');
\`\`\`\n
`;

document.querySelector('#app').innerHTML = `
  <div>
    ${MarkdownUtils.toSafeHtml(text)}
  </div>
`;
```

輸出如下：

```html
  <div>
    <h2>Memo Chou</h2>
<p>Hi there 🙋</p>
<p>I'm Memo Chou, a creative developer passionate about Go, PHP, Rust and JavaScript.</p>
<p>Any questions, or want to get involved, please get in touch.</p>
<p><a rel="noopener noreferrer" target="_blank" title="" href="https://epoch.epoch.tw">Click me</a> for more details.</p>
<pre><code class="lang-javascript"><span class="hljs-variable language_">console</span>.<span class="hljs-title function_">log</span>(<span class="hljs-string">'Hello, World!'</span>);
</code></pre>
  </div>
```

## 程式碼

- [markdown-js-example](https://github.com/memochou1993/markdown-js-example)

## 參考資料

- [markedjs/marked](https://github.com/markedjs/marked)
- [cure53/DOMPurify](https://github.com/cure53/DOMPurify)
