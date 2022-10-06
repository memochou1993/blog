---
title: 在 macOS 上安裝 Valet 環境
date: 2019-01-27 03:17:15
tags: ["程式設計", "PHP", "Laravel", "macOS", "Valet"]
categories: ["程式設計", "PHP", "環境安裝"]
---

## 步驟

安裝 `laravel/valet` 套件。

```bash
composer global require laravel/valet
```

啟動。

```bash
valet install
```

更新 Composer 環境變數：

```bash
export PATH="$PATH:$HOME/.composer/vendor/bin"
```

建立專案目錄。

```bash
mkdir ~/Sites
cd ~/Sites
valet park
This directory has been added to Valet's paths.
```

建立專案。

```bash
laravel new laravel
```

停止 Valet。

```bash
valet uninstall
```

## 加密

使用 HTTPS 的站點：

```bash
valet secure laravel
```

還原回 HTTP 的站點：

```bash
valet unsecure laravel
```

## 瀏覽網頁

前往 <http://laravel.test> 瀏覽。

## 補充

Valet 會破壞預設的 `Nginx.conf` 檔，並持續監聽 80 埠。
