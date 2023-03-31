---
title: 將 GoDaddy 的電子郵件轉移至 AWS 託管
date: 2023-04-01 00:59:01
tags: ["環境部署", "AWS", "EC2", "Linux", "GoDaddy", "VPS", "DNS"]
categories: ["雲端運算服務", "AWS"]
---

## 做法

首先，在 AWS Route53 新增一個託管區域。

新增 MX 和 TXT 等紀錄，其中 MX 的 Record Name 可能需設置為空值。

| Record Name | Type | IP Address |
| --- | --- | --- |
| 空值 | MX | 0 example.com.mail.protection.outlook.com |
| @ | TXT | "NETORGFT13267104.onmicrosoft.com" |
| @ | TXT | "v=spf1 include:secureserver.net -all" |
| email | CNAME | email.secureserver.net |
| autodiscover | CNAME | autodiscover.outlook.com |
| lyncdiscover | CNAME | webdir.online.lync.com |
| autodiscover | CNAME | autodiscover.outlook.com |
| msoid | CNAME | clientconfig.microsoftonline-p.net |
| sip | CNAME | sipdir.online.lync.com |
| @ | SRV | 1 100 443 sipdir.online.lync.com |
| @ | SRV | 1 100 5061 sipfed.online.lync.com |

約等待 24 小時即可生效。

## 參考資料

- [Google Admin Toolbox - Check MX](https://toolbox.googleapps.com/apps/checkmx/)
- [GoDaddy - 編輯 MX 記錄](https://tw.godaddy.com/help/edit-an-mx-record-19235)
