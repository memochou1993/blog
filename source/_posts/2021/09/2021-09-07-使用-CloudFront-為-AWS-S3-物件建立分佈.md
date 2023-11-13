---
title: 使用 CloudFront 為 AWS S3 物件建立分佈
date: 2021-09-07 21:50:40
tags: ["Deployment", "AWS", "S3", "Storage Service", "CloudFront"]
categories: ["Cloud Computing Service", "AWS"]
---

## 建立儲存貯體

1. 進到 [S3](https://s3.console.aws.amazon.com/s3) 首頁，點選「建立儲存貯體」按鈕。
2. 如果是公開物件，取消勾選「封鎖所有公開存取權」。
3. 點選「建立儲存貯體」按鈕。

## 建立存取使用者

1. 進到 [IAM](https://console.aws.amazon.com/iamv2/home) 首頁，點選「使用者」。
2. 點選「新增使用者」。
3. 勾選「程式設計方式存取」。
4. 連結「`AmazonS3FullAccess`」政策。
5. 複製「存取金鑰 ID」和「私密存取金鑰」。

## 建立分佈

1. 進到 [CloudFront](https://console.aws.amazon.com/cloudfront/v3/home) 首頁，點選「建立分佈」。
2. 選擇來源網域。
3. 如果有需要，將預設根對象設為「index.html」。
4. 點選「建立分佈」。

## 清除快取

1. 進到指定分佈。
2. 點選「建立無效判定」。
3. 輸入物件路徑，例如「`/*`」。
4. 點選「建立無效判定」。
