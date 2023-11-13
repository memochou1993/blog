---
title: 使用 AWS Route 53 建立將流量導至 CloudFront 的紀錄
date: 2021-09-28 16:31:31
tags: ["Deployment", "AWS", "S3", "Route 53", "CloudFront"]
categories: ["Cloud Computing Service", "AWS"]
---

## 設定分佈

1. 進到 [CloudFront](https://console.aws.amazon.com/cloudfront/v3/home) 首頁。
2. 點選指定分佈。
3. 填入「備用網域名稱」，例如「blog.example.com」。
4. 填入「自訂 SSL 憑證」。

## 建立 DNS 紀錄

1. 進到 [Route 53](https://console.aws.amazon.com/route53/v2/home) 首頁，點選「託管區域」。
2. 點選指定網域名稱。
3. 填入紀錄名稱，例如「blog」。
4. 將「別名」打勾。
5. 將選單「將流量路由至」選擇為「CloudFront 分配的別名」，並選擇指定分配。
6. 點選「建立紀錄」。
