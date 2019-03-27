---
title: 在 Laravel 5.8 使用 Policy 授權原則
permalink: 在-Laravel-5-8-使用-Policy-授權原則
date: 2019-03-28 01:14:41
tags: ["程式寫作", "PHP", "Laravel"]
categories: ["程式寫作", "PHP", "Laravel"]
---

## 前言
自 Laravel 5.8 開始，Policy 授權原則有自動發現功能，不需要另外註冊。

## 做法
新增 Policy 授權原則。
```
$ php artisan make:policy RecordPolicy --model=Record
```

撰寫授權邏輯。
```PHP
/**
 * Determine whether the user can view the record.
 *
 * @param  \App\User  $user
 * @param  \App\Record  $record
 * @return mixed
 */
public function view(User $user, Record $record)
{
    return $user->id === $record->user_id;
}
```
- 第一個參數 `$user` 是當前登入的使用者實例。

在控制器使用 `authorize()` 方法：
```PHP
public function show(User $user, Record $record)
{
    $this->authorize('view', $record);
    
    return $record;
}
```

如果要手動帶入使用者實例，可以使用 `authorizeForUser()` 方法：
```PHP
public function show(User $user, Record $record)
{
    $this->authorizeForUser($user, 'view', $record);
    
    return $record;
}
```

## 補充
在使用 Password 時，要在路由定義 `auth:api` 中介層，如此授權原則才能獲取當前登入的使用者實例。
