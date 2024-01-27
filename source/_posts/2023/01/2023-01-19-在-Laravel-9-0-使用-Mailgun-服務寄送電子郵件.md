---
title: 在 Laravel 9.0 使用 Mailgun 服務寄送電子郵件
date: 2023-01-19 21:56:36
tags: ["Programming", "PHP", "Laravel", "Mail"]
categories: ["Programming", "PHP", "Laravel"]
---

## 前置作業

首先在 [Mailgun](https://www.mailgun.com/) 服務註冊一個帳號，並且把要接收的電子郵件地址添加到「Authorized Recipients」列表中。

## 建立專案

建立專案。

```bash
laravel new example
cd example
```

修改 `.env` 檔。

```env
MAIL_MAILER=mailgun
MAIL_HOST=smtp.mailgun.org
MAIL_PORT=587
MAIL_USERNAME=your-mail-username
MAIL_PASSWORD=your-mail-password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="memochou1993@gmail.com"
MAIL_FROM_NAME="${APP_NAME}"

MAILGUN_DOMAIN=your-mailgun-domain
MAILGUN_SECRET=your-mailgun-secret
```

## 安裝套件

安裝套件。

```bash
composer require symfony/mailgun-mailer symfony/http-client
```

## 建立郵件類別

建立一個 `HelloEmail` 郵件類別。

```bash
php artisan make:mail HelloEmail
```

修改 `HelloEmail.php` 檔。

```php
<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class HelloEmail extends Mailable
{
    use Queueable, SerializesModels;

    /**
     * Create a new message instance.
     *
     * @return void
     */
    public function __construct()
    {
        //
    }

    /**
     * Get the message envelope.
     *
     * @return \Illuminate\Mail\Mailables\Envelope
     */
    public function envelope()
    {
        return new Envelope(
            subject: 'Hello Email',
        );
    }

    /**
     * Get the message content definition.
     *
     * @return \Illuminate\Mail\Mailables\Content
     */
    public function content()
    {
        return new Content(
            view: 'hello',
        );
    }

    /**
     * Get the attachments for the message.
     *
     * @return array
     */
    public function attachments()
    {
        return [];
    }
}
```

## 建立視圖

新增 `resources/views/hello.blade.php` 檔。

```html
<div>
    Hello, World!
</div>
```

## 寄送郵件

修改 `routes/api.php` 檔，新增一個測試路由。

```php
Route::get('/', function () {
    Mail::to('memochou1993@gmail.com')->send(new \App\Mail\HelloEmail());
});
```

使用 `curl` 指令呼叫測試路由，將 `HelloEmail` 郵件寄送出去。

```bash
curl --request GET --url http://127.0.0.1:8000/api
```

## 參考資料

- [Laravel - Mail](https://laravel.com/docs/9.x/mail)
