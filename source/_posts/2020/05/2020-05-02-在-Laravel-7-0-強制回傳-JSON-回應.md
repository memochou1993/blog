---
title: 在 Laravel 7.0 強制回傳 JSON 回應
date: 2020-05-02 18:49:49
tags: ["程式設計", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 前言

在認證失敗的情況下，Laravel 預設會導向 Login 頁面，前端需要特別指示頭欄位 `Accept` 為 `application/json` 才能接收 JSON 格式的訊息。因此以下藉由註冊一個中介層，讓 Laravel 強制回傳 JSON 格式的回應。

## 做法

新增一個 `ResponseJson` 中介層。

```BASH
php artisan make:middleware ResponseJson
```

修改 `ResponseJson.php` 檔：

```PHP
namespace App\Http\Middleware;

use Closure;

class ResponseJson
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        $request->headers->set('Accept', 'application/json');

        return $next($request);
    }
}
```

將中介層註冊到 `Kernel.php` 檔的 `api` 群組：

```PHP
protected $middlewareGroups = [
    // ...

    'api' => [
        // ...
        \App\Http\Middleware\ResponseJson::class,
    ],
];
```

新增一個 `$middlewarePriority` 屬性，讓 `ResponseJson` 中介層優先被通過：

```PHP
/**
 * The priority-sorted list of middleware.
 *
 * This forces non-global middleware to always be in the given order.
 *
 * @var array
 */
protected $middlewarePriority = [
    \App\Http\Middleware\ResponseJson::class,
    // ...
];
```

- 列表中必須註冊完整的類別名稱。

## 參考資料

- [Laravel Middleware](https://laravel.com/docs/master/middleware)
