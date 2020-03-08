---
title: 在 Laravel 5.7 使用 UUID 做為資料庫主鍵
permalink: 在-Laravel-5-7-使用-UUID-做為資料庫主鍵
date: 2018-12-02 20:45:35
tags: ["程式設計", "PHP", "Laravel", "UUID", "資料庫"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 環境

- Windows 10
- Homestead

## 安裝套件

安裝 `spatie/laravel-binary-uuid` 套件。

```BASH
composer require spatie/laravel-binary-uuid
```

## 修改遷移

以 `users` 遷移檔為例：

```PHP
Schema::create('users', function (Blueprint $table) {
    $table->uuid('uuid');
    $table->primary('uuid');
    $table->string('name');
    $table->string('email')->unique();
    $table->timestamp('email_verified_at')->nullable();
    $table->string('password');
    $table->rememberToken();
    $table->timestamps();
});
```

## 修改模型

以 `User` 模型為例：

```PHP
<?php

namespace App;

use Spatie\BinaryUuid\HasBinaryUuid; // 調用特徵機制
use Illuminate\Notifications\Notifiable;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    use Notifiable;
    use HasBinaryUuid; // 使用特徵機制

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'name', 'email', 'password',
    ];

    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        'password', 'remember_token',
    ];
}
```

## 參考資料

- [Ready to use UUID in your next laravel app?](https://www.qcode.in/ready-to-use-uuid-in-your-next-laravel-app/)
