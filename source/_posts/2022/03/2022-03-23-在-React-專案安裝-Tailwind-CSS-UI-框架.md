---
title: 在 React 專案安裝 Tailwind CSS UI 框架
permalink: 在-React-專案安裝-Tailwind-CSS-UI-框架
date: 2022-03-23 02:12:40
tags: ["程式設計", "JavaScript", "React"]
categories: ["程式設計", "JavaScript", "React"]
---

## 做法

安裝依賴套件。

```BASH
npm install -D tailwindcss postcss autoprefixer
```

初始化專案，建立 `tailwind.config.js` 設定檔。

```BASH
npx tailwindcss init -p
```

修改 `tailwind.config.js` 檔。

```JS
module.exports = {
  content: [
    './src/**/*.{js,jsx,ts,tsx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};
```

修改 `app.css` 檔，添加 `@tailwind` 裝飾器。

```CSS
@tailwind base;
@tailwind components;
@tailwind utilities;
```

在元件中使用。

```JS
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

```BASH
npm run start
```

## 參考資料

- [Tailwind - Documentation](https://tailwindcss.com/docs/guides/create-react-app)
