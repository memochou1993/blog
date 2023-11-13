---
title: 在 Homestead 中安裝 PHP 的 Redis 擴充套件
date: 2018-10-17 21:44:25
tags: ["Programming", "PHP", "Redis", "Homestead", "CodeIgniter"]
categories: ["Programming", "PHP", "Extension"]
---

## 前言

如使用 CodeIgniter 框架，需安裝 PHP 的 Redis 擴充套件；如使用 Laravel 框架，則只要在專案使用 Composer 安裝 predis/predis 套件即可。

## 步驟

查看 PHP 版本。

```bash
vagrant@homestead:~$ php -v
```

新增 `ondrej/php` 套件庫。

```bash
vagrant@homestead:~$ sudo add-apt-repository ppa:ondrej/php
```

安裝 `php7.2-dev` 擴充套件。

```bash
vagrant@homestead:~$ sudo apt-get install php7.2-dev
```

安裝 `redis` 擴充套件。

```bash
vagrant@homestead:~$ sudo pecl install redis
```

新增 `redis.ini` 設定檔。

```bash
vagrant@homestead:~$ sudo vi /etc/php/7.2/mods-available/redis.ini
```

寫入以下內容：

```
extension=redis.so
```

### fpm

建立擴充套件的軟連結到 `fpm` 目錄：

```bash
vagrant@homestead:~$ sudo ln -s /etc/php/7.2/mods-available/redis.ini /etc/php/7.2/fpm/conf.d/20-redis.ini
```

重啟 PHP 服務。

```bash
vagrant@homestead:~$ sudo service php7.2-fpm restart
```

在 PHP 腳本中使用函式查看安裝是否成功：

```php
phpinfo();
```

### cli

建立擴充套件的軟連結到 `cli` 目錄：

```bash
vagrant@homestead:~$ sudo ln -s /etc/php/7.2/mods-available/redis.ini /etc/php/7.2/cli/conf.d/20-redis.ini
```

重啟 PHP 服務。

```bash
vagrant@homestead:~$ sudo service php7.2-fpm restart
```

使用指令查看安裝是否成功：

```bash
vagrant@homestead:~$ php -m | grep redis
redis
```

## 其他

查看詳細資訊。

```bash
vagrant@homestead:~$ php --ri redis
```

查看擴充套件的安裝位置。

```bash
vagrant@homestead:~$ php -i | grep extension_dir
```
