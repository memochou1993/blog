---
title: 在 Laravel 5.6 實現 Repository 模式
date: 2018-05-17 10:22:15
tags: ["Programming", "PHP", "Laravel"]
categories: ["Programming", "PHP", "Laravel"]
---

## 前言

本文參考〈[如何使用 Repository 模式](http://oomusou.io/laravel/repository/)〉與〈[深入探討 Service Provider](http://oomusou.io/laravel/laravel-service-provider/)〉二文，試圖將資料庫邏輯寫在資源庫（Repository），並將其依賴注入到服務容器（Service Container）。

## 環境

- Windows 10
- Homestead 7.4.1

## 建立專案

```bash
laravel new package
```

## 新增遷移

```bash
php artisan make:migration create_packages_table
```

```php
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreatePackagesTable extends Migration
{
    public function up()
    {
        Schema::create('packages', function (Blueprint $table) {
            $table->increments('id');
            $table->string('name');
            $table->string('login');
            $table->text('description');
            $table->integer('watchers_count');
            $table->integer('forks_count');
            $table->integer('subscribers_count');
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('packages');
    }
}
```

## 新增填充

```bash
php artisan make:seed PackagesTableSeeder
```

```php
use Illuminate\Database\Seeder;

class PackagesTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        factory(App\Package::class, 20)->create();
    }
}
```

```bash
php artisan make:factory PackageFactory
```

```php
use Faker\Generator as Faker;

$factory->define(App\Package::class, function (Faker $faker) {
    return [
        'name' => $faker->safeColorName,
        'login' => $faker->userName,
        'description' => $faker->text($maxNbChars = 200),
        'watchers_count' => $faker->numberBetween($min = 100, $max = 10000),
        'forks_count' => $faker->numberBetween($min = 100, $max = 10000),
        'subscribers_count' => $faker->numberBetween($min = 100, $max = 10000),
    ];
});
```

執行遷移

```bash
php artisan migrate --seed
```

## 新增模型

```bash
php artisan make:model Package
```

```php
namespace App;

use Illuminate\Database\Eloquent\Model;

class Package extends Model
{
    protected $fillable = [
        'name',
        'login',
        'description',
    ];
}
```

## 新增介面

手動新增 `app\Contracts\PackageInterface.php` 檔。

```php
namespace App\Contracts;

interface PackageInterface
{
    public function getAllPackages();
}
```

## 新增資源庫

手動新增 `app\Repositories\PackageRepository.php` 檔。

```php
namespace App\Repositories;

use App\Contracts\PackageInterface;
use App\Package;

// 實作 PackageInterface 介面
class PackageRepository implements PackageInterface
{
    // 透過隱式綁定取得的 Package 模型實例
    protected $package;

    public function __construct(Package $package)
    {
        $this->package = $package;
    }

    public function getAllPackages()
    {
        return $this->package->all(); // 資料庫邏輯
    }
}
```

## 新增控制器

```bash
php artisan make:controller PackageController
```

```php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Contracts\PackageInterface;

class PackageController extends Controller
{
    protected $package; // 實作 PackageInterface 介面的物件

    public function __construct(PackageInterface $package)
    {
        $this->package = $package;
    }

    public function index()
    {
        $packages = $this->package->getAllPackages();

        dd($packages);
    }
}
```

## 新增服務提供者

手動新增 `app\Providers\RepositoryServiceProvider.php` 檔。

```php
namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use App\Contracts\PackageInterface;
use App\Repositories\PackageRepository;

class RepositoryServiceProvider extends ServiceProvider
{
    protected $defer = true; // 延遲註冊

    public function boot()
    {
        //
    }

    public function register()
    {
        // 訪問容器並註冊綁定
        $this->app->bind(
            PackageInterface::class,
            PackageRepository::class
        );
    }

    public function provides()
    {
        // 回傳要處理的介面名稱
        return [
            PackageInterface::class
        ];
    }
}
```

## 註冊服務提供者

在 `config\app.php` 檔註冊服務提供者。

```php
'providers' => [
    // ...
    App\Providers\RepositoryServiceProvider::class,
]
```

## 重啟服務

```bash
php artisan clear-compiled
php artisan serve
```

## 程式碼

- [laravel-repository-example](https://github.com/memochou1993/laravel-repository-example)
