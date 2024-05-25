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

### DNS

進到域名註冊服務商的後台，點選 DNS 管理，設置由 Cloudflare 提供的名稱伺服器：

- xxx.ns.cloudflare.com
- yyy.ns.cloudflare.com

回到 Cloudflare 設定 DNS 紀錄：

| Type | Name | Content | Proxy Status | TTL |
| --- | --- | --- | --- | --- |
| A | your-domain.com | your-ip | Proxied | Auto |
| CNAME | blog | your-domain.com | Proxied | Auto |

### Caching

前往「Cache Rules」頁面，建立規則後，按下「部署」按鈕。

| Field | Operator | Value |
| --- | --- | --- |
| Hostname | contains | your-domain.com

運算式預覽如下：

```bash
(http.host contains "your-domain.com")
```

## 檢查

可以從 `CF-Cache-Status` 標頭檢查資源是否已快取。以下是所有快取回應狀態：

### ​​HIT

資源在 Cloudflare 的快取中找到。

### ​​MISS

資源未在 Cloudflare 的快取中找到，而是從原始網頁伺服器提供。

### ​​NONE/UNKNOWN

Cloudflare 生成了一個表示該資產不適合進行快取的回應。

### ​​EXPIRED

資源在 Cloudflare 的快取中找到，但已過期，並從原始網頁伺服器提供。

### ​​STALE

資源從 Cloudflare 的快取中提供，但已過期。Cloudflare 無法聯繫原始來源以檢索更新的資源。

### ​​BYPASS

原始伺服器通過將 `Cache-Control` 標頭設置為 `no-cache`、`private` 或 `max-age=0` 指示 Cloudflare 繞過快取，即使 Cloudflare 最初希望對資產進行快取。

### ​​REVALIDATED

資源從 Cloudflare 的快取中提供，但已過期。資源已通過 `If-Modified-Since` 標頭或 `If-None-Match` 標頭重新驗證。

### ​​UPDATING

資源從 Cloudflare 的快取中提供，但已過期，但原始網頁伺服器正在更新資源。`UPDATING` 通常僅用於非常受歡迎的快取資源。

### ​​DYNAMIC

Cloudflare 不認為資產符合快取條件，且快取設置中並未明確指示 Cloudflare 對資產進行快取。於是從原始網頁伺服器請求了資產。

## 參考資料

- [CloudFlare Docs - Cloudflare cache responses](https://developers.cloudflare.com/cache/concepts/cache-responses/)
- [CloudFlare Docs - Create a cache rule in the dashboard](https://developers.cloudflare.com/cache/how-to/cache-rules/create-dashboard/)
