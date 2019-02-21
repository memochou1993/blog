---
title: 學習使用 Amazon Web Services 雲端運算服務
permalink: 學習使用-Amazon-Web-Services-雲端運算服務
date: 2019-01-30 22:06:19
tags: ["環境部署", "AWS", "Linux", "雲端運算服務"]
categories: ["其他", "雲端運算服務"]
---

## 註冊帳號
首先到[官方網站](https://aws.amazon.com/tw/)註冊帳號，選擇為期一年的免費方案。

## 建立角色
以 AWS 使用者登入。

步驟：
- 點選「My Security Credentials」
- 點選「Continue to Security Credentials」
- 點選「Users」的「Add user」新增使用者：admin
- 將選項「Programmatic access」打勾
- 將選項「AWS Management Console access」打勾
- 將選項「Custom password」打勾，並自訂密碼
- 將選項「Require password reset」取消打勾
- 點選「Create group」以建立群組
-- 群組名稱：Administrators
-- 篩選政策：AdministratorAccess（類型：工作職能）
- 點選「Create user」以建立使用者。

點選「Dashboard」可以看到「IAM users sign-in link」，即 IAM 使用者的登入地址。

## 設置區域
以 IAM 使用者登入。

將區域設置為最近的「Asia Pacific (Tokyo)」，以降低應用程式中的資料延遲。

## 啟動執行個體
以 IAM 使用者登入。

步驟：
- 點選「EC2」
- 點選「Launch Instance」
- 搜尋 AMI，如「ubuntu」或「centos」
- 選擇「Instance Type」，點選「t2.micro」
- 在「Security Group」新增規則：HTTP
- 點選「Review and Launch」以檢閱
- 建立金鑰 `aws.pem` 檔，並下載至本機 `~/.ssh` 資料夾
- 點選「Review and Launch」以啟動執行個體

## 建立啟動樣板
以 IAM 使用者登入。

步驟：
- 點選「Create launch template」
- 搜尋 AMI，如「ubuntu」或「centos」
- 將選項「Instance type」設為：t2.micro
- 將選項「Key pair name」設為先前建立的 `aws` 金鑰
- 將選項 「Security Groups」設為先前建立的 `launch-wizard-1`
- 點選「Create launch template」以建立啟動樣板

在「Actions」點選「Launch instance from template」，可以啟動執行個體。

## 建立彈性 IP 地址
以 IAM 使用者登入。

步驟：
- 點選「Allocate new address」
- 點選「Allocate」

在「Actions」點選「Associate address」，可以關聯彈性 IP 地址。

## 設定 DNS
以 IAM 使用者登入。

步驟：
- 點選「Route 53」
- 購買一個網域名稱
- 點選「Hosted zones」
- 選擇購買的網域名稱，點選「Go to Record Sets」
- 點選「Create Record Set」
-- 選項「Name」輸入子網域名稱
-- 選項「Type」設為「IPv4 address」
-- 選項「Value」輸入先前為執行個體關聯的彈性 IP 地址
- 點選「Create」，以建立紀錄集

## 連線
使用終端機登入。

修改金鑰 `aws.pem` 檔的權限為 `400`。
```
$ chmod 400 ~/.ssh/aws.pem
```

使用 SSH 進行連線。
```
$ ssh -i "~/.ssh/aws.pem" xx@xxx.compute.amazonaws.com
```
