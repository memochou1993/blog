---
title: 實作「YouTube API」元件在 Laravel 專案中使用（二）
permalink: 實作「YouTube-API」元件在-Laravel-專案中使用（二）
date: 2018-10-30 20:57:19
tags: ["程式寫作", "PHP", "Laravel", "元件", "YouTube", "API", "Packagist"]
categories: ["程式寫作", "PHP", "元件"]
---

## 前言

本文實作一個可以讀取 YouTube API 的元件。

## 專案目錄

```
|- youtube-api/
    |- component/
        |- example/
            |- index.php
        |- src/
            |- config/
                |- youtube.php
            |- Facades/
                |- Youtube.php
            |- Youtube.php
            |- YoutubeServiceProvider.php
        |- tests/
            |- YoutubeTest.php
        |- vendor/
        |- .gitignore
        |- composer.json
        |- composer.lock
        |- phpunit.xml
        |- README.md
```

## 建立 Laravel 設定

在 `src/config` 資料夾中新增一個 `youtube.php` 檔。

```PHP
<?php

return [

    'key' => env('YOUTUBE_API_KEY', 'YOUR_API_KEY')

];
```

## 建立 Laravel 靜態代理

在 `src/Facades` 資料夾中新增一個 `Youtube.php` 檔。

```PHP
<?php

namespace Memo\Youtube\Facades;

use Illuminate\Support\Facades\Facade;

class Youtube extends Facade {

    /**
     * Get the registered name of the component.
     *
     * @return string
     */
    protected static function getFacadeAccessor()
    {
        return 'youtube';
    }
}
```

## 建立 Laravel 服務提供者

在 `src` 資料夾中新增一個 `YoutubeServiceProvider.php` 檔。

```PHP
<?php

namespace Memo\Youtube;

use Illuminate\Support\ServiceProvider;

class YoutubeServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap the application events.
     *
     * @return void
     */
    public function boot()
    {
        $this->publishes([
            __DIR__ . '/config/youtube.php' => config_path('youtube.php')
        ]);
    }

    /**
     * Register the service provider.
     *
     * @return void
     */
    public function register()
    {
        $this->app->bind(Youtube::class, function () {
            return new Youtube(config('youtube.key'));
        });

        $this->app->alias(Youtube::class, 'youtube');
    }
}
```

## 建立 .gitignore 檔

```
/example
/vendor
composer.lock
```

## 建立 README.md 檔

```
## 概述
此元件用於 YouTube API 的讀取。
```

## 修改 composer.json 檔

```
{
    "name": "memochou1993/youtube-api",
    "description": "YouTube API",
    "keywords": ["youtube", "api"],
    "homepage": "https://github.com/memochou1993/youtube-api",
    "license": "MIT",
    "authors": [
        {
            "name": "Memo Chou",
            "homepage": "https://github.com/memochou1993",
            "role": "Developer"
        }
    ],
    "support": {
        "email": "memochou1993@hotmail.com"
    },
    "require": {
        "php": "^7.0",
        "guzzlehttp/guzzle": "^6.1"
    },
    "require-dev": {
        "phpunit/phpunit": "^6.1"
    },
    "autoload": {
        "psr-4": {
            "Memo\\Youtube\\": "src/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "Memo\\Youtube\\Tests\\": "tests"
        }
    },
    "extra": {
        "laravel": {
            "providers": [
                "Memo\\Youtube\\YoutubeServiceProvider"
            ],
            "aliases": {
                "Youtube": "Memo\\Youtube\\Facades\\Youtube"
            }
        }
    }
}
```

## 發布

1. 登入 [GitHub](https://github.com/)，創建一個 `youtube-api` 儲存庫，將元件上傳。
2. 登入 [Packagist](https://packagist.org/)，註冊 https://github.com/memochou1993/youtube-api 元件。

## 版本控制

在 GitHub 為元件建立一個語意化版本作為標籤：

1. 點選 `release`。
2. 點選 `Create a new release`。
3. 在 `Tag version` 輸入 `v0.0.1`。
4. 點選 `Publish release`。

## 啟動掛鉤

GitHub 如果沒有自動建立，可以手動為元件啟動掛鉤。

1. 點選 `Settings`。
2. 點選 `Webhooks`。
3. 在 `Payload URL` 輸入 https://packagist.org/api/github。
4. 點選 `Add webhook`。

## 安裝

建立 Laravel 專案。

```CMD
laravel new youtube
```

安裝元件。

```CMD
composer require memochou1993/youtube-api dev-master
```

發布資源。

```CMD
php artisan vendor:publish --provider="Memo\Youtube\YoutubeServiceProvider"
```

## 使用

```PHP
use Youtube;

Youtube::getChannel('Google');
```

## 程式碼

[GitHub](https://github.com/memochou1993/github-api)
