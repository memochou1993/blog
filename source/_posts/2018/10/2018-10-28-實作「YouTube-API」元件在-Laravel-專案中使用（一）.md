---
title: 實作「YouTube API」套件在 Laravel 專案中使用（一）
permalink: 實作「YouTube-API」套件在-Laravel-專案中使用（一）
date: 2018-10-28 20:56:37
tags: ["程式設計", "PHP", "Laravel", "套件開發", "YouTube", "API", "Packagist"]
categories: ["程式設計", "PHP", "套件開發"]
---

## 前言

本文實作一個可以讀取 YouTube API 的套件。

## 專案目錄

```BASH
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

## 使用 YouTube API

[YouTube API](https://developers.google.com/youtube/v3/) 提供詳細的文件供開發者使用。

## 申請 API Key

首先到 [Google 開發者平台](https://console.developers.google.com/)建立專案，並且取得 API Key。

## 安裝相依套件

建立 `composer.json` 檔。

```
{
    "require": {
        "guzzlehttp/guzzle": "^6.1"
    },
    "require-dev": {
        "phpunit/phpunit": "^6.1"
    },
}
```

安裝 `Guzzle` 及 `PHPUnit` 相依套件。

```BASH
composer install
```

## 實作

在 `src` 資料夾中新增一個 `Youtube.php` 檔。

```PHP
namespace Memo\Youtube;

use GuzzleHttp\Client;
use GuzzleHttp\Exception\ClientException;

class Youtube
{
    protected $client;
    protected $url;
    protected $key;
    protected $params;

    public function __construct($key)
    {
        $this->client = new Client();
        $this->url = 'https://www.googleapis.com/youtube/v3';
        $this->key = $key;
        $this->params = [];
    }

    protected function setResource($type)
    {
        $this->url .= '/' . $type;
    }

    protected function setParams()
    {
        if (func_num_args() === 1) {
            foreach (func_get_arg(0) as $key => $value) {
                $this->params[$key] = $value;
            }
        }

        if (func_num_args() === 2) {
            $this->params[func_get_arg(0)] = func_get_arg(1);
        }
    }

    protected function request()
    {
        $this->setParams('key', $this->key);

        $url = $this->url . '?' . http_build_query($this->params);

        try {
            $response = $this->client->get($url)->getBody();
        } catch (ClientException $e) {
            $response = $e->getResponse()->getBody()->getContents();
        }

        return json_decode($response);
    }

    public function getChannelByName($username, array $part = ['id', 'snippet', 'contentDetails', 'statistics', 'brandingSettings'])
    {
        $this->setResource('channels');

        $this->setParams([
            'part' => implode(', ', $part),
            'forUsername' => $username,
        ]);

        return $this->request();
    }
}
```

## 測試

新增一個 `phpunit.xml` 檔，並將 API Key 設為環境變數。

```XML
<?xml version="1.0" encoding="UTF-8"?>
<phpunit backupGlobals="false"
         backupStaticAttributes="false"
         bootstrap="vendor/autoload.php"
         colors="true"
         convertErrorsToExceptions="true"
         convertNoticesToExceptions="true"
         convertWarningsToExceptions="true"
         processIsolation="false"
         stopOnFailure="false"
         syntaxCheck="false">
    <testsuites>
        <testsuite name="Package Test Suite">
            <directory suffix="Test.php">./tests/</directory>
        </testsuite>
    </testsuites>
    <php>
        <env name="YOUTUBE_API_KEY" value="YOUTUBE_API_KEY"/>
    </php>
</phpunit>
```

在 `tests` 資料夾新增一個 `YoutubeTest.php` 檔。

```PHP
namespace Memo\Youtube\Tests;

use Memo\Youtube\Youtube;
use PHPUnit\Framework\TestCase;

class YoutubeTest extends TestCase
{
    public $youtube;

    public function setUp()
    {
        $this->youtube = new Youtube(getenv("YOUTUBE_API_KEY"));
    }

    public function testGetChannel()
    {
        $response = $this->youtube->getChannel('Google');

        $this->assertEquals('youtube#channel', $response->items[0]->kind);
        $this->assertEquals('Google', $response->items[0]->snippet->title);

        $this->assertObjectHasAttribute('id', $response->items[0]);
        $this->assertObjectHasAttribute('snippet', $response->items[0]);
        $this->assertObjectHasAttribute('contentDetails', $response->items[0]);
        $this->assertObjectHasAttribute('statistics', $response->items[0]);
        $this->assertObjectHasAttribute('brandingSettings', $response->items[0]);
    }

    public function tearDown()
    {
        $this->youtube = null;
    }
}
```

執行測試。

```BASH
vendor/bin/phpunit
```

## 使用

在 `example` 資料夾新增一個 `index.php` 檔。

```PHP
require '../vendor/autoload.php';
require '../src/Youtube.php';

use Memo\Youtube\Youtube;

$youtube = new Youtube('API Key');

var_dump($youtube->getChannelByName('Google'));
```

## 程式碼

- [youtube-api](https://github.com/memochou1993/youtube-api)
