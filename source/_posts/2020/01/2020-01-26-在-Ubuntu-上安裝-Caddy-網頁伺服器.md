---
title: 在 Ubuntu 上安裝 Caddy 網頁伺服器
permalink: 在-Ubuntu-上安裝-Caddy-網頁伺服器
date: 2020-01-26 20:51:53
tags:
categories:
---

## 安裝

```BASH
curl https://getcaddy.com | bash -s personal
```

查看版本。

```BASH
caddy --version
```

## 使用

在 `/etc/caddy` 資料夾新增 `Caddyfile` 檔：

```ENV
xxx.com {
    root /var/www/

    log /var/log/caddy/access.log
    errors /var/log/caddy/error.log

    tls email@gmail.com
}
```

啟動網頁伺服器。

```BASH
caddy
```
