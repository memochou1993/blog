---
title: 在 macOS 上安裝 PHP 的 Xdebug 擴充套件
permalink: 在-macOS-上安裝-PHP-的-Xdebug-擴充套件
date: 2018-11-30 10:24:31
tags: ["環境部署", "PHP", "Xdebug", "macOS", "Laravel"]
categories: ["環境部署", "PHP"]
---

## 步驟
安裝 PHP 的 Xdebug 擴充套件。
```
$ pecl install xdebug
```
修改 `php.ini` 檔，並刪除第一行 `zend_extension="xdebug.so"`。
```
$ vi /usr/local/etc/php/7.2/php.ini
```

新增 `xdebug.ini` 檔。
```
$ vi /usr/local/etc/php/7.2/conf.d/xdebug.ini
```

加入以下內容：
```
[xdebug]
zend_extension="/usr/local/lib/php/pecl/20170718/xdebug.so"
```

使用指令查看擴充套件是否安裝成功，或在 PHP 腳本中使用 `phpinfo()` 查看。
```
$ php -m |grep xdebug
xdebug
$ php -i|grep extension_dir
extension_dir => /usr/local/lib/php/pecl/20170718 => /usr/local/lib/php/pecl/20170718
$ cd /usr/local/lib/php/pecl/20170718 && ls
```

查看詳細資訊。
```
vagrant@homestead:~$ php --ri xdebug
```
