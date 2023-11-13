---
title: 在 Laravel 5.7 使用 Vuetify UI 框架
date: 2019-01-21 22:33:25
tags: ["Programming", "Laravel", "Vue", "Vuetify"]
categories: ["Programming", "PHP", "Laravel"]
---

## 建立專案

建立專案。

```bash
laravel new laravel-vuetify
```

啟動伺服器。

```bash
php artisan serve
```

## 修改 package.json 檔

```json
{
    "axios": "^0.18",
    "cross-env": "^5.1",
    "laravel-mix": "^4.0.7",
    "lodash": "^4.17.5",
    "resolve-url-loader": "^2.3.1",
    "sass": "^1.15.2",
    "sass-loader": "^7.1.0",
    "vue": "^2.5.17"
}
```

## 安裝

```bash
npm install
npm install vuetify --save-dev
```

- `vue-template-compiler` 會被自動安裝。

## 新增路由

```php
Route::get('/example', function () {
    return view('example');
});
```

## 新增視圖

新增 `resources\views\layouts\app.blade.php` 檔：

```php
<!doctype html>
<html lang="{{ app()->getLocale() }}">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>{{ env('APP_NAME', 'Laravel') }}</title>
    <link href="{{ asset('css/app.css') }}" rel="stylesheet" type="text/css">
</head>
<body>
    <div id="app">
        @yield('content')
    </div>
    <script src="{{ asset('js/manifest.js') }}"></script>
    <script src="{{ asset('js/vendor.js') }}"></script>
    <script src="{{ asset('js/app.js') }}"></script>
</body>
</html>
```

新增 `resources\views\example.blade.php` 檔：

```php
@extends('layouts.app')

@section('content')
    <app-component></app-component>
@endsection
```

## 配置

註解 `resources/js/bootstrap.js`。

```js
// window.Popper = require('popper.js').default;
// window.$ = window.jQuery = require('jquery');

// require('bootstrap');
```

新增 `resources\stylus\app.styl` 檔。

```js
@import '~vuetify/src/stylus/main'
```

修改 `webpack.mix.js` 檔：

```js
mix.js('resources/js/app.js', 'public/js')
    .extract()
    .stylus('resources/stylus/app.js', 'public/js');
```

移除 `sass` 和 `sass-loader` 套件。

```bash
npm uninstall sass
npm uninstall sass-loader
```

修改 `.editorconfig` 檔：

```conf
[*.{js,jsx,ts,tsx,vue}]
insert_final_newline = true
max_line_length = 100
```

## 監聽

```bash
npm run watch-poll
```

- 會自動安裝 `stylus` 和 `stylus-loader`。

## 編譯資源

```bash
npm run prod
```
