---
title: 在 Homestead 中安裝 PHP 的 Swoole 擴充套件
permalink: 在-Homestead-中安裝-PHP-的-Swoole-擴充套件
date: 2019-01-24 00:29:06
tags: ["程式設計", "PHP", "Swoole", "Homestead", "Laravel"]
categories: ["程式設計", "PHP", "擴充套件"]
---

## 步驟

查看 PHP 版本。

```BASH
vagrant@homestead:~$ php -v
```

更新 PECL 倉庫。

```BASH
vagrant@homestead:~$ sudo pecl channel-update pecl.php.net
```

安裝 `swoole` 擴充套件。

```BASH
vagrant@homestead:~$ sudo pecl install swoole
```

新增 `swoole.ini` 設定檔。

```BASH
vagrant@homestead:~$ sudo vi /etc/php/7.2/mods-available/swoole.ini
```

寫入以下內容：

```
extension=swoole.so
```

### fpm

建立擴充套件的軟連結到 `fpm` 目錄：

```BASH
vagrant@homestead:~$ sudo ln -s /etc/php/7.2/mods-available/swoole.ini /etc/php/7.2/fpm/conf.d/20-swoole.ini
```

重啟 PHP 服務。

```BASH
vagrant@homestead:~$ sudo service php7.2-fpm restart
```

在 PHP 腳本中使用函式查看安裝是否成功：

```PHP
phpinfo();
```

### cli

建立擴充套件的軟連結到 `cli` 目錄：

```BASH
vagrant@homestead:~$ sudo ln -s /etc/php/7.2/mods-available/swoole.ini /etc/php/7.2/cli/conf.d/20-swoole.ini
```

重啟 PHP 服務。

```BASH
vagrant@homestead:~$ sudo service php7.2-fpm restart
```

使用指令查看安裝是否成功：

```BASH
vagrant@homestead:~$ php -m |grep swoole
swoole
```

## 其他

查看詳細資訊。

```BASH
vagrant@homestead:~$ php --ri swoole
```

查看擴充套件的安裝位置。

```BASH
vagrant@homestead:~$ php -i|grep extension_dir
```
