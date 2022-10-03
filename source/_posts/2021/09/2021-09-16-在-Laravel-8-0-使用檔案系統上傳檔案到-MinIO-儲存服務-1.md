---
title: 在 Laravel 8.0 使用檔案系統上傳檔案到 MinIO 儲存服務
date: 2021-09-16 23:26:07
tags: ["程式設計", "PHP", "Laravel", "MinIO", "Storage Service"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 安裝套件

安裝 `league/flysystem-aws-s3-v3` 套件。

```BASH
composer require --with-all-dependencies league/flysystem-aws-s3-v3 "^1.0"
```

## 環境變數

更新 `.env` 檔，填入必要參數：

```ENV
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_ENDPOINT=http://127.0.0.1:9000
AWS_USE_PATH_STYLE_ENDPOINT=true
```

- 將 `AWS_USE_PATH_STYLE_ENDPOINT` 參數設為 `true`。

## 存取檔案

上傳檔案。

```PHP
Storage::disk('s3')->put('test.txt', file_get_contents('test.txt'));
```

下載檔案。

```PHP
Storage::disk('s3')->get('test.txt');
```

## 參考資料

- [File Storage](https://laravel.com/docs/8.x/filesystem)
