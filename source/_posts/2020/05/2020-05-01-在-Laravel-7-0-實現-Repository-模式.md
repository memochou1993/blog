---
title: 在 Laravel 7.0 實現 Repository 模式
date: 2020-05-01 19:07:35
tags: ["Programming", "PHP", "Laravel"]
categories: ["Programming", "PHP", "Laravel"]
---

## 建立專案

建立專案。

```bash
laravel new laravel-abstract-repository-example
```

## 資料庫

使用 SQLite 資料庫，在 `database` 資料夾新增 `database.sqlite` 檔，修改 `.env` 檔如下：

```env
DB_CONNECTION=sqlite
DB_HOST=127.0.0.1
DB_PORT=3306
# DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=
```

## 資料夾結構

資料夾結構如下：

```bash
|- app/
  |- Repositories/
    |- Contracts/
      |- RepositoryInterface.php # 共用方法的介面
      |- UserRepositoryInterface.php # 專用方法的介面
    |- Repository.php # 共用方法
    |- UserRepository.php # 專用方法
```

## 介面

在 `app/Repositories/Contracts` 資料夾新增一個 `RepositoryInterface.php` 介面，規定所有模型共用的資料庫存取方法。

```php
namespace App\Repositories\Contracts;

use Illuminate\Database\Eloquent\Model;

interface RepositoryInterface
{
    public function getById(int $id): Model;
}
```

在 `app/Repositories/Contracts` 資料夾新增一個 `UserRepositoryInterface.php` 介面，規定 `User` 模型專屬的資料庫存取方法。

```php
namespace App\Repositories\Contracts;

use Illuminate\Database\Eloquent\Model;

interface UserRepositoryInterface
{
    public function getById(int $id): Model;
    public function getByEmail(string $email): Model;
}
```

## 實作

在 `app/Repositories` 資料夾新增一個 `Repository` 抽象類別，實作 `RepositoryInterface` 介面：

```php
namespace App\Repositories;

use App\Repositories\Contracts\RepositoryInterface;
use Illuminate\Database\Eloquent\Model;

abstract class Repository implements RepositoryInterface
{
    /**
     * @var Model
     */
    protected Model $model;

    /**
     * @return string
     */
    abstract public function model(): string;

    /**
     * Instantiate a new repository instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->model = app($this->model());
    }

    /**
     * @param  int  $id
     * @return Model
     */
    public function getById(int $id): Model
    {
        return $this->model->findOrFail($id);
    }
}
```

在 `app/Repositories` 資料夾新增一個 `UserRepository` 具象類別，擴展 `Repository` 抽象類別，並實作 `UserRepositoryInterface` 介面：

```php
namespace App\Repositories;

use App\User;
use App\Repositories\Contracts\UserRepositoryInterface;
use Illuminate\Database\Eloquent\Model;

class UserRepository extends Repository implements UserRepositoryInterface
{
    /**
     * @return string
     */
    public function model(): string
    {
        return User::class;
    }

    /**
     * @param  string  $email
     * @return Model
     */
    public function getByEmail(string $email): Model
    {
        return $this->model->where('email', $email)->firstOrFail();
    }
}
```

## 服務提供者

新增一個 `RepositoryServiceProvider` 服務提供者。

```bash
php artisan make:provider RepositoryServiceProvider
```

在服務提供者註冊容器綁定，並且實作 `DeferrableProvider` 介面延遲加載：

```php
namespace App\Providers;

use App\Repositories\Contracts\UserRepositoryInterface;
use App\Repositories\UserRepository;
use Illuminate\Contracts\Support\DeferrableProvider;
use Illuminate\Support\ServiceProvider;

class RepositoryServiceProvider extends ServiceProvider implements DeferrableProvider
{
    /**
     * Register services.
     *
     * @return void
     */
    public function register()
    {
        $this->app->bind(
            UserRepositoryInterface::class,
            UserRepository::class
        );
    }

    /**
     * Bootstrap services.
     *
     * @return void
     */
    public function boot()
    {
        //
    }

    /**
     * Get the services provided by the provider.
     *
     * @return array
     */
    public function provides()
    {
        return [
            UserRepositoryInterface::class,
        ];
    }
}
```

- 由於此服務提供者只有做容器綁定的註冊，因此可以延遲載入，以提升系統效能。Laravel 會在綁定的服務被解析時，到 `bootstrap/cache/services.php` 檔中加載對應的服務提供者。

將服務提供者註冊到 `config` 資料夾的 `app.php` 中：

```php
return [

    'providers' => [

        // ...
        App\Providers\RepositoryServiceProvider::class,

    ],

];
```

重新產生 Composer 自動載入檔案。

```bash
composer dump-autoload
```

## 路由

修改 `routes` 資料夾的 `web.php` 檔：

```php
Route::get('/id/{id}', 'UserController@getById');
Route::get('/email/{email}', 'UserController@getByEmail');
```

## 控制器

新增一個 `UserController` 控制器。

```bash
php artisan make:controller UserController
```

修改控制器，將 `UserRepositoryInterface` 介面注入到建構子中，並實作相關方法：

```php
namespace App\Http\Controllers;

use App\Repositories\Contracts\UserRepositoryInterface;
use App\User;

class UserController extends Controller
{
    private $repository;

    public function __construct(UserRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function getById($id): User
    {
        return $this->repository->getById($id);
    }

    public function getByEmail($email): User
    {
        return $this->repository->getByEmail($email);
    }
}
```

## 測試

新增一個 `UserControllerTest` 測試案例。

```bash
php artisan make:test UserControllerTest
```

修改測試案例。

```php
namespace Tests\Feature;

use App\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class UserControllerTest extends TestCase
{
    use RefreshDatabase;

    /**
     * @return void
     */
    public function testGetById()
    {
        $user = factory(User::class)->create();

        $response = $this->get('/id/'.$user->id);

        $response
            ->assertStatus(200)
            ->assertJson($user->toArray());
    }

    /**
     * @return void
     */
    public function testGetByEmail()
    {
        $user = factory(User::class)->create();

        $response = $this->get('/email/'.$user->email);

        $response->assertStatus(200)
            ->assertJson($user->toArray());
    }
}
```

執行測試。

```php
phpunit
OK
```

## 程式碼

- [laravel-abstract-repository-example](https://github.com/memochou1993/laravel-abstract-repository-example)
