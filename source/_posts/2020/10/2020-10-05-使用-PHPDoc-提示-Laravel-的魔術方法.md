---
title: 使用 PHPDoc 提示 Laravel 的魔術方法
permalink: 使用-PHPDoc-提示-Laravel-的魔術方法
date: 2020-10-05 22:50:58
tags: ["程式設計", "PHP", "Laravel", "PHPDoc"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 前言

Laravel 使用了許多的魔術方法，為了讓編輯器能有更友善的提示，因此可以使用 PHPDoc 註解，避免出現錯誤提示。

## 範例

使用 `@property` 標籤，告訴編輯器 `User` 模型有一個 `$name` 屬性。

```PHP
/**
 * @property string $name
 */
class User extends Authenticatable
{
    // ...
}
```

使用 `@var` 標籤，告訴編輯器 `$user` 變數實際上是一個 `User` 模型。在存取 `$user` 變數時，就不會出現錯誤提示。

```PHP
/** @var User $user */
$user = factory(User::class)->create();

$user->name; // 魔術方法
```
