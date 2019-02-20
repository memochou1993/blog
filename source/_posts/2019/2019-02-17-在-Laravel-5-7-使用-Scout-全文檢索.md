---
title: 在 Laravel 5.7 使用 Scout 全文檢索
permalink: 在-Laravel-5-7-使用-Scout-全文檢索
date: 2019-02-17 09:39:34
tags: ["程式寫作", "PHP", "Laravel", "全文檢索", "Scout"]
categories: ["程式寫作", "PHP", "Laravel"]
---

## 環境
- Laradock

## 建立專案
```
$ laravel new scout
```

## 步驟
安裝 `laravel/scout` 套件。
```
$ composer require laravel/scout
```

發布資源。
```
$ php artisan vendor:publish --provider="Laravel\Scout\ScoutServiceProvider"
```

在模型使用 `Searchable` 特徵機制。
```PHP
namespace App;

use Laravel\Scout\Searchable;
use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    use Searchable;
}
```

安裝驅動套件。
```
$ composer require algolia/algoliasearch-client-php
```

修改 `config/scout.php` 檔。
```
SCOUT_QUEUE＝true
ALGOLIA_APP_ID=<Application ID>
ALGOLIA_SECRET=<Admin API Key>
```

導入模型至 Algolia 檢索索引。
```
$ php artisan scout:import "App\User"
```

使用全文檢索。
```PHP
$users = App\User::search('John')->get();
```
