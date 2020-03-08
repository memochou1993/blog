---
title: 實作「GitHub API」元件在 PHP 專案中使用（一）
permalink: 實作「GitHub-API」元件在-PHP-專案中使用（一）
date: 2018-06-02 17:40:32
tags: ["程式設計", "PHP", "元件", "GitHub", "API", "Packagist"]
categories: ["程式設計", "PHP", "元件"]
---

## 前言

本文實作一個可以讀取 GitHub API 的元件。

## 專案目錄

```
|- github-api/
    |- dev/
        |- src/
            |- Github.php
        |- vendor/
        |- composer.json
        |- composer.lock
        |- index.php

```

- 元件的所有檔案都會放在 `src` 資料夾。

## 使用 GitHub API

[GitHub REST API v3.](https://developer.github.com/v3/) 提供詳細的文件供開發者使用。

### 取得儲存庫資料

| Method | URL                                          |
| ------ | -------------------------------------------- |
| GET    | <https://api.github.com/repos/laravel/laravel> |

### 取得使用者資料

| Method | URL                                       |
| ------ | ----------------------------------------- |
| GET    | <https://api.github.com/users/memochou1993> |

本文將使用以上兩個方法實作一個可以讀取 GitHub API 的元件。

## 安裝相依元件

讀取 GitHub API 會需要發送 `HTTP` 請求以及獲取響應，所以安裝 `Guzzle` 元件。

```BASH
cd github-api/github-api-dev
composer require guzzlehttp/guzzle
```

## 實作

在 `src` 資料夾中新增一個 `Github.php` 檔。

```PHP
namespace Memo;

class Github
{
    protected $client;
    protected $url;
    protected $option;
    protected $exception;
    protected $paginate;

    public function __construct()
    {
        // 實例一個發送 HTTP 請求以及獲取響應的 Client 物件
        $this->client = new \GuzzleHttp\Client();
        // GitHub API 的根端點
        $this->url = 'https://api.github.com';
    }

    public function option($option)
    {
        // 設置 HTTP 請求選項
        $this->option = $option;

        return $this;
    }

    public function showException()
    {
        // 當發生例外狀況時，顯示來自 GitHub API 的錯誤訊息
        $this->exception = true;

        return $this;
    }

    public function request($type, $name, $target = null)
    {
        // 設置 HTTP 請求目標
        $this->url .= '/' . $type . '/' . $name;

        // 判斷是否有子項目
        if ($target) $this->url .= '/' . $target;

        return $this;
    }

    public function paginate($per_page = 10, $page = null)
    {
        // 設置每頁顯示筆數
        $this->paginate = '?per_page=' . $per_page;

        // 判斷是否有指定讀取的頁瑪
        if ($page) $this->paginate .= '&page=' . $page;

        return $this;
    }

    public function getBody()
    {
        // 如果 getResponse() 方法回傳 null 値，則終止程序
        if (!$this->getResponse()) return;

        // 回傳 URL 和 GitHub API 響應的 body
        return (object) [
            'url' => $this->url . $this->paginate,
            'response' => json_decode($this->getResponse()->getBody())
        ];
    }

    public function getHeaderLine($field)
    {
        // 如果 getResponse() 方法回傳 null 値，則終止程序
        if (!$this->getResponse()) return;

        // 回傳 URL 和 GitHub API 響應的指定 header line
        return (object) [
            'url' => $this->url . $this->paginate,
            'response' => json_decode($this->getResponse()->getHeaderLine($field))
        ];
    }

    protected function getResponse()
    {
        try {
            // 發送 HTTP 請求
            $response = $this->client->get($this->url . $this->paginate, $this->option);
        } catch (\GuzzleHttp\Exception\ClientException $e) {
            // 如果 exception 設置為 true，回傳來自 GitHub API 的錯誤訊息
            $response = ($this->exception) ? $e->getResponse() : null;
        }

        return $response;
    }
}
```

## 使用

新增一個 `index.php` 檔。

```PHP
require 'vendor/autoload.php'; // 載入 autoload.php
require 'src/Github.php'; // 載入製作好的元件

$github = new \Memo\Github(); // 實例一個 Guthub 物件

$github
    // 設置 HTTP 請求目標
    ->request('repos', 'laravel/laravel')
    // 設置 HTTP 請求選項
    ->option([
        'headers' => [
            // 認證
            'Authorization' => 'token 84411234372912342f351234dc9712343b301234',
            // 文本格式
            'Accept' => 'application/vnd.github.mercy-preview+json'
            ]
    ])
    // 分頁
    ->paginate()
    // 顯示錯誤訊息
    ->showException();

var_dump($github->getHeaderLine('X-RateLimit-Remaining'));

var_dump($github->getBody());
```

結果：

```PHP
object(stdClass)#19 (2) {
  ["url"]=>
  string(63) "https://api.github.com/repos/laravel/laravel/topics?per_page=10"
  ["response"]=>
  int(4990)
}
object(stdClass)#16 (2) {
  ["url"]=>
  string(63) "https://api.github.com/repos/laravel/laravel/topics?per_page=10"
  ["response"]=>
  object(stdClass)#17 (1) {
    ["names"]=>
    array(3) {
      [0]=>
      string(3) "php"
      [1]=>
      string(9) "framework"
      [2]=>
      string(7) "laravel"
    }
  }
}
```

## 程式碼

[GitHub](https://github.com/memochou1993/github-api)
