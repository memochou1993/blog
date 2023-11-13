---
title: 《現代 PHP》學習筆記（五）：Closure
date: 2018-05-22 10:24:41
tags: ["Programming", "PHP"]
categories: ["Programming", "PHP", "《現代 PHP》Study Notes"]
---

## 前言

本文為《現代 PHP》一書的學習筆記。

## 環境

- Windows 10
- XAMPP 3.2.2

## 閉包

> 閉包是個在創造時就封裝了內部狀態的函式，這個被封裝的狀態會一直被保存在閉包中，即使環境消失了。

閉包的例子如下：

範例 2-19：基本的閉包

```php
$closure = function ($name) {
    return sprintf('Hello %s', $name);
};

echo $closure("John");
```

- 建立了一個閉包物件，指派給了 `$closure` 變數。

閉包可以被當成是參數傳入其他的 PHP 函式。

範例 2-20：array_map 閉包

```php
$numbersPlusOne = array_map(function ($number) {
    return $number + 1;
}, [1, 2, 3]);

print_r($numbersPlusOne);
```

- `array_map()` 函式將自定義函式作用到陣列的每個元素，並返回帶有新値的陣列。

> 閉包和匿名函式（沒有名稱的函式）理論上是不同的事，不過 PHP 將他們視為相同。

PHP 使用 `use` 關鍵字來繫結狀態。

範例 2-21：繫節狀態到閉包

```php
function enclosePerson($name) {
    return function ($doCommand) use ($name) {
        return sprintf('%s, %s', $name, $doCommand);
    };
}

// 把 "Clay" 關閉在閉包中
$clay = enclosePerson('Clay');

// 呼叫閉包
echo $clay('get me sweet tea!');
```

> 可以利用 `use` 關鍵字傳入多個參數到閉包中，利用逗號區分參數。

`bindTo()` 方法經常被一些 PHP 框架用來當成對應 URL 路由到匿名回呼函式的方式。這使得在匿名函式中可以用 `$this` 關鍵字存取主要應用程式物件。

範例 2-22：利用 bindTo() 繫結閉包狀態

```php
class App
{
    protected $routes = [];
    protected $responseStatus = '200 OK';
    protected $responseContentType = 'text/html';
    protected $responseBody = 'Hello world';

    public function addRoute($routePath, $routeCallback)
    {
        // 將路由儲存至陣列，値是一個用來操作 App 實體狀態的回呼函式
        $this->routes[$routePath] = $routeCallback->bindTo($this, __CLASS__);
    }

    public function dispatch($currentPath)
    {
        foreach ($this->routes as $routePath => $callback) {
            // 如果目前路由是已註冊路由
            if ($routePath === $currentPath) {
                // 呼叫對應的路由回呼
                $callback();
            }
        }

        header('HTTP/1.1 ' . $this->responseStatus);
        header('Content-type: ' . $this->responseContentType);
        header('Content-length: ' . mb_strlen($this->responseBody));
        echo $this->responseBody;
    }
}

$app = new App();
// 註冊一條路由
$app->addRoute('/users/josh', function () {
    $this->responseContentType = 'application/json;charset=utf8';
    $this->responseBody = '{"name": "Josh"}';
});

// 目前路由
$app->dispatch('/users/josh');
```

- `bindTo()` 方法的第 2 個參數指定了閉包要連結的物件的類別。

> 利用 `bindTo()` 方法把一個物件的內部狀態連結到一個不同的物件。

## 參考資料

- Josh Lockhart（2015）。現代 PHP。台北市：碁峯資訊。
