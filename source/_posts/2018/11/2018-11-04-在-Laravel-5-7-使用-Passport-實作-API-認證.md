---
title: 在 Laravel 5.7 使用 Passport 實作 API 認證
permalink: 在-Laravel-5-7-使用-Passport-實作-API-認證
date: 2018-11-04 02:41:25
tags: ["程式設計", "PHP", "Laravel", "Passport"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 環境

- Windows 10
- Homestead

## 建立專案

```BASH
laravel new passport
```

## 安裝套件

```BASH
composer require laravel/passport
```

## 執行遷移

```BASH
php artisan migrate
```

## 新增填充

新增 `UsersTableSeeder` 填充。

```BASH
php artisan make:seed UsersTableSeeder
```

在 `UsersTableSeeder.php` 檔新增一名測試用使用者資訊。

```PHP
public function run()
{
    App\User::create([
        'name' => 'Test User',
        'email' => 'homestead@test.com',
        'password' => bcrypt('secret'),
    ]);
}
```

執行填充。

```BASH
php artisan db:seed
```

## 生成密鑰

執行安裝。

```BASH
php artisan passport:install
```

得到以下資訊。

```TEXT
Personal access client created successfully.
Client ID: 1
Client Secret: AHB4p……tdffF
Password grant client created successfully.
Client ID: 2
Client Secret: 28ch1……ioMe7
```

若只有密碼授權，執行：

```BASH
php artisan passport:client --password
```

若只有客戶端憑證授權，執行：

```BASH
php artisan passport:client --client
```

## 修改模型

修改 `User` 模型。

```PHP
namespace App;

use Laravel\Passport\HasApiTokens;
use Illuminate\Notifications\Notifiable;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;
}
```

## 註冊路由

在 `app\Providers\AuthServiceProvider.php` 檔註冊路由。

```PHP
namespace App\Providers;

use Laravel\Passport\Passport;
use Illuminate\Support\Facades\Gate;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The policy mappings for the application.
     *
     * @var array
     */
    protected $policies = [
        'App\Model' => 'App\Policies\ModelPolicy',
    ];

    /**
     * Register any authentication / authorization services.
     *
     * @return void
     */
    public function boot()
    {
        $this->registerPolicies();

        Passport::routes(function ($router) {
            $router->forAccessTokens();
        });

        Passport::tokensExpireIn(now()->addMinutes(360)); // Token 有效時間

        Passport::refreshTokensExpireIn(now()->addDays(7)); // Refresh Token 有效時間

        Passport::pruneRevokedTokens(); // 從資料庫將過期 Token 刪除
    }
}
```

## 修改認證設定

修改 `config/auth.php` 檔。

```PHP
'guards' => [
    'web' => [
        'driver' => 'session',
        'provider' => 'users',
    ],

    'api' => [
        'driver' => 'passport', // 改成 passport
        'provider' => 'users',
    ],
```

## 發起 HTTP 請求

向 <http://passport.test/api/user> 發起 `GET` 請求，得到回應如下：

```JSON
[MethodNotAllowedHttpException] No message
```

在 `Accept` 輸入 `application/json` 可以得到以下回應：

```JSON
{
    "message": "Unauthenticated."
}
```

### 客戶端憑證授權

在 `app/Http/Kernel.php` 的 `routeMiddleware` 新增中介層。

```PHP
protected $routeMiddleware = [
    // ...
    'client' => \Laravel\Passport\Http\Middleware\CheckClientCredentials::class,
];
```

修改路由。

```PHP
Route::get('/user', function (Request $request) {
    return \App\User::get();
})->middleware('client');
```

向 <http://passport.test/oauth/token> 發起 `POST` 請求：

```JSON
{
    "grant_type": "client_credentials",
    "client_id" : 2,
    "client_secret": "28ch1……ioMe7"
}
```

得到回應如下：

```JSON
{
    "token_type": "Bearer",
    "expires_in": 599,
    "access_token": "eyJ0e……uAqSw"
}
```

最後在 `Headers` 輸入以下鍵値，再向 <http://passport.test/api/user> 發起 `GET` 請求。

| Key | Value |
| --- | --- |
| Authorization | Bearer eyJ0e……uAqSw |

- Value 的部分為：Bearer + 空一格 + Token。

結果得到回應如下：

```JSON
[
    {
        "id": 1,
        "name": "Test User",
        "email": "homestead@test.com",
        "email_verified_at": null,
        "created_at": "2018-11-03 16:27:33",
        "updated_at": "2018-11-03 16:27:33"
    }
]
```

### 密碼授權

使用預設路由。

```PHP
Route::middleware('auth:api')->get('/user', function (Request $request) {
    return $request->user();
});
```

向 <http://passport.test/oauth/token> 發起 `POST` 請求：

```JSON
{
    "grant_type": "password",
    "client_id" : 2,
    "client_secret": "28ch1……ioMe7",
    "username": "homestead@test.com",
    "password": "secret"
}
```

得到回應如下：

```JSON
{
    "token_type": "Bearer",
    "expires_in": 599,
    "access_token": "eyJ0e……uAqSw",
    "refresh_token": "def50……29a13"
}
```

最後在 `Headers` 輸入以下鍵値，再向 <http://passport.test/api/user> 發起 `GET` 請求。

| Key | Value |
| --- | --- |
| Authorization | Bearer def50……29a13 |

- Value 的部分為：Bearer + 空一格 + Token。

結果得到回應如下：

```JSON
[
    {
        "id": 1,
        "name": "Test User",
        "email": "homestead@test.com",
        "email_verified_at": null,
        "created_at": "2018-11-03 16:27:33",
        "updated_at": "2018-11-03 16:27:33"
    }
]
```

如果要刷新 Token，則向 <http://passport.test/oauth/token> 發起 `POST` 請求：

```JSON
{
    "grant_type": "refresh_token",
    "client_id" : 2,
    "client_secret": "28ch1……ioMe7",
    "refresh_token": "def50……29a13"
}
```

得到回應如下：

```JSON
{
    "token_type": "Bearer",
    "expires_in": 599,
    "access_token": "eyJ0e……sLOaA",
    "refresh_token": "def50……9d38c"
}
```

## 部署

部署到正式環境時，需要產生 Passport 金鑰。

```BASH
php artisan passport:keys
```

## 程式碼

- [passport-example](https://github.com/memochou1993/passport-example)

## 參考資料

- [Laravel 道場：API 認證（Passport）](https://docs.laravel-dojo.com/laravel/5.5/passport)
- [Laravel 的 API 認證系统 Passport](https://laravel-china.org/docs/laravel/5.5/passport/1309)
- [Laravel 使用 Passport 實作 OAuth2 Client 註冊與認證](http://carlleesnote.blogspot.com/2017/03/laravel-passport-oauth2-client-by-grant.html)
- [Vue.js Todo App - Laravel Passport - Part 9](https://www.youtube.com/watch?v=HGh0cKEVXPI)
