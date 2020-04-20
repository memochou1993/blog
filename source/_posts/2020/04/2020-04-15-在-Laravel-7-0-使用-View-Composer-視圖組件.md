---
title: 在 Laravel 7.0 使用 View Composer 視圖組件
permalink: 在-Laravel-7-0-使用-View-Composer-視圖組件
date: 2020-04-15 14:44:27
tags: ["程式設計", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 做法

以 `User` 模型為例，在 `app\Http\ViewComposers\` 資料夾新增一個 `UserComposer.php` 檔：

```PHP
namespace App\Http\ViewComposers;

use App\User;
use Illuminate\View\View;

class UserComposer
{
    /**
     * The user model.
     *
     * @var User
     */
    protected $user;

    /**
     * Create a new user composer.
     *
     * @param  User  $user
     * @return void
     */
    public function __construct(User $user)
    {
        $this->user = $user;
    }

    /**
     * Bind data to the view.
     *
     * @param  View  $view
     * @return void
     */
    public function compose(View $view)
    {
        $view->with('count', $this->user->count());
    }
}
```

在 `app\Providers` 資料夾新增一個 `app\Providers\ComposerServiceProvider.php` 服務提供者：

```PHP
namespace App\Providers;

use Illuminate\Support\Facades\View;
use Illuminate\Support\ServiceProvider;

class ComposerServiceProvider extends ServiceProvider
{
    /**
     * Register bindings in the container.
     *
     * @return void
     */
    public function boot()
    {
        View::composer(
            ['layouts.app'],
            \App\Http\ViewComposers\UserComposer::class
        );
    }

    /**
     * Register the service provider.
     *
     * @return void
     */
    public function register()
    {
        //
    }
}
```

在 `composer()` 方法的第 1 個參數，可以使用「`*`」萬用字元將資料傳遞給所有視圖。

```PHP
View::composer(
    '*', \App\Http\ViewComposers\UserComposer::class
);
```

將服務提供者註冊到 `config\app.php` 檔：

```PHP
return [

    'providers' => [

        \\ ...
        App\Providers\ComposerServiceProvider::class,

    ],

];
```

在視圖中使用變數：

```HTML
<div>{{ count }}</div>
```

## 參考資料

- [Laravel Views](https://laravel.com/docs/master/views)
