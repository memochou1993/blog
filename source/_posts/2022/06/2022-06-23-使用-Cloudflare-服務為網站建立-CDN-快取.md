---
title: 使用 Cloudflare 服務為網站建立 CDN 快取
date: 2022-06-23 23:42:39
tags: ["Deployment", "Linode", "GoDaddy", "Cloudflare", "DNS", "CDN"]
categories: ["Cloud Computing Service", "Linode"]
---

## 做法

首先，在 [Cloudflare](https://dash.cloudflare.com/) 建立一個帳號。

點選「Add a site」新增一個網站，輸入網站的網域名稱。

Cloudflare 會開始掃描此網站的所有 DNS 紀錄。

進到 GoDaddy 點選 DNS 管理，設置由 Cloudflare 提供的名稱伺服器：

- xxx.ns.cloudflare.com
- yyy.ns.cloudflare.com

回到 Cloudflare 設定以下內容：

- 將 Automatic HTTPS Rewrites 選項打勾。
- 將 Always Use HTTPS 選項打勾。
- 將 Auto Minify 選項打勾。
- 將 Brotli 選項打勾。
