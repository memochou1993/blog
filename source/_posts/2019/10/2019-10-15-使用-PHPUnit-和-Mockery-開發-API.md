---
title: 使用 PHPUnit 和 Mockery 開發 API
permalink: 使用-PHPUnit-和-Mockery-開發-API
date: 2019-10-15 22:34:57
tags: ["程式寫作", "PHP", "Laravel", "PHPUnit", "Mockery", "API"]
categories: ["程式寫作", "PHP", "Laravel"]
---

## 前言

本文為「[PHP 也有 Day #46：如何利用 PHPUnit + Mockery 開發 API？](https://www.youtube.com/watch?v=hpUjMnd81xw)」影片的學習筆記。

## 前置作業

申請 [CoinMarketCap](https://coinmarketcap.com/api/) 帳號。

## 建立專案

建立專案。

```BASH
laravel new coin
```

將 API Key 寫入專案的 `.env` 檔：

```ENV
CMC_PRO_API_KEY=5d8af388-xxxx-xxxx-xxxx-5b4ea08b7438
```

修改 `phpunit.xml` 檔，新增 `CMC_PRO_API_KEY` 環境變數：

```XML
<?xml version="1.0" encoding="UTF-8"?>
<phpunit backupGlobals="false"
         backupStaticAttributes="false"
         bootstrap="vendor/autoload.php"
         colors="true"
         convertErrorsToExceptions="true"
         convertNoticesToExceptions="true"
         convertWarningsToExceptions="true"
         processIsolation="false"
         stopOnFailure="false">
    <testsuites>
        <testsuite name="Unit">
            <directory suffix="Test.php">./tests/Unit</directory>
        </testsuite>

        <testsuite name="Feature">
            <directory suffix="Test.php">./tests/Feature</directory>
        </testsuite>
    </testsuites>
    <filter>
        <whitelist processUncoveredFilesFromWhitelist="true">
            <directory suffix=".php">./app</directory>
        </whitelist>
    </filter>
    <php>
        <server name="APP_ENV" value="testing"/>
        <server name="BCRYPT_ROUNDS" value="4"/>
        <server name="CACHE_DRIVER" value="array"/>
        <server name="MAIL_DRIVER" value="array"/>
        <server name="QUEUE_CONNECTION" value="sync"/>
        <server name="SESSION_DRIVER" value="array"/>
        <server name="CMC_PRO_API_KEY" value=""/>
    </php>
</phpunit>
```

## 安裝套件

安裝 `guzzlehttp/guzzle` 套件。

```BASH
composer require guzzlehttp/guzzle
```

## 做法

在 `app` 資料夾新增 `Services/Client.php` 檔：

```PHP
namespace App\Services;

use GuzzleHttp\Client as GuzzleClient;

class Client
{
    protected $client;

    public function __construct(GuzzleClient $client)
    {
        $this->client = $client;
    }

    public function query()
    {
        $response = $this->client->request('GET', 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest', [
            'headers' => [
                'X-CMC_PRO_API_KEY' => env('CMC_PRO_API_KEY'),
            ],
        ]);

        dump($response->getBody()->getContents());
    }
}
```

在 `tests/Unit` 資料夾新增 `Services/ClientTest.php` 檔：

```PHP
namespace Tests\Unit\Services;

use App\Services\Client;
use PHPUnit\Framework\TestCase;
use GuzzleHttp\Client as GuzzleClient;

class ClientTest extends TestCase
{
    /** @test */
    public function testQuery()
    {
        $guzzleClient = new GuzzleClient();

        $client = new Client($guzzleClient);

        $client->query();
    }
}
```

執行測試。

```BASH
phpunit

OK, but incomplete, skipped, or risky tests!
```

修改 `app/Services` 資料夾的 `Client.php` 檔，以獲取用來測試的資料：

```PHP
namespace App\Services;

use GuzzleHttp\Client as GuzzleClient;

class Client
{
    protected $client;

    public function __construct(GuzzleClient $client)
    {
        $this->client = $client;
    }

    public function query()
    {
        $response = $this->client->request('GET', 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest', [
            'headers' => [
                'X-CMC_PRO_API_KEY' => env('CMC_PRO_API_KEY'),
            ],
        ]);

        $results = (string) $response->getBody()->getContents();

        file_put_contents(base_path('tests/Unit/Services/result.json'), $results);
    }
}
```

執行測試。

```BASH
phpunit

OK, but incomplete, skipped, or risky tests!
```

使用 Mockery 假造物件，將 `tests/Unit/Services` 資料夾的 `ClientTest.php` 檔修改為：

```PHP
namespace Tests\Unit\Services;

use Mockery;
use App\Services\Client;
use GuzzleHttp\Psr7\Response;
use PHPUnit\Framework\TestCase;
use GuzzleHttp\Client as GuzzleClient;

class ClientTest extends TestCase
{
    /** @test */
    public function testQuery()
    {
        /** @var \GuzzleHttp\Client $guzzleClient */
        $guzzleClient = Mockery::mock(GuzzleClient::class);
        $guzzleClient->shouldReceive('request')->andReturn(
            new Response('200', [], file_get_contents(__DIR__.'/result.json'))
        );

        $client = new Client($guzzleClient);

        $this->assertEquals([
            'USD' => [
                'price' => 8004.20129962,
                'volume_24h' => 16527569995.0296,
                'percent_change_1h' => 0.0534322,
                'percent_change_24h' => -3.30471,
                'percent_change_7d' => -5.0892,
                'market_cap' => 144038403857.11676,
                'last_updated' => '2019-10-16T15:52:37.000Z'
            ],
        ], $client->query('BTC'));
    }
}
```

修改 `app/Services` 資料夾的 `Client.php` 檔：

```PHP
namespace App\Services;

use Illuminate\Support\Arr;
use GuzzleHttp\Client as GuzzleClient;

class Client
{
    protected $client;

    public function __construct(GuzzleClient $client)
    {
        $this->client = $client;
    }

    public function query($symbol = 'BTC')
    {
        $response = $this->client->request('GET', 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest', [
            'headers' => [
                'X-CMC_PRO_API_KEY' => env('CMC_PRO_API_KEY'),
            ],
        ]);

        $results = json_decode($response->getBody()->getContents(), true);

        $item = collect($results['data'])->where('symbol', $symbol)->first();

        return Arr::get($item, 'quote');
    }
}
```

執行測試。

```BASH
phpunit

OK
```

為了測試程式碼的執行次數，將 `tests/Unit/Services` 資料夾的 `ClientTest.php` 檔修改為：

```PHP
namespace Tests\Unit\Services;

use Mockery;
use App\Services\Client;
use GuzzleHttp\Psr7\Response;
use PHPUnit\Framework\TestCase;
use GuzzleHttp\Client as GuzzleClient;

class ClientTest extends TestCase
{
    /** @test */
    public function testQuery()
    {
        /** @var \GuzzleHttp\Client $guzzleClient */
        $guzzleClient = Mockery::mock(GuzzleClient::class);
        $guzzleClient->shouldReceive('request')->andReturn(
            new Response('200', [], file_get_contents(__DIR__.'/result.json'))
        )->once();

        $client = new Client($guzzleClient);

        $this->assertEquals([
            'USD' => [
                'price' => 8004.20129962,
                'volume_24h' => 16527569995.0296,
                'percent_change_1h' => 0.0534322,
                'percent_change_24h' => -3.30471,
                'percent_change_7d' => -5.0892,
                'market_cap' => 144038403857.11676,
                'last_updated' => '2019-10-16T15:52:37.000Z'
            ],
        ], $client->query('BTC'));
    }

    protected function tearDown(): void
    {
        parent::tearDown();

        Mockery::close();
    }
}
```

執行測試。

```BASH
phpunit

OK
```

為了測試沒有回傳值的程式碼，需要使用 Mockery 的 `spy` 方法。將 `tests/Unit/Services` 資料夾的 `ClientTest.php` 檔修改為：

```PHP
namespace Tests\Unit\Services;

use Mockery;
use App\Services\Log;
use App\Services\Client;
use GuzzleHttp\Psr7\Response;
use PHPUnit\Framework\TestCase;
use GuzzleHttp\Client as GuzzleClient;

class ClientTest extends TestCase
{
    /** @test */
    public function testQuery()
    {
        /** @var \GuzzleHttp\Client $guzzleClient */
        $guzzleClient = Mockery::mock(GuzzleClient::class);
        $guzzleClient->shouldReceive('request')->andReturn(
            new Response('200', [], file_get_contents(__DIR__.'/result.json'))
        )->once();

        /** @var \App\Services\Log $log */
        $log = Mockery::spy(Log::class);

        $client = new Client($guzzleClient, $log);

        $this->assertEquals([
            'USD' => [
                'price' => 8004.20129962,
                'volume_24h' => 16527569995.0296,
                'percent_change_1h' => 0.0534322,
                'percent_change_24h' => -3.30471,
                'percent_change_7d' => -5.0892,
                'market_cap' => 144038403857.11676,
                'last_updated' => '2019-10-16T15:52:37.000Z'
            ],
        ], $client->query('BTC'));

        $key = env('CMC_PRO_API_KEY');
        $log->shouldHaveReceived('info')->with($key);
    }

    protected function tearDown(): void
    {
        parent::tearDown();

        Mockery::close();
    }
}
```

在 `app` 資料夾新增 `Services/Log.php` 檔：

```PHP
namespace App\Services;

class Log
{
    public function info()
    {
        //
    }
}
```

修改 `app/Services` 資料夾的 `Client.php` 檔：

```PHP
namespace App\Services;

use Illuminate\Support\Arr;
use GuzzleHttp\Client as GuzzleClient;

class Client
{
    protected $client;

    protected $log;

    public function __construct(GuzzleClient $client, Log $log)
    {
        $this->client = $client;
        $this->log = $log;
    }

    public function query($symbol = 'BTC')
    {
        $key = env('CMC_PRO_API_KEY');
        $this->log->info($key);

        $response = $this->client->request('GET', 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest', [
            'headers' => [
                'X-CMC_PRO_API_KEY' => $key,
            ],
        ]);

        $results = json_decode($response->getBody()->getContents(), true);

        $item = collect($results['data'])->filter(function ($item) use ($symbol) {
            return $item['symbol'] === trim(strtoupper($symbol));
        })->first();

        return Arr::get($item, 'quote');
    }
}
```

執行測試。

```BASH
phpunit

OK
```

在路由使用 Client 服務：

```PHP
Route::get('/', function (\App\Services\Client $client) {
    return $client->query();
});
```

結果：

```JSON
{
  "USD": {
    "price": 7967.28751166,
    "volume_24h": 13325927512.1252,
    "percent_change_1h": -0.136658,
    "percent_change_24h": 0.142715,
    "percent_change_7d": -4.86056,
    "market_cap": 143417748222.07712,
    "last_updated": "2019-10-19T12:19:34.000Z"
  }
}
```
