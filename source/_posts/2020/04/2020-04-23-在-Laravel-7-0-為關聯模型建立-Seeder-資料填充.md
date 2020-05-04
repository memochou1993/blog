---
title: 在 Laravel 7.0 為關聯模型建立 Seeder 資料填充
permalink: 在-Laravel-7-0-為關聯模型建立-Seeder-資料填充
date: 2020-04-23 01:47:13
tags: ["程式設計", "PHP", "Laravel", "Eloquent"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 前言

本文以「一個使用者擁有多個專案和多筆文章」為例，為關聯模型建立資料填充。

## 關聯方法

首先，為 `User` 模型建立 `projects()` 和 `posts()` 關聯方法：

```PHP
/**
 * Get all of the projects for the user.
 *
 * @return \Illuminate\Database\Eloquent\Relations\hasMany
 */
public function projects() {
    return $this->hasMany(Project::class);
}

/**
 * Get all of the posts for the user.
 *
 * @return \Illuminate\Database\Eloquent\Relations\hasMany
 */
public function posts() {
    return $this->hasMany(Post::class);
}
```

## 做法一

以父模型為主，由上而下建立關聯資料。

首先，建立一個 `UserSeeder` 資料填充，建立 5 個使用者，為每個使用者建立 10 個專案和 10 筆文章。

```PHP
use App\Post;
use App\Project;
use App\User;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        factory(User::class, 5)->create()->each(function ($user) {
            $user->projects()->saveMany(factory(Project::class, 10)->make());
            $user->posts()->saveMany(factory(Post::class, 10)->make());
        });
    }
}
```

此方法將所有模型都寫在同一個檔案，在互相關聯的情況下，很容易寫出複雜的巢狀結構，不易維護。

## 做法二

將模型工廠生成的測試資料儲存在靜態屬性中，讓測試資料可以在不同的 Seeder 之間分享。

首先，在 `App\Traits` 資料夾建立一個 `HasStaticAttributes` 特徵機制：

```PHP
trait HasStaticAttributes
{
    /**
     * @var array
     */
    private static array $attributes = [];

    /**
     * @param  string  $key
     * @param  mixed  $value
     * @return void
     */
    private function setAttribute(string $key, $value)
    {
        self::$attributes[$key] = $value;
    }

    /**
     * @param  string  $key
     * @return array
     */
    private function getAttribute(string $key)
    {
        return self::$attributes[$key] ?? null;
    }

    /**
     * @param  string  $key
     * @param  mixed  $value
     * @return void
     */
    public function set(string $key, $value)
    {
        $this->setAttribute($key, $value);
    }

    /**
     * @param  string  $key
     * @return mixed
     */
    public function get(string $key)
    {
        return $this->getAttribute($key);
    }

    /**
     * @param  string  $key
     * @param  mixed  $value
     * @return void
     */
    public function __set(string $key, $value)
    {
        $this->setAttribute($key, $value);
    }

    /**
     * @param  string  $key
     * @return mixed
     */
    public function __get(string $key)
    {
        return $this->getAttribute($key);
    }

    /**
     * @param  $method
     * @param  $parameters
     * @return mixed
     */
    public function __call($method, $parameters)
    {
        return $this->getAttribute($method);
    }
}
```

建立一個 `UserSeeder` 資料填充，引入特徵機制，建立 5 個使用者：

```PHP
use App\User;
use App\Traits\HasStaticAttributes;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    use HasStaticAttributes;

    private const AMOUNT = 5;

    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        $this->users = factory(User::class, self::AMOUNT)->create();
    }
}
```

建立一個 `ProjectSeeder` 資料填充，引入特徵機制，從 `UserSeeder` 取得測試資料，並為每個使用者建立 10 個專案。

```PHP
use App\Project;
use App\Traits\HasStaticAttributes;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    use HasStaticAttributes;

    private const AMOUNT = 10;

    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        app(UserSeeder::class)->users->each(function ($user) {
            $user->projects()->saveMany(factory(Project::class, self::AMOUNT)->make());
        });
    }
}
```

建立一個 `PostSeeder` 資料填充，引入特徵機制，從 `UserSeeder` 取得測試資料，並為每個使用者建立 10 筆文章。

```PHP
use App\Post;
use App\Traits\HasStaticAttributes;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    use HasStaticAttributes;

    private const AMOUNT = 10;

    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        app(UserSeeder::class)->users()->each(function ($user) {
            $user->posts()->saveMany(factory(Post::class, self::AMOUNT)->make());
        });
    }
}
```

此方法避免將所有模型都寫在同一個檔案內，而是利用靜態屬性分享測試資料，靈活度比較高。
