---
title: 在 Laravel 5.7 使用 Telescope 除錯工具
permalink: 在-Laravel-5-7-使用-Telescope-除錯工具
date: 2018-11-18 02:05:25
tags: ["程式寫作", "PHP", "Laravel", "除錯", "Telescope"]
categories: ["程式寫作", "PHP", "Laravel"]
---

## 環境
- Windows 10
- Homestead

## 建立專案
```
$ laravel new telescope
```

## 步驟
### 一般使用
安裝 `laravel/telescope` 套件。
```
$ composer require laravel/telescope
```
執行安裝。
```
$ php artisan telescope:install
```
執行遷移。
```
$ php artisan migrate
```
發布資源。
```
$ php artisan telescope:publish
```
前往 http://telescope.test/telescope。

### 限於本地使用
安裝 `laravel/telescope` 套件。
```
$ composer require laravel/telescope --dev
```
執行安裝。
```
$ php artisan telescope:install
```
執行遷移。
```
$ php artisan migrate
```
發布資源。
```
$ php artisan telescope:publish
```
在 `config/app.php` 檔中，註解服務提供者。
```PHP
'providers' => [
    ...
    // App\Providers\TelescopeServiceProvider::class,
    ...
]
```
在 `app\Providers\AppServiceProvider.php` 檔中，新增服務提供者。
```PHP
public function register()
{
    if ($this->app->isLocal()) {
        $this->app->register(TelescopeServiceProvider::class);
    }
}
```
前往 http://telescope.test/telescope。