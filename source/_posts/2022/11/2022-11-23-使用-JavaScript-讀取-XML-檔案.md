---
title: 使用 JavaScript 讀取 XML 檔案
date: 2022-11-23 02:00:15
tags: ["程式設計", "JavaScript", "XML"]
categories: ["程式設計", "JavaScript", "其他"]
---

## 做法

以下使用部落格的 Atom 供稿檔為例。

### JavaScript

新增 `index.html` 檔，使用 Web API 解析。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
<script>
(async () => {
    const res = await fetch('https://blog.epoch.tw/atom.xml');
    const doc = new DOMParser().parseFromString(await res.text(), 'text/xml');
    const data = Array.from(doc.querySelectorAll('entry').values())
        .map((entry) => ({
            title: entry.querySelector('title')?.textContent,
            link: entry.querySelector('link')?.getAttribute('href'),
            published: entry.querySelector('published')?.textContent,
        }));
    console.log(data);
})();
</script>
</body>
</html>
```

### Node

安裝依賴套件。

```bash
npm i node-fetch xml2js
```

新增 `index.mjs` 檔。

```js
import fetch from 'node-fetch';
import xml2js from 'xml2js';

(async () => {
  const res = await fetch('https://blog.epoch.tw/atom.xml');
  const str = await res.text();
  const doc = await xml2js.parseStringPromise(str);
  const data = doc.feed.entry.map((entry) => ({
    title: entry.title[0],
    link: entry.link[0].$.href,
    published: entry.published[0],
  }));
  console.log(data);
})();
```

執行程式。

```bash
node index.js
```
