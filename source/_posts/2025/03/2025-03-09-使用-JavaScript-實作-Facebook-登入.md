---
title: 使用 JavaScript 實作 Facebook 登入
date: 2025-03-08 21:51:22
tags: ["Programming", "JavaScript", "OAuth", "Facebook OAuth"]
categories: ["Programming", "JavaScript", "Others"]
---

## 前置作業

首先，前往 [Meta 開發者平台](https://developers.facebook.com/apps)，建立一個應用程式。例如：

- 應用程式名稱：`post-bot-auth`
- 新增使用案例：「使用 Facebook 登入，驗證用戶並索取資料」
- 商家：「我還不想連結商家資產管理組合」

完成後，點選「建立應用程式」按鈕。

## 建立專案

建立專案。

```bash
mkdir facebook-auth-example
cd facebook-auth-example
```

初始化專案。

```bash
npm init
```

安裝依賴套件。

```bash
npm i -D live-server
```

新增 `.gitignore` 檔。

```env
node_modules/
```

修改 `package.json` 檔，添加一個 `dev` 啟動腳本。

```json
{
  "name": "facebook-auth-example",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "dev": "live-server"
  },
  "author": "",
  "license": "ISC",
  "description": "",
  "devDependencies": {
    "live-server": "^1.2.2"
  }
}
```

啟動服務。

```bash
npm run dev
```

使用 `ngrok` 指令，啟動一個 HTTP 代理伺服器。

```bash
ngrok http 8080
```

## 設定

回到 Meta 開發者平台，在「使用案例」頁面，點選「自訂」按鈕。進到「自訂使用案例」頁面，點選「設定」按鈕。

設置以下：

- 有效的 OAuth 重新導向 URI：<https://random.ngrok-free.app>
- JavaScript SDK 允許的網域：<https://random.ngrok-free.app>
- 使用 JavaScript SDK 登入：設為啟用

### 檢查

設置以下，點選「檢查 URI」按鈕。

- 重新導向 URI 驗證程式：<https://random.ngrok-free.app>

如果成功，會顯示「此重新導向 URI 對此應用程式有效」。

### 快速入門

點選「快速入門」頁籤，點選「網站」按鈕，查看如何設定 Facebook JavaScript SDK 到網站。

## 實作

新增 `index.html` 檔。

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Document</title>
  </head>
  <body>
    <div id="info" ></div>
    <button id="login">Login</button>
    <button id="logout" hidden>Logout</button>
    <script>
      window.fbAsyncInit = function () {
        FB.init({
          appId: "9368643076536346",
          cookie: true,
          version: "v22.0",
        });
        FB.AppEvents.logPageView();
      };

      (function (d, s, id) {
        var js,
          fjs = d.getElementsByTagName(s)[0];
        if (d.getElementById(id)) {
          return;
        }
        js = d.createElement(s);
        js.id = id;
        js.src = "https://connect.facebook.net/en_US/sdk.js";
        fjs.parentNode.insertBefore(js, fjs);
      })(document, "script", "facebook-jssdk");

      const loginElement = document.getElementById("login");
      const logoutElement = document.getElementById("logout");
      const infoElement = document.getElementById("info");

      loginElement.addEventListener("click", function () {
        FB.login(
          function (response) {
            if (!response.authResponse) {
              console.log("User cancelled login or did not fully authorize.");
              return;
            }

            FB.api("/me", function (response) {
              infoElement.innerHTML = `Good to see you, ${response.name}.`;
            });

            logoutElement.hidden = false;
            loginElement.hidden = true;
          },
          {
            scope: "public_profile,email",
          }
        );
      });

      logoutElement.addEventListener("click", function () {
        FB.logout(function () {
          infoElement.innerHTML = "Goodbye!";
          loginElement.hidden = false;
          logoutElement.hidden = true;
        });
      });
    </script>
  </body>
</html>
```

前往 <https://random.ngrok-free.app> 瀏覽。

## 程式碼

- [facebook-auth-example](https://github.com/memochou1993/facebook-auth-example)

## 參考資料

- [Meta - Facebook 登入](https://developers.facebook.com/docs/facebook-login/web)
