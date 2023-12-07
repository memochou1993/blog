---
title: 在 macOS 上安裝 PHP 的 OpenCC 擴充套件
date: 2023-11-30 11:33:30
tags: ["Programming", "PHP", "OpenCC"]
categories: ["Programming", "PHP", "Extension"]
---

## 前言

此方法只能在 PHP 8.1 版本使用。

## 做法

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

檢查是否編譯成功。

```bash
make test
```

查看編譯後的檔案。

```bash
ls modules                                                              ✔  11:31:38 ▓▒░
opencc.la opencc.so
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
extension=/Users/<User>/Projects/opencc4php/modules/opencc.so
```

執行範例腳本。

```bash
php opencc.php

我的滑鼠哪兒去了？
```

建立轉換函式。

```php
function s2t($content)
{
    $config = opencc_open("s2twp.json");
    $text = opencc_convert($content, $config);
    opencc_close($config);
    return $text;
}
```

使用函式轉換。

```bash
s2t('简体中文')
```

## 參考資料

- [BYVoid/OpenCC](https://github.com/BYVoid/OpenCC)
- [nauxliu/opencc4php](https://github.com/nauxliu/opencc4php)
