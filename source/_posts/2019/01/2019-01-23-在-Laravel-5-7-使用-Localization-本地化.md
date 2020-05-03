---
title: 在 Laravel 5.7 使用 Localization 本地化
permalink: 在-Laravel-5-7-使用-Localization-本地化
date: 2019-01-23 23:39:51
tags: ["程式設計", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 語系檔案

新增 `resources\lang\zh-tw\localization.php` 檔：

```PHP
return [
    'localization' => '本地化',
];
```

## 新增中介層

新增 `app\Http\Middleware\SetLocale.php` 檔：

```PHP
namespace App\Http\Middleware;

use App;
use Closure;
use Session;
use Carbon\Carbon;

class SetLocale
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @param  string|null  $guard
     * @return mixed
     */
    public function handle($request, Closure $next, $guard = null)
    {
        if (Session::has('locale')) {
            $locale = Session::get('locale');
            App::setLocale($locale);
            Carbon::setLocale($locale);
        }

        return $next($request);
    }
}
```

修改 `app\Http\Kernel.php` 檔：

```PHP
'web' => [
    // ...
    \App\Http\Middleware\SetLocale::class,
],
```

## 新增路由

```PHP
Route::get('/{locale}', function ($locale) {
    Session::put('locale', $locale);

    dump([
        $locale,
        Session::get('locale'),
    ]);
});

Route::get('/', function () {
    dump([
        App::getLocale(),
        \Carbon\Carbon::now(),
        \Carbon\Carbon::now()->diffForHumans(),
    ]);

    echo __('localization.localization');
});
```

- 使用 `php artisan dump-server` 指令查看 `dump()` 中的內容。
- 使用 `__()` 輔助函式輸出在地化檔案的語句。

## 測試

前往：<http://localhost:8000/zh-tw>

## 程式碼

- [localization-example](https://github.com/memochou1993/localization-example)
