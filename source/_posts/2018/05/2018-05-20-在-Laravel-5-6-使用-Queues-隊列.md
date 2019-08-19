---
title: 在 Laravel 5.6 使用 Queues 隊列
permalink: 在-Laravel-5-6-使用-Queues-隊列
date: 2018-05-20 10:24:13
tags: ["程式寫作", "PHP", "Laravel"]
categories: ["程式寫作", "PHP", "Laravel"]
---

## 環境

- Windows 10
- Homestead 7.4.1

## 安裝套件

```BASH
composer require predis/predis
```

## 建立工作

設定一個可以儲存包裹的工作。

```BASH
php artisan make:job StorePackage
```

## 設定工作

新增 `App\Jobs\StorePackage.php` 檔並建立工作：

```PHP
namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Queue\SerializesModels;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use App\Package;

class StorePackage implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct()
    {
        //
    }

    public function handle()
    {
        $package = New Package;
        $package->name = 'Test Package';
        $package->save();
    }
}
```

## 推入隊列

在 `PackageController` 的 `index()` 方法內推入隊列。

```PHP
public function index()
{
    dispatch(New \App\Jobs\StorePackage);
}
```

## 隊列工人

讓隊列工人從隊列拉出工作並執行它們。

```BASH
php artisan queue:work --timeout=10 --sleep=10 --tries=3
```

- `--timeout` 代表停止它前，可以執行的秒數。
- `--sleep` 代表沒有在工作時，應休眠的秒數。
- `--tries` 代表過程出錯時，最多嘗試的次數。
