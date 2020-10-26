---
title: 實作基於 Webhook 的「翻譯管理系統」（二）：客戶端 PHP 套件
permalink: 實作基於-Webhook-的「翻譯管理系統」（二）：客戶端-PHP-套件
date: 2020-10-27 14:08:34
tags: ["程式設計", "PHP", "Laravel", "Localization", "Lexicon", "套件開發"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 前言

此套件的目的是封裝 Guzzle HTTP 套件，使客戶端在不需要知道 API 路徑的情況下，就能夠透過套件所提供的方法獲取服務端的資源。

## 核心

在 `Client` 類別中，定義了 `fetchProject` 方法，此方法可以向服務端獲取專案的所有翻譯鍵以及翻譯值。

```PHP
declare(strict_types=1);

namespace MemoChou1993\Lexicon;

use GuzzleHttp\Client as GuzzleClient;
use GuzzleHttp\Exception\GuzzleException;
use Psr\Http\Message\ResponseInterface;

class Client
{
    /**
     * @var GuzzleClient $client
     */
    private GuzzleClient $client;

    /**
     * @var array $config
     */
    private array $config;

    /**
     * @param array $config
     */
    public function __construct(array $config = [])
    {
        $this->config = array_merge(
            [
                'host' => getenv('LEXICON_HOST') ?: null,
                'api_key' => getenv('LEXICON_API_KEY') ?: null,
            ],
            $config,
        );
    }

    /**
     * @return string
     */
    protected function host(): string
    {
        return $this->config['host'];
    }

    /**
     * @return string
     */
    protected function apiKey(): string
    {
        return $this->config['api_key'];
    }

    /**
     * @return array
     */
    protected function headers(): array
    {
        return [
            'Authorization' => sprintf('Bearer %s', $this->apiKey()),
        ];
    }

    /**
     * @return array
     */
    protected function options(): array
    {
        return [
            'headers' => $this->headers(),
        ];
    }

    /**
     * @return GuzzleClient
     */
    protected function getClient(): GuzzleClient
    {
        return $this->client ?? $this->createClient();
    }

    /**
     * @return GuzzleClient
     */
    protected function createClient(): GuzzleClient
    {
        $this->client = new GuzzleClient([
            'base_uri' => $this->host(),
        ]);

        return $this->client;
    }

    /**
     * @return ResponseInterface
     * @throws GuzzleException
     */
    public function fetchProject(): ResponseInterface
    {
        try {
            return $this->getClient()->get('/api/project', $this->options());
        } catch (GuzzleException $e) {
            throw $e;
        }
    }
}
```

## 使用

安裝套件。

```PHP
composer require memochou1993/lexicon-api-php-client
```

複製 `.env.example` 範本到 `.env` 檔：

```
LEXICON_HOST=
LEXICON_API_KEY=
```

- `LEXICON_HOST` 參數是服務端的網址。
- `LEXICON_API_KEY` 參數是客戶端向服務端存取資源的 API 金鑰。

初始化 `Client` 類別，並使用 `fetchProject` 方法獲取資源。

```PHP
$client = new \MemoChou1993\Lexicon\Client();

$project = $client->fetchProject();
```

## 程式碼

- [lexicon-api-php-client](https://github.com/memochou1993/lexicon-api-php-client)
