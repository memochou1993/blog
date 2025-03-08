---
title: 在 Nuxt 3.13 使用 Google Tag Manager 代碼管理工具
date: 2025-03-08 17:26:17
tags: ["Programming", "JavaScript", "Vue", "Nuxt", "Google Tag Manager"]
categories: ["Programming", "JavaScript", "Nuxt"]
---

## 做法

安裝 Nuxt Scripts 模組。

```bash
npx nuxi@latest module add scripts
```

修改 `.env` 檔。

```env
NUXT_PUBLIC_GOOGLE_TAG_MANAGER_ID=your-id
```

修改 `nuxt.config.ts` 檔。

```js
export default defineNuxtConfig({
  scripts: {
    registry: {
      googleTagManager: {
        id: process.env.NUXT_PUBLIC_GOOGLE_TAG_MANAGER_ID as string,
      },
    },
  },
});
```

使用 `useScriptGoogleTagManager` 方法。

```js
const { proxy: gtm } = useScriptGoogleTagManager();

gtm.dataLayer.push({ event: 'conversion', value: 1 });
```

## 助手函式

如果不想要每次都執行 `useScriptGoogleTagManager` 方法，可以封裝成 `gtmUtils` 助手函式。

### 實作

新增 `utils/gtmUtils.js` 檔。

```js
import { GtmConstant } from '~/constants';

class gtmUtils {
  static globalParams = {};

  static setGlobalParam(key, value) {
    this.globalParams[key] = value;
  }

  static pushEvent(name, data = {}) {
    window.dataLayer = window.dataLayer || [];
    window.dataLayer.push({
      event: name,
      ...Object.fromEntries(Object.entries(this.globalParams).filter(([, v]) => v !== undefined)),
      ...data,
    });
  }

  static pushEventIf(condition, name, data) {
    if (!condition) return;
    this.pushEvent(name, data);
  }
}

export default gtmUtils;
```

使用方式如下：

```js
gtmUtils.pushEvent('sign_in_with_google', { status: 'pending' })
```

### 全域參數

可以新增一個全域的 `gtm.global.js` 中介層，當有 `userId` 時，就設置全域參數。

```js
export default defineNuxtRouteMiddleware(() => {
  const authStore = useAuthStore();

  // 設置全域參數
  gtmUtils.setGlobalParam('userId', authStore.userId);

  return;
});
```

## 參數合併問題

使用單頁式應用程式（SPA）時，可能會遇到事件都是獨立的，但是事件參數卻被合併在一起的問題。這是因為 Data Layer Variable V2 的行為是將參數內容都進行合併。

```bash
# push event
{ "event": "event_1", "foo": true }
# actual
{ "event": "event_1", "foo": true }
# push event
{ "event": "event_2", "bar": true }
# actual
{ "event": "event_2", "foo": true, "bar": true }
```

可以將所有事件都顯式列舉在常數檔案中，在推送事件的時候透過 GTM 腳本中內建的 Getter 和 Setter 方法，將遺留的資料移除。

### 實作

新增  `constants/GtmConstant.js` 檔。

```js
const Event = Object.freeze({
  SIGN_IN_WITH_EMAIL: 'sign_in_with_email',
  SIGN_IN_WITH_GOOGLE: 'sign_in_with_google',
});

const Key = Object.freeze({
  ERROR: 'error',
  STATUS: 'status',
  USER_ID: 'userId',
});

const Status = Object.freeze({
  ERROR: 'error',
  PENDING: 'pending',
  SUCCESS: 'success',
});

export {
  Event,
  Key,
  Status,
};
```

修改 `utils/gtmUtils.js` 檔。

```js
import { GtmConstant } from '~/constants';

class gtmUtils {
  static globalParams = {};

  static setGlobalParam(key, value) {
    this.globalParams[key] = value;
  }

  static pushEvent(name, data = {}) {
    window.dataLayer = window.dataLayer || [];

    // Clear previous values to prevent the default recursive object merging behavior of data layer variable v2.
    window.dataLayer.push(function () {
      Object.values(GtmConstant.Key).forEach((key) => {
        if (this.get(key) !== undefined) {
          this.set(key, undefined);
        }
      });
    });

    window.dataLayer.push({
      event: name,
      ...Object.fromEntries(Object.entries(this.globalParams).filter(([, v]) => v !== undefined)),
      ...data,
    });
  }

  static pushEventIf(condition, name, data) {
    if (!condition) return;
    this.pushEvent(name, data);
  }
}

export default gtmUtils;
```

使用方式如下：

```js
import { GtmConstant } from '~/constants';

gtmUtils.pushEvent(GtmConstant.Event.SIGN_IN_WITH_GOOGLE, { [GtmConstant.Key.STATUS]: GtmConstant.Status.PENDING });
```

## 參考資料

[Nuxt Scripts](https://scripts.nuxt.com/scripts/tracking/google-tag-manager)
