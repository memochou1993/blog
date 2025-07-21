---
title: 透過 Slack App 將 GitLab 事件推送到 Slack 頻道
date: 2025-07-20 00:21:51
tags: ["Others", "Slack", "WebHooks", "GitLab"]
categories: ["Others", "Slack"]
---

## 前言

以往都是透過 Slack 的 Incoming WebHooks URL，直接將 GitLab 事件推送到 Slack 頻道。但 Slack 平台的更新，Incoming WebHooks 功能已整合進 Slack App。

## 做法

1. 建立 Slack App
    - 前往[ Slack 文件](https://api.slack.com/messaging/webhooks)。
    - 點選 Create your Slack app(https://api.slack.com/apps/new) 按鈕，建立一個 Slack App。
    - 選擇 From scratch
    - 輸入 App 名稱，例如：status-my-project
    - 選擇要安裝的 Slack 工作區
    - 啟用 Incoming Webhooks 功能
2. 啟用 Incoming Webhooks 功能
    - 在 App 功能頁面中，點選 Incoming Webhooks
    - 將 Activate Incoming Webhooks 切換為 On
    - 點選 Add New Webhook to Workspace
3. 選擇推送頻道並授權
    - 選擇要這個 Webhook 發送訊息的頻道
    - 點選允許 (Allow)，Slack 會建立一組專屬的 Webhook URL
    - 複製這組 URL，後續會用在 GitLab WebHook 設定中
4. 安裝 App 到組織
    - 若是管理員，Slack 會自動授權；若不是，需請管理員核准安裝這個 App 到 Workspace
5. 在 GitLab 設定 WebHook
    - 前往 GitLab 專案 > Settings > Webhooks
    - 貼上剛剛複製的 Slack Webhook URL
    - 選擇要監聽的事件（例如：Push、Merge Request、Pipeline）
    - 儲存並測試送出

另外，如果有自訂訊息格式的需求，可以使用 [Block Kit Builder](https://app.slack.com/block-kit-builder/) 自訂訊息卡片。

## 參考資料

- [Slack API](https://api.slack.com/messaging/webhooks)
- [Building with Block Kit](https://api.slack.com/block-kit/building)
