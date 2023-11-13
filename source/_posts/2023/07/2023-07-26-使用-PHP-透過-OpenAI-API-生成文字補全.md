---
title: 使用 PHP 透過 OpenAI API 生成文字補全
date: 2023-07-26 23:32:34
tags: ["Programming", "PHP", "GPT", "AI", "OpenAI"]
categories: ["Programming", "PHP", "Others"]
---

## 建立專案

建立專案。

```bash
mkdir gpt-function-calling
cd gpt-function-calling
```

安裝 `openai-php/client` 套件。

```bash
composer require openai-php/client
```

新增 `.gitignore` 檔。

```txt
/vendor
.env
```

新增 `.env` 檔。

```env
OPENAI_API_KEY=your-openai-api-key
```

## 實作

### Chat Completions API

新增 `index.php` 檔。

```php
<?php

require __DIR__ . '/vendor/autoload.php';

$dotenv = \Dotenv\Dotenv::createImmutable(__DIR__);
$dotenv->load();

print_r(ask('你好嗎？'));

function ask(string $question): array {
    $client = OpenAI::client($_ENV['OPENAI_API_KEY']);
    $response = $client->chat()->create([
        'model' => 'gpt-3.5-turbo-0613',
        'messages' => [
            [
                'role' => 'user',
                'content' => $question,
            ],
        ],
        'temperature' => 1,
    ]);
    
    return $response['choices'][0]['message'];
}
```

輸出如下：

```php
Array
(
    [role] => assistant
    [content] => 我很好，謝謝你！有什麼我可以幫你的嗎？
)
```

### Function Calling

修改 `index.php` 檔。

```php
<?php

require __DIR__ . '/vendor/autoload.php';

$dotenv = \Dotenv\Dotenv::createImmutable(__DIR__);
$dotenv->load();

print_r(ask('我想知道台北的天氣如何？'));

function ask(string $question): array {
    $client = OpenAI::client($_ENV['OPENAI_API_KEY']);
    $response = $client->chat()->create([
        'model' => 'gpt-3.5-turbo-0613',
        'messages' => [
            [
                'role' => 'user',
                'content' => $question,
            ],
        ],
        'temperature' => 1,
        'functions' => [
            [
                'name' => 'get_wether',
                'description' => 'Get the current weather in a given location.',
                'parameters' => [
                    'type' => 'object',
                    'properties' => [
                        'location' => [
                            'type' => 'string',
                            'description' => 'The city and state, e.g. San Francisco, CA',
                        ],
                        'unit' => [
                            'type' => 'string',
                            'enum' => ['celsius', 'fahrenheit'],
                        ],
                    ],
                    'required' => [
                        'location',
                    ],
                ],
            ],
        ],
    ]);
    
    return $response['choices'][0]['message'];
}
```

輸出如下：

```php
Array
(
    [role] => assistant
    [content] => 
    [function_call] => Array
        (
            [name] => get_wether
            [arguments] => {
                "location": "Taipei"
            }
        )
)
```

將 Weather API 的查詢結果，發送給 AI 做回應。

```php
<?php

require __DIR__ . '/vendor/autoload.php';

$dotenv = \Dotenv\Dotenv::createImmutable(__DIR__);
$dotenv->load();

print_r(ask('我想知道台北的天氣如何？'));

function ask(string $question): array {
    $client = OpenAI::client($_ENV['OPENAI_API_KEY']);
    $response = $client->chat()->create([
        'model' => 'gpt-3.5-turbo-0613',
        'messages' => [
            [
                'role' => 'user',
                'content' => $question,
            ],
            [
                'role' => 'assistant',
                'content' => null,
                'function_call' => [
                    'name' => 'get_current_weather',
                    'arguments' => 'Taipei',
                ],
            ],
            [
                'role' => 'function',
                'name' => 'get_current_weather',
                'content' => json_encode([
                    'temperature' => 22,
                    'unit' => 'celsius',
                    'description' => 'Sunny',
                ]),
            ],
        ],
        'temperature' => 1,
        'functions' => [
            [
                'name' => 'get_wether',
                'description' => 'Get the current weather in a given location.',
                'parameters' => [
                    'type' => 'object',
                    'properties' => [
                        'location' => [
                            'type' => 'string',
                            'description' => 'The city and state, e.g. San Francisco, CA',
                        ],
                        'unit' => [
                            'type' => 'string',
                            'enum' => ['celsius', 'fahrenheit'],
                        ],
                    ],
                    'required' => [
                        'location',
                    ],
                ],
            ],
        ],
    ]);
    
    return $response['choices'][0]['message'];
}
```

輸出如下：

```php
Array
(
    [role] => assistant
    [content] => 台北的天氣目前是晴天，溫度約為攝氏22度。
)
```

## 參考資料

- [OpenAI - Documentation](https://platform.openai.com/docs/guides/gpt)
