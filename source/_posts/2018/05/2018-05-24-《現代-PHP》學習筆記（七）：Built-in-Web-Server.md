---
title: 《現代 PHP》學習筆記（七）：Built-in Web Server
permalink: 《現代-PHP》學習筆記（七）：Built-in-Web-Server
date: 2018-05-24 10:25:11
tags: ["程式設計", "PHP"]
categories: ["程式設計", "PHP", "《現代 PHP》學習筆記"]
---

## 前言

本文為《現代 PHP》一書的學習筆記。

## 環境

- Windows 10
- XAMPP 3.2.2

## 內建伺服器

PHP 自 5.4.0 開始有內建網頁伺服器，雖不該用來使用在產品階段，但對於本地端開發是個不錯的選擇。

> PHP 內建網頁伺服器可以用來預覽 HTML 靜態頁面或 PHP 檔案。

## 啟動伺服器

開啟終端機並輸入指令：

```BASH
php -S localhost:8000
```

- 當前目錄會成為伺服器的根目錄。

## 配置伺服器

要讓內建伺服器使用特定的 `.ini` 檔，可以利用 `-c` 選項：

```BASH
php -S localhost:8000 -c app/config/pnp.ini
```

## 路由器腳本

內建伺服器沒有支援 `.htaccess` 檔（負責分發 HTTP 請求並分配適當的 PHP 檔），因此內建伺服器利用「路由器腳本」實作出跟 `.htaccess` 檔相同的功能。

```BASH
php -S localhost:8000 router.php
```

## 偵測伺服器

要知道目前的 PHP 腳本是被內建伺服器還是傳統的網頁伺服器服務，可以使用 `php_sapi_name()` 函式偵測。

```PHP
if (php_sapi_name() == 'cli-server') {
    echo "<p>Welcome to PHP</p>";
}
```

## 缺陷

1. 內建伺服器的效能並非最佳化，它一次只處理一個 HTTP 請求，每一個請求都會阻塞（blocking）。
2. 內建伺服器只支援固定種類的 MIME types。
3. 內建伺服器的路由腳本器只能重寫有限的 URL。

## 參考資料

- Josh Lockhart（2015）。現代 PHP。台北市：碁峯資訊。
