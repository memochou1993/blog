---
title: 在 Next 12.0 使用 ESLint 分析工具並套用 Airbnb 程式碼風格
permalink: 在-Next-12-0-使用-ESLint-分析工具並套用-Airbnb-程式碼風格
date: 2022-03-14 23:56:36
tags: ["程式設計", "JavaScript", "ESLint", "Airbnb", "React", "Next"]
categories: ["程式設計", "JavaScript", "ESLint"]
---

## 做法

安裝 `eslint` 依賴套件。

```BASH
yarn add eslint \         
    eslint-config-airbnb \
    eslint-plugin-jsx-a11y \
    eslint-plugin-react \
    eslint-plugin-import \
    --save-dev
```

安裝 `prop-types` 依賴套件。

```BASH
yarn add prop-types
```

修改 `.eslintrc.json` 檔，並添加相關規則。

```JSON
{
  "extends": "airbnb",
  "rules": {
    "react/jsx-props-no-spreading": "off"
  }
}
```

將 `_app.js` 檔重新命名為 `_app.jsx` 檔，並修改如下。

```JS
import React from 'react';
import PropTypes from 'prop-types';
import '../styles/globals.css';

export default function App({ Component, pageProps }) {
  return <Component {...pageProps} />;
}

App.propTypes = {
  Component: PropTypes.element.isRequired,
  pageProps: PropTypes.element.isRequired,
};
```

執行檢查。

```BASH
npm run lint
```
