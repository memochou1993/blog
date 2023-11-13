---
title: 使用 CodeMirror 6 建立網頁程式碼編輯器
date: 2023-11-12 01:08:29
tags: ["Programming", "JavaScript", "Code Editor"]
categories: ["Programming", "JavaScript", "Others"]
---

## 建立專案

建立專案。

```bash
npm create vite
  ✔ Project name: … codemirror-example
  ✔ Select a framework: › Vanilla
  ✔ Select a variant: › TypeScript
cd codemirror-example
```

安裝依賴套件。

```bash
npm install
```

## 實作

安裝 `codemirror` 套件。

```bash
npm install codemirror
```

修改 `index.html` 檔。

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Vite + TS</title>
  </head>
  <body>
    <div id="editor"></div>
    <script type="module" src="/src/main.ts"></script>
  </body>
</html>
```

修改 `style.css` 檔。

```css
:root {
  background: black;
}

#editor {
  background: white;
}
```

修改 `main.ts` 檔。

```ts
import './style.css';
import { minimalSetup, EditorView } from 'codemirror';

const initialText = 'console.log("Hello, world!")';

const targetElement = document.querySelector('#editor') as Element;

new EditorView({
  doc: initialText,
  extensions: [
    minimalSetup,
  ],
  parent: targetElement,
});
```

啟動服務。

```bash
npm run dev
```

### 進階使用

安裝依賴套件。

```bash
npm install @codemirror/lang-javascript \
@codemirror/state \
@codemirror/view \
@codemirror/autocomplete \
@codemirror/commands \
@codemirror/language \
@codemirror/lint \
@codemirror/search
```

修改 `main.ts` 檔。

```ts
import './style.css';
import { autocompletion, closeBrackets, closeBracketsKeymap, completionKeymap } from '@codemirror/autocomplete';
import { defaultKeymap, history, historyKeymap } from '@codemirror/commands';
import { javascript } from '@codemirror/lang-javascript';
import { bracketMatching, defaultHighlightStyle, foldGutter, foldKeymap, indentOnInput, syntaxHighlighting } from '@codemirror/language';
import { lintKeymap } from '@codemirror/lint';
import { highlightSelectionMatches, searchKeymap } from '@codemirror/search';
import { EditorState } from '@codemirror/state';
import { crosshairCursor, drawSelection, dropCursor, EditorView, highlightActiveLine, highlightActiveLineGutter, highlightSpecialChars, keymap, lineNumbers, rectangularSelection } from '@codemirror/view';

const initialText = 'console.log("Hello, world!")';
const targetElement = document.querySelector('#editor') as Element;

new EditorView({
  parent: targetElement,
  state: EditorState.create({
    doc: initialText,
    extensions: [
      lineNumbers(),
      highlightActiveLineGutter(),
      highlightSpecialChars(),
      history(),
      foldGutter(),
      drawSelection(),
      dropCursor(),
      EditorState.allowMultipleSelections.of(true),
      EditorView.theme({
        '&': {
          // ...
        },
      }, { dark: true }),
      indentOnInput(),
      syntaxHighlighting(defaultHighlightStyle, { fallback: true }),
      bracketMatching(),
      closeBrackets(),
      autocompletion(),
      rectangularSelection(),
      crosshairCursor(),
      highlightActiveLine(),
      highlightSelectionMatches(),
      keymap.of([
        ...closeBracketsKeymap,
        ...defaultKeymap,
        ...searchKeymap,
        ...historyKeymap,
        ...foldKeymap,
        ...completionKeymap,
        ...lintKeymap,
      ]),
      javascript(),
    ],
  }),
});
```

啟動服務。

```bash
npm run dev
```

## 程式碼

- [codemirror-example](https://github.com/memochou1993/codemirror-example)

## 參考資料

- [CodeMirror](https://codemirror.net/docs/)
- [How to build a Code Editor with CodeMirror 6 and TypeScript: Introduction](https://davidmyers.dev/blog/how-to-build-a-code-editor-with-codemirror-6-and-typescript/introduction)
