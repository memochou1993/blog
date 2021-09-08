---
title: 使用 AWS Certificate Manager 為 CloudFront 分佈建立憑證
permalink: 使用-AWS-Certificate-Manager-為-CloudFront-分佈建立憑證
date: 2021-09-08 14:25:02
tags: ["環境部署", "AWS", "ACM", "Storage Service", "CloudFront"]
categories: ["其他", "雲端運算服務"]
---

## 前言

以下使用 ACM 建立憑證，提供 CloudFront 和外部 Domain 使用。

使用以下為例：

- Domain Name: test.epoch.tw
- CloudFront Domain Name: xxxxxx.cloudfront.net

## 設定 ACM

1. 進到 [ACM](https://console.aws.amazon.com/acm/home)，點選「申請憑證」。
2. 勾選「申請公有憑證」。
3. 輸入網域名稱。
4. 勾選「DNS 驗證」。
5. 點選「檢閱」。
6. 點選「確認和請求」。
7. 複製「狀態」內用於驗證使用的 CNAME 紀錄。
8. 等待驗證完成。

## 設定 DNS

1. 進到 DNS 服務商的 Domain 管理頁面。
2. 新增一筆 `CNAME` 紀錄，以供 ACM 驗證：

- Hostname: `xxxxxxxxxx.test`
- Alias to: `yyyyyyyyyy.zzzzzzzzzz.acm-validations.aws`
- TTL: `30 seconds`

使用 `dig` 指令檢查。

```BASH
dig xxxxxxxxxx.test.epoch.tw.

;; ANSWER SECTION:
xxxxxxxxxx.test.epoch.tw. 30 IN CNAME yyyyyyyyyy.zzzzzzzzzz.acm-validations.aws.
```

3. 新增一筆 `CNAME` 紀錄，以供 CloudFront 使用：

- Hostname: `test`
- Alias to: `xxxxxx.cloudfront.net`
- TTL: `30 seconds`

使用 `dig` 指令檢查。

```BASH
dig CNAME test.epoch.tw.

;; ANSWER SECTION:
test.epoch.tw.		30	IN	CNAME	xxxxxx.cloudfront.net.
```

## 設定 CloudFront

1. 進到 CloudFront，點選「編輯設定」。
2. 輸入備用網域名稱 `test.epoch.tw`。
3. 選擇自訂 SSL 憑證為 `test.epoch.tw` 的憑證。
4. 點選「儲存變更」。
