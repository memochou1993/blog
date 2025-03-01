---
title: 在 Laravel 10.0 使用 Socialite 和 Sanctum 實現 Google 登入機制
date: 2023-10-08 14:44:11
tags: ["Programming", "PHP", "Laravel", "OAuth"]
categories: ["Programming", "PHP", "Laravel"]
---

## 前置作業

- 首先在 [Google Cloud](https://console.cloud.google.com/projectcreate) 頁面，建立一個專案。
- 啟用 Google+ API。
- 設定 OAuth 同意畫面
- 建立 OAuth 用戶端
  - 設定已授權的重新導向 URI：<http://localhost:3000/auth/google/callback>

## 實作

### 後端

安裝依賴套件。

```bash
composer require laravel/socialite
```

修改 `.env` 檔。

```php
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-client-secret
GOOGLE_REDIRECT_URI=http://localhost:3000/auth/google/callback
```

修改 `config/services.php` 檔。

```php
'google' => [
    'client_id' => env('GOOGLE_CLIENT_ID'),
    'client_secret' => env('GOOGLE_CLIENT_SECRET'),
    'redirect' => env('GOOGLE_REDIRECT_URI'),
],
```

修改 `database/migrations/create_package_user_table.php` 檔。

```php
public function up(): void
{
    Schema::create('users', function (Blueprint $table) {
        // ...
        $table->string('password')->nullable();
        // ...
    });
}
```

修改 `routes/api.php` 檔。

```php
Route::prefix('auth/{provider}')->group(function () {
    Route::get('/', [ProviderController::class, 'redirect']);
    Route::get('callback', [ProviderController::class, 'handleCallback']);
});
```

新增 `app/Http/Controllers/Auth/GoogleController.php` 檔。

```php
<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Laravel\Socialite\Facades\Socialite;
use Laravel\Socialite\Two\AbstractProvider;

class ProviderController extends Controller
{
    private $available = [
        'google',
    ];

    public function redirect($provider)
    {
        if (!in_array($provider, $this->available)) {
            abort(Response::HTTP_NOT_FOUND);
        }

        /** @var AbstractProvider $provider */
        $provider = Socialite::driver($provider);

        return $provider->stateless()->redirect();
    }

    public function handleCallback(Request $request, $provider)
    {
        if (!in_array($provider, $this->available)) {
            abort(Response::HTTP_NOT_FOUND);
        }

        $request->validate([
            'code' => 'required',
        ]);

        /** @var AbstractProvider $provider */
        $provider = Socialite::driver($provider);

        $providerUser = $provider->stateless()->user();

        $user = User::query()->firstOrCreate([
            'email' => $providerUser->email,
        ], [
            'name' => $providerUser->name,
            'email' => $providerUser->email,
        ]);

        $token = $user->createToken('')->plainTextToken;

        return response()->json(compact('token'));
    }
}
```

### 前端

建立一個跳轉函式，當使用者按下按鈕後，頁面將由後端帶往至 Google 登入頁面。。

```js
const signInWithGoogle = () => {
  window.location.href = 'http://localhost:8000/api/auth/google';
};
```

新增 `pages/auth/google/callback.vue` 檔。當使用者從 Google 登入頁面導回前端時，前端就可以將 `code` 發送至後端處理。

```html
<script setup>
const route = useRoute();

const { code } = route.query;

const { data } = await useFetch('http://127.0.0.1:8000/api/auth/google/callback', {
  ssr: false,
  method: 'GET',
  params: {
    provider: 'google',
    code,
  },
});

console.log(data.value);
</script>

<template>
  <div />
</template>
```

## 參考資料

- [Laravel Socialite](https://laravel.com/docs/10.x/socialite)
