---
title: 在 Laravel 7.0 使用 Sanctum 實作 API 認證
permalink: 在-Laravel-7-0-使用-Sanctum-實作-API-認證
date: 2020-03-19 12:28:13
tags: ["程式設計", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 前言

Laravel Sanctum 原來的名字是 Laravel Airlock，因商標爭議改名。

## 建立專案

```BASH
laravel new airlock
```

## 安裝套件

```BASH
composer require laravel/sanctum
```

## 發布資源

```BASH
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

## 執行遷移

```BASH
php artisan migrate
```

## 註冊中介層

修改 `app\Http\Kernel.php` 檔：

```PHP
protected $middlewareGroups = [
    // ...

    'api' => [
        'throttle:60,1',
        \Illuminate\Routing\Middleware\SubstituteBindings::class,
        \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
    ],
];
```

## 修改模型

修改 `app\User.php` 檔：

```PHP
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens;
    use Notifiable;
}
```

## 修改路由

修改 `routes\api.php` 檔：

```PHP
Route::prefix('auth')->group(function () {
    Route::post('/login', 'AuthController@login');

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/user', 'AuthController@user');
        Route::post('/logout', 'AuthController@logout');
    });
});
```

## 建立控制器

建立控制器。

```BASH
php artisan make:controller AuthController
```

修改 `app\Http\Controllers\AuthController.php` 檔：

```PHP
<?php

namespace App\Http\Controllers;

use App\User;
use App\Http\Controllers\Controller;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function user()
    {
        return Auth::user();
    }

    public function login(Request $request)
    {
        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            throw new AuthenticationException();
        }

        return response([
            'access_token' => $user->createToken($request->device_name)->plainTextToken,
        ]);
    }

    public function logout()
    {
        Auth::user()->tokens()->delete();

        return response(null, 204);
    }
}
```

## 守衛

若要使用全域函式 `auth()` 取得 Sanctum 令牌的所屬模型，將 Guard 指定為 `sanctum`。

```PHP
auth()->guard('sanctum')->user();
```

## 測試

在做單元測試的時候，使用以下方法來認證當前的模型。

```PHP
$user = factory(User::class)->make();

Sanctum::actingAs($user);
```

## 設定

如果部署到正式環境，需要在 `.env` 檔設置 SPA 應用程式的網域。

```ENV
SANCTUM_STATEFUL_DOMAINS=
```

## 程式碼

- [sanctum-example](https://github.com/memochou1993/sanctum-example)

## 參考文件

- [Laravel Sanctum](https://laravel.com/docs/master/sanctum)
