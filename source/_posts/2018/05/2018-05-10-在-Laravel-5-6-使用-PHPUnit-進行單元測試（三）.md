---
title: 在 Laravel 5.6 使用 PHPUnit 進行單元測試（三）
permalink: 在-Laravel-5-6-使用-PHPUnit-進行單元測試（三）
date: 2018-05-10 10:20:59
tags: ["程式寫作", "PHP", "Laravel", "PHPUnit"]
categories: ["程式寫作", "PHP", "Laravel"]
---

## 前言

本文為參考《[Laravel 5 中的 TDD 觀念與實戰](https://jaceju-books.gitbooks.io/tdd-in-laravel-5)》一書的學習筆記。

## 環境

- Windows 10
- Homestead 7.4.1

## 測試控制器

新增 `PostController` 和 `index` 視圖。

```CMD
php artisan make:controller PostController
$ touch resources/views/post/index.blade.php
```

在 `PostController` 加入 `index()` 方法。

```PHP
public function index()
{
    $posts = [];
    return view('post.index', compact('posts');
}
```

新增 `tests/Feature/PostControllerTest.php` 測試類別。

```PHP
public function testPostList()
{
    // 用 GET 方法瀏覽網址
    $response = $this->get('posts');

    // assertStatus 斷言指定的 HTTP 狀態
    $response->assertStatus(200);

    // assertViewHas 斷言該視圖擁有指定的綁定資料
    $response->assertViewHas('posts');
}
```

執行測試。

```CMD
phpunit // 失敗
```

## 新增路由

新增一個資源路由。

```PHP
Route::resource('posts', 'PostController');
```

執行測試。

```CMD
phpunit // 成功
```

## 注入資源庫

調用 `PostRepository` 資源庫。

```PHP
use App\Repositories\PostRepository;
```

透過建構子注入依賴。

```PHP
protected $repository;

public function __construct(PostRepository $repository)
{
    $this->repository = $repository;
}
```

修改 `index()` 方法為：

```PHP
public function index()
{
    $posts = $this->repository->latestPost();

    return view('post.index', compact('posts'));
}
```

執行測試。

```CMD
phpunit // 失敗
```

## 隔離資源庫

安裝 `Mockery` 套件。

```CMD
composer require mockery/mockery --dev
```

- 不讓控制器測試接觸資料庫。
- 利用 `Mockery` 透過資源庫生成假物件。
- 利用服務容器注入假物件取代原本應該被呼叫的物件。
- 讓假物件的方法回傳假値。

在 `PostControllerTest` 調用 `Mockery。`

```PHP
use Mockery;
```

新增 `setUp()` 方法以開始測試。

```PHP
protected $repositoryMock = null;

public function setUp()
{
    parent::setUp();

    // Mockery::mock 可以利用反射機制建立假物件
    $this->repositoryMock = Mockery::mock('App\Repositories\PostRepository');

    // 容器服務的 instance 方法可以用假物件取代原來的資源庫物件
    $this->app->instance('App\Repositories\PostRepository', $this->repositoryMock);
}
```

修改 `testPostList()` 方法為以下：

```PHP
public function testPostList()
{
    $this->repositoryMock
        ->shouldReceive('latestPost') // 為 mock 物件加入 latestPost() 方法
        ->once() // 確認程式會呼叫一次
        ->andReturn([]); // 回傳一個空陣列

    // 透過 GET 方法訪問 /posts
    $response = $this->get('/posts');

    // 斷言是否得到 HTTP 狀態 200
    $response->assertStatus(200);

    // 斷言是否得到 posts 視圖
    $response->assertViewHas('posts');
}
```

新增 `tearDown()` 方法以結束測試。

```PHP
public function tearDown()
{
    // 清除被 mock 的假物件
    Mockery::close();
}
```

執行測試。

```PHP
$ phpunit // 成功
```

新增 `testCreatePostSuccess()` 方法以測試新增文章。

```PHP
public function testCreatePostSuccess()
{
    // 會呼叫到 PostRepository::create
    $this->repositoryMock
        ->shouldReceive('create')
        ->once();

    // 模擬送出表單
    $response = $this->post('/posts', [
        'title' => 'title 999',
        'content' => 'content 999'
    ]);

    // 斷言文章新增完成是否進行跳轉
    $response->assertStatus(302);

    // 斷言文章新增完成是否導向 /posts 網址
    $response->assertRedirect('/posts');
}
```

執行測試。

```PHP
$ phpunit // 失敗
```

回到 `PostController` 新增 `store` 方法以儲存資料並導向 `/posts` 網址。

```PHP
public function store(Request $request)
{
    $this->repository->create($request->all());

    return redirect()->route('posts.index');
}
```

執行測試。

```PHP
$ phpunit //成功
```

## 程式碼

[GitHub](https://github.com/memochou1993/post)
