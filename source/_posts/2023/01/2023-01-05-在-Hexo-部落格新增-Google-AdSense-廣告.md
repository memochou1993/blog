---
title: 在 Hexo 部落格新增 Google AdSense 廣告
date: 2023-01-05 23:21:34
tags: ["Hexo", "Google AdSense"]
categories: ["靜態網頁生成器", "Hexo"]
---

## 做法

首先，在 [Google AdSense](https://www.google.com.tw/adsense/start/) 新增一個網站，提交審查的網站，必須放置於主網域。

審核通過後，在 Hexo 專案的 `source` 資料夾新增 `ads.txt` 檔。

```txt
google.com, pub-xxxxxxxxxxxxxxxx, DIRECT, f08c47fec0942fa0
```

修改 `themes/cactus/_config.yml` 檔，新增 `google_adsense` 欄位。

```yaml
# Enable or disable the Google AdSense.
google_adsense:
  enable: true
  google_ad_client_id: pub-xxxxxxxxxxxxxxxx
```

修改 `themes/cactus/layout/_partial/scripts.ejs` 檔。

```ejs
<% if (theme.google_analytics.enabled && theme.google_analytics.id){ %>
   <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-<%= theme.google_adsense.google_ad_client_id %>" crossorigin="anonymous"></script>
<% } %>
```

發布。

```bash
hexo d -g
```
