---
title: 在 SvelteKit 專案使用 Playwright 進行 UI 測試
date: 2024-05-23 01:22:56
tags: ["Programming", "JavaScript", "Svelte", "SvelteKit", "Testing", "Playwright"]
categories: ["Programming", "JavaScript", "Svelte"]
---

## 安裝

安裝依賴套件。

```bash
npm install -D @playwright/test@latest
```

下載瀏覽器執行檔和相依套件。

```
npx playwright install
```

修改 `tests/test.ts` 檔。

```js
import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('https://playwright.dev/');

  // 預期標題
  await expect(page).toHaveTitle(/Playwright/);
});

test('get started link', async ({ page }) => {
  await page.goto('https://playwright.dev/');

  // 點擊連結
  await page.getByRole('link', { name: 'Get started' }).click();

  // 預期標題
  await expect(page.getByRole('heading', { name: 'Installation' })).toBeVisible();
});
```

執行測試。

```bash
npm run test
```

## 導航

大多數的測試，會先導航到指定 URL，然後就能開始與頁面元素進行互動。

```js
await page.goto('https://playwright.dev/');
```

## 互動

執行操作通常會從定位元素開始。Playwright 的定位器（Locators）代表一種在任何時候找到頁面上元素的方式。Playwright 會等待元素可操作後才執行操作。

```js
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

## 斷言

Playwright 有像是 `expect` 函數形式的測試斷言，以及許多通用匹配器，如 `toEqual`、`toContain`、`toBeTruthy`，可以用來斷言任何條件。

```js
expect(success).toBeTruthy();
```

Playwright 還包含非同步匹配器，它會等待直到滿足預期條件。例如，以下代碼會等待頁面獲取包含 `Playwright` 的標題。

```js
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

## 測試隔離

Playwright 測試基於測試夾具（test fixtures）的概念，例如內建的 page fixture，它會被傳遞到測試中。由於瀏覽器上下文的存在，測試之間的頁面是隔離的，這等同於一個全新的瀏覽器設定檔案，每個測試都會獲得一個全新的環境，即使在單個瀏覽器中運行多個測試時也是如此。

```js
import { test } from '@playwright/test';

test('example test', async ({ page }) => {
  // 此 "page" 屬於一個為此特定測試所建立的隔離的瀏覽器上下文
});

test('another test', async ({ page }) => {
  // 此 "page" 是另一個與前一個不一樣且完全隔離的瀏覽器上下文
});
```

## 測試鉤子

還可以使用各種測試鉤子（test hooks），例如使用 `test.describe` 來宣告一組測試，以及 `test.beforeEach` 和 `test.afterEach`，可以在每個測試之前或之後執行。或者像是 `test.beforeAll` 和 `test.afterAll`，可以在每個工作程序之前或之後執行所有測試。

```js
import { test, expect } from '@playwright/test';

test.describe('navigation', () => {
  test.beforeEach(async ({ page }) => {
    // 在每個測試之前轉到起始 URL
    await page.goto('https://playwright.dev/');
  });

  test('main navigation', async ({ page }) => {
    // 斷言使用 expect API
    await expect(page).toHaveURL('https://playwright.dev/');
  });
});
```

如此一來，就可以在每個測試之前導航到特定的 URL，以確保每個測試都在一個已知的起始狀態下運行。

## 參考資料

- [Playwright](https://playwright.dev/)
