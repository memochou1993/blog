---
title: 在 Nuxt 4.1 透過 Rollbar 將錯誤訊息推送至 Slack 頻道
date: 2025-12-26 09:56:37
tags: ["Programming", "JavaScript", "Nuxt", "Vue", "Rollbar"]
categories: ["Programming", "JavaScript", "Nuxt"]
---

## 前置作業

1. 註冊 Rollbar 後，新增一個專案。
2. 在專案頁面，點選「Add to Slack」按鈕，取得管理員授權。
3. 將 Rollbar 機器人加進要推送訊息的 Slack 頻道中。
4. 點選「Settings」頁籤，再點選「Notifications」頁籤，啟用 Slack 整合。
5. 點選「Projects」頁籤，進到新增的專案頁面，點選「Notifications」頁籤，新增 Slack 整合，並設定要推送訊息的 Slack 頻道。
6. 設定推送條件。
7. 新增一個專案使用的 access token。

## 實作

在 Nuxt 專案中，安裝依賴套件。

```bash
npm install --save rollbar
```

修改 `.env` 檔。

```env
ROLLBAR_URL_PREFIX=
ROLLBAR_CLIENT_TOKEN=your-client-token
ROLLBAR_SERVER_TOKEN=your-server-token
```

修改 `nuxt.config.js` 檔。

```js
export default defineNuxtConfig({
  // ...
  runtimeConfig: {
    public: {
      // ...
      rollbarClientToken: process.env.ROLLBAR_CLIENT_TOKEN,
    },
  },
});
```

建立 `app/plugins/rollbar.js` 檔，將全域錯誤推送至 Rollbar。

```js
import Rollbar from 'rollbar';

export default defineNuxtPlugin((nuxtApp) => {
  const { awsAccountEnv, rollbarClientToken } = useRuntimeConfig().public;

  const rollbar = new Rollbar({
    accessToken: rollbarClientToken,
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

## 上傳 Source Maps

修改 `nuxt.config.ts` 檔。將 `sourcemap` 欄位設成 `hidden`，代表產生 source maps，但不在最終輸出的編譯檔中加入任何參考連結。

```js
export default defineNuxtConfig({
  // ...
  sourcemap: {
    client: 'hidden',
    server: 'hidden',
  },
  // ...
});
```

修改 `rollbar.js` 檔。將 `source_map_enabled` 設為 `true`，並加上從環境變數帶入的應用程式版本。

```js
import Rollbar from 'rollbar';

export default defineNuxtPlugin((nuxtApp) => {
  const { appVersion, awsAccountEnv, rollbarClientToken } = useRuntimeConfig().public;

  const rollbar = new Rollbar({
    accessToken: rollbarClientToken,
    captureUncaught: true,
    captureUnhandledRejections: true,
    payload: {
      environment: awsAccountEnv,
      client: {
        javascript: {
          source_map_enabled: true,
          code_version: appVersion,
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

修改 `.gitlab-ci.yml` 檔。

```yml
.build-template: &build-template
  stage: build
  image: node:22-alpine
  variables:
    GIT_DEPTH: 0
  before_script:
    - apk add --no-cache git
    # 打包時，將 git 版本帶入環境變數
    - export APP_VERSION=$(git describe --tags --abbrev=0 2>/dev/null)
    - cp $ENV .env
    - npm ci
  # ...

# ...

.upload-sourcemaps-template: &upload-sourcemaps-template
  stage: deploy
  image: node:22-alpine
  variables:
    GIT_DEPTH: 0
  before_script:
    - apk add --no-cache git curl
    - cp "$ENV" .env
    - sed -i 's/\r$//' .env
    - set -a; . ./.env; set +a
  script:
    - export APP_VERSION=$(git describe --tags --abbrev=0 2>/dev/null)
    - cd .output/public/_nuxt/
    - |
      for mapfile in *.js.map; do
        curl https://api.rollbar.com/api/1/sourcemap \
          -F access_token=$ROLLBAR_SERVER_TOKEN \
          -F version=$APP_VERSION \
          -F minified_url="${ROLLBAR_URL_PREFIX}${mapfile%.map}" \
          -F source_map=@"$mapfile" \
          --silent --show-error --fail
      done

upload-sourcemaps-dev:
  <<: *upload-sourcemaps-template
  variables:
    ENV: $ENV_DEV
  needs:
    - job: build-dev
      artifacts: true
  rules:
    - if: '$CI_COMMIT_REF_NAME =~ /^(\d+\.)+(\d+\.)+(\d+)$/'
```

在 GitLab 新增環境變數。

```env
ROLLBAR_URL_PREFIX=//your-domain.com/_nuxt/
ROLLBAR_CLIENT_TOKEN=your-client-token
ROLLBAR_SERVER_TOKEN=your-server-token
```

將程式碼推送到儲存庫。

## 參考資料

- [Rollbar](https://docs.rollbar.com/docs/)
