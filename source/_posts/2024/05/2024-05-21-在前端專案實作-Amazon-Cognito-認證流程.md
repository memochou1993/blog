---
title: 在前端專案實作 Amazon Cognito 認證流程
date: 2024-05-21 17:20:31
tags: ["Deployment", "AWS", "Cognito", "OAuth", "JavaScript"]
categories: ["Cloud Computing Service", "AWS"]
---

## 前置作業

先在 AWS Cognito 上設置好一個使用者池。

需要設置：

- 允許的回呼 URL：<http://localhost:5173/auth/callback>
- 允許的登出 URL：<http://localhost:5173/sign-in>

需要取得：

- Cognito Domain
- Client ID

## 建立專案

建立專案。

```bash
npm create vite

✔ Project name: … aws-cognito-auth-example
✔ Select a framework: › Vanilla
✔ Select a variant: › JavaScript
```

## 建立工具函式

建立 `utils/generateNonce.js` 檔。

```js
import toSha256 from './toSha256';

const generateNonce = async () => {
  const hash = await toSha256(crypto.getRandomValues(new Uint32Array(4)).toString());
  const hashArray = Array.from(new Uint8Array(hash));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
};

export default generateNonce;
```

建立 `utils/toSha256.js` 檔。

```js
const toSha256 = async (str) => {
  return await crypto.subtle.digest('SHA-256', new TextEncoder().encode(str));
};

export default toSha256;
```

建立 `utils/toBase64Url.js` 檔。

```js
const toBase64Url = (string) => {
  return btoa(String.fromCharCode.apply(null, new Uint8Array(string)))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');
};

export default toBase64Url;
```

建立 `utils/cognito.js` 檔。

```js
const redirectToSignIn = ({
  awsCognitoApiUrl,
  clientId: client_id,
  state,
  codeChallenge: code_challenge,
}) => {
  const params = new URLSearchParams({
    response_type: 'code',
    client_id,
    redirect_uri: `${window.location.origin}/auth/callback`,
    state,
    code_challenge_method: 'S256',
    code_challenge,
  });
  window.location.href = `${awsCognitoApiUrl}/login?${params.toString()}`;
};

const redirectToSignOut = ({
  awsCognitoApiUrl,
  clientId: client_id,
}) => {
  const params = new URLSearchParams({
    client_id,
    logout_uri: `${window.location.origin}/sign-in`,
  });
  window.location.href = `${awsCognitoApiUrl}/logout?${params.toString()}`;
};

const createToken = ({
  awsCognitoApiUrl,
  clientId: client_id,
  redirectUri: redirect_uri,
  code,
  codeVerifier: code_verifier,
}) => {
  return fetch(`${awsCognitoApiUrl}/oauth2/token`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      grant_type: 'authorization_code',
      client_id,
      redirect_uri,
      code,
      code_verifier,
    }).toString(),
  });
};

export {
  redirectToSignIn,
  redirectToSignOut,
  createToken,
};
```

建立 `utils/index.js` 檔。

```js
import * as cognito from './cognito';
import generateNonce from './generateNonce';
import toBase64Url from './toBase64Url';
import toSha256 from './toSha256';

export { cognito, generateNonce, toBase64Url, toSha256 };
```

## 實作流程

修改 `main.js` 檔。

```js
// 引入必要的 CSS 和工具函式
import './style.css';
import { cognito, generateNonce, toBase64Url, toSha256 } from './utils';

// AWS Cognito API 的 URL 和客戶端 ID
const awsCognitoApiUrl = 'your-cognito-api-url';
const awsCognitoClientId = 'your-cognito-client-id';

// 設置網頁上的按鈕元素
document.querySelector('#app').innerHTML = `
  <button type="button" id="sign-in">Sign In</button>
  <button type="button" id="sign-out">Sign Out</button>
`;

// 處理登入邏輯的函式
const handleSignIn = async () => {
  const nonce = await generateNonce(); // 生成 nonce
  const codeVerifier = await generateNonce(); // 生成 code verifier

  // 將 nonce 和 code verifier 存儲在 sessionStorage 中
  sessionStorage.setItem('state', nonce);
  sessionStorage.setItem('code_verifier', codeVerifier);

  // 重定向到 Cognito 登入頁面
  cognito.redirectToSignIn({
    awsCognitoApiUrl,
    clientId: awsCognitoClientId,
    state: nonce,
    codeChallenge: toBase64Url(await toSha256(codeVerifier)), // 生成 code challenge
  });
};

// 處理登出邏輯的函式
const handleSignOut = () => {
  cognito.redirectToSignOut({
    awsCognitoApiUrl,
    clientId: awsCognitoClientId,
  });
};

// 處理 Cognito 回調邏輯的函式
const handleCallback = async () => {
  const searchParams = new URLSearchParams(window.location.search);
  const state = searchParams.get('state'); // 從 URL 參數中獲取 state
  const code = searchParams.get('code'); // 從 URL 參數中獲取授權碼 code

  const localState = sessionStorage.getItem('state'); // 從 sessionStorage 中獲取之前保存的 state
  const localCodeVerifier = sessionStorage.getItem('code_verifier'); // 從 sessionStorage 中獲取之前保存的 code verifier

  // 清除 sessionStorage 中的狀態和驗證碼
  sessionStorage.removeItem('state');
  sessionStorage.removeItem('code_verifier');

  // 檢查 state 和 code 的有效性
  if (!state || !code || !localState || !localCodeVerifier || (state !== localState)) {
    throw new Error('Invalid state or code'); // 如果不匹配則拋出錯誤
  }

  // 請求 token
  const res = await cognito.createToken({
    awsCognitoApiUrl,
    clientId: awsCognitoClientId,
    redirectUri: `${window.location.origin}/auth/callback`,
    code,
    codeVerifier: localCodeVerifier,
  });

  const { access_token } = await res.json(); // 從響應中獲取 access token

  console.log(access_token); // 在控制台中輸出 access token
};

// 為按鈕設置事件監聽器
document.getElementById('sign-in').addEventListener('click', handleSignIn);
document.getElementById('sign-out').addEventListener('click', handleSignOut);

// 如果當前路徑是回調路徑，則處理回調
if (window.location.pathname === '/auth/callback') {
  handleCallback();
}
```

啟動專案。

```bash
npm run dev
```

前往 <http://localhost:5173> 瀏覽。

## 程式碼

- [aws-cognito-auth-example](https://github.com/memochou1993/aws-cognito-auth-example)

## 參考資料

- [Amazon Cognito](https://docs.aws.amazon.com/cognito/latest/developerguide)
- [How to secure the Cognito login flow with a state nonce and PKCE](https://advancedweb.hu/how-to-secure-the-cognito-login-flow-with-a-state-nonce-and-pkce/)
