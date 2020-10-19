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

如果令牌不是由 `User` 模型所建立，例如由 `Company` 模型所建立，使用此另牌去存取 `User` 模型的資料，有可能在 Policy 的隱式綁定中出現問題。

```PHP
public function viewAny(User $user)
{
    // 出現錯誤，因為 $user 不是 User 模型
}
```

因此需要建立一個 `VerifyToken` 中介層，來區別目前的認證是什麼模型：

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
        // 確保當前的認證模型是指定的模型
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

在路由中使用：

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

修改 `AppServiceProvider` 服務提供者，在 `boot()` 方法中設定 Sanctum 要使用的 `Token` 模型。

```PHP
namespace App\Providers;

use App\Models\Token;
use Illuminate\Support\ServiceProvider;
use Laravel\Sanctum\Sanctum;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        //
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        Sanctum::usePersonalAccessTokenModel(Token::class);
    }
}
```

## 遷移檔

如果要客製 Sanctum 的 `personal_access_tokens` 資料表，可以使用以下指令匯出遷移檔。

```BASH
php artisan vendor:publish --tag=sanctum-migrations
```

修改 `AppServiceProvider` 服務提供者，停止使用預設的遷移檔：

```PHP
namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Laravel\Sanctum\Sanctum;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        Sanctum::ignoreMigrations();
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        //
    }
}
```

## 測試

在做單元測試的時候，使用以下方法來認證當前的模型：

```PHP
$company = factory(Company::class)->make();

Sanctum::actingAs($company);
```
