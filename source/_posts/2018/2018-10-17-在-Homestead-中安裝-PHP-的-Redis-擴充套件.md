---
title: 在 Homestead 中安裝 PHP 的 Redis 擴充套件
permalink: 在-Homestead-中安裝-PHP-的-Redis-擴充套件
date: 2018-10-17 21:44:25
tags: ["環境部署", "PHP", "Redis", "Homestead", "Laravel", "CodeIgniter"]
categories: ["環境部署", "PHP"]
---

## 前言
由於公司目前使用 CodeIgniter 框架，需要安裝 PHP 的 Redis 擴充套件；如果使用 Laravel 框架，只要在專案使用 Composer 安裝 predis/predis 套件即可。 

## 步驟
首先執行以下指令以查看 PHP 版本，本文以 PHP 7.2 為例。
```
vagrant@homestead:~$ php -v
```
新增 `ondrej/php` 套件庫。
```
vagrant@homestead:~$ sudo add-apt-repository ppa:ondrej/php
```
安裝 `php7.2-dev` 擴充套件
```
vagrant@homestead:~$ sudo apt-get install php7.2-dev
```
安裝 `redis` 擴充套件
```
vagrant@homestead:~$ sudo pecl install redis
vagrant@homestead:~$ cd /etc/php/7.2/fpm/conf.d
vagrant@homestead:~$ sudo touch 20-redis.ini
vagrant@homestead:~$ sudo vi 20-redis.ini
```
寫入以下內容。
```
extension=redis.so
```
重啟 PHP 服務。
```
vagrant@homestead:~$ sudo service php7.2-fpm restart
```
使用指令或 `phpinfo()` 查看擴充套件是否安裝成功。
```
vagrant@homestead:~$ php -m |grep redis
redis
vagrant@homestead:~$ php -i|grep extension_dir
extension_dir => /usr/lib/php/20170718 => /usr/lib/php/20170718
vagrant@homestead:~$ cd /usr/lib/php/20170718 && ls
```
查看詳細資訊。
```
vagrant@homestead:~$ php --ri swoole
```