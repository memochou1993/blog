---
title: 使用 PHP 透過 Amazon Bedrock 生成文字補全
date: 2024-01-23 18:02:25
tags: ["Programming", "PHP", "AWS", "Bedrock", "AI"]
categories: ["Programming", "PHP", "Others"]
---

## 前言

在 Amazon Bedrock 上可以調用許多不同的模型，但是每個模型的參數、回傳格式，以及 Prompt Engineering 的細節都不同，需要注意。

## 建立專案

建立專案。

```bash
mkdir aws-bedrock-php-example
cd aws-bedrock-php-example
```

安裝依賴套件。

```bash
composer require aws/aws-sdk-php
```

## 實作

建立 `index.php` 檔，初始化一個客戶端實體。

```php
<?php

require './vendor/autoload.php';

use Aws\Sdk;

$sharedConfig = [
    'region' => 'us-west-2',
];

$sdk = new Sdk($sharedConfig);

$bedrockRuntime = $sdk->createBedrockRuntime();
```

### Amazon Titan

建立 `invokeTitan` 範例函式，調用代號為 `amazon.titan-text-express-v1` 的模型。

```php
function invokeTitan($bedrockRuntime, $text) {
    $body = [
        'inputText' => "User: $text\nAssistant:",
        'textGenerationConfig' => [
            'maxTokenCount' => 512,
            'temperature' => 0,
            'stopSequences' => ['User:'],
        ],
    ];

    $response = $bedrockRuntime->invokeModel([
        'modelId' => 'amazon.titan-text-express-v1',
        'contentType' => 'application/json',
        'body' => json_encode($body),
    ]);

    $result = json_decode($response['body']);

    return $result;
}

print_r(invokeTitan($bedrockRuntime, '你好嗎？'));
```

執行程式。

```bash
aws-vault exec your-profile -- php index.php
```

結果如下：

```bash
stdClass Object
(
    [inputTextTokenCount] => 16
    [results] => Array
        (
            [0] => stdClass Object
                (
                    [tokenCount] => 24
                    [outputText] =>  您好，有什么可以帮您的？
                    [completionReason] => FINISH
                )

        )

)
```

### Anthropic Claude

建立 `invokeClaude` 範例函式，調用代號為 `anthropic.claude-v2:1` 的模型。

```php
function invokeClaude($bedrockRuntime, $text) {
    $body = [
        'prompt' => "\n\nHuman:$text\n\nAssistant:",
        'max_tokens_to_sample' => 512,
        'temperature' => 0,
        'stop_sequences' => ["\n\nHuman:"],
    ];

    $response = $bedrockRuntime->invokeModel([
        'modelId' => 'anthropic.claude-v2:1',
        'contentType' => 'application/json',
        'body' => json_encode($body),
    ]);

    $result = json_decode($response['body']);

    return $result;
}

print_r(invokeClaude($bedrockRuntime, '你好嗎？'));
```

執行程式。

```bash
aws-vault exec your-profile -- php index.php
```

結果如下：

```bash
stdClass Object
(
    [completion] =>  很高興認識你。我是 Claude,一個 AI 助手。
    [stop_reason] => stop_sequence
    [stop] => 

Human:
)
```

## 程式碼

- [memochou1993/aws-bedrock-php-example](https://github.com/memochou1993/aws-bedrock-php-example)
