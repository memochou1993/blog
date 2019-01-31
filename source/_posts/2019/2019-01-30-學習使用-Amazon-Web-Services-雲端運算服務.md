---
title: 學習使用 Amazon Web Services 雲端運算服務
permalink: 學習使用-Amazon-Web-Services-雲端運算服務
date: 2019-01-30 22:06:19
tags: ["環境部署", "AWS"]
categories: ["環境部署", "AWS"]
---

## 註冊帳號
首先到[官方網站](https://aws.amazon.com/tw/)註冊帳號，選擇為期一年的免費方案。

## 建立 IAM 使用者
參考[此文](https://docs.aws.amazon.com/zh_tw/IAM/latest/UserGuide/getting-started_create-admin-group.html)建立 IAM 使用者。

以 AWS 帳戶登入：
- 點選「我的安全憑證」
- 點選「Continue to Security Credentials」
- 新增使用者：admin
- 程式設計方式存取：打勾
- AWS Management Console 存取：打勾
- 自訂密碼：打勾
- 需要密碼重設：取消打勾

建立群組：
- 群組名稱：Administrators
- 篩選政策：AdministratorAccess（類型：工作職能）

新增標籤：
- Key：email
- Value：xxx@hotmail.com

建立使用者。

## 啟動虛擬機器
登入 IAM 使用者，點選「啟動虛擬機器：使用 EC2」。

設定：
- 選擇映像檔：Amazon Linux
- 選擇執行個體類型：t2.micro（Free tier eligible）
- 在安全群組（Security Group）新增規則：HTTP
- 點選「檢閱並啟動」
- 建立金鑰 `aws.pem` 檔，並下載至本機 `~/.ssh` 資料夾
- 啟動執行個體

## 連線
修改金鑰 `aws.pem` 檔的權限為 `400`。
```
$ chmod 400 ~/.ssh/aws.pem
```

新增連線至執行個體的 `ec2` 命令腳本：
```
$ echo "ssh -i "~/.ssh/aws.pem" xx-user@xxx.compute.amazonaws.com" > ec2
```
修改命令腳本 `ec2` 檔的權限為 `755`。
```
$ chmod 755 ./ec2
```

執行命令腳本。
```
$ ./ec2
Amazon Linux AMI
```
