---
title: 在 Laravel 9.0 使用 File Storage 上傳檔案到 Amazon S3 儲存服務
date: 2023-04-22 16:50:23
tags: ["Programming", "PHP", "Laravel", "AWS", "S3", "Storage Service"]
categories: ["Programming", "PHP", "Laravel"]
---

## 建立憑證

首先，在 Amazon S3 新增一個水桶。接著，在安全憑證的頁面，建立一個具有存取 S3 權限的 IAM 角色，並新增一個存取金鑰。

## 實作

安裝套件。

```bash
composer require league/flysystem-aws-s3-v3
```

更新 `.env` 檔。

```env
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=ap-northeast-1
AWS_BUCKET=
```

更新 `routes/api.php` 檔。

```php
Route::get('/', function () {
    $result = Storage::disk('s3')->put('.env.example', '.env.example');
    return response()->json($result);
});
```

上傳檔案。

```bash
curl http://localhost:8000/api
```

輸出結果如下：

```bash
true
```

## S3 Policy

如果要公開所有物件，可以使用以下政策。

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::your-bucket-name/*"
        }
    ]
}
```

## SSO

使用 SSO 憑證，修改 `config/filesystems.php` 檔。

```php
's3' => [
    'driver' => 's3',
    'key' => null, // 不可有值
    'secret' => null, // 不可有值
    // ...
],
```

啟動服務。

```bash
aws-vault exec your-profile -- php artisan serve
```

## 參考資料

- [Laravel - File Storage](https://laravel.com/docs/9.x/filesystem)
