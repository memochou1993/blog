---
title: 在 Nuxt.js 2.0 使用 AdonisJs 4.0 進行全端開發
permalink: 在-Nuxt-js-2-0-使用-AdonisJs-4-0-進行全端開發
date: 2019-01-23 00:39:13
tags: ["程式寫作", "JavaScript", "Node.js", "AdonisJs", "Nuxt.js"]
categories: ["程式寫作", "JavaScript", "Node.js"]
---

## 前言
123456Nuxt 將 Adonis 進行整合，成為 [Adonuxt](https://github.com/nuxt-community/adonuxt-template)。

## 安裝
```
$ npx create-nuxt-app adonuxt
```
- 選擇 Adonis 作為後端框架。

## 安裝 SQLite
```
$ npm install --save sqlite3
```

## 更新套件
執行遷移時會出現警告：
```
Knex:warning - .returning() is not supported by sqlite3 and will not have any effect.
```
- `lucid` 套件需要更新。

更新套件到最新版本：
```JSON
"dependencies": {
  "@adonisjs/ace": "^5.0.8",
  "@adonisjs/auth": "^3.0.7",
  "@adonisjs/bodyparser": "^2.0.5",
  "@adonisjs/cors": "^1.0.7",
  "@adonisjs/fold": "^4.0.9",
  "@adonisjs/framework": "^5.0.9",
  "@adonisjs/ignitor": "^2.0.8",
  "@adonisjs/lucid": "^6.1.3",
  "@adonisjs/session": "^1.0.27",
  "@adonisjs/shield": "^1.0.8"
  ...
}
```

## 新增路由
```JS
'use strict';

/*
|--------------------------------------------------------------------------
| Routes
|--------------------------------------------------------------------------
|
| Http routes are entry points to your web application. You can create
| routes for different URL's and bind Controller actions to them.
|
| A complete guide on routing is available here.
| http://adonisjs.com/guides/routing
|
*/

const Route = use('Route');

Route.get('api/users', 'UserController.index');

Route.any('*', 'NuxtController.render'); // 前端渲染
```
- 後端路由必須建立在前端渲染之前。

## 後端開發
前後端同時編譯相當耗時，因此新增一列命令，在開發後端時不對前端程式碼編譯。
```JS
"dev:server": "cross-env NODE_NO_CLIENT=true nodemon --watch app --watch bootstrap --watch config --watch .env -x node server.js",
```

修改 `app\Controllers\Http\NuxtController.js` 檔：
```JS
'use strict';

const Env = use('Env');
const Config = use('Config');
const { Nuxt, Builder } = require('nuxt');

class NuxtController {
  constructor() {
    // 停止運行
    if (process.env.NODE_NO_CLIENT) {
      return;
    }
    const config = Config.get('nuxt');
    config.dev = Env.get('NODE_ENV') === 'development';
    this.nuxt = new Nuxt(config);
    // Start build process (only in development)
    if (config.dev) {
      new Builder(this.nuxt).build();
    }
  }

  async render({ request: { request: req }, response: { response: res } }) {
    await new Promise((resolve, reject) => {
      this.nuxt.render(req, res, (promise) => {
        promise.then(resolve).catch(reject);
      });
    });
  }
}

module.exports = new NuxtController();
```

執行。
```
$ npm run dev:server
```

## 前端開發
前端編譯比較不會耗時，直接執行以下命令。
```
$ npm run dev
```

## 程式碼
[GitHub](https://github.com/memochou1993/adonuxt)
