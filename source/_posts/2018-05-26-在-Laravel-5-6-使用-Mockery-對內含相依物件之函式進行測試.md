---
title: 在 Laravel 5.6 使用 Mockery 對內含相依物件之函式進行測試
date: 2018-05-26 10:25:37
tags: ["程式寫作", "PHP", "Laravel"]
---

## 前言
本文參考〈[如何測試內含相依物件的函式](http://oomusou.io/tdd/tdd-isolated-test/)〉一文，對先前〈在 Laravel 5.6 使用 Repository 與 Service Container〉一文之實作進行測試。

## 環境
- Windows 10
- Homestead 7.4.1

## 新增資源庫
在資源庫新增一個 `getAllPackages()` 方法，以取得資料庫的所有 Packages。
```PHP
namespace App\Repositories;

use App\Contracts\PackageInterface;
use App\Package;

class PackageRepository implements PackageInterface
{
    protected $package;

    public function __construct(Package $package)
    {
        $this->package = $package;
    }

    public function getAllPackages()
    {
        $packages = $this->package->all();

        return $packages;
    }
}
```

## 新增控制器
在 `PackageController` 新增 `getAllPackages()` 方法。
```PHP
namespace App\Http\Controllers;

use App\Contracts\PackageInterface;

class PackageController extends Controller
{
    protected $package;

    public function __construct(PackageInterface $package)
    {
        $this->package = $package;
    }

    public function index()
    {
        $packages = $this->package->getAllPackages();

        return view('package.index', compact('packages'));
    }
}
```

## 測試
編輯 `tests\TestCase.php` 檔。
```PHP
namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use Mockery;

abstract class TestCase extends BaseTestCase
{
    use CreatesApplication;

    public function initMock($class)
    {
        // 使用 `Mockery::mock()` 去 mock 該 class 或 interface
        $mock = Mockery::mock($class);

        // `$this->app->instance()` 是告訴 Laravel 的 Service container，當 Type hint 為該 class 時，使用指定的物件
        $this->app->instance($class, $mock);

        return $mock;
    }
}
```
在 `tests\Feature` 新增 `PackageControllerTest.php` 檔。
```PHP
namespace Tests\Feature;

use Tests\TestCase;
use App\Contracts\PackageInterface;
use App\Http\Controllers\PackageController;
use Illuminate\Database\Eloquent\Collection;
use Mockery;

class PackageControllerTest extends TestCase
{
    // 放待測物件
    protected $mock;

    // 放 mock 物件
    protected $target;

    public function setUp()
    {
        parent::setUp();

        // 將 `PackageInterface::class` 傳入建立好的 `initMock()`
        $this->mock = $this->initMock(PackageInterface::class);
        
        // 使用 Service container 的 `$this->app->make()` 建立 `PackageController` 物件
        $this->target = $this->app->make(PackageController::class);
    }

    public function testIndex()
    {
        // 使用 `new Collection()` 建立 3 筆假資料
        $expected = new Collection([
            ['name' => 'Name 1', 'html_url' => 'HTML URL 1'],
            ['name' => 'Name 2', 'html_url' => 'HTML URL 2'],
            ['name' => 'Name 3', 'html_url' => 'HTML URL 3'],
        ]);

        // 使用 `Mockery` 的 `shouldReceive()` 來 mock `PackageInterface` 的 `getAllPackages()` 方法
        $this->mock
            ->shouldReceive('getAllPackages')
            ->once()
            ->andReturn($expected);

        // 實際執行 `PackageController` 的 `index()` 方法，並取得 `packages` 集合
        $actual = $this->target->index()->packages;

        // 斷言假資料和 mock 的集合是否相同
        $this->assertEquals($expected, $actual);
    }

    public function tearDown()
    {
        // 把 `$mock` 和 `$target` 設為 `null` 避免干擾下次測試。
        $this->mock = null;
        $this->target = null;
    }
}
```

## 單元測試的 3A 原則
### Arrange
準備測試資料 `$fake`、`mock` 物件 `$mock`、待測物件 `$target`，與建立測試期望值 `$expected`。

### Act
執行待測物件的 `method`，與建立實際結果值 `$actual`。

### Assert
使用 PHPUnit 的斷言函式測試 `$expected` 與 `$actual` 是否如預期。
