---
title: 在 PHP 專案使用 OpenCC 開放中文轉換
date: 2023-04-04 01:19:28
tags: ["Programming", "PHP", "OpenCC"]
categories: ["Programming", "PHP", "Extension"]
---

## 前言

以下做法會在 Linux 環境中，透過 [nauxliu/opencc4php](https://github.com/nauxliu/opencc4php) 開源專案的指示，編譯所需要的 `opencc.so` 擴充套件。

## 編譯

使用 Docker 啟動一個 PHP 環境。

```bash
docker run --rm -it php:8.2-fpm bash
```

安裝相關指令。

```bash
apt update && apt install -y libopencc-dev git vim
```

下載 `nauxliu/opencc4php` 專案。

```bash
git clone https://github.com/nauxliu/opencc4php.git --depth 1
cd opencc4php
```

執行編譯腳本。

```bash
phpize
./configure
make && make install
```

編譯後，可以看到擴充套件的資料夾路徑。

```bash
Libraries have been installed in:
   /var/www/html/opencc4php/modules

Installing shared extensions:     /usr/local/lib/php/extensions/no-debug-non-zts-20220829/
```

檢查是否編譯成功。

```bash
make test
```

## 安裝

查看 `php.ini` 的路徑。

```bash
php --ini

Configuration File (php.ini) Path: /usr/local/etc/php
Loaded Configuration File:         /usr/local/etc/php/php.ini
```

修改 `php.ini` 檔。

```bash
vim /usr/local/etc/php/php.ini
```

添加 `opencc.so` 到 `php.ini` 檔。

```bash
extension=/usr/local/lib/php/extensions/no-debug-non-zts-20220829/opencc.so
```

執行範例腳本。

```bash
php opencc.php

我的滑鼠哪兒去了？
```

## 在 Docker 容器使用

下載編譯好的 `opencc.so` 檔。

```bash
git clone git@github.com:memochou1993/opencc4php.git
```

將編譯好的 `opencc.so` 檔複製到 PHP 專案的 `docker/php/modules` 資料夾。

```bash
cp opencc4php/modules/opencc.so docker/php/modules/opencc.so
```

新增 `docker/php/php.ini` 檔。

```ini
extension=/usr/lib/php/modules/opencc.so
```

修改 `Dockerfile` 檔。

```dockerfile
RUN apt-get update && apt-get -y install opencc

COPY ./docker/php/modules/opencc.so /usr/lib/php/modules/opencc.so
COPY ./docker/php/php.ini /usr/local/etc/php/php.ini
```

在程式中建立 `s2t` 方法。

```php
public static function s2t($content)
{
    if (extension_loaded('opencc')) {
        $config = opencc_open("s2twp.json");
        $text = opencc_convert($content, $config);
        opencc_close($config);
        return $text;
    }
    return $content;
}
```

## 參考資料

- [BYVoid/OpenCC](https://github.com/BYVoid/OpenCC)
- [nauxliu/opencc4php](https://github.com/nauxliu/opencc4php)
