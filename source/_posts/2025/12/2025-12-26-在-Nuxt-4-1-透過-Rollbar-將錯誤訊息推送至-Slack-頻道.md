---
title: 在 Nuxt 4.1 透過 Rollbar 將錯誤訊息推送至 Slack 頻道
date: 2025-12-26 09:56:37
tags:
categories:
---

## 前置作業

1. 註冊 Rollbar 後，新增一個專案。
2. 在專案頁面，點選「Add to Slack」按鈕，取得管理員授權。
3. 將 Rollbar 機器人加進要推送訊息的 Slack 頻道中。
4. 點選「Settings」頁籤，再點選「Notifications」頁籤，啟用 Slack 整合。
5. 點選「Projects」頁籤，進到新增的專案頁面，點選「Notifications」頁籤，新增 Slack 整合，並設定要推送訊息的 Slack 頻道。
6. 設定推送條件。

## 實作

在 Nuxt 專案中，安裝依賴套件。

```bash
npm install --save rollbar
```

修改 `.env` 檔。

```env
ROLLBAR_ACCESS_TOKEN=your-access-token
```

修改 `nuxt.config.js` 檔。

```js
export default defineNuxtConfig({
  // ...
  runtimeConfig: {
    public: {
      // ...
      rollbarAccessToken: process.env.ROLLBAR_ACCESS_TOKEN,
    },
  },
});
```

建立 `app/plugins/rollbar.js` 檔，將全域錯誤推送至 Rollbar。

```js
import Rollbar from 'rollbar';

export default defineNuxtPlugin((nuxtApp) => {
  const { awsAccountEnv, rollbarAccessToken } = useRuntimeConfig().public;

  const rollbar = new Rollbar({
    accessToken: rollbarAccessToken,
    captureUncaught: true, // 未被捕獲的同步錯誤
    captureUnhandledRejections: true, // 未被捕獲的非同步錯誤
    payload: {
      environment: 'dev', // 環境
      client: {
        javascript: {
          code_version: '1.0.0',
        },
      },
    },
  });

  nuxtApp.vueApp.config.errorHandler = (error, instance, info) => {
    rollbar.error(error, {
      vueComponent: instance?.$options?.name,
      info,
    });

    if (import.meta.dev) {
      console.error(error);
    }
  };

  nuxtApp.provide('rollbar', rollbar);
});
```

手動推送錯誤。

```js
const { $rollbar } = useNuxtApp();

$rollbar.error(error);
```

## 參考資料

- [Rollbar](https://docs.rollbar.com/docs/)
