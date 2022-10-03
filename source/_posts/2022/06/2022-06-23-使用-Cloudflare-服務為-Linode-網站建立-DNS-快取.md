---
title: 使用 Cloudflare 服務為 Linode 網站建立 DNS 快取
date: 2022-06-23 23:42:39
tags: ["環境部署", "Linode", "GoDaddy", "Cloudflare", "DNS"]
categories: ["雲端運算服務", "Linode"]
---

## 做法

首先，在 [Cloudflare](https://dash.cloudflare.com/) 建立一個帳號。

點選「Add a site」新增一個網站，輸入網站的網域名稱。

Cloudflare 會開始掃描此網站的所有 DNS 紀錄。

進到 GoDaddy 點選 DNS 管理，將原來由 Linode 提供的名稱伺服器刪除：

- ns1.linode.com
- ns2.linode.com
- ns3.linode.com
- ns4.linode.com
- ns5.linode.com

改為 Cloudflare 提供的名稱伺服器：

- damien.ns.cloudflare.com
- oaklyn.ns.cloudflare.com

回到 Cloudflare 設定以下內容：

- 將 Automatic HTTPS Rewrites 選項打勾。
- 將 Always Use HTTPS 選項打勾。
- 將 Auto Minify 選項打勾。
- 將 Brotli 選項打勾。

## 參考資料

- [How to Set Up Cloudflare with Linode](https://www.linode.com/docs/guides/how-to-set-up-cloudflare-with-linode/)
