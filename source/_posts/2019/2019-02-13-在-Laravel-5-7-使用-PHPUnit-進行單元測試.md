---
title: 在 Laravel 5.7 使用 PHPUnit 進行單元測試
permalink: 在 Laravel 5.7 使用 PHPUnit 進行單元測試
date: 2019-02-13 20:53:17
tags: ["程式寫作", "PHP", "Laravel", "PHPUnit"]
categories: ["程式寫作", "PHP", "Laravel"]
---

## 做法
新增測試。
```
$ php artisan make:test UserTest
```

修改 `phpunit.xml` 檔，使用 SQLite 作為測試環境的資料庫。
```XML
<php>
    <env name="APP_ENV" value="testing"/>
    <env name="BCRYPT_ROUNDS" value="4"/>
    <env name="CACHE_DRIVER" value="array"/>
    <env name="MAIL_DRIVER" value="array"/>
    <env name="QUEUE_CONNECTION" value="sync"/>
    <env name="SESSION_DRIVER" value="array"/>
    <env name="DB_CONNECTION" value="sqlite"/>
    <env name="DB_DATABASE" value=":memory:"/>
</php>
```

修改 `tests/TestCase.php` 檔：
```PHP
namespace Tests;

use Illuminate\Support\Facades\Artisan;
use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    use CreatesApplication;
    
    protected function setUp()
    {
        parent::setUp();
        
        Artisan::call('migrate');
        Artisan::call('db:seed');
    }

    protected function tearDown()
    {
        parent::tearDown();
    }

}
```

執行測試。
```
$ phpunit
```
