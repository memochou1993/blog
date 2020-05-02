---
title: 在 Laravel 5.8 使用 Policy 授權策略
permalink: 在-Laravel-5-8-使用-Policy-授權策略
date: 2019-03-28 01:14:41
tags: ["程式設計", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 前言

自 Laravel 5.8 開始，Policy 有自動發現的功能，不需要另外註冊。

## 新增

新增 Policy 授權策略。

```BASH
php artisan make:policy RecordPolicy --model=Record
```

在 `app/Policies` 資料夾的 `RecordPolicy.php` 檔撰寫授權邏輯，第一個參數 `$user` 是當前登入的使用者實例。

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

## 方法

在控制器中使用 `authorize()` 方法，在驗證失敗後會自動導向 403 頁面。

```PHP
public function show(User $user, Record $record)
{
    $this->authorize('view', $record);

    //
}
```

在不帶有模型實例的方法中使用時，需要將其模型類別帶入。

```PHP
public function store(User $user)
{
    $this->authorize('create', Record::class);

    //
}
```

如果要手動帶入使用者實例，可以使用 `authorizeForUser()` 方法。

```PHP
public function show(User $user, Record $record)
{
    $this->authorizeForUser($user, 'view', $record);

    //
}
```

## 授權資源

在控制器的建構子使用 `authorizeResource()` 方法，可以一次為所有方法套用授權策略。

```PHP
$this->authorizeResource(Record)::class, 'record');
```

此方法必須在各個類別方法中注入模型實例，如此 Policy 才能知道需要被處理的對象為何。

```PHP
public function show(Record $record)
{
    //
}
```

## 自動發現

如果模型不是放在預設的資料夾，而是 `App\Models` 的話，需要修改 Policy 的自動發現方法。在 `AppServiceProvider` 服務提供者的 `boot()` 方法中加入以下：

```PHP
\Illuminate\Support\Facades\Gate::guessPolicyNamesUsing(function ($model) {
    return 'App\\Policies\\'.class_basename($model).'Policy';
});
```

## 認證

在使用認證套件時，記得在路由定義認證中介層，例如 `auth:api`，如此當前登入的使用者實例才能被獲取。
