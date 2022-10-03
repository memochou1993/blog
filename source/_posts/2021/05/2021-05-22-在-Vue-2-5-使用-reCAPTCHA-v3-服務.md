---
title: 在 Vue 2.5 使用 reCAPTCHA v3 服務
date: 2021-05-22 22:20:10
tags: ["程式設計", "JavaScript", "Vue", "reCAPTCHA"]
categories: ["程式設計", "JavaScript", "Vue"]
---

## 前置作業

首先，到 [Google reCAPTCHA v3 Admin Console](https://www.google.com/recaptcha/admin/create) 註冊一個新網站，並取得「網站金鑰」和「密鑰」，前者使用於前端，後者使用於後端。

## 做法

### 前端

在 Vue 專案新增 `vue-recaptcha-v3` 套件。

```BASH
yarn add vue-recaptcha-v3@^1.9.0
```

在 `.env` 檔新增一個環境變數：

```ENV
VUE_APP_RECAPTCHA_SITE_KEY=XXXXXXXXXX
```

在 `plugins` 新增一個 `recaptcha.js` 檔：

```JS
import Vue from 'vue';
import { VueReCaptcha } from 'vue-recaptcha-v3';

Vue.use(VueReCaptcha, {
  siteKey: process.env.VUE_APP_RECAPTCHA_SITE_KEY,
});
```

將 `recaptcha.js` 檔匯入至 `main.js` 檔。

```JS
import './plugins/recaptcha';
```

在登入頁面使用，將套件產生的 token 帶至後端。

```JS
new Vue({
  // ...
  methods: {
    async getRecaptchaToken() {
      await this.$recaptchaLoaded();
      const token = await this.$recaptcha('login');
      return token;
    },
    async verify() {
      axios({
        method: 'POST',
        url: '/auth/verify',
        data: {
          token: await this.getRecaptchaToken(),
        },
      })
        .then(() => {
            // ...
        });
    },
  },
  // ...
});
```

### 後端

以 Laravel 為例，在 `.env` 檔新增以下參數：

```ENV
RECAPTCHA_API_URL=https://www.google.com/recaptcha/api/siteverify
RECAPTCHA_SECRET_KEY=XXXXXXXXXX
```

向 Google 發出 POST 請求，以進行驗證：

```PHP
$client = new \GuzzleHttp\Client();

$response = $client->post(env('RECAPTCHA_API_URL'), [
    'headers' => [
        'Accept' => 'application/json',
    ],
    'form_params' => [
        'secret' => env('RECAPTCHA_SECRET_KEY'),
        'response' => $this->request->token,
    ],
]);

return $response->getBody();
```

## 參考資料

- [reCAPTCHA - Guides](https://developers.google.com/recaptcha/intro)
