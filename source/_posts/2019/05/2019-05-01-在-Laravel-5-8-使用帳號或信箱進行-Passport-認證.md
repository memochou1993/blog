---
title: 在 Laravel 5.8 使用帳號或信箱進行 Passport 認證
date: 2019-05-01 16:24:20
tags: ["程式設計", "PHP", "Laravel", "Passport"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 做法

在 `User` 模型新增 `findForPassport()` 方法。

```PHP
use HasApiTokens;

/**
 * @param  $username
 * @return mixed
 */
public function findForPassport($username) {
    $field = filter_var($username, FILTER_VALIDATE_EMAIL)
        ? 'email'
        : 'username';

    return $this->where($field, $username)->first();
}
```
