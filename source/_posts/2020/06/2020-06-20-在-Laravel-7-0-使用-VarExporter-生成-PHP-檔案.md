---
title: 在 Laravel 7.0 使用 VarExporter 生成 PHP 檔案
permalink: 在-Laravel-7-0-使用-VarExporter-生成-PHP-檔案
date: 2020-06-20 23:00:12
tags: ["程式設計", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 前言

一個 Laravel 的語言檔是由 PHP 的陣列所組成，如果想要生成一個類似這樣的 PHP 檔案，可以使用 `symfony/var-exporter` 套件，這個套件在 Laravel 框架中已經被引入。

## 使用方法

### 輸出陣列

單純輸出一個陣列。

```PHP
use Symfony\Component\VarExporter\VarExporter;

$data = VarExporter::export([
    'foo' => 'bar',
]);

dd($data);
```

輸出結果：

```PHP
"""
[\n
    'foo' => 'bar',\n
]
"""
```

### 生成檔案

生成一個 PHP 檔案。

```PHP
use Symfony\Component\VarExporter\VarExporter;

$data = vsprintf('%s%s%s%s%s%s%s', [
    '<?php',
    PHP_EOL,
    PHP_EOL,
    'return ',
    VarExporter::export([
        'foo' => 'bar',
    ]),
    ';',
    PHP_EOL,
]);

$path = sprintf('%s/%s.php', app()->langPath().DIRECTORY_SEPARATOR.'en', 'example');

file_put_contents($path, $data);
```

匯出結果：

```PHP
<?php

return [
    'foo' => 'bar',
];
```
