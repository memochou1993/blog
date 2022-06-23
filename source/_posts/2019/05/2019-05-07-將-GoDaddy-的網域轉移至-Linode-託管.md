---
title: 將 GoDaddy 的網域轉移至 Linode 託管
permalink: 將-GoDaddy-的網域轉移至-Linode-託管
date: 2019-05-07 23:20:15
tags: ["環境部署", "Linode", "GoDaddy", "VPS", "DNS"]
categories: ["雲端運算服務", "Linode"]
---

## 前言

由於使用 Linode 虛擬專用伺服器，因此需要把在 GoDaddy 購買的網域交由給 Linode 託管。

## 註冊

到 Linode 官方網站註冊，並選擇 5 塊美金的方案。資料中心選擇東京，作業系統則選擇 Ubuntu 18.04 LTS。

## 轉移網域

首先將 GoDaddy 的網域轉移給 Linode 託管，在 GoDaddy 的 DNS 管理使用自訂的網域名稱伺服器。

| 網域名稱伺服器 |
| --- |
| ns1.linode.com |
| ns2.linode.com |
| ns3.linode.com |
| ns4.linode.com |
| ns5.linode.com |

## 設定 DNS

在 Linode 的 Domains 頁面新增一個 Domain。

編輯 Domain，新增 A/AAAA 記錄，並指向主機的 IP 位置。

| Hostname | IP Address |
| --- | --- |
| （空白） | xxx.xxx.xxx.xxx |
| www | xxx.xxx.xxx.xxx |

新增 CNAME 記錄，設定別名。

| Hostname | IP Address |
| --- | --- |
| laravel | www.domain.com |

約等待 15 分鐘即可生效。
