---
title: 在 macOS 上安裝 PHP 的 Xdebug 擴充套件
date: 2018-11-30 10:24:31
tags: ["程式設計", "PHP", "Xdebug", "macOS", "Laravel"]
categories: ["程式設計", "PHP", "擴充套件"]
---

## 步驟

安裝 PHP 的 Xdebug 擴充套件。

```bash
pecl install xdebug
```

修改 `php.ini` 檔，並刪除第一行 `zend_extension="xdebug.so"`。

```bash
vi /usr/local/etc/php/7.2/php.ini
```

新增 `xdebug.ini` 檔。

```bash
vi /usr/local/etc/php/7.2/conf.d/xdebug.ini
```

加入以下內容：

```bash
[xdebug]
zend_extension="/usr/local/lib/php/pecl/20170718/xdebug.so"
```

使用指令查看擴充套件是否安裝成功，或在 PHP 腳本中使用 `phpinfo()` 查看。

```bash
php -m | grep xdebug
xdebug
```

查看擴充套件的安裝位置。

```bash
php -i | grep extension_dir
```

查看詳細資訊。

```bash
vagrant@homestead:~$ php --ri xdebug
```
