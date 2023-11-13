---
title: 在 Laravel 5.7 使用 Laravel-Scout 全文檢索
date: 2019-02-17 09:39:34
tags: ["Programming", "PHP", "Laravel", "Full-Text Search", "Scout", "Algolia"]
categories: ["Programming", "PHP", "Laravel"]
---

## 環境

- Laradock

## 建立專案

至 Algolia 註冊帳號，並建立專案。

```bash
laravel new scout
```

## 步驟

安裝 `laravel/scout` 套件。

```bash
composer require laravel/scout
```

發布資源。

```bash
php artisan vendor:publish --provider="Laravel\Scout\ScoutServiceProvider"
```

安裝驅動套件。

```bash
composer require algolia/algoliasearch-client-php
```

修改 `.env` 檔。

```env
SCOUT_QUEUE＝true
ALGOLIA_APP_ID=<Application ID>
ALGOLIA_SECRET=<Admin API Key>
```

在模型使用 `Searchable` 特徵機制。

```php
namespace App;

use Laravel\Scout\Searchable;
use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    use Searchable;
}
```

可以在模型中使用 `shouldBeSearchable()` 方法，決定是否將資料加入至檢索索引。

```php
/**
 * Determine if the model should be searchable.
 *
 * @return bool
 */
public function shouldBeSearchable()
{
    return $this->isPublished();
}
```

一次導入模型的所有資料至檢索索引。

```bash
php artisan scout:import "App\Project"
```

新增一筆資料至檢索索引。

```php
$project = $user->projects()->create($request->all());
```

使用全文檢索。

```php
$projects = App\Project::search('Test Project')->get();
```
