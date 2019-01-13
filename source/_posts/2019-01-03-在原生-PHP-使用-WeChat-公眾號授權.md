---
title: 在原生 PHP 使用 WeChat 公眾號授權
date: 2019-01-03 22:26:01
tags: ["程式寫作", "PHP", "WeChat"]
categories: ["程式寫作", "PHP"]
---

## 安裝套件
使用 `EasyWeChat` 套件處理授權。
```
$ composer install overtrue/wechat
```

使用 `simplesoftwareio/simple-qrcode` 套件生成二維條碼。
```
$ composer install simplesoftwareio/simple-qrcode
```

引入第三方套件：
```PHP
require __DIR__ . '/vendor/autoload.php';

$app = \EasyWeChat\Factory::officialAccount([
    'app_id' => $config['app_id'],
    'secret' => $config['secret'],
    'token' => $config['token'],
    'oauth' => [
        'scopes'   => explode(',', $config['oauth']['scopes']),
        'callback' => $config['oauth']['callback'],
    ],
    'log' => [
        'level' => $config['log']['level'],
        'file' => __DIR__ . '/' . $config['log']['file'],
    ],
]);
```

生成登入條碼：
```PHP
$link = 'login.php' // 登入網址

echo (new \SimpleSoftwareIO\QrCode\BaconQrCodeGenerator)->size(500)->generate($link);
```

登入：
```PHP
$app->oauth->redirect()->send(); // 跳轉到微信方
```

回調：
```PHP
var_dump($app->oauth->user()); // 取得使用者資訊
```