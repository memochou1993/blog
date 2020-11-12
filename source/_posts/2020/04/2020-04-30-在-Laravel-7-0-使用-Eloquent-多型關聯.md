---
title: 在 Laravel 7.0 使用 Eloquent 多型關聯
permalink: 在-Laravel-7-0-使用-Eloquent-多型關聯
date: 2020-04-30 22:42:02
tags: ["程式設計", "PHP", "Laravel", "Eloquent", "ORM"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 前言

Laravel 官方文件為多型資料表的外鍵使用了特殊的命名規則，例如 `imageable`、`commentable`，和 `taggable` 等，這樣的命名方式不是很自然，並且需要在 Model 中定義資料表的名稱，因為 Laravel 並不知道這些詞彙的複數型態為何。

以下參考 [spatie/laravel-permission](https://github.com/spatie/laravel-permission) 套件的命名方式，使用 `model` 作為多型資料表的外鍵名稱，並使用例如 `model_has_tags` 來為多型資料表命名。

## 一對一多型關聯

假設一個網站的頁面（page）和文章（post）各自擁有一張圖片（image），可以利用一對一多型關聯（one-to-one polymorphic relation）將圖片儲存在共用的資料表。

### 關聯架構

```BASH
pages
  id - integer
  name - string

posts
  id - integer
  name - string

images
  id - integer
  model_id - integer
  model_type - string
```

### 模型、遷移檔與模型工廠

新增 `Page` 模型，與其遷移檔、模型工廠。

```BASH
php artisan make:model Page -m -f
```

新增 `Post` 模型，與其遷移檔、模型工廠。

```BASH
php artisan make:model Post -m -f
```

新增 `Image` 模型，與其遷移檔、模型工廠。

```BASH
php artisan make:model Image -m -f
```

### 遷移檔

修改 `create_images_table.php` 遷移檔：

```PHP
Schema::create('images', function (Blueprint $table) {
    $table->id();
    $table->morphs('model');
    $table->timestamps();
});
```

執行遷移。

```BASH
php artisan migrate
```

### 關聯方法

修改 `Page` 模型，定義關聯方法：

```PHP
/**
 * Get the page's image.
 */
public function image()
{
    return $this->morphOne(Image::class, 'model');
}
```

修改 `Post` 模型，定義關聯方法：

```PHP
/**
 * Get the post's image.
 */
public function image()
{
    return $this->morphOne(Image::class, 'model');
}
```

修改 `Image` 模型，定義關聯方法：

```PHP
/**
 * Get the owning model.
 */
public function model()
{
    return $this->morphTo();
}
```

### 測試資料

進入 Tinker 介面。

```BASH
php artisan tinker
```

新增一些測試資料：

```BASH
factory(App\Page::class)->create();
factory(App\Post::class)->create();
```

### 使用

為第一個頁面新增一張圖片：

```PHP
Page::first()->image()->save(factory(App\Image::class)->make());
```

為第一個頁面取得所有圖片：

```PHP
Page::first()->image()->get();
```

為第一篇文章新增一張圖片：

```PHP
Post::first()->image()->save(factory(App\Image::class)->make());
```

為第一篇文章取得所有圖片：

```PHP
Post::first()->image()->get();
```

取得擁有第一張圖片的模型：

```PHP
Image::first()->model()->get();
```

## 一對多多型關聯

假設一個網站的頁面（page）和文章（post）各自擁有多個評論（comment），可以利用一對多多型關聯（one-to-many polymorphic relation）將評論儲存在共用的資料表。

### 關聯架構

```BASH
pages
  id - integer
  name - string

posts
  id - integer
  name - string

comments
  id - integer
  model_id - integer
  model_type - string
```

### 模型、遷移檔與模型工廠

新增 `Page` 模型，與其遷移檔、模型工廠。

```BASH
php artisan make:model Page -m -f
```

新增 `Post` 模型，與其遷移檔、模型工廠。

```BASH
php artisan make:model Post -m -f
```

新增 `Comment` 模型，與其遷移檔、模型工廠。

```BASH
php artisan make:model Comment -m -f
```

### 遷移檔

修改 `create_comments_table.php` 遷移檔：

```PHP
Schema::create('comments', function (Blueprint $table) {
    $table->id();
    $table->morphs('model');
    $table->timestamps();
});
```

執行遷移。

```BASH
php artisan migrate
```

### 關聯方法

修改 `Page` 模型，定義關聯方法：

```PHP
/**
 * Get all of the page's comments.
 */
public function comments()
{
    return $this->morphMany(Comment::class, 'model');
}
```

修改 `Post` 模型，定義關聯方法：

```PHP
/**
 * Get all of the post's comments.
 */
public function comments()
{
    return $this->morphMany(Comment::class, 'model');
}
```

修改 `Image` 模型，定義關聯方法：

```PHP
/**
 * Get the owning model.
 */
public function model()
{
    return $this->morphTo();
}
```

### 測試資料

進入 Tinker 介面。

```BASH
php artisan tinker
```

新增一些測試資料：

```BASH
factory(App\Page::class)->create();
factory(App\Post::class)->create();
```

### 使用

為第一個頁面新增兩則評論：

```PHP
Page::first()->comments()->saveMany(factory(App\Comment::class, 2)->make());
```

為第一個頁面取得所有評論：

```PHP
Page::first()->comments()->get();
```

為第一篇文章新增兩則評論：

```PHP
Post::first()->comments()->saveMany(factory(App\Comment::class, 2)->make());
```

為第一篇文章取得所有評論：

```PHP
Post::first()->comments()->get();
```

取得擁有第一則評論的模型：

```PHP
Comment::first()->model()->get();
```

## 多對多多型關聯

假設一個網站的頁面（page）和文章（post）共用多個標籤（tag），可以利用多對多多型關聯（many-to-many polymorphic relation）將標籤儲存在共用的資料表。

### 關聯架構

```BASH
pages
  id - integer
  name - string

posts
  id - integer
  name - string

tags
  id - integer
  name - string

model_has_tags
  tag_id - integer
  model_id - integer
  model_type - string
```

### 模型、遷移檔與模型工廠

新增 `Page` 模型，與其遷移檔、模型工廠。

```BASH
php artisan make:model Page -m -f
```

新增 `Post` 模型，與其遷移檔、模型工廠。

```BASH
php artisan make:model Post -m -f
```

新增 `Tag` 模型，與其遷移檔、模型工廠。

```BASH
php artisan make:model Tag -m -f
```

新增 `create_model_has_tags_table` 遷移檔。

```BASH
php artisan make:migration create_model_has_tags_table
```

### 遷移檔

修改 `create_model_has_tags_table.php` 遷移檔：

```PHP
Schema::create('model_has_tags', function (Blueprint $table) {
    $table->foreignId('tag_id')->constrained()->onDelete('cascade');
    $table->morphs('model');
});
```

執行遷移。

```BASH
php artisan migrate
```

### 關聯方法

修改 `Page` 模型，定義關聯方法：

```PHP
/**
 * Get all of the tags for the page.
 */
public function tags()
{
    return $this->morphToMany(Tag::class, 'model', 'model_has_tags');
}
```

修改 `Post` 模型，定義關聯方法：

```PHP
/**
 * Get all of the tags for the post.
 */
public function tags()
{
    return $this->morphToMany(Tag::class, 'model', 'model_has_tags');
}
```

修改 `Tag` 模型，定義關聯方法：

```PHP
/**
 * Get all of the pages that are assigned this tag.
 */
public function pages()
{
    return $this->morphedByMany(Page::class, 'model', 'model_has_tags');
}

/**
 * Get all of the posts that are assigned this tag.
 */
public function posts()
{
    return $this->morphedByMany(Post::class, 'model', 'model_has_tags');
}
```

### 測試資料

進入 Tinker 介面。

```BASH
php artisan tinker
```

新增一些測試資料：

```BASH
factory(App\Page::class)->create();
factory(App\Post::class)->create();
factory(App\Tag::class, 2)->create();
```

### 使用

為第一個頁面新增所有標籤：

```PHP
Page::first()->tags()->saveMany(Tag::all());
```

為第一個頁面取得所有標籤：

```PHP
Page::first()->tags()->get();
```

為第一篇文章新增所有標籤：

```PHP
Post::first()->tags()->saveMany(Tag::all());
```

為第一篇文章取得所有標籤：

```PHP
Post::first()->tags()->get();
```

取得擁有第一個標籤的所有頁面：

```PHP
Tag::first()->pages()->get();
```

取得擁有第一個標籤的所有文章：

```PHP
Tag::first()->posts()->get();
```

## 特徵機制

由於 `Page` 模型和 `Post` 模型會使用到共同的關聯方法，因此可以在 `app` 資料夾新增 `Traits` 資料夾，並建立共用的特徵機制。

新增 `HasImage.php` 檔：

```PHP
namespace App\Traits;

use App\Image;

trait HasImage {
    /**
     * Get the model's image.
     */
    public function image()
    {
        return $this->morphOne(Image::class, 'model');
    }
}
```

新增 `HasComments.php` 檔：

```PHP
namespace App\Traits;

use App\Comment;

trait HasComments {
    /**
     * Get all of the model's comments.
     */
    public function comments()
    {
        return $this->morphMany(Comment::class, 'model');
    }
}
```

新增 `HasTags.php` 檔：

```PHP
namespace App\Traits;

use App\Tag;

trait HasTags {
    /**
     * Get all of the tags for the model.
     */
    public function tags()
    {
        return $this->morphToMany(Tag::class, 'model', 'model_has_tags');
    }
}
```

重構 `Page` 模型：

```PHP
namespace App;

use App\Traits\HasComments;
use App\Traits\HasImage;
use App\Traits\HasTags;
use Illuminate\Database\Eloquent\Model;

class Page extends Model
{
    use HasImage;
    use HasComments;
    use HasTags;
}
```

重構 `Post` 模型：

```PHP
namespace App;

use App\Traits\HasComments;
use App\Traits\HasImage;
use App\Traits\HasTags;
use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
    use HasImage;
    use HasComments;
    use HasTags;
}
```

## 自訂多型類型

Laravel 預設會使用完全符合的類別名稱來儲存關聯模型的類型，也就是 `model_type` 會儲存像是 `App\Page` 或 `App\Post` 這樣的類別名稱。最好定義一個關聯的對照表，來指示 Eloquent 使用自訂的名稱來儲存類型，將應用程式與資料庫解耦。

新增一個 `RelationServiceProvider` 服務提供者。

```BASH
php artisan make:provider RelationServiceProvider
```

將服務提供者修改如下：

```PHP
namespace App\Providers;

use Illuminate\Database\Eloquent\Relations\Relation;
use Illuminate\Support\ServiceProvider;

class RelationServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     *
     * @return void
     */
    public function register()
    {
        //
    }

    /**
     * Bootstrap services.
     *
     * @return void
     */
    public function boot()
    {
        Relation::morphMap([
            'page' => \App\Page::class,
            'post' => \App\Post::class,
        ]);
    }
}
```

註冊到 `config` 資料夾的 `app.php` 設定檔。

```PHP
return [
    // ...
    App\Providers\RelationServiceProvider::class,
];
```

重新產生 Composer 自動載入檔案。

```BASH
composer dump-autoload
```

## 程式碼

- [eloquent-polymorphic-relationships-example](https://github.com/memochou1993/eloquent-polymorphic-relationships-example)

## 參考資料

- [Eloquent: Relationships](https://laravel.com/docs/master/eloquent-relationships)
