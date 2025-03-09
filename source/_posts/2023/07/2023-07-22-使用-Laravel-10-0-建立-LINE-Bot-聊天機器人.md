---
title: 使用 Laravel 10.0 建立 LINE Bot 聊天機器人
date: 2023-07-22 23:35:08
tags: ["Programming", "PHP", "Laravel", "LINE", "chatbot"]
categories: ["Programming", "PHP", "Laravel"]
---

## 做法

建立專案。

```bash
laravel new line-bot-laravel
cd line-bot-laravel
```

安裝 LINE Bot SDK 套件。

```bash
composer require linecorp/line-bot-sdk:^8.1
```

修改 `.env` 檔。

```env
LINE_CHANNEL_ACCESS_TOKEN=line-channel-access-token
LINE_CHANNEL_SECRET=line-channel-secret
```

建立控制器。

```bash
artisan make:controller WebhookController
```

修改 `WebhookController.php` 檔。

```php
<?php

namespace App\Http\Controllers;

use GuzzleHttp\Client;
use Illuminate\Http\Request;
use LINE\Clients\MessagingApi\Api\MessagingApiApi;
use LINE\Clients\MessagingApi\Configuration;
use LINE\Clients\MessagingApi\Model\ReplyMessageRequest;
use LINE\Clients\MessagingApi\Model\TextMessage;
use LINE\Constants\HTTPHeader;
use LINE\Constants\MessageType;
use LINE\Parser\EventRequestParser;
use LINE\Parser\Exception\InvalidEventRequestException;
use LINE\Parser\Exception\InvalidSignatureException;
use LINE\Webhook\Model\MessageEvent;
use LINE\Webhook\Model\TextMessageContent;
use Symfony\Component\HttpFoundation\Response;

class WebhookController extends Controller
{
    public function __invoke(Request $request)
    {
        $config = new Configuration();
        $config->setAccessToken(env('LINE_CHANNEL_ACCESS_TOKEN'));
        $client = new MessagingApiApi(new Client(), $config);

        $signature = $request->header(HTTPHeader::LINE_SIGNATURE);
        if (!$signature) {
            abort(Response::HTTP_BAD_REQUEST);
        }

        try {
            $secret = env('LINE_CHANNEL_SECRET');
            $parsedEvents = EventRequestParser::parseEventRequest($request->getContent(), $secret, $signature);
        } catch (InvalidSignatureException) {
            abort(Response::HTTP_BAD_REQUEST);
        } catch (InvalidEventRequestException) {
            abort(Response::HTTP_BAD_REQUEST);
        }

        collect($parsedEvents->getEvents())
            ->filter(fn ($event) => $event instanceof MessageEvent)
            ->filter(fn ($event) => $event->getMessage() instanceof TextMessageContent)
            ->each(function ($event) use ($client) {
                $replyText = $event->getMessage()->getText();

                $client->replyMessage(new ReplyMessageRequest([
                    'replyToken' => $event->getReplyToken(),
                    'messages' => [
                        new TextMessage([
                            'type' => MessageType::TEXT,
                            'text' => $replyText,
                        ]),
                    ],
                ]));
            });

        return response()->json(null);
    }
}
```

修改 `routes/api.php` 檔。

```php
use App\Http\Controllers\WebhookController;
use Illuminate\Support\Facades\Route;

Route::post('/webhook', WebhookController::class);
```

啟動本地伺服器。

```bash
artisan server
```

使用 `ngrok` 指令，啟動一個 HTTP 代理伺服器，將本地埠映射到外部網址。

```bash
ngrok http 8000
```

在 LINE 平台上，修改 Webhook URL：<https://xxx.jp.ngrok.io/api/webhook>

認證 Webhook URL，並使用手機測試訊息。

## 程式碼

- [line-bot-laravel](https://github.com/memochou1993/line-bot-laravel)

## 參考資料

- [line/line-bot-sdk-php](https://github.com/line/line-bot-sdk-php)
