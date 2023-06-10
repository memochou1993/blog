---
title: 處理 PHP 專案的 504 Gateway Time-out 錯誤
date: 2023-06-08 13:36:27
tags: ["程式設計", "PHP", "Nginx", "Terraform", "AWS", "ALB"]
categories: ["程式設計", "PHP", "其他"]
---

## 前言

如果是使用 Docker 容器的方案，可以先在本地將容器啟動，檢查是否為 PHP 或 Nginx 的問題。確認沒問題後，再檢查是否為 ALB 或其他服務的網路問題。

## 做法

### PHP

首先，要幫 `php.ini` 加上以下設定：

```
max_execution_time = 300
```

### Nginx

也要幫 Nginx 的 `default.conf` 加上以下設定：

```
fastcgi_read_timeout 300s;
```

如果是 `nginx` 的問題，錯誤頁面會顯示提示文字。

### ALB

如果有使用 AWS 的 ALB 服務，可以幫 Terraform 加上以下設定：

```
idle_timeout = 300
```

## 參考資料

- [Terraform - aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb)

