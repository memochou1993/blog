---
title: 使用 JavaScript 透過 Google Sheets API 存取 Google 試算表
date: 2022-10-07 21:03:02
tags: ["Programming", "JavaScript", "Google APIs", "Google Sheets API"]
categories: ["Programming", "JavaScript", "Others"]
---

## 前置作業

首先要取得一個存取 Google Sheets API 的金鑰。步驟如下：

1. 前往 [Google Cloud](https://cloud.google.com/)。
2. 在控制台輸入「Google Sheets API」，並啟用。
3. 點選「IAM 與管理」頁籤，點選「服務帳戶」頁籤，建立一個服務帳戶。
4. 點選建立好的服務帳戶，點選「金鑰」頁籤，建立一個 JSON 格式的金鑰。
5. 建立一個試算表，與服務帳戶共用。

## 建立專案

建立專案。

```bash
mkdir google-spreadsheet-example
cd google-spreadsheet-example
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

- [google-spreadsheet-example](https://github.com/memochou1993/google-spreadsheet-example)

## 參考資料

- [Google Sheets API](https://developers.google.com/sheets/api/guides/concepts)
