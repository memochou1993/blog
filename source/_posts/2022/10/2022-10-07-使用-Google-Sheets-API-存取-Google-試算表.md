---
title: 使用 Google Sheets API 存取 Google 試算表
date: 2022-10-07 21:03:02
tags: ["程式設計", "JavaScript", "Google APIs"]
categories: ["程式設計", "JavaScript", "其他"]
---

## 前置作業

申請 [Google Sheets API](https://developers.google.com/sheets/api) 並取得憑證。

## 建立專案

建立專案。

```bash
mkdir google-sheets-example
cd google-sheets-example
```

初始化專案。

```bash
npm init
```

安裝依賴套件。

```bash
npm i google-spreadsheet
```

新增 `index.js` 檔。

```js
const { GoogleSpreadsheet } = require('google-spreadsheet');

(async () => {
  const spreadsheetId = ''; // required
  const sheetID = '0'; // required
  const doc = new GoogleSpreadsheet(spreadsheetId);
  await doc.useServiceAccountAuth(require('./credentials.json')); // required
  await doc.loadInfo();
  const sheet = doc.sheetsById[sheetID];
  const rows = await sheet.getRows();
  console.log(rows);
})();
```

執行程式。

```bash
node index.js
```

## 程式碼

- [google-sheets-api-example](https://github.com/memochou1993/google-sheets-api-example)

## 參考資料

- [Google Sheets API](https://developers.google.com/sheets/api/guides/concepts)
