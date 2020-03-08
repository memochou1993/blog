---
title: 在 Laravel 5.7 使用 Voyager 後台管理系統
permalink: 在-Laravel-5-7-使用-Voyager-後台管理系統
date: 2018-11-23 02:58:23
tags: ["程式設計", "PHP", "Laravel", "後台管理系統", "Voyager"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 環境

- Windows 10
- Homestead

## 安裝

```BASH
composer require tcg/voyager
```

## 設定

修改 `.env` 檔。

```ENV
APP_URL=voyager.test
```

## 執行安裝

```BASH
php artisan voyager:install --with-dummy
```

- 參數 `--with-dummy` 會附帶預設的假資料。

## 指派管理員

```BASH
php artisan voyager:admin your@email.com --create
```

- 參數 `--create` 會建立一個新的使用者。

## 使用 Google Analytics

1. 在 [Google 開發者平台](https://console.developers.google.com/)建立專案。
2. 點選 `Create credentials` 的 `Oauth client ID`。
3. 點選 `Web application`。
4. 在 `Authorized JavaScript origins` 輸入 http://voyager.test。
5. 到 [API Library](https://console.developers.google.com/apis/library) 點選 `Analytics API`，並啟用。
6. 到 http://voyager.test/admin/settings 的 Admin 選單，新增 Google Analytics Client ID。

## 首頁工具

### 新增預設模型

修改 `config\voyager.php` 檔。

```PHP
'widgets' => [
    'TCG\\Voyager\\Widgets\\UserDimmer',
],
```

### 新增自訂模型

1. 建立 Item 模型。
2. 在 http://fitness.test/admin/bread 新增 Item 模型的 `BREAD`。
3. 新增 `app\Widgets\ItemDimmer.php` 檔。
4. 在 https://unsplash.com 找到適合的圖片放到 `public\vendor\tcg\voyager\assets\images\widget-backgrounds` 資料夾。

```PHP
<?php

namespace App\Widgets;

use App\Item;
use Illuminate\Support\Str;
use TCG\Voyager\Facades\Voyager;
use TCG\Voyager\Widgets\BaseDimmer;
use Illuminate\Support\Facades\Auth;

class ItemDimmer extends BaseDimmer
{
    /**
     * The configuration array.
     *
     * @var array
     */
    protected $config = [];

    /**
     * Treat this method as a controller action.
     * Return view() or other content to display.
     */
    public function run()
    {
        $count = Item::count();
        $string = 'Items';

        return view('voyager::dimmer', array_merge($this->config, [
            'icon'   => 'voyager-group',
            'title'  => $count . ' ' . $string,
            'text'   => 'You have' . $count . 'items in your database. Click on button below to view all items.',
            'button' => [
                'text' => 'View all items',
                'link' => route('voyager.items.index'),
            ],
            'image' => voyager_asset('images/widget-backgrounds/item.jpg'),
        ]));
    }

    /**
     * Determine if the widget should be displayed.
     *
     * @return bool
     */
    public function shouldBeDisplayed()
    {
        return Auth::user()->can('browse', app(Item::class));
    }
}
```

修改 `config\voyager.php` 檔。

```PHP
'widgets' => [
    'App\\Widgets\\ItemDimmer',
],
```
