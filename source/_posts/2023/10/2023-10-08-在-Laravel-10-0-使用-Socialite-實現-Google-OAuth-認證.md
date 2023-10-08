---
title: 在 Laravel 10.0 使用 Socialite 實現 Google OAuth 認證
date: 2023-10-08 14:44:11
tags: ["程式設計", "PHP", "Laravel", "OAuth"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 前置作業

- 首先在 [Google Cloud](https://console.cloud.google.com/projectcreate) 頁面，建立一個專案。
- 啟用 Google+ API。
- 設定 OAuth 同意畫面
- 建立 OAuth 用戶端
  - 設定已授權的重新導向 URI：<http://localhost:8000/auth/google/callback>

## 實作

安裝依賴套件。

```bash
composer require laravel/socialite
```

修改 `.env` 檔。

```php
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-client-secret
GOOGLE_REDIRECT_URI=http://localhost:8000/auth/google/callback
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

新增 `app/Http/Controllers/Auth/GoogleController.php` 檔。

```php
namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Laravel\Socialite\Facades\Socialite;
use Laravel\Socialite\Two\AbstractProvider;

class GoogleController extends Controller
{
    const DRIVER = 'google';

    public function redirectToProvider()
    {
        /** @var AbstractProvider $provider */
        $provider = Socialite::driver(self::DRIVER);

        return $provider->stateless()->redirect();
    }

    public function handleProviderCallback()
    {
        /** @var AbstractProvider $provider */
        $provider = Socialite::driver(self::DRIVER);

        $providerUser = $provider->stateless()->user();

        $user = User::query()->firstOrCreate([
            'email' => $providerUser->email,
        ], [
            'name' => $providerUser->name,
            'email' => $providerUser->email,
        ]);

        $token = $user->createToken('')->plainTextToken;

        return response()->json(null)->withHeaders(['Access-Token' => $token]);
    }
}
```

啟動本地伺服器。

```bash
artisan serve
```

前往 <http://localhost:8000/auth/google> 瀏覽。

## 參考資料

- [Laravel Socialite](https://laravel.com/docs/10.x/socialite)
