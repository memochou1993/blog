---
title: 在 Next 13.0 使用 Font Awesome 字體套件
date: 2022-11-21 14:31:19
tags: ["Programming", "JavaScript", "React", "Next", "Font Awesome"]
categories: ["Programming", "JavaScript", "Next"]
---

## 做法

安裝依賴。

```bash
npm i @fortawesome/fontawesome-svg-core \
    @fortawesome/react-fontawesome \
    @fortawesome/free-solid-svg-icons \
    @fortawesome/free-brands-svg-icons \
    --save
```

修改 `_app.tsx` 檔。

```tsx
import React from 'react';
import '../styles/globals.css';
import type { AppProps } from 'next/app';
import { config } from '@fortawesome/fontawesome-svg-core';
import '@fortawesome/fontawesome-svg-core/styles.css';

config.autoAddCss = false;

export default function App({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />;
}
```

修改 `index.tsx` 檔，引入字體。

```tsx
import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faFaceSmile } from '@fortawesome/free-solid-svg-icons';

export default function Home() {
  return (
    <div className="container">
      <main>
        <h1 className="title">
          <FontAwesomeIcon icon={faFaceSmile} />
        </h1>
      </main>
    </div>
  );
};
```

## 參考資料

- [Use Font Awesome on the Web - Next.js](https://fontawesome.com/docs/web/use-with/react/use-with#next-js)
