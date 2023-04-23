---
title: 為 PHP 專案設定 php.ini 檔
date: 2023-04-23 16:08:06
tags: ["程式設計", "PHP"]
categories: ["程式設計", "PHP", "其他"]
---

## 做法

設定 `php.ini` 檔。

```ini
memory_limit = 256M
max_execution_time = 60
upload_max_filesize = 100M
post_max_size = 100M

date.timezone = "Asia/Taipei"

realpath_cache_size = 128M
realpath_cache_ttl = 86400

opcache.enable = On
opcache.memory_consumption = 256
opcache.interned_strings_buffer = 64
opcache.max_accelerated_files = 50000
opcache.revalidate_freq = 60

session.cookie_httponly = On
session.cookie_secure = On
session.use_strict_mode = On

log_errors = On
error_log = /proc/self/fd/2
```

## 參考資料

- [List of php.ini directives](https://www.php.net/manual/en/ini.list.php)
