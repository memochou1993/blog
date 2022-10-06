---
title: 在 Laravel 5.7 使用 Broadcasting 廣播系統
date: 2019-02-22 11:18:36
tags: ["程式設計", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 環境

- Laradock
- Horizon

## 後端

建立專案。

```bash
laravel new echo
```

安裝 `predis/predis` 套件。

```bash
composer require predis/predis
```

修改 `.env` 檔。

```env
BROADCAST_DRIVER=redis #改為 redis
CACHE_DRIVER=file
QUEUE_CONNECTION=redis #改為 redis
SESSION_DRIVER=file
SESSION_LIFETIME=120
```

修改 `config/app.php` 檔，取消註解。

```php
'providers' => [
    // ...
    App\Providers\BroadcastServiceProvider::class,
    // ...
]
```

建立事件。

```bash
php artisan make:event BroadcastEvent
```

修改 `app/Events/BroadcastEvent.php` 檔。

```php
namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Queue\SerializesModels;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;

class BroadcastEvent implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $message;

    /**
     * Create a new event instance.
     *
     * @return void
     */
    public function __construct($message)
    {
        $this->message = $message;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return \Illuminate\Broadcasting\Channel|array
     */
    public function broadcastOn()
    {
        return new Channel('news');
    }
}
```

新增路由。

```php
Route::post('/send', function(\Illuminate\Http\Request $request){
    event(new \App\Events\BroadcastEvent($request->message));
    return response($request->message);
});
```

## 前端

安裝前端套件。

```bash
npm install
npm install -g laravel-echo-server
npm install --save laravel-echo pusher-js
```

修改 `resources/js/bootstrap.js` 檔。

```js
/**
 * Echo exposes an expressive API for subscribing to channels and listening
 * for events that are broadcast by Laravel. Echo and event broadcasting
 * allows your team to easily build robust real-time web applications.
 */

import Echo from 'laravel-echo'

window.io = require('socket.io-client');

window.Echo = new Echo({
    broadcaster: 'socket.io',
    host: window.location.hostname + ':6001'
});
```

修改 `resources/js/components/ExampleComponent.vue` 元件。

```html
<form action="">
    <input type="text" v-model="message">
    <input type="submit" @click.prevent="submit">
</form>

<script>
    export default {
        mounted() {
            console.log('Component mounted.')
        },
        data() {
            return {
                message: ''
            }
        },
        methods: {
            submit() {
                axios.post('/send', {
                    message: this.message
                })
                .then(response => {
                    console.log(response)
                })
                this.message = ''
            }
        }
    }
</script>
```

修改 `resources/views/welcome.blade.php` 檔，並註冊元件。

```html
<!doctype html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <!-- CSRF Protection -->
        <meta name="csrf-token" content="{{ csrf_token() }}">
        <title>Laravel</title>
    </head>
    <body>
        <div id="app">
            <div class="content">
                <!-- 註冊元件 -->
                <example-component></example-component>
            </div>
        </div>

        <script src="{{ asset('js/app.js') }}"></script>
        <!-- 監聽事件 -->
        <script>
            window.Echo.channel('news')
                .listen('BroadcastEvent', (e) => {
                console.log(e.message);
            });
        </script>
    </body>
</html>
```

執行編譯。

```bash
npm run watch-poll
```

初始化 `laravel-echo-server` 服務。

```bash
laravel-echo-server init
```

啟動 `laravel-echo-server` 服務。

```bash
laravel-echo-server start
```

前往 <http://echo.test/> 瀏覽。
