---
title: 使用 PHP 透過 Amazon SES 服務寄送電子郵件
date: 2024-01-26 21:02:15
tags: ["Programming", "PHP", "AWS", "SES", "Mail"]
categories: ["Programming", "PHP", "Others"]
---

## 建立專案

建立專案。

```bash
mkdir aws-ses-php-example
cd aws-ses-php-example
```

安裝依賴套件。

```bash
composer require aws/aws-sdk-php
```

## 實作

建立 `index.php` 檔。

```php
<?php

require './vendor/autoload.php';

use Aws\Sdk;
use Aws\Exception\AwsException;

$sharedConfig = [
    'region' => 'ap-northeast-1',
];

$sdk = new Sdk($sharedConfig);

$ses = $sdk->createSes();

$sender_email = 'user@example.com';

$recipient_emails = ['memochou1993@hotmail.com'];

$subject = 'Amazon SES test (AWS SDK for PHP)';
$plaintext_body = 'This email was sent with Amazon SES using the AWS SDK for PHP.' ;
$html_body =  '<h1>AWS Amazon Simple Email Service Test Email</h1>'.
              '<p>This email was sent with <a href="https://aws.amazon.com/ses/">'.
              'Amazon SES</a> using the <a href="https://aws.amazon.com/sdk-for-php/">'.
              'AWS SDK for PHP</a>.</p>';
$char_set = 'UTF-8';

try {
    $result = $ses->sendEmail([
        'Destination' => [
            'ToAddresses' => $recipient_emails,
        ],
        'ReplyToAddresses' => [$sender_email],
        'Source' => $sender_email,
        'Message' => [
          'Body' => [
              'Html' => [
                  'Charset' => $char_set,
                  'Data' => $html_body,
              ],
              'Text' => [
                  'Charset' => $char_set,
                  'Data' => $plaintext_body,
              ],
          ],
          'Subject' => [
              'Charset' => $char_set,
              'Data' => $subject,
          ],
        ],
    ]);
    $messageId = $result['MessageId'];
    echo("Email sent! Message ID: $messageId"."\n");
} catch (AwsException $e) {
    // output error message if fails
    echo $e->getMessage();
    echo("The email was not sent. Error message: ".$e->getAwsErrorMessage()."\n");
    echo "\n";
}
```

執行程式。

```bash
aws-vault exec your-profile -- php index.php
```

## 程式碼

- [memochou1993/aws-ses-php-example](https://github.com/memochou1993/aws-ses-php-example)
