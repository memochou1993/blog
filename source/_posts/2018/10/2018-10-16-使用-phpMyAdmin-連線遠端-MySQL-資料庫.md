---
title: 使用 phpMyAdmin 連線遠端 MySQL 資料庫
date: 2018-10-16 21:39:35
tags: ["phpMyAdmin", "MySQL"]
categories: ["Database", "MySQL"]
---

## 環境

- macOS
- Homestead

## 步驟

編輯 `phpMyAdmin/config.inc.php` 檔，找到以下設定：

```php
/**
 * Servers configuration
 */
$i = 0;

/**
 * First server
 */
$i++;
/* Authentication type */
$cfg['Servers'][$i]['auth_type'] = 'cookie';
/* Server parameters */
$cfg['Servers'][$i]['host'] = 'localhost';
$cfg['Servers'][$i]['compress'] = false;
$cfg['Servers'][$i]['AllowNoPassword'] = false;
```

新增以下內容：

```php
/**
 * Second server
 */
$i++;
/* Authentication type */
$cfg['Servers'][$i]['auth_type'] = 'config';
/* Server parameters */
$cfg['Servers'][$i]['user'] = '';
$cfg['Servers'][$i]['password'] = '';
$cfg['Servers'][$i]['extension'] = 'mysqli';
$cfg['Servers'][$i]['AllowNoPassword'] = true;
$cfg['Servers'][$i]['host'] = '';
$cfg['Servers'][$i]['verbose'] = '';
```

## 參考資料

- [phpMyAdmin](https://docs.phpmyadmin.net/zh_CN/latest/config.html)
