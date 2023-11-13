---
title: 在 Laravel 5.6 使用 PHPUnit 進行單元測試（一）
date: 2018-05-08 10:20:33
tags: ["Programming", "PHP", "Laravel", "Testing", "PHPUnit"]
categories: ["Programming", "PHP", "Laravel"]
---

## 前言

本文為參考《[Laravel 5 中的 TDD 觀念與實戰](https://jaceju-books.gitbooks.io/tdd-in-laravel-5)》一書的學習筆記。

## 環境

- Windows 10
- Homestead 7.4.1

## 建立專案

建立專案。

```bash
laravel new post
```

## 編輯 TestCase.php 檔

設定 `initDatabase()` 方法以初始化資料庫。

```php
protected function initDatabase()
{
    // 使用 sqlite 作為測試資料庫
    config([
        'database.default' => 'sqlite',
        'database.connections.sqlite' => [
            'driver'    => 'sqlite',
            'database'  => ':memory:',
            'prefix'    => '',
        ],
    ]);
    // 呼叫 migrate 進行遷移
    Artisan::call('migrate');
    // 呼叫 db:seed 進行填充
    Artisan::call('db:seed');
}
```

設定 `resetDatabase()` 方法以重置資料庫。

```php
protected function resetDatabase()
{
    // 呼叫 migrate:reset 重置遷移和填充
    Artisan::call('migrate:reset');
}
```

## 測試模型

新增 `Post` 模型和 `create_posts_table` 遷移。

```bash
php artisan make:model Post -m
```

配置可寫入欄位。

```php
protected $fillable = ['title', 'content'],
```

新增 `tests\Feature\PostTest.php` 測試類別。

```
// 調用 Post 模型
use App\Post;
```

設定 `setUp()` 方法以開始測試。

```php
public function setUp()
{
    // 在測試類定義自己的方法，需要調用 setUp() 方法
    parent::setUp();
    // 初始化資料庫
    $this->initDatabase();
}
```

新增 `testEmptyResult()` 方法以測試文章為空。

```php
public function testEmptyResult()
{
    // 取得所有文章
    $posts = Post::get();
    // 確認 posts 是 Collection 實例
    $this->assertInstanceOf('Illuminate\Database\Eloquent\Collection', $posts);
    // 確認文章數是 0
    $this->assertEquals(0, $posts->count());
}
```

新增 `testCreateAndList()` 以測試新增文章。

```php
public function testCreateAndList()
{
    // 新增 10 筆文章
    for ($i = 1; $i <= 10; $i ++) {
        Post::create([
            'title' => 'title ' . $i,
            'content'  => 'content ' . $i,
        ]);
    }
    // 取得所有文章
    $posts = Post::all();
    // 確認文章數是 10 筆
    $this->assertEquals(10, $posts->count());
}
```

設定 `tearDown()` 方法以結束測試。

```php
public function tearDown()
{
    // 重置資料庫
    $this->resetDatabase();
}
```

執行測試。

```bash
phpunit
```

## 程式碼

- [post](https://github.com/memochou1993/post)
