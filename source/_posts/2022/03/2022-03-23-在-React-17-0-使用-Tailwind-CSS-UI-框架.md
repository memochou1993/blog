---
title: 在 React 17.0 使用 Tailwind CSS UI 框架
date: 2022-03-23 02:12:40
tags: ["Programming", "JavaScript", "React"]
categories: ["Programming", "JavaScript", "React"]
---

## 做法

建立專案。

```bash
npm create vite@latest my-project -- --template react
cd my-project
```

安裝依賴套件。

```bash
npm install -D tailwindcss postcss autoprefixer
```

初始化專案，建立 `tailwind.config.js` 設定檔。

```bash
npx tailwindcss init -p
```

修改 `tailwind.config.js` 檔。

```js
module.exports = {
  content: [
    './index.html',
    './src/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};
```

修改 `src/index.css` 檔，添加 `@tailwind` 裝飾器。

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

在元件中使用。

```js
import './App.css';

function App() {
  return (
    <h1 className="text-3xl font-bold underline">
      Hello, World!
    </h1>
  );
}

export default App;
```

啟動服務。

```bash
npm run dev
```

## 參考資料

- [Tailwind - Documentation](https://tailwindcss.com/docs/guides/vite)
