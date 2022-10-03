---
title: 在 Laravel 5.7 使用 Larastan 靜態分析工具
date: 2019-01-26 22:28:27
tags: ["程式設計", "PHP", "Laravel", "除錯"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 做法

安裝 `nunomaduro/larastan` 套件。

```BASH
composer require --dev nunomaduro/larastan
```

執行檢查。

```BASH
php artisan code:analyse --level=5 --paths="app"
```

- 參數 `level` 表示嚴格程度，0 表示最寬鬆，7 表示最嚴格，默認為 5。
- 參數 `path` 表示指定路徑。

## 客製化設定

如果是檢查專案，在專案根目錄新增 `phpstan.neon` 檔：

```ENV
includes:
    - ./vendor/nunomaduro/larastan/extension.neon
parameters:
    level: 5
    ignoreErrors:
        - '#Access to an undefined property App\\Demo\\[a-zA-Z0-9\\_]+::\$[a-zA-Z0-9\\_]+\.#'
        - '#Call to an undefined method App\\Http\\Resources\\DemoResource::DemoMethod\(\)\.#'
    excludes_analyse:
        - /*/*/FileToBeExcluded.php
```

如果是檢查套件，在套件根目錄新增 `phpstan.neon.dist` 檔：

```ENV
includes:
    - ./vendor/nunomaduro/larastan/extension.neon
parameters:
    level: 5
    paths:
        - src
```

執行檢查。

```BASH
./vendor/bin/phpstan analyse
```
