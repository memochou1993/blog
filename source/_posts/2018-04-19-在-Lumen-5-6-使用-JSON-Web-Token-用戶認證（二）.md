---
title: 在 Lumen 5.6 使用 JSON Web Token 用戶認證（二）
date: 2018-04-19 10:16:01
tags: ["程式寫作", "PHP", "Laravel", "Lumen"]
---

## 前言
本文為參考〈[Developing RESTful APIs with Lumen](https://auth0.com/blog/developing-restful-apis-with-lumen/)〉一文的學習筆記。

## 環境
- Windows 7
- Apache 2.4.33
- MySQL 5.7.21
- PHP 7.2.4

## 安裝 Postman
到 [Postman](https://www.getpostman.com/) 下載電腦安裝版。

## 新增遷移
新增 `users` 資料表。
```
$ php artisan make:migration create_users_table
```
配置欄位。
```PHP
Schema::create('users', function (Blueprint $table) {
    $table->increments('id');
    $table->string('name');
    $table->string('email');
    $table->string('password');
    $table->timestamps();
});
```

## 新增填充
新增 `UsersTableSeeder` 填充。
```
$ php artisan make:seeder UsersTableSeeder
```
建立一名測試用使用者帳號。
```PHP
App\User::create([
    'name' => 'test',
    'email' => 'test@gmail.com',
    'password' => app('hash')->make('secret'),
]);
```
執行遷移。
```
$ php artisan migrate --seed
```

## 新增模型
手動在 `app` 資料夾新增 `User` 模型。
```PHP
...
use Tymon\JWTAuth\Contracts\JWTSubject; // 調用相關類別

// 擴展相關類別
class User extends Model implements AuthenticatableContract, AuthorizableContract, JWTSubject
{
    ...
}
```
配置可寫入欄位。
```PHP
protected $fillable = [
    'name', 'email',
];

protected $hidden = [
    'password',
];
```

## 新增路由
```PHP
$router->post('auth/login', 'AuthController@login');

$router->group(['middleware' => 'auth:api'], function($router) {
    $router->get('/', ['as' =>'index', 'uses' => 'UserController@index']);
});
```

## 新增控制器
手動在 `app\Http\Controllers` 資料夾新增 `UserController` 控制器。
```PHP
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Auth;
use App\User;

class UserController extends Controller
{
    public function index(Request $request) {
        return response()->json(Auth::user());
    }
}
```
手動在 `app\Http\Controllers` 資料夾再新增 `AuthController` 控制器。
```PHP
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Tymon\JWTAuth\JWTAuth;

class AuthController extends Controller
{
    protected $jwt;

    public function __construct(JWTAuth $jwt)
    {
        $this->jwt = $jwt;
    }

    public function login(Request $request)
    {
        if (!$token = $this->jwt->attempt($request->only('email', 'password'))) {
            return response()->json(['user_not_found'], 404);
        }

        return response()->json(compact('token'));
    }
}
```
## 進行 HTTP 請求測試
向 http://localhost/lumen/public 發起 `GET` 請求，得到回應如下：
```
Unauthorized.
```
再向 http://localhost/lumen/public/auth/login 給 `Body` 輸入以下鍵値發起 `POST` 請求：

Key	| Value
--- | ---
email | test@test.com
password | secret

得到回應如下：
```
{"token":"eyJ0e......q5o0M"}
```
最後再向 http://localhost/lumen/public 給 `Headers` 輸入以下鍵値發起 `GET` 請求。
（Value 的部分為：Bearer + 空一格 + Token）

Key	| Value
--- | ---
Authorization | Bearer eyJ0e……q5o0M

結果得到回應如下：
```
{"id":2,"name":"Tester","email":"test@test.com","created_at":"2018-04-19 11:38:53","updated_at":"2018-04-19 11:38:53"}
```

## 程式碼
[GitHub](https://github.com/memochou1993/lumen-jwt)