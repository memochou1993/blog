---
title: 認識 Laravel Service Container 服務容器
date: 2019-11-23 13:29:01
tags: ["程式設計", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 前言

Laravel 服務容器是管理類別依賴與執行依賴注入的工具。依賴注入指的是：類別的依賴透過建構子「注入」，或在某些情況下透過「setter」方法注入。

由於被注入的類別可以更容易地抽換成其他的實作，所以我們可以很容易地「mock」，或者建立一個假的類別實作來測試我們的應用程式。

## 簡易綁定

首先新增一個路由在 `routes/web.php` 檔。

```php
Route::get('pay', 'OrderController@store');
```

新增一個 `OrderController` 控制器。

```bash
php artisan make:controller OrderController
```

新增一個 `app/Billing/PaymentGateway.php` 檔，做為一個付款的閘道器。

```php
namespace App\Billing;

use Illuminate\Support\Str;

class PaymentGateway
{
    public function charge(int $amount)
    {
        return [
            'amount' => $amount,
            'confirmation_number' => Str::random(),
        ];
    }
}
```

修改 `OrderController` 控制器：

```php
namespace App\Http\Controllers;

use App\Billing\PaymentGateway;

class OrderController extends Controller
{
    public function store()
    {
        $paymentGateway = new PaymentGateway();

        dd($paymentGateway->charge(2500));
    }
}
```

結果：

```php
array:2 [▼
  "amount" => 2500
  "confirmation_number" => "XvS8O4BNLrhz6gUK"
]
```

修改 `OrderController` 控制器，將 `PaymentGateway` 閘道器改為依賴注入的方式：

```php
namespace App\Http\Controllers;

use App\Billing\PaymentGateway;

class OrderController extends Controller
{
    public function store(PaymentGateway $paymentGateway)
    {
        dd($paymentGateway->charge(2500));
    }
}
```

一樣可以運作：

```php
array:2 [▼
  "amount" => 2500
  "confirmation_number" => "iB3HK755ZMqo7ob0"
]
```

但是如果有參數要放進 `PaymentGateway` 閘道器的建構子，像是：

```php
namespace App\Billing;

use Illuminate\Support\Str;

class PaymentGateway
{
    private $currency;

    public function __construct(string $currency)
    {
        $this->currency = $currency;
    }

    public function charge(int $amount)
    {
        return [
            'amount' => $amount,
            'confirmation_number' => Str::random(),
            'currency' => $this->currency,
        ];
    }
}
```

就會出錯，因為我們沒有提供參數給它：

```php
Illuminate\Contracts\Container\BindingResolutionException
Unresolvable dependency resolving [Parameter #0 [ <required> string $currency ]] in class App\Billing\PaymentGateway
```

因此我們需要在 `app/Providers/AppServiceProvider.php` 服務提供者中註冊一個容器綁定。

首先透過 `$this->app` 物件屬性來取得整個應用程式容器，並使用 `bind()` 方法註冊一個綁定，傳遞一組希望綁定的類別或介面名稱作為第一個參數，接著第二個參數放入用來回傳類別實例的閉包。

```php
namespace App\Providers;

use App\Billing\PaymentGateway;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        $this->app->bind(PaymentGateway::class, function ($app) {
            return new PaymentGateway('NTD');
        });
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        //
    }
}
```

結果：

```php
array:3 [▼
  "amount" => 2500
  "confirmation_number" => "hZL4jafa5sxY942S"
  "currency" => "NTD"
]
```

如果有很多個控制器都需要使用這個閘道器，只需要從服務提供者修改參數即可，而不需要到每個控制器去修改。

## 單例綁定

接下來，在 `PaymentGateway` 閘道器建立一個 `setDiscount()` 方法，用來設置折扣金額：

```php
namespace App\Billing;

use Illuminate\Support\Str;

class PaymentGateway
{
    private $currency;

    private $discount = 0;

    public function __construct(string $currency)
    {
        $this->currency = $currency;
    }

    public function setDiscount(int $amount)
    {
        $this->discount = $amount;
    }

    public function charge(int $amount)
    {
        return [
            'amount' => $amount - $this->discount,
            'confirmation_number' => Str::random(),
            'currency' => $this->currency,
            'discount' => $this->discount,
        ];
    }
}
```

新增一個 `app/Order/OrderDetails.php` 檔，用來取得訂單資訊：

```php

namespace App\Order;

use App\Billing\PaymentGateway;

class OrderDetails
{
    private $paymentGateway;

    public function __construct(PaymentGateway $paymentGateway)
    {
        $this->paymentGateway = $paymentGateway;
    }

    public function all()
    {
        $this->paymentGateway->setDiscount(500);

        return [
            'name' => 'Memo Chou',
            'Address' => 'Taiwan',
        ];
    }
}
```

修改 `OrderController` 控制器，使用 `all()` 方法取得訂單：

```php
namespace App\Http\Controllers;

use App\Billing\PaymentGateway;
use App\Order\OrderDetails;

class OrderController extends Controller
{
    public function store(OrderDetails $orderDetails, PaymentGateway $paymentGateway)
    {
        $order = $orderDetails->all();

        dd($paymentGateway->charge(2500));
    }
}
```

結果：

```php
array:4 [▼
  "amount" => 2500
  "confirmation_number" => "YuVBGKPIqJMrjIij"
  "currency" => "NTD"
  "discount" => 0
]
```

由於被注入到 `OrderDetails` 類別和 `OrderController` 類別的 `PaymentGateway` 閘道器是兩個不同的實例，所以 `discount` 會是 0。

我們需要使用 `singleton()` 方法，將服務提供者所註冊的容器綁定改為單例。被綁定至容器中的類別或介面只會被解析一次，之後的呼叫都會從容器中回傳相同的實例。

```php
namespace App\Providers;

use App\Billing\PaymentGateway;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        $this->app->singleton(PaymentGateway::class, function ($app) {
            return new PaymentGateway('NTD');
        });
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        //
    }
}
```

結果：

```php
array:4 [▼
  "amount" => 2000
  "confirmation_number" => "F2MFaYLIKFfKl7sD"
  "currency" => "NTD"
  "discount" => 500
]
```

## 綁定介面至實作

由於付款方式可能不只一種，因此新增一個 `app/Billing/PaymentGatewayContract.php` 介面，讓所有的付款方式都去實作：

```php
namespace App\Billing;

interface PaymentGatewayContract
{
    public function setDiscount(int $amount);

    public function charge(int $amount);
}
```

將 `PaymentGateway` 閘道器重新命名為 `BankPaymentGateway` ，並實作 `PaymentGatewayContract` 介面。

```php
namespace App\Billing;

use Illuminate\Support\Str;

class BankPaymentGateway implements PaymentGatewayContract
{
    private $currency;

    private $discount = 0;

    public function __construct(string $currency)
    {
        $this->currency = $currency;
    }

    public function setDiscount(int $amount)
    {
        $this->discount = $amount;
    }

    public function charge(int $amount)
    {
        return [
            'amount' => $amount - $this->discount,
            'confirmation_number' => Str::random(),
            'currency' => $this->currency,
            'discount' => $this->discount,
        ];
    }
}
```

將 `OrderController` 控制器中注入的 `PaymentGateway` 閘道器改為 `PaymentGatewayContract` 介面：

```php
namespace App\Http\Controllers;

use App\Billing\PaymentGatewayContract;
use App\Order\OrderDetails;

class OrderController extends Controller
{
    public function store(OrderDetails $orderDetails, PaymentGatewayContract $paymentGateway)
    {
        $order = $orderDetails->all();

        dd($paymentGateway->charge(2500));
    }
}
```

將 `OrderDetails` 類別中注入的 `PaymentGateway` 閘道器也改為 `PaymentGatewayContract` 介面：

```php
namespace App\Order;

use App\Billing\PaymentGatewayContract;

class OrderDetails
{
    private $paymentGateway;

    public function __construct(PaymentGatewayContract $paymentGateway)
    {
        $this->paymentGateway = $paymentGateway;
    }

    public function all()
    {
        $this->paymentGateway->setDiscount(500);

        return [
            'name' => 'Memo Chou',
            'Address' => 'Taiwan',
        ];
    }
}
```

修改 `AppServiceProvider` 服務提供者，將原先綁定的 `PaymentGateway` 類別改為 `PaymentGatewayContract` 介面：

```php
namespace App\Providers;

use App\Billing\BankPaymentGateway;
use App\Billing\PaymentGatewayContract;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        $this->app->singleton(PaymentGatewayContract::class, function ($app) {
            return new BankPaymentGateway('NTD');
        });
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        //
    }
}
```

結果：

```php
array:4 [▼
  "amount" => 2000
  "confirmation_number" => "quDGIkn79T3dHWD1"
  "currency" => "NTD"
  "discount" => 500
]
```

接下來，新增一個 `CreditPaymentGateway` 閘道器，一樣也是實作 `PaymentGatewayContract` 介面：

```php
namespace App\Billing;

use Illuminate\Support\Str;

class CreditPaymentGateway implements PaymentGatewayContract
{
    private $currency;

    private $discount = 0;

    public function __construct(string $currency)
    {
        $this->currency = $currency;
    }

    public function setDiscount(int $amount)
    {
        $this->discount = $amount;
    }

    public function charge(int $amount)
    {
        $fees = $amount * 0.03;

        return [
            'amount' => $amount - $this->discount + $fees,
            'confirmation_number' => Str::random(),
            'currency' => $this->currency,
            'discount' => $this->discount,
            'fees' => $fees,
        ];
    }
}
```

如果要變更付款方式，只要在 `AppServiceProvider` 服務提供者將要綁定的實例改為 `CreditPaymentGateway` 閘道器即可。

```php
namespace App\Providers;

use App\Billing\CreditPaymentGateway;
use App\Billing\PaymentGatewayContract;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        $this->app->singleton(PaymentGatewayContract::class, function ($app) {
            return new CreditPaymentGateway('NTD');
        });
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        //
    }
}
```

結果：

```php
array:5 [▼
  "amount" => 2075.0
  "confirmation_number" => "jOM7mLCGYgIPR1B8"
  "currency" => "NTD"
  "discount" => 500
  "fees" => 75.0
]
```

如果要動態切換付款方式，只要將服務提供者修改如下即可：

```php
namespace App\Providers;

use App\Billing\BankPaymentGateway;
use App\Billing\CreditPaymentGateway;
use App\Billing\PaymentGatewayContract;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        $this->app->singleton(PaymentGatewayContract::class, function ($app) {
            switch (request()->payMethod) {
                case 'bank':
                    return new BankPaymentGateway('NTD');

                default:
                    return new CreditPaymentGateway('NTD');
            }
        });
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        //
    }
}
```

前往路由 `pay?payMethod=bank`，結果：

```php
array:4 [▼
  "amount" => 2000
  "confirmation_number" => "joHVe6Ah19wVZWx5"
  "currency" => "NTD"
  "discount" => 500
]
```

前往路由 `pay?payMethod=credit`，結果：

```php
array:5 [▼
  "amount" => 2075.0
  "confirmation_number" => "s2w2dkTw98XWbkhs"
  "currency" => "NTD"
  "discount" => 500
  "fees" => 75.0
]
```

## 建立服務提供者

新增一個獨立的服務提供者來處理付款。

```bash
php artisan make:provider PaymentServiceProvider
```

將原來寫在 `AppServiceProvider` 中的容器綁定移至 `PaymentServiceProvider` 中。

```php
namespace App\Providers;

use App\Billing\BankPaymentGateway;
use App\Billing\CreditPaymentGateway;
use App\Billing\PaymentGatewayContract;
use Illuminate\Support\ServiceProvider;

class PaymentServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     *
     * @return void
     */
    public function register()
    {
        $this->app->singleton(PaymentGatewayContract::class, function ($app) {
            switch (request()->payMethod) {
                case 'bank':
                    return new BankPaymentGateway('NTD');

                default:
                    return new CreditPaymentGateway('NTD');
            }
        });
    }

    /**
     * Bootstrap services.
     *
     * @return void
     */
    public function boot()
    {
        //
    }
}
```

在 `config/app.php` 設定檔中註冊一個服務提供者：

```php
'providers' => [

    // ...

    /*
    * Application Service Providers...
    */
    App\Providers\AppServiceProvider::class,
    App\Providers\AuthServiceProvider::class,
    // App\Providers\BroadcastServiceProvider::class,
    App\Providers\EventServiceProvider::class,
    App\Providers\RouteServiceProvider::class,
    App\Providers\PaymentServiceProvider::class, // 新增此行

    // ...

],
```

前往路由 `pay?payMethod=bank`，結果：

```php
array:4 [▼
  "amount" => 2000
  "confirmation_number" => "joHVe6Ah19wVZWx5"
  "currency" => "NTD"
  "discount" => 500
]
```

前往路由 `pay?payMethod=credit`，結果：

```php
array:5 [▼
  "amount" => 2075.0
  "confirmation_number" => "s2w2dkTw98XWbkhs"
  "currency" => "NTD"
  "discount" => 500
  "fees" => 75.0
]
```

## 參考資料

- [Laravel Service Container](https://laravel.com/docs/master/container)
- [Laravel 6 Advanced - Service Container](https://www.youtube.com/watch?v=_z9nzEUgro4)
