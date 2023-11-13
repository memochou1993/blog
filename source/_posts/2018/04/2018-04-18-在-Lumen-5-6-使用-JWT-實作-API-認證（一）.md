---
title: 在 Lumen 5.6 使用 JWT 實作 API 認證（一）
date: 2018-04-18 10:15:52
tags: ["Programming", "PHP", "Laravel", "Lumen", "JWT"]
categories: ["Programming", "PHP", "Lumen"]
---

## 前言

本文為參考〈[Developing RESTful APIs with Lumen](https://auth0.com/blog/developing-restful-apis-with-lumen/)〉一文的學習筆記。

## 環境

- Windows 7
- Apache 2.4.33
- MySQL 5.7.21
- PHP 7.2.4

## 建立專案

```bash
lumen new lumen
```

## 新增資料庫

```env
CREATE DATABASE `lumen`
```

## 設置 .env 檔

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=lumen
DB_USERNAME=root
DB_PASSWORD=secret
```

## 安裝套件

下載 `jwt-auth` 套件。

```bash
composer require tymon/jwt-auth:"^1.0@dev"
```

## 環境配置

編輯 `bootstrap/app.php` 檔並取消以下註解：

```php
// $app->withFacades();
// $app->withEloquent();
// ...
// $app->routeMiddleware([
//     'auth' => App\Http\Middleware\Authenticate::class,
// ]);
// ...
// $app->register(App\Providers\AppServiceProvider::class);
// $app->register(App\Providers\AuthServiceProvider::class);
```

在 Register Service Providers 中註冊 `LumenServiceProvider。`

```php
$app->register(Tymon\JWTAuth\Providers\LumenServiceProvider::class);
```

## 新增 auth.php 檔

- 在根目錄手動建立 `config` 資料夾。
- 把 Laravel 專案的 `config` 資料夾的 `auth.php` 檔複製過來。
- 更改為以下內容：

```php
'defaults' => [
    'guard' => 'api',
    'passwords' => 'users',
],
// ...
'guards' => [
    'api' => [
        'driver' => 'jwt',
        'provider' => 'users',
    ],
],
```

安裝 Lumen 文件配置指令。

```bash
composer require laravelista/lumen-vendor-publish
```

註冊指令到 `app/Console/Kernel.php` 檔。

```php
protected $commands = [
    \Laravelista\LumenVendorPublish\VendorPublishCommand::class
];
```

## 新增 helpers.php 檔

在 `app` 資料夾內新增 `helpers.php` 檔。

```php
if (!function_exists('config_path')) {
    /**
     * Get the configuration path.
     *
     * @param string $path
     * @return string
     */
    function config_path($path = '')
    {
        return app()->basePath() . '/config' . ($path ? '/' . $path : $path);
    }
}
```

## 配置文件

在 `composer.json` 檔的 `autoload` 的部分自動加載 `app/helpers.php` 檔。

```php
"autoload": {
    "psr-4": {
        "App\\": "app/"
    },
    "files": [
        "app/helpers.php"
    ]
},
```

執行 Composer 自動載入指令。

```bash
composer dump-autoload
```

將 `vendor\tymon\jwt-auth\src\Providers\LumenServiceProvider.php` 檔更改為以下：

```php
public function boot()
{
    $this->app->configure('jwt');

    $path = realpath(__DIR__.'/../../config/config.php');

    $this->publishes([$path => config_path('jwt.php'),], 'config');
    $this->mergeConfigFrom($path, 'jwt');

    $this->app->routeMiddleware($this->middlewareAliases);

    $this->extendAuthGuard();

    $this->app['tymon.jwt.parser']->setChain([
        new AuthHeaders,
        new QueryString,
        new InputSource,
        new LumenRouteParams,
    ]);
}
```

複製需要的套件文檔。

```bash
php artisan vendor:publish --provider="Tymon\JWTAuth\Providers\JWTAuthServiceProvider"
```

## 產生 JWT 密鑰

```bash
php artisan jwt:generate
```

## 程式碼

- [jwt-lumen](https://github.com/memochou1993/jwt-lumen)
