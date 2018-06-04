---
title: 使用 PHP 實作「GitHub API 讀取元件」（二）
date: 2018-06-03 17:40:43
tags: ["PHP", "元件", "GitHub", "API"]
---

## 前言
本文實作一個可以讀取 GitHub API 的元件。

## 建立專案目錄
```
|- github-api/
    |- component/
        |- src/
            |- Github.php
        |- .gitignore
        |- composer.json
        |- README.md
        
```
- 元件的所有檔案都會放在 `src` 資料夾。

## 新增 .gitignore 檔
```
vendor
composer.lock
```

## 新增 composer.json 檔
```JSON
{
    "name": "memochou1993/github-api",
    "description": "GitHub API",
    "keywords": ["github", "api"],
    "homepage": "https://github.com/memochou1993/github-api",
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
        "php" : ">=5.6.0",
        "guzzlehttp/guzzle": "^6.1"
    },
    "autoload": {
        "psr-4": {
            "Memo\\": "src/"
        }
    }
}
```

## 新增 README.md 檔
見 https://github.com/memochou1993/github-api/blob/master/README.md

## 發布
1. 登入 [GitHub](https://github.com/)，創建一個 `github-api` 儲存庫，將元件上傳。
2. 登入 [Packagist](https://packagist.org/)，註冊 https://github.com/memochou1993/github-api 元件。

## 版本控制
回到 GitHub 為元件建立一個語意化版本作為標籤：
1. 點選 `release`。
2. 點選 `Create a new release`。
3. 在 `Tag version` 輸入 `v1.0.0`。
4. 點選 `Publish release`。

## 啟動掛鉤
啟動 GitHub 掛鉤，讓元件儲存庫更新時送出一個提醒給 Packagist。
1. 點選 `Settings`。
2. 點選 `Integrations & services`。
3. 點選 `Add service` 並輸入 `packagist`。
4. 在 `User` 輸入 `Packagist` 使用者名稱。
5. 在 `Token` 輸入 `Packagist` 的 `API Token`。
6. 確認將 `Active` 選項打勾。
7. 點選 `Add service`。

## 使用
現在可以輸入以下命令使用做好的元件了。
```
$ composer require memochou1993/github-api
```

## 程式碼
[GitHub](https://github.com/memochou1993/github-api)