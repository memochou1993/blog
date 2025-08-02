---
title: 使用 JavaScript 透過 Google Sheets API 存取 Google 試算表
date: 2025-08-02 01:49:29
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
mkdir google-sheets-api-example
cd google-sheets-api-example
```

初始化專案。

```bash
npm init
```

修改 `package.json` 檔。

```json
{
  "type": "module",
}
```

安裝依賴套件。

```bash
npm i googleapis
```

建立 `GoogleSheetsClient.js` 檔。

```js
import fs from 'fs';
import { google } from 'googleapis';

/**
 * GoogleSheetsClient class
 * Handles operations with Google Sheets API
 */
class GoogleSheetsClient {
  #spreadsheetId;
  #credentialsPath;
  #auth;
  #sheets;

  /**
   * Constructor
   * @param {Object} params - Constructor parameters
   * @param {string} params.spreadsheetId - Google Spreadsheet ID
   * @param {string} [params.credentialsPath='./credentials.json'] - Path to credentials file
   */
  constructor({
    spreadsheetId,
    credentialsPath = './credentials.json',
  }) {
    this.#spreadsheetId = spreadsheetId;
    this.#credentialsPath = credentialsPath;
    this.#auth = null;
    this.#sheets = null;
  }

  /**
   * Initialize and authorize
   * Establishes connection with Google Sheets API
   */
  async initialize() {
    try {
      const credentials = JSON.parse(fs.readFileSync(this.#credentialsPath, 'utf8'));

      this.#auth = new google.auth.GoogleAuth({
        credentials,
        scopes: ['https://www.googleapis.com/auth/spreadsheets'], // Updated to allow write access
      });

      this.#sheets = google.sheets({ version: 'v4', auth: this.#auth });
      console.log('Google Sheets API authorization successful');

      return this;
    } catch (err) {
      console.error('Initialization error:', err);
      throw err;
    }
  }

  /**
   * Ensures the specified directory exists
   * @param {string} dir - Directory path
   */
  ensureDirectoryExists(dir) {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
      console.log(`Directory created: ${dir}`);
    }
  }

  /**
   * Get list of all worksheets in the spreadsheet
   * @returns {Promise<Array>} Array containing worksheet names and IDs
   */
  async getSheetList() {
    try {
      const { data: { sheets } } = await this.#sheets.spreadsheets.get({
        spreadsheetId: this.#spreadsheetId,
      });

      return sheets.map(({ properties: { title, sheetId } }) => ({
        title,
        sheetId,
      }));
    } catch (err) {
      console.error('Error fetching worksheet list:', err);
      throw err;
    }
  }

  /**
   * Get spreadsheet data for specified range
   * @param {string} range - Range to fetch, e.g. 'Sheet1!A1:D10'
   * @returns {Promise<Array>} Spreadsheet data array
   */
  async getSheetData(range) {
    try {
      const { data: { values: rows } } = await this.#sheets.spreadsheets.values.get({
        spreadsheetId: this.#spreadsheetId,
        range,
      });

      if (!rows?.length) {
        console.log('No data found in specified range');
        return [];
      }

      return rows;
    } catch (err) {
      console.error('Error fetching spreadsheet data:', err);
      throw err;
    }
  }

  /**
   * Get all data from a specific worksheet
   * @param {string} sheetName - Worksheet name
   * @returns {Promise<Array>} Worksheet data array
   */
  getEntireSheetData = (sheetName) => this.getSheetData(`${sheetName}!A:Z`);

  /**
   * Update spreadsheet data for specified range
   * @param {string} range - Range to update, e.g. 'Sheet1!A1:D10'
   * @param {Array} values - 2D array of values to write
   * @returns {Promise<Object>} Update result
   */
  async updateSheetData(range, values) {
    try {
      const result = await this.#sheets.spreadsheets.values.update({
        spreadsheetId: this.#spreadsheetId,
        range,
        valueInputOption: 'RAW', // or 'USER_ENTERED' for formula support
        resource: {
          values,
        },
      });

      console.log(`Updated ${result.data.updatedCells} cells in range "${range}"`);
      return result.data;
    } catch (err) {
      console.error('Error updating spreadsheet data:', err);
      throw err;
    }
  }

  /**
   * Clear and then update sheet data (ensures consistent structure)
   * @param {string} sheetName - Sheet name
   * @param {Array} values - 2D array of values to write
   * @returns {Promise<Object>} Update result
   */
  async clearAndUpdateSheet(sheetName, values) {
    try {
      // First, clear the existing data
      await this.#sheets.spreadsheets.values.clear({
        spreadsheetId: this.#spreadsheetId,
        range: `${sheetName}!A:Z`,
      });

      // Then write the new data
      return this.updateSheetData(`${sheetName}!A1`, values);
    } catch (err) {
      console.error(`Error clearing and updating sheet "${sheetName}":`, err);
      throw err;
    }
  }
}

export default GoogleSheetsClient;
```

建立 `index.js` 檔。

```js
import GoogleSheetsClient from './GoogleSheetsClient.js';

const {
  GOOGLE_SPREADSHEET_ID,
} = process.env;

const client = new GoogleSheetsClient({
  spreadsheetId: GOOGLE_SPREADSHEET_ID,
});

client.initialize();

const sheets = await client.getSheetList();

console.log(`Available sheets: ${sheets.map(sheet => sheet.title).join(', ')}`);

sheets.forEach(async (sheet) => {
  const data = await client.getEntireSheetData(sheet.title);
  console.log(`Data from ${sheet.title}:`, data);
});
```

執行程式。

```bash
GOOGLE_SPREADSHEET_ID=your-spreadsheet-id node index.js
```

## 程式碼

- [google-sheets-api-example](https://github.com/memochou1993/google-sheets-api-example)

## 參考資料

- [Google Sheets API](https://developers.google.com/sheets/api/guides/concepts)
