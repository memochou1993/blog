---
title: 在 Laravel 5.7 使用 JSON Web Token 實作 API 認證
permalink: 在-Laravel-5-7-使用-JSON-Web-Token-實作-API-認證
date: 2018-11-03 01:55:05
tags: ["程式寫作", "PHP", "Laravel", "API", "JWT"]
categories: ["程式寫作", "PHP", "Laravel"]
---

## 環境
- Windows 10
- Homestead

## 新增專案
```
$ laravel new jwt
```

## 安裝套件
```
$ composer require tymon/jwt-auth 1.*
```

## 發布資源
```
$ php artisan vendor:publish --provider="Tymon\JWTAuth\Providers\LaravelServiceProvider"
```

## 生成密鑰
```
$ php artisan jwt:secret
```

## 修改模型
修改 `User` 模型。
```PHP
namespace App;

use Illuminate\Notifications\Notifiable;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Tymon\JWTAuth\Contracts\JWTSubject;

class User extends Authenticatable implements JWTSubject
{
    use Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'name', 'email', 'password',
    ];

    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        'password', 'remember_token',
    ];

    /**
     * Get the identifier that will be stored in the subject claim of the JWT.
     *
     * @return mixed
     */
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    /**
     * Return a key value array, containing any custom claims to be added to the JWT.
     *
     * @return array
     */
    public function getJWTCustomClaims()
    {
        return [];
    }
}
```

## 註冊靜態代理
在 `config/app.php` 新增靜態代理。
```PHP
'aliases' => [
    ...
    'JWTAuth' => 'Tymon\JWTAuth\Facades\JWTAuth',
    'JWTFactory' => 'Tymon\JWTAuth\Facades\JWTFactory',
],
```

## 修改認證設定
修改  `config/auth.php` 檔。
```PHP

    'defaults' => [
        'guard' => 'api', // 改成 api
        'passwords' => 'users',
    ],

    'guards' => [
        'web' => [
            'driver' => 'session',
            'provider' => 'users',
        ],

        'api' => [
            'driver' => 'jwt', // 改成 jwt
            'provider' => 'users',
        ],
    ],
```

## 新增填充
新增 `UsersTableSeeder` 填充。
```
$ php artisan make:seed UsersTableSeeder
```
在 `UsersTableSeeder.php` 檔新增一名測試用使用者資訊。
```PHP
public function run()
{
    App\User::create([
        'name' => 'test',
        'email' => 'test@gmail.com',
        'password' => app('hash')->make('secret'),
    ]);
}
```
執行遷移。
```
$ php artisan migrate --seed
```

## 新增控制器
新增 `AuthController` 控制器。
```PHP
namespace App\Http\Controllers;

use Illuminate\Http\Request;

class AuthController extends Controller
{
    /**
     * Create a new AuthController instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('auth:api')->except('login');
    }

    /**
     * Get a JWT via given credentials.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(Request $request)
    {
        $credentials = $request->only(['email', 'password']);

        if (! $token = auth()->attempt($credentials)) {
            return response()->json([
                'error' => 'Unauthorized'
            ], 401);
        }

        return $this->respondWithToken($token);
    }

    /**
     * Log the user out (Invalidate the token).
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout()
    {
        auth()->logout();

        return response()->json([
            'message' => 'Successfully logged out'
        ]);
    }

    /**
     * Get the token array structure.
     *
     * @param  string $token
     *
     * @return \Illuminate\Http\JsonResponse
     */
    protected function respondWithToken($token)
    {
        return response()->json([
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth()->factory()->getTTL() * 60
        ]);
    }
}
```
新增 `UserController` 控制器。
```PHP
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\User;

class UserController extends Controller
{
    public function index(User $user) {
        return $user->get();
    }
}
```

## 新增路由
在 `routes\api.php` 新增路由。
```PHP
Route::prefix('auth')->group(function () {
    Route::post('login', 'AuthController@login')->name('login');
    Route::post('logout', 'AuthController@logout')->name('logout');
});

Route::middleware('auth:api')->group(function () {
    Route::get('users', 'UserController@index');
});
```

## 發起 HTTP 請求
向 http://jwt.test/api/users 發起 `GET` 請求，得到回應如下：
```
[MethodNotAllowedHttpException] No message
```

在 `Accept` 輸入 `application/json` 可以得到以下回應：
```
{"message":"Unauthenticated."}
```

在 `Body` 輸入以下鍵値向 http://jwt.test/auth/login 發起 `POST` 請求：

Key	| Value
--- | ---
email | test@gmail.com
password | secret

得到回應如下：
```
{"token":"eyJ0e……bnWfg"}
```

最後在 `Headers` 輸入以下鍵値，再向 http://jwt.test/users 發起 `GET` 請求。
（Value 的部分為：Bearer + 空一格 + Token）

Key	| Value
--- | ---
Authorization | Bearer eyJ0e……bnWfg

結果得到回應如下：
```
[{"id":1,"name":"test","email":"test@gmail.com","email_verified_at":null,"created_at":"2018-11-02 17:34:07","updated_at":"2018-11-02 17:34:07"}]
```

## 程式碼
[GitHub](https://github.com/memochou1993/laravel-jwt)
