---
title: 使用 Laravel 9.0 建立 LINE Bot 聊天機器人
date: 2023-02-22 10:35:35
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
composer require linecorp/line-bot-sdk:^7.6
```

安裝 `laravel-dump-server` 測試工具。

```bash
composer require --dev beyondcode/laravel-dump-server
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
namespace App\Http\Controllers;

use Exception;
use Illuminate\Http\Request;
use LINE\LINEBot;
use LINE\LINEBot\Constant\HTTPHeader;
use LINE\LINEBot\Event\MessageEvent\TextMessage;
use LINE\LINEBot\HTTPClient\CurlHTTPClient;
use Symfony\Component\HttpFoundation\Response;

class WebhookController extends Controller
{
    function handleEvents(Request $request) {
        $channelToken = env('LINE_CHANNEL_ACCESS_TOKEN');
        $channelSecret = env('LINE_CHANNEL_SECRET');

        $httpClient = new CurlHTTPClient($channelToken);
        $bot = new LINEBot($httpClient, ['channelSecret' => $channelSecret]);

        $signature = $request->header(HTTPHeader::LINE_SIGNATURE);
        if (!$signature) {
            return response()->json(null, Response::HTTP_BAD_REQUEST);
        }

        try {
            $events = $bot->parseEventRequest($request->getContent(), $signature);
        } catch (Exception) {
            return response()->json(null, Response::HTTP_BAD_REQUEST);
        }

        collect($events)
            ->filter(fn ($event) => $event instanceof TextMessage)
            ->each(function ($event) use ($bot) {
                $replyText = $event->getText();
                try {
                    $bot->replyText($event->getReplyToken(), $replyText);
                } catch (Exception) {
                    response()->json(null, Response::HTTP_INTERNAL_SERVER_ERROR);
                }
            });

        return response()->json([], Response::HTTP_OK);
    }
}
```

修改 `routes/api.php` 檔。

```php
use App\Http\Controllers\WebhookController;
use Illuminate\Support\Facades\Route;

Route::post('/webhook', [WebhookController::class, 'handleEvents']);
```

啟動日誌工具。

```bash
artisan dump-server
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
