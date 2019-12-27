---
title: 在 Laradock 使用 Caddy 為網站設置 HTTPS 連線
permalink: 在-Laradock-使用-Caddy-為網站設置-HTTPS-連線
date: 2019-12-27 10:56:24
tags: ["環境部署", "Laradock", "SSL", "HTTPS", "Caddy"]
categories: ["環境部署", "Laradock"]
---

## 前言

Caddy 是一個開源並使用 Golang 編寫的 Web 伺服器，它使用 Golang 標準庫提供的 HTTP 功能。Caddy 的特性是默認啟用 HTTPS，是第一個無需額外配置即可提供 HTTPS 特性的 Web 伺服器。

## 做法

進到 `~/Laradock/caddy/caddy` 資料夾。

```BASH
cd ~/Laradock/caddy/caddy
```

修改 `Caddyfile` 檔，將 `0.0.0.0:80` 改為指定網址：

```ENV
# 0.0.0.0:80
https://yourdomain.com
```

將 `tls` 開啟，並寫入電子郵件地址。

```BASH
#tls self-signed
tls youremail@gmai.com
```

啟動 Caddy 以產生 Let’s Encrypt 憑證。

```BASH
docker-compose up caddy
```

使用 `Ctrl` + `C` 離開後，將所有容器關閉。

```BASH
docker-compose down
```

再啟動一次容器。

```BASH
docker-compose up -d mysql caddy
```

訪問網站：https://yourdomain.com

## 參考資料

- [Laradock Guides](https://laradock.io/guides/)
