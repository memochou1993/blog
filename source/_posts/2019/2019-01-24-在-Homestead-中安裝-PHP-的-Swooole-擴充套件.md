---
title: 在 Homestead 中安裝 PHP 的 Swooole 擴充套件
permalink: 在-Homestead-中安裝-PHP-的-Swooole-擴充套件
date: 2019-01-24 00:29:06
tags: ["程式寫作", "PHP", "Laravel", "Homestead", "Swooole"]
categories: ["程式寫作", "PHP", "其他"]
---

## 步驟
更新 PECL 倉庫。
```
vagrant@homestead:~$ sudo pecl channel-update pecl.php.net
```

安裝 `swoole` 擴充套件。
```
vagrant@homestead:~$ sudo pecl install swoole
```

查找 `php.ini` 位置。
```
vagrant@homestead:~$ php -i|grep php.ini
Configuration File (php.ini) Path => /etc/php/7.2/cli
Loaded Configuration File => /etc/php/7.2/cli/php.ini
```

修改 `php.ini` 檔：
```
vagrant@homestead:~$ sudo vi /etc/php/7.2/cli/php.ini
```

寫入以下內容。
```
extension=swoole.so
```

使用指令或 `phpinfo()` 查看擴充套件是否安裝成功。
```
vagrant@homestead:~$ php -m |grep swoole
swoole
vagrant@homestead:~$ php -i|grep extension_dir
extension_dir => /usr/lib/php/20170718 => /usr/lib/php/20170718
vagrant@homestead:~$ cd /usr/lib/php/20170718 && ls
```

查看詳細資訊。
```
vagrant@homestead:~$ php --ri swoole
```
