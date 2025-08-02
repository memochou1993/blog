---
title: 實作「Google Sheets I18N Syncer」命令列介面
date: 2025-08-03 01:50:24
tags: ["Programming", "JavaScript", "Google APIs", "Google Sheets API", "CLI"]
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
mkdir google-sheets-i18n-syncer
cd google-sheets-i18n-syncer
```

建立 `package.json` 檔。

```json
{
  "name": "@memochou1993/google-sheets-i18n-syncer",
  "version": "1.0.1",
  "description": "A CLI tool to fetch and sync translations from Google Sheets",
  "main": "lib/index.js",
  "type": "module",
  "exports": {
    ".": "./lib/index.js",
    "./GoogleSheetsClient": "./lib/GoogleSheetsClient.js",
    "./I18nSyncer": "./lib/I18nSyncer.js",
    "./formatHandlers": "./lib/formatHandlers/index.js"
  },
  "bin": {
    "i18n-syncer": "./bin/i18n-syncer.js"
  },
  "files": [
    "bin/",
    "lib/"
  ],
  "scripts": {
    "cli": "node bin/i18n-syncer.js",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix"
  },
  "keywords": [
    "i18n",
    "localization",
    "google-sheets",
    "cli",
    "translation"
  ],
  "author": "",
  "license": "MIT",
  "dependencies": {
    "commander": "^14.0.0",
    "googleapis": "^154.0.0"
  },
  "peerDependencies": {
    "dotenv": "^17.0.0"
  },
  "devDependencies": {
    "dotenv": "^17.2.1",
    "@eslint/eslintrc": "^3.3.1",
    "@eslint/js": "^9.32.0",
    "eslint": "^9.32.0",
    "eslint-plugin-import": "^2.32.0",
    "globals": "^16.3.0"
  },
  "engines": {
    "node": ">=14.0.0"
  }
}
```

安裝依賴套件。

```bash
npm i
```

建立 `.env.example` 檔。

```env
# Google Sheets i18n Syncer Configuration
# Copy this file to .env and fill in your values

# Required: Your Google Spreadsheet ID (from the URL)
I18N_SYNCER_SPREADSHEET_ID=

# Optional: Default sheet name within the spreadsheet
# I18N_SYNCER_SHEET_NAME=Translations

# Optional: Path to Google API credentials file
# I18N_SYNCER_CREDENTIALS_PATH=./credentials.json

# Optional: Directory to store translation files
# I18N_SYNCER_TRANSLATION_DIR=./translations

# Optional: Format for translation files
# I18N_SYNCER_FORMAT=json
```

建立 `.gitignore` 檔。

```env
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Credentials (don't commit these to git!)
credentials*.json

# Translation files
translations/

# Logs
logs
*.log

# IDE files
.idea/
.vscode/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db
```

建立 `eslint.config.js` 檔。

```js
import { FlatCompat } from '@eslint/eslintrc';
import js from '@eslint/js';
import globals from 'globals';

const compat = new FlatCompat();

export default [
  js.configs.recommended,
  ...compat.config({
    plugins: ['import'],
    extends: ['plugin:import/errors', 'plugin:import/warnings'],
  }),
  {
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        ...globals.node,
        ...globals.es2022,
      },
    },
    rules: {
      'no-console': 'off',
      'import/extensions': ['error', 'ignorePackages'],
      'semi': ['error', 'always'],
      'quotes': ['error', 'single'],
      'indent': ['error', 2],
      'comma-dangle': ['error', 'always-multiline'],
    },
    ignores: [
      'node_modules/',
      'coverage/',
      'dist/',
      '**/*.min.js',
      'translations/*.json',
      'credentials.json',
    ],
  },
];
```

## 實作

### 實作客戶端

建立 `lib` 資料夾。

```bash
mkdir lib
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

### 實作格式化處理器

建立 `lib/formatHandlers/BaseFormatHandler.js` 檔。

