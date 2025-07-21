---
title: 在 JavaScript 專案使用 Playwright 進行 UI 測試
date: 2024-10-06 22:20:15
tags: ["Programming", "JavaScript", "Testing", "Playwright"]
categories: ["Programming", "JavaScript", "End-to-end Testing"]
---

## 建立專案

建立專案。

```bash
npm create vite@latest playwright-example -- --template vanilla
cd playwright-example
```

## 安裝

安裝依賴套件。

```bash
npm install -D @playwright/test@latest
```

下載瀏覽器執行檔和相依套件。

```bash
npx playwright install
```

## 概念

### 導航

大多數的測試，會先導航到指定的 URL，就能開始與頁面元素進行互動。

```ts
await page.goto('/');
```

### 互動

執行操作通常會從定位元素開始。Playwright 的定位器（locators）代表一種在任何時候找到頁面上元素的方式。例如，可以使用元素的文字內容、CSS 選擇器、屬性值或其相對位置等方式，精確地找到特定的按鈕、輸入框或標籤。Playwright 會等待元素可操作後才執行操作。

```ts
// 建立一個定位器
const getStarted = page.getByRole('link', { name: 'Get started' });

// 點擊
await getStarted.click();
```

常用的基本操作有：

操作 | 說明
--- | ---
`locator.check()` | 勾選輸入框
`locator.click()` | 點擊元素
`locator.uncheck()` | 取消勾選輸入框
`locator.hover()` | 懸停在元素上
`locator.fill()` | 填寫表單輸入框
`locator.focus()` | 焦點在元素上
`locator.press()` | 按下單個鍵
`locator.setInputFiles()` | 選擇要上傳的檔案
`locator.selectOption()` | 在下拉式選單中選擇選項

### 斷言

Playwright 有像是 `expect` 函數形式的測試斷言，以及許多通用匹配器，如 `toEqual`、`toContain`、`toBeTruthy`，可以用來斷言任何條件。

```ts
expect(success).toBeTruthy();
```

Playwright 還包含非同步匹配器，它會等待直到滿足預期條件。例如，以下代碼會等待頁面獲取包含 `Playwright` 的標題。

```ts
await expect(page).toHaveTitle(/Playwright/);
```

常用的非同步匹配器：

Assertion | Description
---  | ---
`expect(locator).toBeChecked()` | 輸入框已被勾選
`expect(locator).toBeEnabled()` | 控制項已被啟用
`expect(locator).toBeVisible()` | 元素可見
`expect(locator).toContainText()` | 元素包含文本
`expect(locator).toHaveAttribute()` | 元素具有屬性
`expect(locator).toHaveCount()` | 元素列表具有給定的長度
`expect(locator).toHaveText()` | 元素匹配文本
`expect(locator).toHaveValue()` | 輸入元素具有值
`expect(page).toHaveTitle()` | 頁面具有標題
`expect(page).toHaveURL()` | 頁面具有 URL

### 測試隔離

Playwright 測試基於測試夾具（test fixtures）的概念，例如內建的 page fixture，它會被傳遞到測試中。由於瀏覽器上下文的存在，測試之間的頁面是隔離的，這等同於一個全新的瀏覽器設定檔案，每個測試都會獲得一個全新的環境，即使在單個瀏覽器中運行多個測試時也是如此。

```ts
import { test } from '@playwright/test';

test('example test', async ({ page }) => {
  // 此頁面屬於一個為此特定測試所建立的隔離的瀏覽器上下文
});

test('another test', async ({ page }) => {
  // 此頁面是另一個與前一個不一樣且完全隔離的瀏覽器上下文
});
```

### 測試鉤子

還可以使用各種測試鉤子（test hooks），例如使用 `test.describe` 來宣告一組測試，以及 `test.beforeEach` 和 `test.afterEach` 鉤子，可以在每個測試之前或之後執行，用於初始化和清理測試環境。而 `test.beforeAll` 和 `test.afterAll` 鉤子，則可以在整個測試組（suite）開始之前或結束之後執行一次，用來執行一次性設置或資源釋放。

```ts
import { test, expect } from '@playwright/test';

test.describe('navigation', () => {
  test.beforeEach(async ({ page }) => {
    // 在每個測試之前轉到起始 URL
    await page.goto('/');
  });

  test('main navigation', async ({ page }) => {
    // 斷言使用 expect API
    await expect(page).toHaveURL('/');
  });
});
```

如此一來，就可以在每個測試之前導航到特定的 URL，以確保每個測試都在一個已知的起始狀態下運行。

## 撰寫測試

新增 `playwright.config.ts` 檔。

```ts
import type { PlaywrightTestConfig } from '@playwright/test';

const config: PlaywrightTestConfig = {
  webServer: {
    command: 'npm run dev',
    port: 5173,
  },
  use: {
    baseURL: 'http://localhost:5173',
  },
  testDir: 'tests',
  testMatch: /(.+\.)?(test|spec)\.[jt]s/,
  timeout: 30000,
};

export default config;
```

新增 `tests/index.test.ts` 檔。

```ts
import { expect, test } from '@playwright/test';

test('Page should have the correct title', async ({ page }) => {
  await page.goto('/');

  await expect(page).toHaveTitle(/Vite App/);

  expect(await page.locator('h1').textContent()).toBe('Hello Vite!');

  const counter = page.locator('#counter');
  await counter.click({ clickCount: 5 });
  expect(await counter.textContent()).toBe('count is 5');
});
```

修改 `package.json` 檔。

```json
{
  // ...
  "scripts": {
    // ...
    "preview": "vite preview",
    "test": "npm run test:integration",
    "test:integration": "playwright test"
  }
  // ...
}
```

執行測試。

```bash
npm run test
```

執行測試，並使用 UI 模式。

```bash
npx playwright test --ui
```

## 測試產生器

Playwright 提供了一個非常強大的 `codegen` 功能，可以自動生成測試腳本。

測試產生器提供以下功能：

- 紀錄（Record）：產生器可以自動為每個測試步驟生成對應的測試程式碼。
- 選擇定位器（Pick locator）：當測試需要與頁面上的特定元素進行交互時，需要選擇合適的定位器（locator）。產生器可以幫助選擇元素的最佳定位器。
- 斷言可見性（Assert visibility）：用來確認元素在頁面上是否可見。
- 斷言文本（Assert text）：用來驗證元素內部的文本內容是否符合預期。
- 斷言值（Assert value）：用於驗證輸入框的 `value` 屬性。

### 實作

啟動本地伺服器。

```bash
npm run dev
```

啟動測試產生器。

```bash
npx playwright codegen http://localhost:5173
```

開始紀錄測試步驟，並產生測試程式碼。

```ts
import { test, expect } from '@playwright/test';

test('test', async ({ page }) => {
  await page.goto('http://localhost:5173/');
  await expect(page.getByRole('heading', { name: 'Hello Vite!' })).toBeVisible();
  await page.getByRole('button', { name: 'count is' }).click({
    clickCount: 5
  });
  await expect(page.locator('#counter')).toContainText('count is 5');
});
```

## 測試報告

執行測試，並產生 HTML 測試報告。

```bash
npx playwright test --reporter=html
```

顯示 HTML 測試報告。

```bash
npx playwright show-report
```

## 程式碼

- [playwright-example](https://github.com/memochou1993/playwright-example)

## 參考資料

- [Playwright](https://playwright.dev/)
