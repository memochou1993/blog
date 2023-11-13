---
title: 將 GoDaddy 的網域轉移至 AWS 託管
date: 2023-03-21 17:03:17
tags: ["Deployment", "AWS", "EC2", "Linux", "GoDaddy", "VPS", "DNS"]
categories: ["Cloud Computing Service", "AWS"]
---

## 做法

首先，在 AWS Route53 新增一個託管區域。

新增 A 紀錄，指向 EC2 主機的 IP 位置。

| Hostname | Type | IP Address |
| --- | --- | --- |
| example.com | A | xxx.xxx.xxx.xxx |
| www.example.com | CNAME | example.com |
| hello.example.com | A | xxx.xxx.xxx.xxx |

然後在 GoDaddy 的 DNS 管理，使用自訂的網域名稱伺服器，設置對應的 NS 紀錄。

| 網域名稱伺服器 |
| --- |
| ns-658.awsdns-18.net |
| ns-26.awsdns-03.com |
| ns-1747.awsdns-26.co.uk |
| ns-1110.awsdns-10.org |

約等待 15 分鐘即可生效。
