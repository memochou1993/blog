---
title: 《現代 PHP》學習筆記（一）：Namespace
date: 2018-05-16 10:22:03
tags: ["程式設計", "PHP"]
categories: ["程式設計", "PHP", "《現代 PHP》學習筆記"]
---

## 前言

本文為《現代 PHP》一書的學習筆記。

## 環境

- Windows 10
- XAMPP 3.2.2

## 現代的 PHP

1. PHP 程式語言正在歷經像是文藝復興的時代。
2. Composer 套件相依性管理工具對如何建立 PHP 應用程式有了革命性的影響。
3. PHP 在剛開始是 Rasmus Lerdorf 寫的一些 CGI 腳本片段，被命名為 Personal Home Page Tools。
4. 1998 年發布 PHP 3，是跟我們現在熟知的 PHP 最相像的第一個版本，重新被命名為 Hypertext Preprocessor。
5. Sara Golemon 和 Facebook 在 2014 年 O'Reilly 的 OSCON 會議上宣布了第一個 PHP 規範草案，可以在 GitHub 上閱讀內文。
6. PHP 引擎是一個可以解析、直譯和執行 PHP 程式碼的程式，如 Zend Engine 和 HipHop Virtual Machine。
7. 現在是個成為 PHP 程式設計師的好時機。

## 名稱空間

> 名稱空間（Namespace）可以創造出獨立於其他開發者的程式，避免和其他開發者的程式碼使用重複的類別、介面、函式或常數名稱。

名稱空間的例子如下：

```PHP
namespace Symfony\Component\HttpFoundation;
```

- 名稱空間宣告以 `namespace` 為開頭，接著一個空白字元，然後是名稱空間的名稱，最後是一個結束的分號「`;`」字元。

這裡下載作者提供的範例進行實作：

```BASH
git clone https://github.com/codeguy/modern-php.git
```

> 最重要的名稱空間是服務提供者名稱空間，這是最上層的名稱空間，用來識別其品牌或機構，必須在全域空間保持唯一。

透過「匯入」，只需要在一開始輸入一次完整的名稱空間。

範例 2-1：不使用別名的名稱空間

```PHP
require 'vendor/autoload.php';

$response = new \Symfony\Component\HttpFoundation\Response('Oops', 400);
$response->send();
```

- 使用 `Symfony HttpFoundation` 元件，可以輕鬆處理 HTTP 請求（Request）和響應（Response）。
- 用瀏覽器打開網路監控器（Network），看見 HTTP 狀態是 `400`。

範例 2-2：使用預設別名的名稱空間

```PHP
require 'vendor/autoload.php';

use Symfony\Component\HttpFoundation\Response;

$response = new Response('Oops', 400);
$response->send();
```

- 使用 `use` 關鍵字告訴 PHP 要使用的類別，只需要完整輸入一次。

範例 2-3：使用自訂別名的名稱空間

```PHP
require 'vendor/autoload.php';

use Symfony\Component\HttpFoundation\Response as Res;

$r = new Res('Oops', 400);
$r->send();
```

- 在匯入的宣告後面加上 `as Res`，PHP 會將 `Res` 當作 `Response` 類別的別名。

> 使用 `use` 關鍵字來匯入程式碼，應當緊接著在 `<?php` 標籤或名稱空間宣告之後。

若是要匯入函式，使用 `use function`：

```PHP
use function Namespace\functionName;

functionName();
```

- 書中誤植為 `use func`。

實作：

```PHP
namespace Foo\Bar {
    function foo() {
        return true;
    }
}

namespace {
    use function Foo\Bar\foo;
    echo foo();
}
```

若是要匯入常數，使用 `use const`：

```PHP
use const Namespace\CONST_NAME;

echo CONST_NAME;
```

- 書中誤植為 `use constant`。

實作：

```PHP
namespace Foo\Bar {
    const FOO = true;
}

namespace {
    use const Foo\Bar\FOO;
    echo FOO;
}
```

多重匯入：

```PHP
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Cookie;
```

有一些程式碼可能並沒有名稱空間，所以將存在於全域名稱空間，例如內建的 `Exception`。

範例 2-4：在其他名稱空間中使用不正確的類別名稱

```PHP
namespace My\App;

class Foo
{
    public function doSomething()
    {
        $exception = new Exception();
    }
}
```

- 使用 `doSomething()` 方法將會出現如 `Class 'My\App\Exception' not found` 的錯誤訊息。

範例 2-5：在其他名稱空間中使用正確的類別名稱

```PHP
namespace My\App;

class Foo
{
    public function doSomething()
    {
        throw new \Exception();
    }
}
```

- 在其他名稱空間中把類別、介面、函式或常數名稱的前面加上「`\`」字元，藉此存取全域性的名稱變數。

> 名稱空間也為由 PHP-FIG 創立的 PSR-4 自動載入器標準提供了基礎。

## 參考資料

- Josh Lockhart（2015）。現代 PHP。台北市：碁峯資訊。
