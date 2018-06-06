---
title: 《現代 PHP》學習筆記（六）：Zend OPcache
date: 2018-05-23 10:24:48
tags: ["程式寫作", "PHP"]
categories: ["程式寫作", "PHP", "《現代 PHP》學習筆記"]
---

## 前言
本文為《現代 PHP》一書的學習筆記。

## 環境
- Windows 10
- XAMPP 3.2.2

## Zend OPcache
PHP 過去沒有任何一個擴充（extension）內建於 PHP 核心版本，直到 PHP 5.5.0 開始有了內建的位元碼快取機制 Zend OPcache。

由於 PHP 是個直譯式的語言，當 PHP 直譯器執行一個 PHP 腳本時，直譯器會解析 PHP 腳本程式碼，將 PHP 程式碼編譯成現有的 Zend Opcodes（機器語言指令），然後執行程式碼。

在接收到每一個 PHP 檔案後都會發生一次上述情形，如果可以快取預先編譯好的位元碼，就可以降低應用程式的回應時間，並減少系統資源的壓力。

> 位元組編碼快取儲存預先編譯好的位元碼，表示 PHP 直譯器不用在接收到每一個 PHP 檔案時讀取、解析、編譯 PHP 程式碼。

## 啟用
預設上 Zend OPcache 是不被啟用的。

在 WAMP 的環境，可以直接在 `php.ini` 檔中指定 Zend OPcache 擴充的路徑。
```
zend_extension=php_opcache.dll
```
然後使用瀏覽器前往 http://localhost/dashboard/phpinfo.php 確認，可以看到 Zend OPcache 已經被啟用。
```
This program makes use of the Zend Scripting Language Engine:
Zend Engine v3.2.0, Copyright (c) 1998-2018 Zend Technologies
    with Zend OPcache v7.2.4, Copyright (c) 1999-2018, by Zend Technologies
```

## 設置
Zend OPcache 被啟用後，可以做進一步的設定。
```
opcache.validate_timestamps=1
opcache.revalidate_freq=0
opcache.memory_consumption=64
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=4000
```
- `validate_timestamps` 設定為 `0` 時，PHP 腳本的變化會被忽略，若是在開發階段建議設為 `1`。

## 參考資料
Josh Lockhart（2015）。現代 PHP。台北市：碁峯資訊。