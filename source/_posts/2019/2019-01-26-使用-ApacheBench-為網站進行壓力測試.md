---
title: 使用 ApacheBench 為網站進行壓力測試
permalink: 使用-ApacheBench-為網站進行壓力測試
date: 2019-01-26 23:05:14
tags: ["ApacheBench", "壓力測試"]
categories: ["其他", "壓力測試"]
---

## 前言
在 macOS 環境已有內建 ApacheBench 壓力測試工具。

## 使用
```
$ ab -n 1000 -c 10 http://laravel.test
```
- 參數 `n` 代表請求次數。
- 參數 `c` 代表併發數量。

## 實作
本文針對乾淨的 Laravel 框架，在 5 種不同的環境下進行 5 次壓力測試，並取得平均值。
```
$ ab -n 1000 -c 10 http://laravel.test
```

測試結果：

Environment | Requests per second | Time taken for tests
--- |--- | ---
PHP Web Server | 27.182 | 37.3468
Nginx with Docker | 40.954 | 24.9864
Nginx | 64.86 | 15.419 
Nginx & Swoole | 88.712 | 11.3406
Swoole | 106.27 | 9.4876

