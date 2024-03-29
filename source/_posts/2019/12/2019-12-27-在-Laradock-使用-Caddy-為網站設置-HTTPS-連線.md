---
title: 在 Laradock 使用 Caddy 為網站設置 HTTPS 連線
date: 2019-12-27 10:56:24
tags: ["Deployment", "Laradock", "SSL", "HTTPS", "Caddy"]
categories: ["Deployment", "Laradock"]
---

## 前言

Caddy 是一個開源並使用 Golang 編寫的 Web 伺服器。其特性是默認啟用 HTTPS，是第一個無需額外配置即可提供 HTTPS 的 Web 伺服器。

## 做法

進到 `~/Laradock/caddy/caddy` 資料夾。

```bash
cd ~/Laradock/caddy/caddy
```

修改 `Caddyfile` 檔，將 `0.0.0.0:80` 改為指定網址：

```env
# 0.0.0.0:80
https://yourdomain.com
```

將 `tls` 開啟，修改為自己的電子郵件地址。

```bash
#tls self-signed
tls youremail@gmai.com
```

啟動 Caddy 容器，以產生 Let's Encrypt 憑證。

```bash
docker-compose up caddy
```

產生後，使用 Ctrl + C 離開，將容器關閉。

```bash
docker-compose down
```

最後再將 Caddy 和其他容器一起啟動即可。

```bash
docker-compose up -d caddy mysql phpmyadmin
```

訪問網站：<https://yourdomain.com>

## 參考資料

- [Laradock Guides](https://laradock.io/guides/#run-site-on-ssl-with-let-s-encrypt-certificate)
- [Caddy](https://caddyserver.com/)
