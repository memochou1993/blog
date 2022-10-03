---
title: 在 Laravel 6.0 建立 Collection 分頁器
date: 2019-12-04 11:44:24
tags: ["程式設計", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 做法

新增 `app/Mixins/CollectionMixin.php` 檔：

```PHP
namespace App\Mixins;

use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Pagination\Paginator;

class CollectionMixin
{
    public function paginate()
    {
        return function ($perPage = 15, $page = null, $options = []) {
            $page = $page ?: (Paginator::resolveCurrentPage() ?: 1);

            return (
                new LengthAwarePaginator(
                    $this->forPage($page, $perPage)->values(),
                    $this->count(),
                    $perPage,
                    $page,
                    $options
                )
            )->withPath('');
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
$items = [1, 2, 3, 4, 5];

return collect($items)->paginate(2, 2);
```

結果：

```PHP
{
    "current_page": 2,
    "data": {
        "2": 3,
        "3": 4
    },
    "first_page_url": "?page=1",
    "from": 3,
    "last_page": 3,
    "last_page_url": "?page=3",
    "next_page_url": "?page=3",
    "path": "",
    "per_page": 2,
    "prev_page_url": "?page=1",
    "to": 4,
    "total": 5
}
```
