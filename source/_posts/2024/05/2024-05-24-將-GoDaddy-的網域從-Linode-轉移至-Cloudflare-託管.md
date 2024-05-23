---
title: 將 GoDaddy 的網域從 Linode 轉移至 Cloudflare 託管
date: 2024-05-24 00:23:24
tags: ["Deployment", "Linode", "GoDaddy", "Cloudflare", "DNS", "HTTP"]
categories: ["Cloud Computing Service", "Linode"]
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

改為由 Cloudflare 提供的名稱伺服器：

- xxx.ns.cloudflare.com
- yyy.ns.cloudflare.com

等待 DNS 傳播，可能需要 24 小時的時間。

## SSL/TLS

### Flexible

如果把加密模式設置為「彈性」，就只有瀏覽器和 Cloudflare 之間的流量會被加密，然後 Cloudflare 和原始伺服器之間的流量不被加密。

需要關閉 Caddy 自動重定向到 HTTPS 和建立 TLS 憑證的功能，允許 HTTP 請求不重定向到 HTTPS。

```env
http://example.com {
    # 允許 HTTP 路由
    root * /var/www/example
    file_server
}
```

### Full

如果把加密模式設置為「完整」，能夠使用伺服器上自我簽署的憑證，實現端對端加密通訊。Cloudflare 和伺服器之間的連線會使用 HTTPS，但不驗證證書的有效性。

需要開啟 Caddy 自動重定向到 HTTPS 和建立 TLS 憑證的功能，允許 HTTP 請求重定向到 HTTPS。

```env
https://example.com {
    # 允許 HTTPS 路由
    root * /var/www/example
    file_server
}
```

### Full (Strict)

如果把加密模式設置為「完整（嚴格）」，即使用端對端加密通訊，但需要使用伺服器上信任的 CA 或 Cloudflare 原點 CA 憑證。

## 重定向循環問題

遇到 `ERR_TOO_MANY_REDIRECTS` 無限重定向的問題，原因可能如下：

Cloudflare 接收到 Caddy 的重定向響應，看到要重定向到 <https://example.com>，但是，由於 Flexible 模式，Cloudflare 依舊會通過 HTTP 訪問 <http://example.com>，再次發送 HTTP 請求到 Caddy，Caddy 再次返回重定向到 HTTPS，循環不斷重複，形成重定向循環。

## 參考資料

- [Cloudflare Docs - Encryption modes](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/)
- [Cloudflare Docs - ERR_TOO_MANY_REDIRECTS](https://developers.cloudflare.com/ssl/troubleshooting/too-many-redirects/)