```js
/* eslint-disable no-unused-vars */
import path from 'path';
import fs from 'fs';

/**
 * BaseFormatHandler
 * Abstract base class for all format handlers
 */
export default class BaseFormatHandler {
  /**
   * Get the file extension for this format
   * @returns {string} File extension with dot prefix
   */
  get extension() {
    throw new Error('extension must be implemented by subclass');
  }

  /**
   * Convert translation object to string format
   * @param {Object} translation - Translation object
   * @returns {string} Formatted content as string
   */
  save(translation) {
    throw new Error('save method must be implemented by subclass');
  }

  /**
   * Read and parse a translation file
   * @param {string} filePath - Path to the translation file
   * @returns {Object} Parsed translation object
   */
  read(filePath) {
    const fileContent = this.readFileContent(filePath);
    return this.parseContent(fileContent, path.basename(filePath));
  }

  /**
   * Read file content
   * @param {string} filePath - Path to the file
   * @returns {string} File content
   * @protected
   */
  readFileContent(filePath) {
    return fs.readFileSync(filePath, 'utf8');
  }

  /**
   * Parse file content (to be implemented by subclasses)
   * @param {string} content - File content
   * @param {string} fileName - File name for error reporting
   * @returns {Object} Parsed translation object
   * @protected
   */
  parseContent(content, fileName) {
    throw new Error('parseContent method must be implemented by subclass');
  }

  /**
   * Generate a file path for a language code
   * @param {string} dir - Directory path
   * @param {string} langCode - Language code
   * @returns {string} Complete file path
   */
  generateFilePath(dir, langCode) {
    return path.join(dir, `${langCode}${this.extension}`);
  }
}
```

建立 `lib/formatHandlers/JsonFormatHandler.js` 檔。

```js
import BaseFormatHandler from './BaseFormatHandler.js';

/**
 * JsonFormatHandler
 * Handles reading and writing translation files in JSON format
 */
export default class JsonFormatHandler extends BaseFormatHandler {
  /**
   * Get the file extension for JSON format
   * @returns {string} File extension (.json)
   */
  get extension() {
    return '.json';
  }

  /**
   * Convert translation object to JSON string format
   * @param {Object} translation - Translation object
   * @returns {string} Formatted JSON content as string
   */
  save(translation) {
    return JSON.stringify(translation, null, 2);
  }

  /**
   * Parse JSON content
   * @param {string} content - File content
   * @param {string} fileName - File name for error reporting
   * @returns {Object} Parsed translation object
   * @protected
   */
  parseContent(content, fileName) {
    try {
      return JSON.parse(content);
    } catch (err) {
      throw new Error(`Invalid JSON in ${fileName}: ${err.message}`);
    }
  }
}
```

建立 `lib/formatHandlers/JsFormatHandler.js` 檔。

