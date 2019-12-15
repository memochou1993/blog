---
title: 在 Laravel 6.0 整合 Vue 2.6 和 Vuetify 2.0 建立 SPA 應用程式
permalink: 在-Laravel-6-0-整合-Vue-2-6-和-Vuetify-2-0-建立-SPA-應用程式
date: 2019-09-08 01:16:40
tags: ["程式寫作", "PHP", "Laravel", "JavaScript", "Vue", "Vuetify"]
categories: ["程式寫作", "PHP", "Laravel"]
---

## 前言

為了開發小型 SPA 應用程式，並且前後端都在同一個專案下，因此開發這個樣板，將 Vue 和 Vuetify 整合到 Laravel 專案中。

## 環境

- PHP 7.2

## 安裝套件

修改 `package.json` 檔：

```JSON
{
    "private": true,
    "scripts": {
        "dev": "npm run development",
        "development": "cross-env NODE_ENV=development node_modules/webpack/bin/webpack.js --progress --hide-modules --config=node_modules/laravel-mix/setup/webpack.config.js",
        "watch": "npm run development -- --watch",
        "watch-poll": "npm run watch -- --watch-poll",
        "hot": "cross-env NODE_ENV=development node_modules/webpack-dev-server/bin/webpack-dev-server.js --inline --hot --config=node_modules/laravel-mix/setup/webpack.config.js",
        "prod": "npm run production",
        "production": "cross-env NODE_ENV=production node_modules/webpack/bin/webpack.js --no-progress --hide-modules --config=node_modules/laravel-mix/setup/webpack.config.js",
        "lint": "eslint --ext .js,.vue resources/js/"
    },
    "devDependencies": {
        "@mdi/font": "^4.3.95",
        "axios": "^0.19",
        "babel-eslint": "^10.0.3",
        "cross-env": "^5.1",
        "eslint": "^6.3.0",
        "eslint-loader": "^3.0.0",
        "eslint-plugin-vue": "^5.2.3",
        "laravel-mix": "^4.1.4",
        "resolve-url-loader": "^2.3.1",
        "sass": "^1.15.2",
        "sass-loader": "^7.1.0",
        "vue": "^2.6.10",
        "vue-axios": "^2.1.4",
        "vue-i18n": "^8.14.0",
        "vue-router": "^3.1.3",
        "vue-template-compiler": "^2.6.10",
        "vuetify": "^2.0.14",
        "vuex": "^3.1.1"
    }
}
```

安裝所需套件。

```BASH
npm install
```

## 修改後端視圖

將 `welcome.blade.php` 檔改名為 `app.blade.php`，並修改如下：

```HTML
<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Laravel SPA</title>
    </head>
    <body>
        <div id="app"></div>
        <script src="{{ asset('js/manifest.js') }}"></script>
        <script src="{{ asset('js/vendor.js') }}"></script>
        <script src="{{ asset('js/main.js') }}"></script>
    </body>
</html>
```

## 修改後端路由

將 `web.php` 檔修改如下：

```PHP
Route::get('/{any}', function () {
    return view('app');
})->where('any', '.*');
```

## 修改資源編譯設定檔

將 `webpack.mix.js` 檔修改如下：

```JS
const mix = require('laravel-mix');

mix
  .webpackConfig({
    module: {
      rules: [
        {
          enforce: 'pre',
          test: /\.(js|vue)$/,
          loader: 'eslint-loader',
          exclude: /node_modules/,
        },
      ],
    },
    resolve: {
      extensions: [
        '.js',
        '.vue',
      ],
      alias: {
        '@': __dirname + '/resources/js',
      },
    },
  })
  .js('resources/js/main.js', 'public/js')
  .extract([
    'vue',
    'vue-router',
    'vuetify',
  ])
  .sourceMaps();
```

## 建立 Vuetify 實例

在 `resources/js` 資料夾新增 `plugins/vuetify.js` 檔：

```jS
import Vue from 'vue';
import Vuetify from 'vuetify';
import 'vuetify/dist/vuetify.min.css';
import '@mdi/font/css/materialdesignicons.css';

Vue.use(Vuetify);

export default new Vuetify({
  icons: {
    iconfont: 'mdi',
  },
});
```

## 修改 app.js 檔

將 `resources/js` 資料夾的 `app.js` 檔改名為 `main.js`，並修改如下：

