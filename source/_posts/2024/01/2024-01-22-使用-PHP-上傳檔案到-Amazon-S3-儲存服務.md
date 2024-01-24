---
title: 使用 PHP 上傳檔案到 Amazon S3 儲存服務
date: 2024-01-22 17:46:49
tags: ["Programming", "PHP", "AWS", "S3", "Storage Service"]
categories: ["Programming", "PHP", "Others"]
---

## 建立專案

建立專案。

```bash
mkdir aws-s3-php-example
cd aws-s3-php-example
```

安裝依賴套件。

```bash
composer require aws/aws-sdk-php
```

## 實作

建立 `index.php` 檔，初始化一個客戶端實體。

```php
<?php

require './vendor/autoload.php';

use Aws\Sdk;

$sharedConfig = [
    'region' => 'ap-northeast-1',
];

$sdk = new Sdk($sharedConfig);

$s3 = $sdk->createS3();
```

### 列出所有儲存貯體

```php
$result = $s3->listBuckets();

foreach ($result['Buckets'] as $bucket) {
    echo $bucket['Name'] . "\n";
}
```

### 上傳檔案

```php
$bucketName = 'your-bucket';
$filePath = './test.txt';
$objectName = 'test.txt';

$s3->putObject([
    'Bucket' => $bucketName,
    'Key'    => $objectName,
    'Body'   => fopen($filePath, 'r'),
]);
```

### 上傳檔案

```php
$bucketName = 'your-bucket';

$result = $s3->listObjects(['Bucket' => $bucketName]);

foreach ($result['Contents'] as $object) {
    echo $object['Key'] . "\n";
}
```

執行程式。

```bash
aws-vault exec your-profile -- php index.php
```

## 程式碼

- [memochou1993/aws-s3-php-example](https://github.com/memochou1993/aws-s3-php-example)
