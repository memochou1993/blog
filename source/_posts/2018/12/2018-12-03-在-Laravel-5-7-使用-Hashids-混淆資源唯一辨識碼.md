---
title: 在 Laravel 5.7 使用 Hashids 混淆資源唯一辨識碼
date: 2018-12-03 21:05:54
tags: ["程式設計", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 環境

- Windows 10
- Homestead

## 安裝套件

使用 [hashids](https://github.com/vinkla/hashids) 套件可以將 ID 打亂，避免將主鍵直接暴露於網址中。

```bash
composer require hashids/hashids
```

## 建立特徵機制

建立 `app\Traits\HashId.php` 檔：

```php
namespace App\Traits;

use Hashids\Hashids;

trait HashId
{
    /**
     * @return string
     */
    public function encode($value)
    {
        return (new Hashids('', 10))->encode($value);
    }

    /**
     * @return array
     */
    public function decode($value)
    {
        return (new Hashids('', 10))->decode($value);
    }

    /**
     * Get the hash id for the model.
     *
     * @return string
     */
    public function getHashIdAttribute()
    {
        return $this->encode($this->attributes['id']);
    }
}
```

## 修改模型

以 `User` 模型為例：

```php
namespace App;

use App\Traits\HashId; // 調用特徵機制
use Illuminate\Notifications\Notifiable;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    use HashId; // 使用特徵機制
    use Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'name', 'email', 'password',
    ];

    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        'password', 'remember_token',
    ];

    /**
     * The accessors to append to the model's array form.
     *
     * @var array
     */
    protected $appends = [
        'hash_id', // 添加屬性
    ];
}
```

## 修改路由服務提供者

以 `users` 路由為例：

```php
namespace App\Providers;

use App\Traits\HashId; // 調用特徵機制
use Illuminate\Support\Facades\Route;
use Illuminate\Foundation\Support\Providers\RouteServiceProvider as ServiceProvider;

class RouteServiceProvider extends ServiceProvider
{
    use HashId; // 使用特徵機制

    /**
     * Define your route model bindings, pattern filters, etc.
     *
     * @return void
     */
    public function boot()
    {
        //

        parent::boot();

        // 修改路由綁定
        Route::bind('user', function ($value) {
            return \App\User::findOrFail(collect($this->decode($value))->first());
        });
    }
}
```

## 使用

```php
User::find(1)->toArray();
```

## 參考資料

- [Use Hashids as an alternative.](https://blog.albert-chen.com/use-hashids-as-an-alternative/)
