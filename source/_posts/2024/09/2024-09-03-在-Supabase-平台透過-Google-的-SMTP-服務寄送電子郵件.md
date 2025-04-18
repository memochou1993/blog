---
title: 在 Supabase 平台透過 Google 的 SMTP 服務寄送電子郵件
date: 2024-09-03 00:52:01
tags: ["Mail", "SMTP", "Supabase"]
categories: ["Others", "Mail"]
---

## 前置作業

首先，到 Google 帳戶的「安全性」頁面，設定以下：

- 啟用兩步驟驗證（2-Step Verification）
- 新增應用程式密碼（App passwords）

## 設定

到 Supabase 的 Settings 頁面，點選 Authentication 頁籤，進行 SMTP 設定：

- Sender email: <memochou1993@gmail.com>
- Sender name: Memo Chou
- SMTP Host: smtp.gmail.com
- SMTP Port number: 587
- Username: <memochou1993@gmail.com>
- Password: [your_application_password]
