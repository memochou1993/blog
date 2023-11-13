---
title: 在 Laradock 開啟 PHP 擴充套件
date: 2019-08-23 21:00:14
tags: ["Deployment", "Docker", "Laradock", "PHP"]
categories: ["Deployment", "Laradock"]
---

修改 `.env` 檔，將要開啟的 PHP 擴充套件開啟，以下以 `SOAP` 套件為例。

```env
WORKSPACE_INSTALL_SOAP=true
PHP_FPM_INSTALL_SOAP=true
```

使用 `docker-compose` 重建 `workspace` 和 `php-fpm` 服務。

```bash
docker-compose build --no-cache workspace php-fpm
```

進入容器，並使用 Composer 查看所有 PHP 擴充套件。

```bash
composer show -p
```
