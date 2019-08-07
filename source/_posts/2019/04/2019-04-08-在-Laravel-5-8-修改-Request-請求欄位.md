---
title: 在 Laravel 5.8 修改 Request 請求欄位
permalink: 在-Laravel-5-8-修改-Request-請求欄位
date: 2019-04-08 11:32:22
tags: ["程式寫作", "PHP", "Laravel"]
categories: ["程式寫作", "PHP", "Laravel"]
---

## 做法

使用 `merge()` 方法，若有重複，則會取代。

```PHP
$request->merge([
    'foo' => 'bar',
]);
```

使用 `replace()` 方法，取代所有欄位。

```PHP
$request->replace([
    'foo' => 'bar',
]);
```

直接設置欄位，若有重複，則會取代。

```PHP
$request['foo'] = 'bar';
```
