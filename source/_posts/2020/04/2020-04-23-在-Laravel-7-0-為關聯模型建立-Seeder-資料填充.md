---
title: 在 Laravel 7.0 為關聯模型建立 Seeder 資料填充
permalink: 在-Laravel-7-0-為關聯模型建立-Seeder-資料填充
date: 2020-04-23 01:47:13
tags: ["程式設計", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 前言

本文使用「一個使用者擁有多個專案和多筆文章」為例，為關聯模型建立資料填充。

## 關聯方法

首先，為 `User` 模型建立關聯方法：

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

`User` 模型和 `Project` 模型是一對多的關聯，和 `Post` 模型也是一對多的關聯

## 做法

### 方法一

以父模型為主，由上而下建立關聯資料。

修改 `UserSeeder` 資料填充，建立 5 個使用者，為每個使用者個別建立 10 個專案和 10 筆文章。

```PHP
factory(App\User::class, 5)->create()->each(function ($user) {
    $user->projects()->saveMany(factory(App\Project::class, 10)->make());
    $user->posts()->saveMany(factory(App\Post::class, 10)->make());
});
```

此方法在模型互相關聯的情況下，容易形成複雜的巢狀結構。而且每一個模型的資料填充都寫在同一個檔案內，形成高度耦合。

### 方法二

以子模型為主，由下而上建立關聯資料。

修改 `ProjectSeeder` 資料填充，建立 5 個專案。

```PHP
factory(App\Project::class, 5)->create();
```

修改 `ProjectFactory` 模型工廠，為每個專案建立 1 個使用者。

```PHP
$factory->define(Project::class, function (Faker $faker) {
    return [
        'user_id' => factory(App\User::class)->create()->id,
    ];
});
```

修改 `PostSeeder` 資料填充，建立 5 筆文章。

```PHP
factory(App\Post::class, 5)->create();
```

修改 `PostFactory` 模型工廠，為每筆文章建立 1 個使用者。

```PHP
$factory->define(Post::class, function (Faker $faker) {
    return [
        'user_id' => factory(App\User::class)->create()->id,
    ];
});
```

此方法導致 `Project` 模型和 `Post` 模型所生產出來的 `User` 模型都不一樣，無法反映一個使用者同時擁有專案和文章的情況。而且在模型工廠做資料填充的行為，違反了單一職責原則。

### 方法三

個別建立關聯資料。

修改 `UserSeeder` 資料填充，建立 5 個使用者。

```PHP
factory(App\User::class, 5)->create();
```

修改 `ProjectSeeder` 資料填充，撈出所有使用者，個別建立 10 個專案。

```PHP
App\User::all()->each(function ($user) {
    $user->projects()->saveMany(
        factory(App\Project::class, 10)->make()
    );
});
```

修改 `PostSeeder` 資料填充，撈出所有使用者，個別建立 10 筆文章。

```PHP
App\User::all()->each(function ($user) {
    $user->posts()->saveMany(
        factory(App\Post::class, 10)->make()
    );
});
```

此方法雖然多了兩次資料庫的查詢，但解耦了模型之間的資料填充。
