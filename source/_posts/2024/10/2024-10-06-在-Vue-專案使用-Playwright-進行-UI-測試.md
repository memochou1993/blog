---
title: 在 Vue 專案使用 Playwright 進行 UI 測試
date: 2024-10-06 22:20:15
tags: ["Programming", "JavaScript", "Vue", "Testing", "Playwright"]
categories: ["Programming", "JavaScript", "Vue"]
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

```
npx playwright install
```

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

## 程式碼

- [playwright-example](https://github.com/memochou1993/playwright-example)

## 參考資料

- [Playwright](https://playwright.dev/)
