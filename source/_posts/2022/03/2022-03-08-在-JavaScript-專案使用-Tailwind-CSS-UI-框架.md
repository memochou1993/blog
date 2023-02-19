---
title: 在 JavaScript 專案使用 Tailwind CSS UI 框架
date: 2022-03-08 14:34:20
tags: ["程式設計", "JavaScript", "UI Framework", "Tailwind CSS"]
categories: ["程式設計", "JavaScript", "其他"]
---

## 前言

Tailwind CSS 的 CDN 連結只適用於開發環境，如果要在正式環境使用，可以安裝 Tailwind CLI 工具。

## 做法

安裝 `tailwindcss` 依賴套件。

```bash
npm install -D tailwindcss
```

初始化專案，建立 `tailwind.config.js` 設定檔。

```bash
npx tailwindcss init
```

修改 `tailwind.config.js` 檔，其中 `content` 參數是指向專案中 `.html` 檔或 `.js` 檔的路徑。

```js
module.exports = {
  content: [
      './**/*.{html,js}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};
```

修改主要的 CSS 樣式檔，添加 `@tailwind` 裝飾器。

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {}
```

修改 `package.json` 檔。

```json
{
    "scripts": {
        "watch": "tailwindcss -i ./src/style.css -o ./dist/style.css --watch",
        "build": "tailwindcss -i ./src/style.css -o ./dist/style.css --minify"
    }
}
```

執行編譯。

```bash
npm run build
```

將編譯後的 `style.css` 檔引入到 `index.html` 檔。

```html
<!doctype html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="dist/style.css" rel="stylesheet">
</head>
<body>
  <h1 class="text-3xl font-bold underline">
    Hello World!
  </h1>
</body>
</html>
```

## 參考資料

- [Tailwind - Documentation](https://tailwindcss.com/docs/installation)