```js
import BaseFormatHandler from './BaseFormatHandler.js';

/**
 * JsFormatHandler
 * Handles reading and writing translation files in JavaScript module format
 */
export default class JsFormatHandler extends BaseFormatHandler {
  /**
   * Get the file extension for JavaScript format
   * @returns {string} File extension (.js)
   */
  get extension() {
    return '.js';
  }

  /**
   * Convert translation object to JavaScript module string format
   * @param {Object} translation - Translation object
   * @returns {string} Formatted JavaScript module content as string
   */
  save(translation) {
    const entries = Object.entries(translation);
    const lines = entries.map(([key, value]) => {
      // Handle special characters, ensure single quotes are escaped
      const escapedValue = String(value).replace(/'/g, '\\\'');

      // Only use quotes for keys that contain spaces
      const formattedKey = key.split('').some(char => char === ' ') ? `'${key}'` : key;

      return `  ${formattedKey}: '${escapedValue}',`;
    });

    return `export default {\n${lines.join('\n')}\n};\n`;
  }

  /**
   * Parse JavaScript module content
   * @param {string} content - File content
   * @param {string} fileName - File name for error reporting
   * @returns {Object} Parsed translation object
   * @protected
   */
  parseContent(content, fileName) {
    const jsObject = this.#extractObjectFromModule(content, fileName);
    return this.#evaluateJsObject(jsObject, fileName);
  }

  /**
   * Extract JavaScript object from module export statement
   * @param {string} content - File content
   * @param {string} fileName - File name for error reporting
   * @returns {string} JavaScript object as string
   * @private
   */
  #extractObjectFromModule(content, fileName) {
    // Try to match export default with object (most common pattern)
    const patterns = [
      /export\s+default\s+(\{[\s\S]*?\n\};?)/m,  // With newline before closing brace
      /export\s+default\s+(\{[\s\S]*?\};?)/m,     // Without requiring newline
    ];

    // Try each pattern until we find a match
    for (const pattern of patterns) {
      const match = content.match(pattern);
      if (match && match[1]) {
        return match[1];
      }
    }

    // If we get here, no patterns matched
    throw new Error(`Could not find valid export default statement in ${fileName}`);
  }

  /**
   * Safely evaluate a JavaScript object string
   * @param {string} jsObjectStr - JavaScript object as string
   * @param {string} fileName - File name for error reporting
   * @returns {Object} Parsed object
   * @private
   */
  #evaluateJsObject(jsObjectStr, fileName) {
    try {
      // Remove any trailing semicolons before evaluating
      const cleanJsObject = jsObjectStr.replace(/;+\s*$/, '');

      // This is generally not recommended, but in this controlled case it's acceptable
      // We're only parsing translation files that we control
      return eval(`(${cleanJsObject})`);
    } catch (err) {
      throw new Error(`Failed to parse JS content in ${fileName}: ${err.message}`);
    }
  }
}
```

建立 `lib/formatHandlers/index.js` 檔。

```js
import JsonFormatHandler from './JsonFormatHandler.js';
import JsFormatHandler from './JsFormatHandler.js';

/**
 * @import BaseFormatHandler from './BaseFormatHandler.js';
 */

// Export all format handlers
export {
  JsonFormatHandler,
  JsFormatHandler,
};

// Map of format name to handler class
const formatHandlers = {
  json: JsonFormatHandler,
  js: JsFormatHandler,
};

/**
 * Get a format handler instance by format name
 * @param {string} format - Format name (e.g., 'json', 'js')
 * @returns {BaseFormatHandler} Format handler instance
 */
export function getFormatHandler(format = 'json') {
  const formatLower = format.toLowerCase();
  const HandlerClass = formatHandlers[formatLower];

  if (!HandlerClass) {
    console.warn(`Invalid format "${format}", using "json" as default`);
    return new formatHandlers.json();
  }

  return new HandlerClass();
}

export default {
  getFormatHandler,
};
```

### 實作同步器

建立 `I18nSyncer.js` 檔。

