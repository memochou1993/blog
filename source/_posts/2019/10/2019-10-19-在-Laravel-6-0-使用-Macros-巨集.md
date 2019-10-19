---
title: 在 Laravel 6.0 使用 Macros 巨集
permalink: 在 Laravel 6.0 使用 Macros 巨集
date: 2019-10-19 16:18:40
tags: ["程式寫作", "PHP", "Laravel"]
categories: ["程式寫作", "PHP", "Laravel"]
---

## 前言

Laravel 提供一個 Macroable 特徵機制，用來擴展基礎類別。

## Str 類別

以 `Str` 類別為例，新增 `app/Mixins/StrMixin.php` 檔：

```PHP
namespace App\Mixins;

class StrMixin
{
    public static function uppercase()
    {
        return function ($value) {
            return strtoupper($value);
        };
    }
}
```

在 `app/Providers/AppServiceProvider.php` 檔註冊：

```PHP
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

```PHP
echo Str::uppercase('test');
```

結果：

```PHP
TEST
```

## Collection 類別

以 `Collection` 類別為例，新增 `app/Mixins/CollectionMixin.php` 檔：

```PHP
namespace App\Mixins;

class CollectionMixin
{
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

```PHP
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

```PHP
return collect(['test'])->uppercase()->toArray();
```

結果：

```PHP
["TEST"]
```

## ResponseFactory 類別

以 ResponseFactory 類別為例，新增 `app/Mixins/ResponseMixin.php` 檔：

```PHP
namespace App\Mixins;

class ResponseMixin
{
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

```PHP
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

```PHP
return Response::error('test');
```

結果：

```PHP
{
  "error": "test"
}
```

## 補充

帶有巨集的類別有：

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

[Macroable Laravel Classes](https://coderstape.com/blog/3-macroable-laravel-classes-full-list)