```JS
import Vue from 'vue';
import App from '@/App.vue';
import router from '@/router';
import vuetify from '@/plugins/vuetify';

Vue.config.productionTip = false;

new Vue({
  router,
  vuetify,
  render: h => h(App),
}).$mount('#app');
```

## 建立前端元件

在 `resources/js` 資料夾新增 `components/TheToolbar.vue` 元件：

```HTML
<template>
  <div>
    <v-navigation-drawer
      v-model="drawer"
      app
      clipped
    >
      <v-list>
        <v-list-item
          v-for="(link, index) in links"
          :key="index"
          :to="link.to"
          exact
        >
          <v-list-item-action>
            <v-icon>
              {{ link.icon }}
            </v-icon>
          </v-list-item-action>
          <v-list-item-content>
            <v-list-item-title>
              {{ link.title }}
            </v-list-item-title>
          </v-list-item-content>
        </v-list-item>
      </v-list>
    </v-navigation-drawer>
    <v-app-bar
      app
      dark
      color="primary"
      clipped-left
    >
      <v-toolbar-title
        class="headline"
      >
        <v-app-bar-nav-icon
          @click.stop="setDrawer(!drawer)"
        />
        Laravel SPA
      </v-toolbar-title>
    </v-app-bar>
  </div>
</template>

<script>
export default {
  data() {
    return {
      drawer: true,
    };
  },
  computed: {
    links() {
      return [
        {
          title: this.$t('links.home'),
          icon: 'mdi-home',
          to: {
            name: 'home',
          },
        },
      ];
    },
  },
  methods: {
    setDrawer(drawer) {
      this.drawer = drawer;
    },
  },
};
</script>
```

在 `resources/js` 資料夾新增 `components/TheFooter.vue` 元件：

```HTML
<template>
  <v-footer
    padless
  >
    <v-card
      width="100%"
      class="primary lighten-1 text-center"
    >
      <v-card-text
        class="white--text"
      >
        &copy; 2019 Memo Chou
      </v-card-text>
    </v-card>
  </v-footer>
</template>
```

## 建立 App.vue 檔

在 `resources/js` 資料夾新增 `App.vue` 檔：

```HTML
<template>
  <v-app>
    <TheToolbar />
    <v-content>
      <v-container>
        <v-flex>
          <router-view />
        </v-flex>
      </v-container>
    </v-content>
    <TheFooter />
  </v-app>
</template>

<script>
import TheToolbar from '@/components/TheToolbar.vue';
import TheFooter from '@/components/TheFooter.vue';

export default {
  name: 'App',
  components: {
    TheToolbar,
    TheFooter,
  },
};
</script>

<style lang="scss">
//
</style>
```

## 建立前端視圖

在 `resources/js` 資料夾新增 `views/Home.vue` 視圖：

```HTML
<template>
  <div>
    Home
  </div>
</template>
```

## 建立前端路由

在 `resources/js` 資料夾新增 `router.js` 檔：

```JS
import Vue from 'vue';
import Router from 'vue-router';

Vue.use(Router);

export default new Router({
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('@/views/Home.vue'),
    },
  ],
});
```

## 建立 ESLint 設定檔

建立 `.eslintrc.js` 檔。

```JS
module.exports = {
  root: true,
  env: {
    browser: true,
    node: true,
  },
  parserOptions: {
    parser: 'babel-eslint',
  },
  extends: [
    'plugin:vue/recommended',
  ],
  plugins: [
    'vue',
  ],
  rules: {
    'no-console': process.env.NODE_ENV === 'production' ? 'error' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'off',
  },
};
```

## 建立 .gitignore 檔

將 `.gitignore` 檔修改如下：

```ENV
/node_modules
/public/hot
/public/storage
/storage/*.key
/vendor
.env
.env.backup
.phpunit.result.cache
Homestead.json
Homestead.yaml
npm-debug.log
yarn-error.log
/public/js
/public/*.js
/public/*.js.map
/public/mix-manifest.json
```

## 編譯資源

```BASH
npm run watch
```

## 程式碼

[GitHub](https://github.com/memochou1993/laravel-spa)

## 參考資料

- [Building a Vue SPA with Laravel](https://medium.com/@weehong/laravel-5-7-vue-vue-router-spa-5e07fd591981)
