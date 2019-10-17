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

申請 [CoinMarketCap](https://coinmarketcap.com/api/) 帳號，將 API Key 寫入 `.env` 檔中。

## 安裝套件

安裝套件。

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
        $quzzleClient = new GuzzleClient();

        $client = new Client($quzzleClient);

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

為了測試執行次數，將 `tests/Unit/Services` 資料夾的 `ClientTest.php` 檔修改為：

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

（未完）
