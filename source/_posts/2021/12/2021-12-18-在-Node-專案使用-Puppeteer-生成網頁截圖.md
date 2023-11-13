---
title: 在 Node 專案使用 Puppeteer 生成網頁截圖
date: 2021-12-18 23:54:09
tags: ["Programming", "JavaScript", "Node", "Web Scraping"]
categories: ["Programming", "JavaScript", "Node"]
---

## 做法

建立專案。

```bash
npm init
```

安裝依賴套件。

```bash
npm i puppeteer
```

新增 `main.js` 檔：

```js
const puppeteer = require('puppeteer');

(async () => {
  // 啟動瀏覽器
  const browser = await puppeteer.launch();
  // 開啟新頁
  const page = await browser.newPage();
  // 前往網站
  await page.goto('https://example.com');
  // 截圖
  await page.screenshot({ path: 'example.png' });
  // 關閉瀏覽器
  await browser.close();
})();
```

如果要將特定元素隱藏，可以使用 `page.evaluate()` 方法執行一段程式：

```js
await page.evaluate(() => {
  document.querySelector('#some-button').style.display = 'none';
});
```

也可以使用選擇器獲取特定節點並進行截圖：

```js
const ele = await page.$('#my-card');
if (ele) {
  const box = await ele.boundingBox();
  await page.screenshot({
    clip: {
      x: box.x,
      y: box.y,
      width: box.width,
      height: box.height,
    },
  });
}
```

## 程式碼

- [puppeteer-example](https://github.com/memochou1993/puppeteer-example)

## 參考資料

- [puppeteer/puppeteer](https://github.com/puppeteer/puppeteer)
