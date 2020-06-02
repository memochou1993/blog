---
title: 在 Laravel 7.0 客製化 Sanctum 認證
permalink: 在-Laravel-7-0-客製化-Sanctum-認證
date: 2020-06-02 22:36:38
tags: ["程式設計", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 前言

一般只有使用者會需要認證，但有時候其他模型也需要認證，例如客戶端、組織或企業等。所幸 Sanctum 使用的關聯是一對多的多態關聯，使得其他的模型可以共用 `personal_access_tokens` 資料表，為模型建立令牌（token）。

## 認證模型

如果有一個自訂的模型需要建立令牌，例如 `Company`，可以將它修改如下：

```PHP
namespace App\Models;

use Illuminate\Auth\Authenticatable;
use Illuminate\Contracts\Auth\Authenticatable as AuthenticatableContract;
use Illuminate\Database\Eloquent\Model;
use Laravel\Sanctum\HasApiTokens;

class Company extends Model implements AuthenticatableContract
{
    use Authenticatable;
    use HasApiTokens;
}
```

## 中介層

如果令牌不是由 `User` 模型所建立，直接將當前的認證模型，例如 `Auth::user()` 帶入有模型綁定的方法中就會發生錯誤。

```PHP
/**
 * @param  User  $user
 */
public function get(User $user)
{
    //
}
```

為了避免錯誤的令牌請求，可以建立一個 `VerifyToken` 中介層：

```PHP
namespace App\Http\Middleware;

use Closure;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Support\Str;

class VerifyToken
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @param  string  $model
     * @return mixed
     * @throws AuthenticationException
     */
    public function handle($request, Closure $next, string $model)
    {
        if (! (class_basename($request->user()) === Str::ucfirst($model))) {
            throw new AuthenticationException();
        }

        return $next($request);
    }
}
```

在 `app/Http/Kernel.php` 檔中註冊。

```PHP
protected $routeMiddleware = [
    // ...
    'token' => \App\Http\Middleware\VerifyToken::class,
];
```

在路由中使用如下：

```PHP
Route::prefix('api/user')->middleware([
    'token:user',
    'auth:sanctum',
])->group(function () {
    // 只有使用 User 模型所建立的令牌能夠進入
});

Route::prefix('api/company')->middleware([
    'token:company',
    'auth:sanctum',
])->group(function () {
    // 只有使用 Company 模型所建立的令牌能夠進入
});
```

## 令牌模型

如果要客製 Sanctum 的 `PersonalAccessToken` 模型，可以建立一個自己的 `Token` 模型來繼承它。

```PHP
namespace App\Models;

use Laravel\Sanctum\PersonalAccessToken;

class Token extends PersonalAccessToken
{
    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'personal_access_tokens';
}
```

修改 `AuthServiceProvider` 服務提供者，在 `boot()` 方法中設定 Sanctum 要使用的 `Token` 模型。

```PHP
namespace App\Providers;

use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use Laravel\Sanctum\Sanctum;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The policy mappings for the application.
     *
     * @var array
     */
    protected $policies = [
        // 'App\Model' => 'App\Policies\ModelPolicy',
    ];

    /**
     * Register any authentication / authorization services.
     *
     * @return void
     */
    public function boot()
    {
        $this->registerPolicies();

        Sanctum::usePersonalAccessTokenModel(\App\Models\Token::class);
    }
}
```

## 測試

在做單元測試的時候，使用以下方法來認證當前的模型：

```PHP
$company = factory(Company::class)->make();

Sanctum::actingAs($company);
```
