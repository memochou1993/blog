---
title: 在 SvelteKit 專案使用 Google Tag Manager 代碼管理工具
date: 2024-06-02 16:51:16
tags: ["Programming", "JavaScript", "Svelte", "SvelteKit", "Google Tag Manager"]
categories: ["Programming", "JavaScript", "Svelte"]
---

## 做法

首先，到 GTM 建立一個專案容器，將 GTM 腳本複製，並添加到專案的 `<head></head>` 標籤中。

## 設定

### 變數

先建立一個「資料層變數」變數，表示這個變數將從資料層（`dataLayer`）中擷取資料。指定資料層中的鍵名為`value`。這表示 GTM 將從資料層中取出名為 `value` 的值。

- 變數名稱：資料層變數
- 變數類型：資料層變數
- 資料層變數名稱：`value`
- 資料層版本：版本二

再建立一個「Google 代碼：事件設定」變數，表示這個變數用於設定 Google Analytics 事件的參數。事件參數指定為 `value`，表示事件參數的名稱。值設定為 `{{資料層變數}}`，表示上面定義的資料層變數，事件參數 `value` 的值將取自資料層變數。

- 變數名稱：事件設定
- 變數類型：Google 代碼：事件設定
- 事件參數：`value`
- 值：`{{資料層變數}}`

### 觸發條件

建立一個「自訂事件」觸發條件。觸發條件會捕捉自訂的事件名稱，當資料層中推送一個事件名為 `toggle_theme` 的事件時，這個觸發條件將會被觸發。

- 觸發條件名稱：toggle_theme
- 觸發條件類型：自訂事件
- 事件名稱：`toggle_theme`
- 這項觸發條件的啟動時機：所有的自訂事件

### 代碼

建立一個「Google Analytics：GA4 事件」代碼：

- 代碼類型：Google Analytics：GA4 事件
- 評估 ID：Google Analytics：GA4 評估 ID
- 事件名稱：`{{Event}}`
- 事件參數：`{{事件設定}}`
- 觸發條件：`toggle_theme`

## 程式

建立 `src/lib/gtm/GTM.ts` 檔。

```ts
class GTM {
  public static pushEvent(event: string, data: Record<string, unknown> = { value: null }): void {
    // @ts-expect-error: dataLayer is a global variable
    window.dataLayer.push({
      event,
      ...data,
    });
  }
}

export default GTM;
```

使用：

```ts
import { GTM } from '$lib/gtm';

GTM.pushEvent('toggle_theme', { value: theme });
```