```js
import { getFormatHandler } from './formatHandlers/index.js';
import fs from 'fs';
import GoogleSheetsClient from './GoogleSheetsClient.js';
import path from 'path';

/**
 * I18nSyncer class
 * Handles the workflow for syncing translations from Google Sheets and organizing by language
 */
export class I18nSyncer {
  #client;
  #translationDir;

  /**
   * Constructor
   * @param {Object} params - Constructor parameters
   * @param {string} params.spreadsheetId - Google Spreadsheet ID
   * @param {string} [params.credentialsPath='./credentials.json'] - Path to credentials file
   * @param {string} [params.translationDir='./translations'] - Directory for translation JSON files
   */
  constructor({
    spreadsheetId,
    credentialsPath = './credentials.json',
    translationDir = './translations',
  } = {}) {
    // Validate required parameters
    if (!spreadsheetId) {
      throw new Error('Spreadsheet ID is required');
    }

    // Validate credentials path
    if (!fs.existsSync(credentialsPath)) {
      throw new Error(`Credentials file not found at: ${credentialsPath}`);
    }

    this.#translationDir = translationDir;
    this.#client = new GoogleSheetsClient({
      spreadsheetId,
      credentialsPath,
    });

    // Ensure translation directory exists
    this.#ensureDirectoryExists(this.#translationDir);
  }

  /**
   * Ensure the specified directory exists
   * @param {string} dir - Directory path
   */
  #ensureDirectoryExists(dir) {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
      console.log(`Directory created: ${dir}`);
    }
  }

  /**
   * Process data into language-specific key-value pairs
   * @param {Array} data - Raw sheet data
   * @returns {Object} Object with language codes as keys and their respective translation objects as values
   */
  #processDataByLanguage(data) {
    if (!data || data.length < 2) {
      console.log('Insufficient data for processing (minimum 2 rows required)');
      return {};
    }

    // First row contains headers: [Key, lang1, lang2, ...]
    const [headers] = data;

    // Assuming "Key" is always the first column
    const keyIndex = 0;

    // Create translation objects for each language
    const translations = {};

    // Initialize translation objects based on headers
    for (let i = 1; i < headers.length; i++) {
      const langCode = headers[i];
      translations[langCode] = {};
    }

    // Process each data row
    for (let rowIndex = 1; rowIndex < data.length; rowIndex++) {
      const row = data[rowIndex];
      const key = row[keyIndex];

      // Skip if no key
      if (!key) continue;

      // For each language, add the translation
      for (let colIndex = 1; colIndex < headers.length; colIndex++) {
        const langCode = headers[colIndex];
        const value = row[colIndex] || '';

        // Store the translation value as is (no special handling for pipe character)
        translations[langCode][key] = value;
      }
    }

    return translations;
  }

  /**
   * Save translations to separate files based on format
   * @param {Object} translations - Processed translations data
   * @param {string} translationDir - Directory to save translation files
   * @param {string} [format='json'] - Format of translation files ('json', 'js', etc.)
   */
  #saveLanguageFiles(translations, translationDir, format = 'json') {
    // Only ensure directory exists if it's different from the default one
    if (translationDir !== this.#translationDir) {
      this.#ensureDirectoryExists(translationDir);
    }

    const formatHandler = getFormatHandler(format);

    for (const [langCode, translation] of Object.entries(translations)) {
      const filePath = formatHandler.generateFilePath(translationDir, langCode);
      const fileContent = formatHandler.save(translation);

      fs.writeFileSync(filePath, fileContent);
      console.log(`Translation file saved: ${filePath}`);
    }
  }

  /**
   * Pull translations from Google Sheets to translation files
   * @param {Object} params - Pull parameters
   * @param {string} [params.translationDir] - Directory to save translation files
   * @param {string} [params.sheetName] - Specific sheet name to pull from
   * @param {string} [params.format='json'] - Format of translation files ('json' or 'js')
   * @returns {Promise<Object>} Translations organized by language code
   */
  async pull({ translationDir, sheetName, format = 'json' } = {}) {
    try {
      console.log('Starting translation pull from Google Sheets...');

      // Initialize client
      await this.#client.initialize();

      // Determine which sheet to use
      let targetSheet = sheetName;

      // If no specific sheet name was provided, use the first sheet
      if (!targetSheet) {
        const sheetsList = await this.#client.getSheetList();

        // Return early if no sheets found
        if (!sheetsList.length) {
          console.error('No worksheets found in the spreadsheet');
          return {};
        }

        // Use first sheet
        const [firstSheet] = sheetsList;
        targetSheet = firstSheet.title;
      }

      console.log(`Fetching data from worksheet "${targetSheet}"...`);
      const data = await this.#client.getEntireSheetData(targetSheet);

      console.log('Processing data and generating language files...');
      const languageData = this.#processDataByLanguage(data);

      // Save language files
      const saveDir = translationDir || this.#translationDir;
      this.#saveLanguageFiles(languageData, saveDir, format);

      // Count languages and keys for symmetrical reporting with push
      const languageCount = Object.keys(languageData).length;
      let keyCount = 0;

      // Get key count if languages exist
      if (languageCount > 0) {
        const firstLang = Object.keys(languageData)[0];
        keyCount = Object.keys(languageData[firstLang]).length;
      }

      console.log(`Pulled ${keyCount} translation keys across ${languageCount} languages from Google Sheets`);
      return languageData;

    } catch (err) {
      console.error('Error pulling data:', err);
      throw err;
    }
  }

  /**
   * Push translations from translation files to Google Sheets
   * @param {Object} params - Push parameters
   * @param {string} [params.translationDir] - Directory to load translation files from
   * @param {string} [params.sheetName] - Specific sheet name to push to
   * @param {string} [params.format='json'] - Format of translation files to read
   * @returns {Promise<boolean>} Success status
   */
  async push({ translationDir, sheetName, format = 'json' } = {}) {
    try {
      // Initialize client
      await this.#client.initialize();

      const sourceDir = translationDir || this.#translationDir;
      console.log(`Scanning for language files in ${sourceDir}...`);

      // Check if directory exists
      if (!fs.existsSync(sourceDir)) {
        console.error(`Directory not found: ${sourceDir}`);
        return false;
      }

      const formatHandler = getFormatHandler(format);

      // Determine which sheet to use
      let targetSheet = sheetName;
      if (!targetSheet) {
        const sheetsList = await this.#client.getSheetList();

        if (!sheetsList.length) {
          console.error('No worksheets found in the spreadsheet');
          return false;
        }

        const [firstSheet] = sheetsList;
        targetSheet = firstSheet.title;
      }

      console.log(`Pushing translations to worksheet "${targetSheet}"...`);

      // Read all language files from the directory
      const languageFiles = fs.readdirSync(sourceDir)
        .filter(file => file.endsWith(formatHandler.extension))
        .map(file => {
          try {
            const filePath = path.join(sourceDir, file);
            let content;

            try {
              content = formatHandler.read(filePath);
            } catch (err) {
              console.warn(`Could not read ${file}: ${err.message}`);
              return null;
            }

            const langCode = path.basename(file, formatHandler.extension);
            return { langCode, content };
          } catch (err) {
            console.warn(`Could not process file ${file}: ${err.message}`);
            return null;
          }
        })
        .filter(Boolean);

      if (languageFiles.length === 0) {
        console.error(`No valid language files with extension ${formatHandler.extension} found in the specified directory`);
        return false;
      }

      console.log(`Found ${languageFiles.length} language files: ${languageFiles.map(f => f.langCode).join(', ')}`);

      // Convert language files to Google Sheets format
      // First, collect all unique keys across all language files
      const allKeys = new Set();
      languageFiles.forEach(({ content }) => {
        Object.keys(content).forEach(key => allKeys.add(key));
      });

      // Create the header row: [Key, lang1, lang2, ...]
      const headers = ['Key', ...languageFiles.map(f => f.langCode)];

      // Create the rows with translations for each key
      const rows = Array.from(allKeys).map(key => {
        // First column is the key
        const row = [key];

        // Add translations for each language
        languageFiles.forEach(({ content }) => {
          // Convert any problematic values to strings and handle potential undefined values
          let value = content[key] || '';

          // Handle nested objects and arrays by stringifying them
          if (typeof value === 'object' && value !== null) {
            value = JSON.stringify(value);
          }

          // Ensure the value is a string
          value = String(value);

          row.push(value);
        });

        return row;
      });

      // Prepare the complete data for upload (headers + rows)
      const sheetData = [headers, ...rows];

      // Log data dimensions for debugging
      console.log(`Preparing data: ${sheetData.length} rows × ${headers.length} columns`);

      // Additional check for any potential null/undefined values that could cause API errors
      const sanitizedData = sheetData.map(row =>
        row.map(cell => (cell === null || cell === undefined) ? '' : String(cell)),
      );

      // Clear and update the sheet with the sanitized data
      await this.#client.clearAndUpdateSheet(targetSheet, sanitizedData);

      console.log(`Pushed ${rows.length} translation keys across ${languageFiles.length} languages to Google Sheets`);
      return true;
    } catch (err) {
      console.error('Error pushing translations:', err);
      // Log more details about the error for debugging
      if (err.response && err.response.data) {
        console.error('API error details:', JSON.stringify(err.response.data, null, 2));
      }
      throw err;
    }
  }
}

export default I18nSyncer;
```

