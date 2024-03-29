---
title: 在 Laravel 6.0 使用 Macros 巨集
date: 2019-10-19 16:18:40
tags: ["Programming", "PHP", "Laravel"]
categories: ["Programming", "PHP", "Laravel"]
---

## 前言

Laravel 提供一個 Macroable 特徵機制，用來擴展基礎類別。

## Str 類別

以 `Str` 類別為例，新增 `app/Mixins/StrMixin.php` 檔：

```php
namespace App\Mixins;

class StrMixin
{
    /**
     * @return \Closure
     */
    public static function uppercase()
    {
        return function ($value) {
            return strtoupper($value);
        };
    }
}
```

在 `app/Providers/AppServiceProvider.php` 檔註冊：

```php
namespace App\Providers;

use App\Mixins\StrMixin;
use Illuminate\Support\Str;
use Illuminate\Support\ServiceProvider;

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
        Str::mixin(new StrMixin());
    }
}
```

使用：

```php
echo Str::uppercase('test');
```

結果：

```php
TEST
```

## Collection 類別

以 `Collection` 類別為例，新增 `app/Mixins/CollectionMixin.php` 檔：

```php
namespace App\Mixins;

class CollectionMixin
{
    /**
     * @return \Closure
     */
    public function uppercase()
    {
        return function () {
            return collect($this->items)->map(function ($item) {
                return strtoupper($item);
            });
        };
    }
}
```

在 `app/Providers/AppServiceProvider.php` 檔註冊：

```php
namespace App\Providers;

use App\Mixins\CollectionMixin;
use Illuminate\Support\Collection;
use Illuminate\Support\ServiceProvider;

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
        Collection::mixin(new CollectionMixin());
    }
}
```

使用：

```php
return collect(['test'])->uppercase()->toArray();
```

結果：

```php
["TEST"]
```

## ResponseFactory 類別

以 ResponseFactory 類別為例，新增 `app/Mixins/ResponseMixin.php` 檔：

```php
namespace App\Mixins;

class ResponseMixin
{
    /**
     * @return \Closure
     */
    public function error()
    {
        return function ($error) {
            return [
                'error' => $error,
            ];
        };
    }
}
```

在 `app/Providers/AppServiceProvider.php` 檔註冊：

```php
namespace App\Providers;

use App\Mixins\ResponseMixin;
use Illuminate\Routing\ResponseFactory;
use Illuminate\Support\ServiceProvider;

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
        ResponseFactory::mixin(new ResponseMixin());
    }
}
```

使用：

```php
return Response::error('test');
```

結果：

```php
{
  "error": "test"
}
```

## 服務提供者

新增一個 `MixinServiceProvider` 服務提供者來集中管理所有的 Mixin 類別。

```bash
php artisan make:provider MixinServiceProvider
```

修改 `MixinServiceProvider` 服務提供者。

```php
namespace App\Providers;

use App\Mixins\CollectionMixin;
use App\Mixins\ResponseMixin;
use App\Mixins\StrMixin;
use Illuminate\Routing\ResponseFactory;
use Illuminate\Support\Collection;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Str;

class MixinServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     *
     * @return void
     */
    public function register()
    {
        //
    }

    /**
     * Bootstrap services.
     *
     * @return void
     */
    public function boot()
    {
        Str::mixin(new StrMixin());
        Collection::mixin(new CollectionMixin());
        ResponseFactory::mixin(new ResponseMixin());
    }
}
```

修改 `config` 資料夾的 `app.php` 檔，以註冊服務提供者：

```php
'providers' => [

    // ...
    App\Providers\MixinServiceProvider::class,

],
```

## 補充

所有帶有巨集的類別有以下：

- Illuminate\Auth\RequestGuard
- Illuminate\Auth\SessionGuard
- Illuminate\Cache\Repository
- Illuminate\Console\Command
- Illuminate\Console\Scheduling\Event
- Illuminate\Cookie\CookieJar
- Illuminate\Database\Eloquent\FactoryBuilder
- Illuminate\Database\Eloquent\Relations\Relation
- Illuminate\Database\Grammar
- Illuminate\Database\Query\Builder
- Illuminate\Database\Schema\Blueprint
- Illuminate\Filesystem\Filesystem
- Illuminate\Foundation\Testing\TestResponse
- Illuminate\Http\JsonResponse
- Illuminate\Http\RedirectResponse
- Illuminate\Http\Request
- Illuminate\Http\Response
- Illuminate\Http\UploadedFile
- Illuminate\Mail\Mailer
- Illuminate\Routing\PendingResourceRegistration
- Illuminate\Routing\Redirector
- Illuminate\Routing\ResponseFactory
- Illuminate\Routing\Route
- Illuminate\Routing\Router
- Illuminate\Routing\UrlGenerator
- Illuminate\Support\Arr
- Illuminate\Support\Collection
- Illuminate\Support\LazyCollection
- Illuminate\Support\Str
- Illuminate\Support\Testing\Fakes\NotificationFake
- Illuminate\Translation\Translator
- Illuminate\Validation\Rule
- Illuminate\View\Factory
- Illuminate\View\View

## 參考資料

- [Macroable Laravel Classes](https://coderstape.com/blog/3-macroable-laravel-classes-full-list)
