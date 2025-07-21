---
title: 透過 WebHooks 將 GitLab 事件推送至 Slack 頻道
date: 2022-07-12 23:56:22
tags: ["Others", "Slack", "WebHooks", "GitLab"]
categories: ["Others", "Slack"]
---

## 做法

首先到 Slack 進行以下操作：

- 進入頻道
- 點選「Integrations」
- 點選「Add an App」
- 點選「Incoming WebHooks」
- 點選「Add to Slack」
- 取得管理員授權
- 複製 Webhook URL

再到 GitLab 進行以下操作：

- 進入儲存庫
- 點選「Settings」
- 點選「Integrations」
- 點選「Slack notifications」
- 貼上 Webhook URL
- 儲存設定

## 參考資料

- [Slack notifications service](https://docs.gitlab.com/ee/user/project/integrations/slack.html)