建立 `lib/index.js` 檔。

```js
/**
 * Google Sheets i18n Syncer
 * Tool for syncing translation data from Google Sheets
 */

export { I18nSyncer } from './I18nSyncer.js';
export { default as GoogleSheetsClient } from './GoogleSheetsClient.js';
export * from './formatHandlers/index.js';
```

### 實作命令列介面

建立 `bin` 資料夾。

```bash
mkdir bin
```

建立 `bin/i18n-syncer.js` 檔。

```js
#!/usr/bin/env node

import { program } from 'commander';
import { I18nSyncer } from '../lib/index.js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

// Load environment variables from .env file
dotenv.config();

// Get package.json info for version
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const packageJsonPath = path.join(__dirname, '../package.json');
const { version } = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));

// Define the CLI version and description
program
  .name('i18n-syncer')
  .description('CLI to pull and push translations between Google Sheets and local files')
  .version(version);

// Helper function to handle common functionality for both commands
const createSyncer = (options) => {
  return new I18nSyncer({
    spreadsheetId: options.spreadsheetId,
    credentialsPath: options.credentials,
    translationDir: options.translationDir,
  });
};

// Enhanced error handler with more informative messages
const handleError = (error) => {
  if (error.code === 'ENOENT' && error.path?.includes('credentials.json')) {
    console.error('Error: Credentials file not found. Please provide a valid path to your Google API credentials.');
    process.exit(1);
  }

  if (error.message?.includes('invalid_grant') || error.message?.includes('authorization')) {
    console.error('Error: Google API authorization failed. Please check your credentials and permissions.');
    process.exit(1);
  }

  if (error.response?.status === 404) {
    console.error('Error: Spreadsheet not found. Please check your spreadsheet ID.');
    process.exit(1);
  }

  // Default case
  console.error('Error:', error.message);
  process.exit(1);
};

// Command to pull translations from Google Sheets
program
  .command('pull')
  .description('Pull translations from Google Sheets to translation files')
  .option('-s, --spreadsheet-id <id>', 'Google Spreadsheet ID', process.env.I18N_SYNCER_SPREADSHEET_ID)
  .option('-n, --sheet-name <name>', 'Name of the sheet to pull data from', process.env.I18N_SYNCER_SHEET_NAME)
  .option('-c, --credentials <path>', 'Path to credentials file', process.env.I18N_SYNCER_CREDENTIALS_PATH || './credentials.json')
  .option('-t, --translation-dir <directory>', 'Directory for translation JSON files', process.env.I18N_SYNCER_TRANSLATION_DIR || './translations')
  .option('-f, --format <format>', 'Format of translation files (json or js)', process.env.I18N_SYNCER_FORMAT || 'json')
  .action(async (options) => {
    try {
      // Check if spreadsheet ID is provided either as option or environment variable
      if (!options.spreadsheetId) {
        console.error('Error: Spreadsheet ID is required. Provide it with --spreadsheet-id option or set I18N_SYNCER_SPREADSHEET_ID in .env file.');
        process.exit(1);
      }

      console.log('Starting translation pull from Google Sheets...');

      const syncer = createSyncer(options);

      await syncer.pull({
        sheetName: options.sheetName,
        translationDir: options.translationDir,
        format: options.format,
      });

    } catch (error) {
      handleError(error);
    }
  });

// Command to push translations to Google Sheets
program
  .command('push')
  .description('Push translations from translation files to Google Sheets')
  .option('-s, --spreadsheet-id <id>', 'Google Spreadsheet ID', process.env.I18N_SYNCER_SPREADSHEET_ID)
  .option('-n, --sheet-name <name>', 'Name of the sheet to push data to', process.env.I18N_SYNCER_SHEET_NAME)
  .option('-c, --credentials <path>', 'Path to credentials file', process.env.I18N_SYNCER_CREDENTIALS_PATH || './credentials.json')
  .option('-t, --translation-dir <directory>', 'Directory for translation JSON files', process.env.I18N_SYNCER_TRANSLATION_DIR || './translations')
  .option('-f, --format <format>', 'Format of translation files to read (json or js)', process.env.I18N_SYNCER_FORMAT || 'json')
  .action(async (options) => {
    try {
      // Check if spreadsheet ID is provided either as option or environment variable
      if (!options.spreadsheetId) {
        console.error('Error: Spreadsheet ID is required. Provide it with --spreadsheet-id option or set I18N_SYNCER_SPREADSHEET_ID in .env file.');
        process.exit(1);
      }

      console.log('Starting translation push to Google Sheets...');

      const syncer = createSyncer(options);

      await syncer.push({
        sheetName: options.sheetName,
        translationDir: options.translationDir,
        format: options.format,
      });

    } catch (error) {
      handleError(error);
    }
  });

// Parse command line arguments
program.parse();
```

