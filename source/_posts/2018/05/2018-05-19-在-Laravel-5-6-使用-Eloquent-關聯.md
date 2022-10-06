---
title: 在 Laravel 5.6 使用 Eloquent 關聯
date: 2018-05-19 10:23:08
tags: ["程式設計", "PHP", "Laravel", "Eloquent", "ORM"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 環境

- Windows 10
- Homestead 7.4.1

## 一對一關聯

假想 1 個使用者只有 1 個手機號碼。

在 `User` 模型新增關聯。

```php
public function phone()
{
    // 把主鍵當外鍵用
    return $this->hasOne(Phone::class, 'id');
}
```

在 `Phone` 模型新增關聯。

```php
public function user()
{
    // 把主鍵當外鍵用
    return $this->belongsTo(User::class, 'id');
}
```

取得使用者唯一的手機號碼。

```php
return App\User::find($user)->phone()->get();
```

取得手機號碼唯一的使用者。

```php
return App\Phone::find($phone)->user()->get();
```

## 一對多關聯

假想 1 個使用者有 1 個以上的文章。

在 `User` 模型新增關聯。

```php
public function posts()
{
    // 外鍵為 `posts.user_id`
    return $this->hasMany(Post::class);
}
```

在 `Post` 模型新增關聯。

```php
public function user()
{
    // 外鍵為 `posts.user_id`
    return $this->belongsTo(User::class);
}
```

取得使用者所有的文章。

```php
return App\User::find($user)->posts()->get();
```

取得文章唯一的使用者。

```php
return App\Post::find($post)->user()->get();
```

## 多對多關聯

假想 1 個使用者有 1 個以上的代表色，1 個代表色有 1 個以上的使用者。

設置 `UserColor` 樞紐資料表。

```php
Schema::create('user_color', function (Blueprint $table) {
    $table->increments('id');
    $table->integer('user_id');
    $table->integer('color_id');
    $table->timestamps();
});
```

在 `UserColor` 模型改寫資料表名稱。

```php
protected $table = 'user_color';
```

在 `User` 模型新增關聯。

```php
public function colors()
{
    // 外鍵為 `user_color.color_id` 及 `user_color.user_id`
    return $this->belongsToMany(Color::class, 'user_color');
}
```

在 `Color` 模型新增關聯。

```php
public function users()
{
    // 外鍵為 `user_color.color_id` 及 `user_color.user_id`
    return $this->belongsToMany(User::class, 'user_color');
}
```

取得使用者所有的代表色。

```php
return App\User::find($user)->colors()->get();
```

取得代表色所有的使用者。

```php
return App\Color::find($color)->users()->get();
```
