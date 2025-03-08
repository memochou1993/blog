---
title: 在 Nuxt 3.13 使用 Supabase 實作 Google 登入
date: 2025-03-01 14:07:48
tags: ["Programming", "JavaScript", "Nuxt", "Supabase", "OAuth", "Google OAuth"]
categories: ["Programming", "JavaScript", "Nuxt"]
---

## 前置作業

### 設定 Google Cloud

- 首先在 [Google Cloud](https://console.cloud.google.com/projectcreate) 頁面，建立一個專案。
- 設定 OAuth 同意畫面
- 建立 OAuth 用戶端
  - 應用程式類型：網頁應用程式
  - 已授權的 JavaScript 來源
    - <http://localhost>
    - <http://localhost:3000>
  - 已授權的重新導向 URI：
    - <http://localhost:3000/auth/callback>

### 設定 Supabase

進到「Authentication」的「Sign In / Up」，開啟「Enable Sign in with Google」選項。填入 Google OAuth 的「Client ID」。

## 客製化登入按鈕

前往 Google Identity 的 [HTML Code Generator](https://developers.google.com/identity/gsi/web/tools/configurator) 客製化登入按鈕：

- 設定
  - Google 用戶端 ID：your-client-id
  - 回呼函式：`handleSignInWithGoogle`
- 選取登入方式
  - 啟用 OneTap
    - 盡可能自動選取憑證
    - 如果使用者點選/輕觸畫面外部，則取消提示
    - 啟用 在 ITP 瀏覽器中升級 One Tap 使用者體驗
  - 啟用「使用 Google 帳戶登入」按鈕
    - 語言：預設
    - 行為：在彈出式視窗中
  - 選擇適合網站的按鈕樣式
    - 新增額外寬度：200

按下「取得程式碼」按鈕，取得生成的程式碼如下：

```html
<div id="g_id_onload"
     data-client_id="your-client-id"
     data-context="signin"
     data-ux_mode="popup"
     data-callback="handleSignInWithGoogle"
     data-nonce=""
     data-auto_select="true"
     data-itp_support="true">
</div>

<div class="g_id_signin"
     data-type="standard"
     data-shape="rectangular"
     data-theme="outline"
     data-text="signin_with"
     data-size="large"
     data-logo_alignment="left"
     data-width="200">
</div>
```

## 認識登入方式

### Google One Tap 自動登入

`<div id="g_id_onload"></div>` 元素是用來自動載入 Google One Tap 登入機制，適合希望用戶快速登入的應用場景。

各屬性說明如下：

| 屬性名稱          | 說明 |
|------------------|------|
| `data-client_id` | Google OAuth 2.0 用戶端 ID |
| `data-context`   | 指定登入的情境，例如 `signin`（登入）或 `signup`（註冊） |
| `data-ux_mode`   | 指定 UX 模式，`popup` 會開啟彈出視窗，`redirect` 會重新導向頁面 |
| `data-callback`  | 指定登入成功後的回呼函式名稱 |
| `data-nonce`     | 用於防止重播攻擊的唯一值（可選） |
| `data-auto_select` | 設為 `true` 時，Google 會嘗試自動選擇帳戶登入 |
| `data-itp_support` | 設為 `true` 時，啟用 Intelligent Tracking Prevention (ITP) 支援，以改善 Safari 上的登入體驗 |

### Google Sign-In 標準登入

`<div class="g_id_signin"></div>` 元素是用來渲染標準的 Google 登入按鈕，用戶需要手動點擊按鈕後，才會跳出 Google 登入畫面。

各屬性說明如下：

| 屬性名稱           | 說明 |
|-------------------|------|
| `data-type`       | 指定按鈕類型，`standard` 為標準按鈕，`icon` 則為僅顯示圖示。 |
| `data-shape`      | 按鈕形狀，`rectangular`（矩形）或 `pill`（圓角）。 |
| `data-theme`      | 按鈕主題，`outline`（外框）或 `filled_blue`（填滿藍色）。 |
| `data-text`       | 按鈕文字，例如 `signin_with`（使用 Google 登入）。 |
| `data-size`       | 按鈕大小，可為 `small`、`medium`、`large`。 |
| `data-logo_alignment` | Google 標誌對齊方式，`left`（靠左）或 `center`（置中）。 |
| `data-width`      | 指定按鈕寬度（單位：像素）。 |

## 實作

安裝依賴套件。

```bash
npm install @supabase/supabase-js
```

修改 `.env` 檔，添加環境變數。

```env
NUXT_PUBLIC_GOOGLE_CLIENT_ID=your_google_client_id
NUXT_PUBLIC_SUPABASE_URL=your_supabase_url
NUXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

修改 `nuxt.config.ts` 檔，加上環境變數。

```ts
export default defineNuxtConfig({
  // ...
  runtimeConfig: {
    public: {
      museApiUrl: process.env.NUXT_PUBLIC_MUSE_API_URL,
      googleClientId: process.env.NUXT_PUBLIC_GOOGLE_CLIENT_ID,
      supabaseUrl: process.env.NUXT_PUBLIC_SUPABASE_URL,
      supabaseAnonKey: process.env.NUXT_PUBLIC_SUPABASE_ANON_KEY,
    },
  },
  // ...
});
```

建立 `utils/authUtils.js` 檔。

```js
class authUtils {
  static async generateNonce() {
    const nonce = btoa(String.fromCharCode(...crypto.getRandomValues(new Uint8Array(32))));
    const encoder = new TextEncoder();
    const encodedNonce = encoder.encode(nonce);
    const hashBuffer = await crypto.subtle.digest('SHA-256', encodedNonce);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const hashedNonce = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
    return {
      nonce,
      hashedNonce,
    };
  }
}

export default authUtils;
```

建立 `composables/useSupabase.js` 檔。

```js
import { createClient } from '@supabase/supabase-js';

export function useSupabase() {
  useHead({ script: [{ src: 'https://accounts.google.com/gsi/client', async: true }] });

  const { supabaseUrl, supabaseAnonKey } = useRuntimeConfig().public;

  const client = createClient(supabaseUrl, supabaseAnonKey);

  const { generateNonce } = authUtils;

  const signInWithGoogle = nonce => (response) => {
    return client.auth.signInWithIdToken({
      provider: 'google',
      token: response.credential,
      nonce,
    });
  };

  return {
    client,
    generateNonce,
    signInWithGoogle,
  };
}
```

建立 `components/AuthGoogleSignInButton.vue` 檔。

```html
<script setup>
const props = defineProps({
  width: {
    type: Number,
    default: undefined,
  },
});

const { generateNonce, signInWithGoogle } = useSupabase();
const authStore = useAuthStore();
const display = useDisplay();
const snackbarStore = useSnackbarStore();

const { googleClientId } = useRuntimeConfig().public;

const { nonce, hashedNonce } = await generateNonce();

const loading = defineModel('loading', {
  type: Boolean,
  default: false,
});

window.handleSignInWithGoogle = async (response) => {
  loading.value = true;
  try {
    const { data, error } = await signInWithGoogle(nonce)(response);
    if (error) {
      snackbarStore.setError('登入失敗！');
      return;
    }
    const { session } = data;
    authStore.setAccessToken(session.access_token);
    authStore.setRefreshToken(session.refresh_token);
    snackbarStore.setSuccess('登入成功！');
    await navigateTo({ name: 'index' });
  } finally {
    loading.value = false;
  }
};
</script>

<template>
  <v-sheet
    color="transparent"
    :min-height="44"
    class="d-flex align-center"
  >
    <div
      id="g_id_onload"
      :data-client_id="googleClientId"
      :data-nonce="hashedNonce"
      data-context="signin"
      data-ux_mode="popup"
      data-callback="handleSignInWithGoogle"
      data-auto_select="true"
      data-itp_support="true"
      data-use_fedcm_for_prompt="true"
    />
    <div
      class="g_id_signin"
      data-type="standard"
      data-shape="rectangular"
      data-theme="outline"
      data-text="signin_with"
      data-size="large"
      data-logo_alignment="left"
      :data-width="display.xs.value ? undefined : props.width"
    />
  </v-sheet>
</template>
```

修改 `pages/sign-in.vue` 檔，將元件引入並使用。

```html
<template>
  <AuthGoogleSignInButton />
</template>
```

## 參考資料

- [Supabase - Login with Google](https://supabase.com/docs/guides/auth/social-login/auth-google)
