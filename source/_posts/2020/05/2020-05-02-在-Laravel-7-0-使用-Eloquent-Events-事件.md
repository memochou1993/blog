---
title: 在 Laravel 7.0 使用 Eloquent Events 事件
date: 2020-05-02 19:06:26
tags: ["Programming", "PHP", "Laravel", "Eloquent", "ORM"]
categories: ["Programming", "PHP", "Laravel"]
---

## 前言

Eloquent 模型有以下生命週期，透過這些鉤子（`hooks`）可以觸發自訂的 Event 事件：

- 當模型被查找時：`retrieved`
- 當模型被新增時：`creating`、`created`
- 當模型被更新時：`updating`、`updated`、`saving`、`saved`
- 當模型被刪除時：`deleting`、`deleted`
- 當模型被回復時：`restoring`、`restored`
- 當模型被複製時：`replicating`

## 服務提供者

首先，建立一個 `ObserverServiceProvider` 服務提供者。

```bash
artisan make:provider ObserverServiceProvider
```

修改服務提供者：

```php
namespace App\Providers;

use App\Observers\UserObserver;
use App\User;
use Illuminate\Support\ServiceProvider;

class ObserverServiceProvider extends ServiceProvider
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
        User::observe(UserObserver::class);
    }
}
```

將服務提供者註冊到 `config` 資料夾的 `app.php` 中：

```php
return [

    'providers' => [

        // ...
        App\Providers\ObserverServiceProvider::class,

    ],

];
```

## 觀察者

建立一個 `UserObserver` 觀察者。

```bash
php artisan make:observer UserObserver --model=User
```

修改 `UserObserver` 觀察者：

```php
namespace App\Observers;

use App\User;

class UserObserver
{
    /**
     * Handle the user "retrieved" event.
     *
     * @param  \App\User  $user
     * @return void
     */
    public function retrieved(User $user)
    {
        dump('user retrieved!');
    }

    /**
     * Handle the user "created" event.
     *
     * @param  \App\User  $user
     * @return void
     */
    public function created(User $user)
    {
        dump('user created!');
    }

    /**
     * Handle the user "updated" event.
     *
     * @param  \App\User  $user
     * @return void
     */
    public function updated(User $user)
    {
        dump('user updated!');
    }

    /**
     * Handle the user "deleted" event.
     *
     * @param  \App\User  $user
     * @return void
     */
    public function deleted(User $user)
    {
        dump('user deleted!');
    }
}
```

## 觸發事件

使用 Tinker 介面進行測試。

```bash
php artisan tinker
```

新增模型。

```bash
User::create(['email'=>'admin@email.com', 'name'=>'admin', 'password'=>'password'])
"user created!"
```

查找模型。

```bash
User::find(1)
"user retrieved!"
```

更新模型。

```bash
User::find(1)->update(['name'=>'user'])
"user retrieved!"
"user updated!"
```

刪除模型。

```bash
User::find(1)->delete()
"user retrieved!"
"user deleted!"
```

## 程式碼

- [eloquent-events-example](https://github.com/memochou1993/eloquent-events-example)

## 參考資料

- [Laravel Eloquent Events](https://laravel.com/docs/master/eloquent#events)
