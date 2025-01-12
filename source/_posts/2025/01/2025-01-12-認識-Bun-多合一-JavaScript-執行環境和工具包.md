---
title: 認識 Bun 多合一 JavaScript 執行環境和工具包
date: 2025-01-12 15:21:13
tags:
categories:
---

## 前言

Bun 可以用在 JavaScript 和 TypeScript 專案的開發、測試、執行和打包。Bun 是多合一 JavaScript 執行環境和工具包，同時也是 Node.js 相容的套件管理工具。

## 認識執行時期

JavaScript（或更正式地稱為 ECMAScript）是一種程式語言的規範。任何人都可以開發 JavaScript 引擎，用於讀取並執行有效的 JavaScript 程式。目前最廣泛使用的兩個引擎是 V8（由 Google 開發）和 JavaScriptCore（由 Apple 開發），兩者均為開源。

大多數 JavaScript 程式並非在孤立環境中執行。它們需要存取外部世界的方法，才能執行實際有用的任務。這正是執行時期發揮作用的地方。執行時期實作了額外的 API，並將其提供給執行的 JavaScript 程式使用。

### 瀏覽器

值得注意的是，瀏覽器內建 JavaScript 執行時期，並透過全域的 `window` 物件公開一組特定於 Web 的 API。瀏覽器執行的任何 JavaScript 程式碼都可以利用這些 API，在當前網頁的背景下實現互動式或動態行為。

### Node.js

同樣地，Node.js 是一種 JavaScript 執行時期，用於非瀏覽器環境，例如伺服器。由 Node.js 執行的 JavaScript 程式可以存取一組特定於 Node.js 的全域變數，例如 `Buffer`、`process` 和 `__dirname`，以及內建模組，用於執行作業系統層級的任務，例如讀取／寫入檔案（`node:fs`）和處理網路（`node:net`、`node:http`）。此外，Node.js 還實作了一個基於 CommonJS 的模組系統和解析演算法，這一系統早於 JavaScript 的原生模組系統。

## 安裝

使用以下指令安裝 Bun 執行檔。

```bash
curl -fsSL https://bun.dev.org.tw/install | bash
```

## 範本

建立一個空的 Bun 專案架構。

```bash
mkdir bun-example
cd bun-example
bun init
```

## 執行時期

Bun 在幕後使用 JavaScriptCore 引擎，此引擎是由 Apple 為 Safari 開發。在多數情況下，啟動和執行效能都比 V8 快，而 V8 是 Node.js 和基於 Chromium 的瀏覽器所使用的引擎。它的轉譯器和執行時間是用 Zig 編寫的，Zig 是一種現代且高效能的語言。在 Linux 上，這轉化為比 Node.js 快 4 倍的啟動時間。

### 執行檔案

使用 `bun run` 指令來執行來源檔案。

```bash
bun run index.js
```

Bun 開箱即支援 TypeScript 和 JSX。

```bash
bun run index.js
bun run index.jsx
bun run index.ts
bun run index.tsx
```

在監聽模式下執行檔案，使用 `--watch` 標記。

```bash
bun --watch run index.tsx
```

### 執行 `package.json` 指令碼

在 `package.json` 定義多個對應於 shell 指令的命名。

```json
{
  // ... other fields
  "scripts": {
    "clean": "rm -rf dist && echo 'Done.'",
    "dev": "bun server.ts"
  }
}
```

使用 `bun run <script>` 指令來執行指令碼。

```bash
bun run clean
```

## 檔案類型

Bun 原生支援 TypeScript。在執行所有檔案之前，Bun 的快速原生轉譯器會即時轉譯。

### JSX

Bun 原生支援 `.jsx` 和 `.tsx` 檔案。Bun 的內部轉譯器會在執行之前將 JSX 語法轉換為純 JavaScript。

```bash
bun index.js
bun index.jsx
bun index.ts
bun index.tsx
```

### 文字檔

文字檔可以當作字串匯入。

```js
import text from "./text.txt";

console.log(text);
```

### JSON

JSON 和 TOML 檔可以直接從來源檔匯入。內容將會載入並以 JavaScript 物件回傳。

```bash
import pkg from "./package.json";
```

## 參考資料

- [Bun](https://bun.dev.org.tw/)