## 使用

在 Google 試算表，建立以下格式的資料，並確保已經與服務帳戶共用。

| Key           | en             | zh-TW         | ja             |
|---------------|----------------|---------------|----------------|
| greeting      | Hello          | 你好          | こんにちは     |
| goodbye       | Goodbye        | 再見          | さようなら     |
| thankyou      | Thank you      | 謝謝          | ありがとう     |
| welcome       | Welcome        | 歡迎          | ようこそ       |

### 使用命令列介面

```bash
# Pull data from Google Sheets and save as language files
node ./bin/i18n-syncer.js pull --spreadsheet-id YOUR_SPREADSHEET_ID --credentials path/to/credentials.json

# Pull data from a specific sheet by name
node ./bin/i18n-syncer.js pull --spreadsheet-id YOUR_SPREADSHEET_ID --sheet-name "Sheet1" --credentials path/to/credentials.json

# Save language files to a custom directory
node ./bin/i18n-syncer.js pull --spreadsheet-id YOUR_SPREADSHEET_ID --translation-dir ./translations

# Push language files to Google Sheets
node ./bin/i18n-syncer.js push --spreadsheet-id YOUR_SPREADSHEET_ID --translation-dir ./translations

# Specify format (json or js)
node ./bin/i18n-syncer.js pull --spreadsheet-id YOUR_SPREADSHEET_ID --format js
```

### 使用程式介面

```js
import { I18nSyncer } from 'google-sheets-i18n-syncer';

const syncer = new I18nSyncer({
  spreadsheetId: 'YOUR_SPREADSHEET_ID',
  credentialsPath: './credentials.json',
  translationDir: './translations',
});

// Pull data from Google Sheets to language files
await syncer.pull();

// Or pull data from a specific sheet
await syncer.pull({
  sheetName: 'Sheet1',
  translationDir: './custom-dir',
});

// Push language files to Google Sheets
await syncer.push({
  sheetName: 'Sheet1',
});
```

## 程式碼

- [google-sheets-i18n-syncer](https://github.com/memochou1993/google-sheets-i18n-syncer)

## 參考資料

- [Google Sheets API](https://developers.google.com/sheets/api/guides/concepts)
