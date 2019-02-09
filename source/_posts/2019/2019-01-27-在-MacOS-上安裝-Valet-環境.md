---
title: 在 MacOS 上安裝 Valet 環境
permalink: 在-MacOS-上安裝-Valet-環境
date: 2019-01-27 03:17:15
tags: ["環境部署", "macOS", "Valet", "Laravel"]
categories: ["環境部署", "Valet"]
---

## 步驟
安裝 `laravel/valet` 套件。
```
$ composer global require laravel/valet
```

啟動。
```
$ valet install
```

更新 Composer 環境變數：
```
$ export PATH="$PATH:$HOME/.composer/vendor/bin"
```

新增專案目錄。
```
$ mkdir ~/Sites
$ cd ~/Sites
$ valet park
This directory has been added to Valet's paths.
```

新增專案。
```
$ laravel new laravel
```

停止 Valet。
```
$ valet uninstall
```

## 加密
使用 HTTPS 的站點：
```
$ valet secure laravel
```

還原回 HTTP 的站點：
```
$ valet unsecure laravel
```

## 瀏覽網頁
前往：http://laravel.test

## 補充
Valet 會破壞預設的 `Nginx.conf` 檔，並持續監聽 80 埠。