---
title: 在 Laravel 5.7 使用 Hashids 做為資源唯一辨識碼
permalink: 在-Laravel-5-7-使用-Hashids-做為資源唯一辨識碼
date: 2018-12-03 21:05:54
tags: ["程式寫作", "PHP", "Laravel"]
categories: ["程式寫作", "PHP", "Laravel"]
---

## 環境

- Windows 10
- Homestead

## 安裝套件

使用 [hashids/hashids
](https://hashids.org/) 套件，或使用提供 Laravel 使用的 `vinkla/hashids` 套件。

```CMD
composer require vinkla/hashids
```

發布資源。

```CMD
php artisan vendor:publish
```

## 修改設定

修改 `config\hashids.php` 檔：

```PHP
return [

    /*
    |--------------------------------------------------------------------------
    | Default Connection Name
    |--------------------------------------------------------------------------
    |
    | Here you may specify which of the connections below you wish to use as
    | your default connection for all work. Of course, you may use many
    | connections at once using the manager class.
    |
    */

    'default' => 'main',

    /*
    |--------------------------------------------------------------------------
    | Hashids Connections
    |--------------------------------------------------------------------------
    |
    | Here are each of the connections setup for your application. Example
    | configuration has been included, but you may add as many connections as
    | you would like.
    |
    */

    'connections' => [

        'main' => [
            'salt' => env('APP_KEY', 'Laravel'),
            'length' => 5,
        ],

    ],

];
```

## 建立特徵機制

建立 `app\Traits\HashId.php` 檔：

```PHP
namespace App\Traits;

use Hashids;

trait HashId
{
    /**
     * Get the Hash Id for the user.
     *
     * @return bool
     */
    public function getHashIdAttribute()
    {
        return Hashids::encode($this->attributes['id']);
    }
}
```

## 修改模型

以 `User` 模型為例：

```PHP
namespace App;

use App\Traits\HashId; // 調用特徵機制
use Illuminate\Notifications\Notifiable;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    use Notifiable;
    use HashId; // 使用特徵機制

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
    protected $appends = ['hash_id']; // 添加屬性
}
```

## 使用

```PHP
User::find(1)->toArray();
```

## 參考資料

[Use Hashids as an alternative.](https://blog.albert-chen.com/use-hashids-as-an-alternative/)
