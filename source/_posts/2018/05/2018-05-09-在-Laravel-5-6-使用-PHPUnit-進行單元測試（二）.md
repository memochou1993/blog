---
title: 在 Laravel 5.6 使用 PHPUnit 進行單元測試（二）
permalink: 在-Laravel-5-6-使用-PHPUnit-進行單元測試（二）
date: 2018-05-09 10:20:40
tags: ["程式設計", "PHP", "Laravel", "測試", "PHPUnit"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 前言

本文為參考《[Laravel 5 中的 TDD 觀念與實戰](https://jaceju-books.gitbooks.io/tdd-in-laravel-5)》一書的學習筆記。

## 環境

- Windows 10
- Homestead 7.4.1

## 測試資源庫

新增 `app/Repositories/PostRepository.php` 檔。

```PHP
namespace App\Repositories;

use App\Post;

class PostRepository
{
    //
}
```

建立 `tests/ArticleRepositoryTest.php` 測試類別。

```PHP
use App\Post; // 調用 Post 模型
```

設定 `setUp()` 方法以開始測試。

```PHP
protected $repository = null;

public function setUp()
{
    parent::setUp();

    $this->initDatabase();

    $this->seedData();

    $this->repository = new PostRepository(); // 建立要測試用的資源庫實例
}
```

新增 `seedData()` 方法以產生 100 筆假文章。

```PHP
protected function seedData()
{
    // 新增 100 筆假文章
    for ($i = 1; $i <= 100; $i ++) {
        Post::create([
            'title' => 'title ' . $i,
            'content'  => 'content ' . $i,
        ]);
    }
}
```

新增 `testFetchLatestPost()` 方法以測試取得最新 1 筆文章。

```PHP
public function testFetchLatestPost()
{
    // 使用 PostRepository 的 latestPost() 方法
    $posts = $this->repository->latestPost();

    // 確認文章數是 1 筆
    $this->assertEquals(1, count($posts));

    // 確認文章標題從 100 開始倒數
    $i = 100;
    foreach ($posts as $post) {
        $this->assertEquals('title ' . $i, $post->title);
        $i -= 1;
    }
}
```

設定 `tearDown()` 方法以結束測試。

```PHP
public function tearDown()
{
    // 重置資料庫
    $this->resetDatabase();

    // 設為 null 避免影響下次測試
    $this->repository = null;
}
```

執行測試。

```BASH
phpunit # 失敗
```

回到 `PostRepository` 增加 `latestPost()` 方法。

```PHP
public function latestPost()
{
    return Post::query()->orderBy('id', 'desc')->limit(1)->get();
}
```

執行測試。

```BASH
phpunit # 成功
```

新增 `testCreatePost()` 方法以測試新增文章。

```PHP
public function testCreatePost()
{
    $postCount = $this->repository->postCount();

    $latestId = $postCount + 1;

    $post = $this->repository->create([
        'title' => 'title ' . $latestId,
        'content'  => 'content ' . $latestId,
    ]);

    $this->assertEquals($postCount + 1, $post->id);
}
```

執行測試。

```BASH
phpunit # 失敗
```

回到 `PostRepository` 增加 `postCount()` 和 `create()` 方法。

```PHP
public function postCount()
{
    return Post::count();
}

public function create(array $attributes)
{
    return Post::create($attributes);
}
```

執行測試。

```BASH
phpunit # 成功
```

## 程式碼

- [post](https://github.com/memochou1993/post)
