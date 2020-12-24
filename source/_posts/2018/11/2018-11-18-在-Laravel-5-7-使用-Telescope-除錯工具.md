---
title: 在 Laravel 5.7 使用 Telescope 除錯工具
permalink: 在-Laravel-5-7-使用-Telescope-除錯工具
date: 2018-11-18 02:05:25
tags: ["程式設計", "PHP", "Laravel", "除錯", "Telescope"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 環境

- Windows 10
- Homestead

## 建立專案

建立專案。

```BASH
laravel new telescope
```

## 一般使用

安裝 `laravel/telescope` 套件。

```BASH
composer require laravel/telescope
```

執行安裝。

```BASH
php artisan telescope:install
```

執行遷移。

```BASH
php artisan migrate
```

發布資源。

```BASH
php artisan telescope:publish
```

前往：<http://telescope.test/telescope>

## 本地使用

安裝 `laravel/telescope` 套件。

```BASH
composer require laravel/telescope --dev
```

修改 `composer.json` 檔。

```JSON
"extra": {
    "laravel": {
        "dont-discover": [
            "laravel/telescope"
        ]
    }
},
```

執行安裝。

```BASH
php artisan telescope:install
```

執行遷移。

```BASH
php artisan migrate
```

發布資源。

```BASH
php artisan telescope:publish
```

將 `config/app.php` 檔中的 `App\Providers\TelescopeServiceProvider::class` 刪除。

在 `app/Providers/AppServiceProvider.php` 檔中註冊服務提供者。

```PHP
/**
 * Register any application services.
 *
 * @return void
 */
public function register()
{
    if ($this->app->isLocal()) {
        $this->app->register(TelescopeServiceProvider::class);
    }
}
```

為了避免在正式環境執行 Telescope 遷移，需要修改 `config/telescope.php` 檔，將預設啟用改為 `false`：

```PHP
return [


    'enabled' => env('TELESCOPE_ENABLED', false),

];
```

再修改 `.env` 檔，即可在本地環境啟用 Telescope：

```ENV
TELESCOPE_ENABLED=true
```

前往：<http://telescope.test/telescope>

## 認證

在非本地環境下使用，可以修改 `app/Providers/TelescopeServiceProvider.php` 檔，定義合法的使用者列表：

```PHP
/**
 * Register the Telescope gate.
 *
 * This gate determines who can access Telescope in non-local environments.
 *
 * @return void
 */
protected function gate()
{
    Gate::define('viewTelescope', function ($user) {
        return in_array($user->email, [
            'user@gmail.com',
        ]);
    });
}
```

如果要取消認證，可以將 `config/telescope.php` 檔中的 `Authorize` 中介層移除：

```PHP
return [
    // ...

    'middleware' => [
        'web',
        // Authorize::class,
    ],

    // ...
];
```
